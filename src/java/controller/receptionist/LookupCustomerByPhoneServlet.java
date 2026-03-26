package controller.receptionist;

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
import model.User;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Live lookup by phone for receptionist Book Appointment popup.
 * GET ?phone=... returns JSON: { "found": true, "customer": {...}, "pets": [...] } or { "found": false }.
 */
@WebServlet("/Receptionist/LookupCustomerByPhone")
public class LookupCustomerByPhoneServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // This endpoint is called as the receptionist types a phone number.
        //
        // Goal:
        // - If a customer account exists for that phone, return the customer profile and their pets
        //   so the UI can auto-fill owner/email and let receptionist pick an existing pet.
        //
        // Security:
        // - This endpoint is protected by RoleBasedAccessFilter (/Receptionist/*).
        // - Response is minimal and tailored for booking/check-in UI.
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String phone = request.getParameter("phone");
        if (phone == null || phone.trim().isEmpty()) {
            // Treat missing/empty phone as "not found" so the UI stays in manual-entry mode.
            response.getWriter().print("{\"success\":true,\"found\":false}");
            return;
        }

        UserDAO userDAO = new UserJdbcDAO();
        CustomerDAO customerDAO = new CustomerJdbcDAO();
        PetDAO petDAO = new PetJdbcDAO();

        Optional<User> userOpt = userDAO.findByPhone(phone.trim());
        if (userOpt.isEmpty()) {
            response.getWriter().print("{\"success\":true,\"found\":false}");
            return;
        }

        User user = userOpt.get();
        Optional<Customer> customerOpt = customerDAO.findByUserId(user.getUserId());
        if (customerOpt.isEmpty()) {
            // User exists but isn't a Customer (or customer row missing) → treat as not found for booking UI.
            response.getWriter().print("{\"success\":true,\"found\":false}");
            return;
        }

        Customer customer = customerOpt.get();
        List<Pet> pets = petDAO.findByCustomerId(customer.getCustomerId());

        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"found\":true,");
        json.append("\"customer\":{");
        json.append("\"customerId\":").append(customer.getCustomerId()).append(",");
        json.append("\"fullName\":\"").append(escapeJson(user.getFullName() != null ? user.getFullName() : "")).append("\",");
        json.append("\"email\":\"").append(escapeJson(user.getEmail() != null ? user.getEmail() : "")).append("\",");
        json.append("\"address\":\"").append(escapeJson(user.getAddress() != null ? user.getAddress() : "")).append("\"");
        json.append("},");
        json.append("\"pets\":[");
        for (int i = 0; i < pets.size(); i++) {
            Pet p = pets.get(i);
            if (i > 0) json.append(",");
            // Each pet option contains species so UI can lock the pet type dropdown for existing pets.
            json.append("{\"petId\":").append(p.getPetId()).append(",\"name\":\"").append(escapeJson(p.getName() != null ? p.getName() : "")).append("\",\"species\":\"").append(escapeJson(p.getSpecies() != null ? p.getSpecies() : "")).append("\"}");
        }
        json.append("]}");
        response.getWriter().print(json.toString());
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
