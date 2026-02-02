package controller.auth;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.impl.UserJdbcDAO;
import model.User;
import service.AuthService;
import service.impl.AuthServiceImpl;

/**
 * Servlet handling customer registration.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If already logged in, redirect to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard");
            return;
        }
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validation
        if (isBlank(fullName) || isBlank(email) || isBlank(password) || isBlank(confirmPassword)) {
            request.setAttribute("error", "All required fields must be filled.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Email format validation
        if (!isValidEmail(email)) {
            request.setAttribute("error", "Please enter a valid email address.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Password strength
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters long.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        if (authService.isEmailTaken(email)) {
            request.setAttribute("error", "This email is already registered. Please sign in or use a different email.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Register the user
        User created = authService.registerCustomer(fullName, email, phone, password);

        if (created == null) {
            String msg = "Registration failed. Please try again.";
            String dbErr = UserJdbcDAO.getLastInsertError();
            String authErr = AuthServiceImpl.getLastRegistrationError();
            if (dbErr != null && !dbErr.isEmpty()) {
                msg = "Registration failed: " + dbErr;
            } else if (authErr != null && !authErr.isEmpty()) {
                msg = authErr;
            }
            request.setAttribute("error", msg);
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Auto-login after registration
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", created);
        session.setMaxInactiveInterval(30 * 60); // 30 minutes

        response.sendRedirect(request.getContextPath() + "/customer/dashboard");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private boolean isValidEmail(String email) {
        return email != null && email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    }

    private void preserveFormData(HttpServletRequest request, String fullName, String email, String phone) {
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
    }
}
