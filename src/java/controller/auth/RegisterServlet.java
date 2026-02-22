package controller.auth;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
import utils.ValidationUtil;

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
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        String fullName = ValidationUtil.trim(request.getParameter("fullName"));
        String email = ValidationUtil.trim(request.getParameter("email"));
        String phone = ValidationUtil.trim(request.getParameter("phone"));
        String password = request.getParameter("password"); // no trim for password
        String confirmPassword = request.getParameter("confirmPassword");

        // No leading/trailing spaces
        if (ValidationUtil.hasLeadingOrTrailingSpaces(request.getParameter("fullName"))
                || ValidationUtil.hasLeadingOrTrailingSpaces(request.getParameter("email"))
                || ValidationUtil.hasLeadingOrTrailingSpaces(request.getParameter("phone"))) {
            request.setAttribute("error", "Fields must not contain leading or trailing spaces.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (fullName == null || email == null || password == null || confirmPassword == null
                || password.isEmpty() || confirmPassword.isEmpty()) {
            request.setAttribute("error", "All required fields must be filled.");
            preserveFormData(request, fullName != null ? fullName : "", email != null ? email : "", phone != null ? phone : "");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Phone is required
        if (phone == null || phone.isEmpty()) {
            request.setAttribute("error", "Phone number is required.");
            preserveFormData(request, fullName, email, phone != null ? phone : "");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Full name: 1-30 chars, letters and spaces only
        if (!ValidationUtil.isValidFullName(fullName)) {
            request.setAttribute("error", "Full name must be 1-30 characters, letters and spaces only (any language).");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Email: must be @gmail.com
        if (!ValidationUtil.isValidGmail(email)) {
            request.setAttribute("error", "Email must be a Gmail address (@gmail.com).");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Phone: 10 digits starting with 0
        if (!ValidationUtil.isValidPhone(phone)) {
            request.setAttribute("error", "Phone must be 10 digits starting with 0 (e.g. 0123456789).");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!ValidationUtil.isValidPassword(password)) {
            request.setAttribute("error", "Password must be 6-128 characters with 1 uppercase letter and 1 number.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (authService.isEmailTaken(email)) {
            request.setAttribute("error", "This email is already registered. Please sign in or use a different email.");
            preserveFormData(request, fullName, email, phone);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

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
            preserveFormData(request, fullName, email, phone != null ? phone : "");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Auto-login after registration
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", created);
        session.setMaxInactiveInterval(30 * 60); // 30 minutes

        response.sendRedirect(request.getContextPath() + "/customer/dashboard");
    }

    private void preserveFormData(HttpServletRequest request, String fullName, String email, String phone) {
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
    }
}
