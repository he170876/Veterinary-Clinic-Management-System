package controller.auth;

import java.io.IOException;
import java.util.Optional;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.AuthService;
import service.impl.AuthServiceImpl;

/**
 * Servlet handling the Login use case.
 * After successful authentication, redirects to a role-specific dashboard.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

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
            redirectToDashboard(request, response, user);
            return;
        }
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Basic validation
        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Please enter both email and password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        Optional<User> userOpt = authService.login(email, password);

        if (!userOpt.isPresent()) {
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userOpt.get();
        
        // Create session and store user
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);
        session.setMaxInactiveInterval(30 * 60); // 30 minutes

        // Redirect based on role
        redirectToDashboard(request, response, user);
    }

    private void redirectToDashboard(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String roleName = user.getRole() != null ? user.getRole().getRoleName() : "";
        String contextPath = request.getContextPath();

        switch (roleName.toLowerCase()) {
            case "clinicowner":
            case "owner":
            case "admin":
                response.sendRedirect(contextPath + "/owner/dashboard");
                break;
            case "veterinarian":
                response.sendRedirect(contextPath + "/vet/dashboard");
                break;
            case "receptionist":
            case "staff":
                response.sendRedirect(contextPath + "/staff/dashboard");
                break;
            case "labstaff":
                response.sendRedirect(contextPath + "/lab/dashboard");
                break;
            default:
                // Customer or unknown
                response.sendRedirect(contextPath + "/customer/dashboard");
                break;
        }
    }
}
