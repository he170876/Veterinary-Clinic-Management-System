package controller.receptionist;

import dao.AppointmentDAO;
import dao.CustomerDAO;
import dao.PetDAO;
import dao.UserDAO;
import dao.impl.CustomerJdbcDAO;
import dao.impl.PetJdbcDAO;
import dao.impl.UserJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.Pet;
import model.Role;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import utils.ValidationUtil;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Receptionist booking endpoint (AJAX).
 *
 * <h3>What this servlet does</h3>
 * This is the server-side handler behind the receptionist "Book Appointment" modal.
 * It creates (or reuses) the Customer + Pet, then creates an Appointment record for a chosen date + AM/PM slot,
 * and links the selected services via {@code appointment_service}.
 *
 * <h3>Request/Response contract</h3>
 * - Method: POST {@code /Receptionist/BookAppointment}
 * - Content-Type: {@code application/x-www-form-urlencoded}
 * - Response: JSON only (success/message/appointmentId)
 *
 * <h3>Important business rules</h3>
 * - phone: must be 10 digits starting with 0
 * - email: must be a valid email format (generic)
 * - appointmentDate + timeSlot: must be bookable (today must be before slot start time)
 * - serviceIds: at least one service must be selected
 *
 * <h3>Data model notes</h3>
 * - {@code appointments} is created with status 'Pending'
 * - {@code appointments.phone} is set from request phone (so invoice/queue can show contact)
 * - services:
 *   - {@code appointments.service_id} stores only the "primary" service (first selected)
 *   - all selected services are inserted into {@code appointment_service}
 */
