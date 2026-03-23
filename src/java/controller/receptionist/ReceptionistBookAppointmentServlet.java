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
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * POST from receptionist Book Appointment modal.
 * Creates appointment with appointment_date + time_slot (AM/PM).
 * Params: ownerName, email, phone, serviceIds[], petId (optional), petName, petType, appointmentDate, timeSlot (AM|PM), notes.
 */
@WebServlet("/Receptionist/BookAppointment")
public class ReceptionistBookAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

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

        if (ownerName == null || ownerName.isEmpty() || email == null || email.isEmpty()
                || phone == null || phone.isEmpty()
                || appointmentDateStr == null || appointmentDateStr.isEmpty()
                || timeSlot == null || timeSlot.isEmpty()) {
            response.getWriter().print("{\"success\":false,\"message\":\"Please fill in all required fields.\"}");
            return;
        }

        if (serviceIdValues == null || serviceIdValues.length == 0) {
            response.getWriter().print("{\"success\":false,\"message\":\"Please select at least one service.\"}");
            return;
        }

        boolean useExistingPet = petIdStr != null && !petIdStr.isEmpty() && !"0".equals(petIdStr);
        if (!useExistingPet && (petName == null || petName.isEmpty() || petType == null || petType.isEmpty())) {
            response.getWriter().print("{\"success\":false,\"message\":\"Pet name and type are required for new customers.\"}");
            return;
        }

        if (!ValidationUtil.isValidPhone(phone)) {
            response.getWriter().print("{\"success\":false,\"message\":\"Phone must be 10 digits starting with 0.\"}");
            return;
        }

        if (!ValidationUtil.isValidEmailFormat(email)) {
            response.getWriter().print("{\"success\":false,\"message\":\"Please enter a valid email address.\"}");
            return;
        }

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
            response.getWriter().print("{\"success\":false,\"message\":\"Invalid date or service.\"}");
            return;
        } catch (IllegalArgumentException e) {
            response.getWriter().print("{\"success\":false,\"message\":\"Invalid service selection.\"}");
            return;
        }

        String normalizedSlot = ValidationUtil.normalizeBookingSlot(timeSlot);
        if (normalizedSlot == null) {
            response.getWriter().print("{\"success\":false,\"message\":\"Invalid time slot selected.\"}");
            return;
        }

        if (!ValidationUtil.isBookableDateSlot(appointmentDate, normalizedSlot)) {
            response.getWriter().print("{\"success\":false,\"message\":\"Selected time slot has passed. Please choose a different slot or date.\"}");
            return;
        }

        String slot = "morning".equals(normalizedSlot) ? "AM" : "PM";

        UserDAO userDAO = new UserJdbcDAO();
        CustomerDAO customerDAO = new CustomerJdbcDAO();
        PetDAO petDAO = new PetJdbcDAO();
        AppointmentDAO appointmentDAO = new AppointmentDAO();

        int customerId;
        int petId;

        if (useExistingPet) {
            try {
                petId = Integer.parseInt(petIdStr);
                Optional<Pet> petOpt = petDAO.findById(petId);
                if (petOpt.isEmpty()) {
                    response.getWriter().print("{\"success\":false,\"message\":\"Selected pet not found.\"}");
                    return;
                }
                Pet pet = petOpt.get();
                petId = pet.getPetId();
                customerId = pet.getOwner() != null ? pet.getOwner().getCustomerId() : 0;
                if (customerId == 0) {
                    response.getWriter().print("{\"success\":false,\"message\":\"Invalid pet data.\"}");
                    return;
                }
            } catch (NumberFormatException e) {
                response.getWriter().print("{\"success\":false,\"message\":\"Invalid pet selection.\"}");
                return;
            }
        } else {
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
                user = createCustomerUser(ownerName, email, phone);
                if (user == null) {
                    response.getWriter().print("{\"success\":false,\"message\":\"Could not create customer account.\"}");
                    return;
                }
                Optional<Customer> newCustOpt = customerDAO.findByUserId(user.getUserId());
                if (newCustOpt.isEmpty()) {
                    response.getWriter().print("{\"success\":false,\"message\":\"Customer record not found after signup.\"}");
                    return;
                }
                customerId = newCustOpt.get().getCustomerId();
            }

            Optional<Pet> existingPet = petDAO.findByCustomerId(customerId).stream()
                    .filter(p -> petName.equalsIgnoreCase(p.getName())).findFirst();
            if (existingPet.isPresent()) {
                petId = existingPet.get().getPetId();
            } else {
                Pet newPet = new Pet();
                newPet.setName(petName);
                newPet.setSpecies(petType);
                Customer c = new Customer();
                c.setCustomerId(customerId);
                newPet.setOwner(c);
                newPet = petDAO.create(newPet);
                petId = newPet.getPetId();
            }
        }

        System.out.println("[RECP_BOOK_DEBUG] services selected=" + serviceIds.size() + " values=" + serviceIds);
        int appointmentId = appointmentDAO.createWithDateAndSlot(petId, customerId, serviceIds.get(0), appointmentDate, slot, notes, phone);
        if (appointmentId > 0) {
            boolean servicesSaved = appointmentDAO.insertAppointmentServices(appointmentId, serviceIds);
            if (!servicesSaved) {
                response.getWriter().print("{\"success\":false,\"message\":\"Appointment saved but services could not be linked.\"}");
                return;
            }
            response.getWriter().print("{\"success\":true,\"message\":\"Appointment booked successfully.\",\"appointmentId\":" + appointmentId + "}");
        } else {
            response.getWriter().print("{\"success\":false,\"message\":\"Could not save appointment. Please try again.\"}");
        }
    }

    private User createCustomerUser(String fullName, String email, String phone) {
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
