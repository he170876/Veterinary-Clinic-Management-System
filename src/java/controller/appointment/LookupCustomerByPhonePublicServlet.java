package controller.appointment;

import dao.CustomerDAO;
import dao.UserDAO;
import dao.impl.CustomerJdbcDAO;
import dao.impl.UserJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.User;

import java.io.IOException;
import java.util.Optional;

/**
 * Public lightweight lookup for landing booking form.
 * Returns whether a customer exists by phone and basic profile fields.
 */
@WebServlet(name = "LookupCustomerByPhonePublicServlet", urlPatterns = {"/book/lookup-phone"})
public class LookupCustomerByPhonePublicServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String phone = request.getParameter("phone");
        if (phone == null || phone.trim().isEmpty()) {
            response.getWriter().print("{\"success\":true,\"found\":false}");
            return;
        }

        UserDAO userDAO = new UserJdbcDAO();
        CustomerDAO customerDAO = new CustomerJdbcDAO();

        Optional<User> userOpt = userDAO.findByPhone(phone.trim());
        if (userOpt.isEmpty()) {
            response.getWriter().print("{\"success\":true,\"found\":false}");
            return;
        }

        User user = userOpt.get();
        Optional<Customer> customerOpt = customerDAO.findByUserId(user.getUserId());
        if (customerOpt.isEmpty()) {
            response.getWriter().print("{\"success\":true,\"found\":false}");
            return;
        }

        String fullName = escapeJson(user.getFullName() == null ? "" : user.getFullName());
        String email = escapeJson(user.getEmail() == null ? "" : user.getEmail());
        response.getWriter().print("{\"success\":true,\"found\":true,\"customer\":{\"fullName\":\""
                + fullName + "\",\"email\":\"" + email + "\"}}");
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