@WebServlet("/Receptionist/BookAppointment")
public class ReceptionistBookAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Always respond JSON to the modal's fetch(). If anything goes wrong, return a safe JSON error.
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.resetBuffer();
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            // Main handler kept in a separate method to keep doPost() minimal and to make error handling consistent.
            handleBookPost(request, response);
        } catch (Throwable t) {
            t.printStackTrace();
            try {
                if (!response.isCommitted()) {
                    // If an exception occurs after the response started, we must not write partial HTML.
                    // resetBuffer() guarantees we only send JSON back to the browser.
                    response.resetBuffer();
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().print("{\"success\":false,\"message\":\"Server error while booking. Please try again.\"}");
                    response.getWriter().flush();
                }
            } catch (IOException ignored) {
            }
        }
    }

    private void handleBookPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 1) Read + trim parameters (ValidationUtil.trim handles nulls safely).
        String ownerName = ValidationUtil.trim(request.getParameter("ownerName"));
        String email = ValidationUtil.trim(request.getParameter("email"));
        String phone = ValidationUtil.trim(request.getParameter("phone"));
        String[] serviceIdValues = request.getParameterValues("serviceIds");
        String petIdStr = ValidationUtil.trim(request.getParameter("petId"));
        String petName = ValidationUtil.trim(request.getParameter("petName"));
        String petType = ValidationUtil.trim(request.getParameter("petType"));
        String appointmentDateStr = ValidationUtil.trim(request.getParameter("appointmentDate"));
        String timeSlot = ValidationUtil.trim(request.getParameter("timeSlot"));
        String notes = ValidationUtil.trim(request.getParameter("notes"));

        // 2) Validate required fields early. This prevents DB work for obviously invalid requests.
        if (ownerName == null || ownerName.isEmpty() || email == null || email.isEmpty()
                || phone == null || phone.isEmpty()
                || appointmentDateStr == null || appointmentDateStr.isEmpty()
                || timeSlot == null || timeSlot.isEmpty()) {
            writeJson(response, "{\"success\":false,\"message\":\"Please fill in all required fields.\"}");
            return;
        }

        // At least one service must be chosen; the UI uses checkboxes.
        if (serviceIdValues == null || serviceIdValues.length == 0) {
            writeJson(response, "{\"success\":false,\"message\":\"Please select at least one service.\"}");
            return;
        }

        // "Pet" can be selected from an existing list (petId present) OR created new (petName + petType required).
        boolean useExistingPet = petIdStr != null && !petIdStr.isEmpty() && !"0".equals(petIdStr);
        if (!useExistingPet && (petName == null || petName.isEmpty() || petType == null || petType.isEmpty())) {
            writeJson(response, "{\"success\":false,\"message\":\"Pet name and type are required for new customers.\"}");
            return;
        }

        // phone/email format validation. These should match the client-side patterns, but server always re-validates.
        if (!ValidationUtil.isValidPhone(phone)) {
            writeJson(response, "{\"success\":false,\"message\":\"Phone must be 10 digits starting with 0.\"}");
            return;
        }

        if (!ValidationUtil.isValidEmailFormat(email)) {
            writeJson(response, "{\"success\":false,\"message\":\"Please enter a valid email address.\"}");
            return;
        }

        // 3) Parse serviceIds and appointment date; reject invalid values.
        List<Integer> serviceIds = new ArrayList<>();
        LocalDate appointmentDate;
        try {
            for (String rawServiceId : serviceIdValues) {
                int parsed = Integer.parseInt(ValidationUtil.trim(rawServiceId));
                if (parsed <= 0) {
                    throw new IllegalArgumentException("Invalid service");
                }
                if (!serviceIds.contains(parsed)) {
                    serviceIds.add(parsed);
                }
            }
            if (serviceIds.isEmpty()) {
                throw new IllegalArgumentException("Invalid service");
            }
            appointmentDate = LocalDate.parse(appointmentDateStr);
        } catch (NumberFormatException | DateTimeParseException e) {
            writeJson(response, "{\"success\":false,\"message\":\"Invalid date or service.\"}");
            return;
        } catch (IllegalArgumentException e) {
            writeJson(response, "{\"success\":false,\"message\":\"Invalid service selection.\"}");
            return;
        }

        // 4) Normalize slot ("AM"/"PM") and apply same-day cutoffs.
        // normalizeBookingSlot accepts values like "AM"/"PM" and returns "morning"/"afternoon".
        String normalizedSlot = ValidationUtil.normalizeBookingSlot(timeSlot);
        if (normalizedSlot == null) {
            writeJson(response, "{\"success\":false,\"message\":\"Invalid time slot selected.\"}");
            return;
        }

        // isBookableDateSlot expects the raw user selection (AM/PM) so it can normalize internally.
        if (!ValidationUtil.isBookableDateSlot(appointmentDate, timeSlot)) {
            writeJson(response, "{\"success\":false,\"message\":\"Selected time slot has passed. Please choose a different slot or date.\"}");
            return;
        }

        // Canonical slot stored in DB is AM/PM.
        String slot = "morning".equals(normalizedSlot) ? "AM" : "PM";

        // 5) Decide customer + pet identity.
        // - If user selected an existing pet, we trust petId and derive customerId from the pet row.
        // - Otherwise, we lookup customer by phone then email, create user/customer if missing,
        //   then find-or-create pet by name for that customer.
        UserDAO userDAO = new UserJdbcDAO();
        CustomerDAO customerDAO = new CustomerJdbcDAO();
        PetDAO petDAO = new PetJdbcDAO();
        AppointmentDAO appointmentDAO = new AppointmentDAO();

        int customerId;
        int petId;

        if (useExistingPet) {
            try {
                // Existing pet flow (from lookup dropdown)
                petId = Integer.parseInt(petIdStr);
                Optional<Pet> petOpt = petDAO.findById(petId);
                if (petOpt.isEmpty()) {
                    writeJson(response, "{\"success\":false,\"message\":\"Selected pet not found.\"}");
                    return;
                }
                Pet pet = petOpt.get();
                petId = pet.getPetId();
                customerId = pet.getOwner() != null ? pet.getOwner().getCustomerId() : 0;
                if (customerId == 0) {
                    writeJson(response, "{\"success\":false,\"message\":\"Invalid pet data.\"}");
                    return;
                }
            } catch (NumberFormatException e) {
                writeJson(response, "{\"success\":false,\"message\":\"Invalid pet selection.\"}");
                return;
            }
        } else {
            // New-pet flow:
            // 1) find existing user by phone, else by email
            // 2) create customer record if user exists but customer row is missing
            // 3) create a new user+customer if not found at all
            Optional<User> userOpt = userDAO.findByPhone(phone);
            if (userOpt.isEmpty()) {
                userOpt = userDAO.findByEmail(email);
            }
            User user;
            if (userOpt.isPresent()) {
                user = userOpt.get();
                Optional<Customer> custOpt = customerDAO.findByUserId(user.getUserId());
                if (custOpt.isEmpty()) {
                    Customer newCust = new Customer();
                    newCust.setUser(user);
                    newCust = customerDAO.create(newCust);
                    customerId = newCust.getCustomerId();
                } else {
                    customerId = custOpt.get().getCustomerId();
                }
            } else {
                // Create brand-new Customer user in Users table (default password), then create Customer row.
                user = createCustomerUser(ownerName, email, phone);
                if (user == null) {
                    writeJson(response, "{\"success\":false,\"message\":\"Could not create customer account.\"}");
                    return;
                }
                Optional<Customer> newCustOpt = customerDAO.findByUserId(user.getUserId());
                if (newCustOpt.isEmpty()) {
                    writeJson(response, "{\"success\":false,\"message\":\"Customer record not found after signup.\"}");
                    return;
                }
                customerId = newCustOpt.get().getCustomerId();
            }

            // Pet de-dup rule: if customer already has a pet with same name (case-insensitive), reuse it.
            Optional<Pet> existingPet = petDAO.findByCustomerId(customerId).stream()
                    .filter(p -> petName.equalsIgnoreCase(p.getName())).findFirst();
            if (existingPet.isPresent()) {
                petId = existingPet.get().getPetId();
            } else {
                // Create new pet row under this customer.
                Pet newPet = new Pet();
                newPet.setName(petName);
                newPet.setSpecies(petType);
                Customer c = new Customer();
                c.setCustomerId(customerId);
                newPet.setOwner(c);
                newPet = petDAO.create(newPet);
                petId = newPet.getPetId();
                if (petId <= 0) {
                    writeJson(response, "{\"success\":false,\"message\":\"Could not save pet. Please check details and try again.\"}");
                    return;
                }
            }
        }

        // 6) Create appointment (status Pending) and link services.
        // The DB schema supports:
        // - primary service_id on appointments (first selected)
        // - appointment_service join table (all selected)
        int appointmentId = appointmentDAO.createWithDateAndSlot(petId, customerId, serviceIds.get(0), appointmentDate, slot, notes, phone);
        if (appointmentId > 0) {
            boolean servicesSaved = appointmentDAO.insertAppointmentServices(appointmentId, serviceIds);
            if (!servicesSaved) {
                writeJson(response, "{\"success\":false,\"message\":\"Appointment saved but services could not be linked.\"}");
                return;
            }
            writeJson(response, "{\"success\":true,\"message\":\"Appointment booked successfully.\",\"appointmentId\":" + appointmentId + "}");
        } else {
            writeJson(response, "{\"success\":false,\"message\":\"Could not save appointment. Please try again.\"}");
        }
    }

    private static void writeJson(HttpServletResponse response, String json) throws IOException {
        // Centralized JSON write helper so we consistently flush to the client (fetch() expects a body).
        PrintWriter w = response.getWriter();
        w.print(json);
        w.flush();
    }

    private User createCustomerUser(String fullName, String email, String phone) {
        // Create a customer user with a default password.
        // The receptionist-facing flow assumes the customer can later reset/change their password if needed.
        String hashed = BCrypt.hashpw("DefaultPassword123", BCrypt.gensalt());
        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setPasswordHash(hashed);
        user.setStatus("Active");
        Role customerRole = new Role();
        customerRole.setRoleId(1); // Customer
        user.setRole(customerRole);
        UserDAO uDao = new UserJdbcDAO();
        User created = uDao.createCustomerUser(user);
        return created;
    }
}
