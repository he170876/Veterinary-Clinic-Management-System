package controller.auth;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.AuthService;
import service.impl.AuthServiceImpl;
import utils.ValidationUtil;

/**
 * Servlet handling the Login use case.
 * After successful authentication, redirects to a role-specific dashboard.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(LoginServlet.class.getName());

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
            User user = (User) session.getAttribute("currentUser");
            LOG.log(Level.FINE, "GET /login: already logged in as {0} (roleId={1}), redirecting to dashboard",
                    new Object[]{user.getEmail(), user.getRole() != null ? user.getRole().getRoleId() : null});
            redirectToDashboard(request, response, user);
            return;
        }
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        String email = ValidationUtil.trim(request.getParameter("email"));
        String password = request.getParameter("password");

        LOG.log(Level.FINE, "POST /login: attempt for email={0}", email);

        if (email == null || password == null || password.isEmpty()) {
            LOG.log(Level.FINE, "POST /login: rejected - missing email or password");
            request.setAttribute("error", "Please enter both email and password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        if (ValidationUtil.hasLeadingOrTrailingSpaces(request.getParameter("email"))) {
            LOG.log(Level.FINE, "POST /login: rejected - email has leading/trailing spaces");
            request.setAttribute("error", "Email must not contain leading or trailing spaces.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        if (!ValidationUtil.isValidEmailFormat(email)) {
            LOG.log(Level.FINE, "POST /login: rejected - invalid email format");
            request.setAttribute("error", "Please enter a valid email address.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        Optional<User> userOpt = authService.login(email, password);

        if (!userOpt.isPresent()) {
            LOG.log(Level.FINE, "POST /login: failed - invalid email or password for {0}", email);
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userOpt.get();
        int roleId = user.getRole() != null ? user.getRole().getRoleId() : 0;
        LOG.log(Level.FINE, "POST /login: success userId={0}, email={1}, roleId={2}",
                new Object[]{user.getUserId(), user.getEmail(), roleId});

        // Create session and store user
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);
        session.setMaxInactiveInterval(30 * 60); // 30 minutes

        // Redirect based on role
        redirectToDashboard(request, response, user);
    }

    private void redirectToDashboard(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        int roleId = (user.getRole() != null) ? user.getRole().getRoleId() : 0;
        String contextPath = request.getContextPath();
        String path;
        switch (roleId) {
            case 5:  // Admin
            case 6:  // ClinicOwner
                path = contextPath + "/owner/dashboard";
                break;
            case 2:  // Veterinarian
                path = contextPath + "/vet/dashboard";
                break;
            case 3:  // Receptionist
                path = contextPath + "/Receptionist/Dashboard";
                break;
            case 4:  // LabStaff
                path = contextPath + "/lab/labqueue";
                break;
            case 1:  // Customer
            default:
                path = contextPath + "/customer/dashboard";
                break;
        }
        LOG.log(Level.FINE, "redirectToDashboard: roleId={0} -> {1}", new Object[]{roleId, path});
        response.sendRedirect(path);
    }
}
