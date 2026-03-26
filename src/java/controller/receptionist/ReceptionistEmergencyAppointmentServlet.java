package controller.receptionist;

import dao.AppointmentDAO;
import dao.CustomerDAO;
import dao.PetDAO;
import dao.UserDAO;
import dao.VisitDAO;
import dao.impl.CustomerJdbcDAO;
import dao.impl.PetJdbcDAO;
import dao.impl.UserJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.Pet;
import model.Role;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import utils.ValidationUtil;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

/**
 * POST from receptionist Emergency modal.
 * Creates appointment with type=Emergency, status=Checked-In, service_id=null,
 * appointment_date=today, time_slot=AM/PM from current time.
 * Params: ownerName, email (new customers only), phone, petId (optional), petName, petType.
 */
@WebServlet("/Receptionist/EmergencyAppointment")
public class ReceptionistEmergencyAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Emergency flow is designed to be fast:
        // - receptionist enters phone + owner name (+ optional email for brand-new customers)
        // - chooses existing pet (if phone lookup found) or enters new pet name/type
        // - server creates a Checked-in appointment immediately (no "Pending/Confirm" step)
        // - server ensures a Visits row exists so vet examination/completion works reliably
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // 1) Read parameters.
        String ownerName = ValidationUtil.trim(request.getParameter("ownerName"));
        String email = ValidationUtil.trim(request.getParameter("email"));
        String phone = ValidationUtil.trim(request.getParameter("phone"));
        String petIdStr = ValidationUtil.trim(request.getParameter("petId"));
        String petName = ValidationUtil.trim(request.getParameter("petName"));
        String petType = ValidationUtil.trim(request.getParameter("petType"));

        // 2) Validate basics.
        if (ownerName == null || ownerName.isEmpty() || phone == null || phone.isEmpty()) {
            response.getWriter().print("{\"success\":false,\"message\":\"Owner name and phone are required.\"}");
            return;
        }

        boolean useExistingPet = petIdStr != null && !petIdStr.isEmpty() && !"0".equals(petIdStr);
        if (!useExistingPet && (petName == null || petName.isEmpty() || petType == null || petType.isEmpty())) {
            response.getWriter().print("{\"success\":false,\"message\":\"Pet name and type are required.\"}");
            return;
        }

        if (!ValidationUtil.isValidPhone(phone)) {
            response.getWriter().print("{\"success\":false,\"message\":\"Phone must be 10 digits starting with 0.\"}");
            return;
        }

        // 3) Prepare DAOs.
        UserDAO userDAO = new UserJdbcDAO();
        CustomerDAO customerDAO = new CustomerJdbcDAO();
        PetDAO petDAO = new PetJdbcDAO();
        AppointmentDAO appointmentDAO = new AppointmentDAO();

        int customerId;
        int petId;

        if (useExistingPet) {
            // Existing pet selected from dropdown after phone lookup.
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
            // New pet / possibly new customer:
            // - Find existing user by phone.
            // - If missing, require email and create a customer user + customer row.
            Optional<User> userOpt = userDAO.findByPhone(phone);
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
                // Brand-new customer account requires a real email, because emergency accounts still need identity/contact.
                if (email == null || email.isEmpty() || !ValidationUtil.isValidEmailFormat(email)) {
                    response.getWriter().print("{\"success\":false,\"message\":\"Please enter a valid email address for the new customer.\"}");
                    return;
                }
                String emergencyEmail = email;
                user = createCustomerUser(ownerName, emergencyEmail, phone);
                if (user == null) {
                    response.getWriter().print("{\"success\":false,\"message\":\"Could not create customer account.\"}");
                    return;
                }
                Optional<Customer> newCustOpt = customerDAO.findByUserId(user.getUserId());
                if (newCustOpt.isEmpty()) {
                    response.getWriter().print("{\"success\":false,\"message\":\"Customer record not found.\"}");
                    return;
                }
                customerId = newCustOpt.get().getCustomerId();
            }

            Optional<Pet> existingPet = petDAO.findByCustomerId(customerId).stream()
                    .filter(p -> petName.equalsIgnoreCase(p.getName())).findFirst();
            if (existingPet.isPresent()) {
                petId = existingPet.get().getPetId();
            } else {
                // Create a new pet under this customer.
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

        int appointmentId = appointmentDAO.createEmergencyAppointment(petId, customerId, phone);
        if (appointmentId > 0) {
            // 4) IMPORTANT: ensure there is a Visits row.
            // Emergency appointments are "Checked-in" immediately, but the normal check-in flow is what creates Visits.
            // Without a visit, vet examination completion cannot progress correctly.
            VisitDAO visitDAO = new VisitDAO();
            if (visitDAO.getByAppointmentId(appointmentId) == null) {
                HttpSession session = request.getSession(false);
                User sessionUser = session != null ? (User) session.getAttribute("currentUser") : null;
                int receptionistId = sessionUser != null ? appointmentDAO.getReceptionistIdByUserId(sessionUser.getUserId()) : 0;
                if (receptionistId > 0) {
                    // Standard path: create a visit with staff_id set (FK to receptionists).
                    visitDAO.createForCheckIn(appointmentId, petId, customerId, null, receptionistId);
                } else {
                    // Fallback: create a visit with staff_id NULL (still allows vet workflow).
                    visitDAO.ensureVisitForAppointment(appointmentId, petId, customerId, null);
                }
            }
            response.getWriter().print("{\"success\":true,\"message\":\"Emergency appointment created. Status: Checked-In.\",\"appointmentId\":" + appointmentId + "}");
        } else {
            response.getWriter().print("{\"success\":false,\"message\":\"Could not create emergency appointment. Please try again.\"}");
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
        return uDao.createCustomerUser(user);
    }
}
