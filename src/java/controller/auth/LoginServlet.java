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
 * Servlet handling the Login use case (AL-01 in the RDS).
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
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Optional<User> userOpt = authService.login(email, password);

        if (!userOpt.isPresent()) {
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userOpt.get();
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);

        // Very simple role-based redirection; adjust view names as you build the dashboards.
        String roleName = user.getRole() != null ? user.getRole().getRoleName() : "";
        if ("ClinicOwner".equalsIgnoreCase(roleName) || "Owner".equalsIgnoreCase(roleName)) {
            response.sendRedirect(request.getContextPath() + "/owner/dashboard");
        } else if ("Veterinarian".equalsIgnoreCase(roleName)) {
            response.sendRedirect(request.getContextPath() + "/vet/dashboard");
        } else if ("Receptionist".equalsIgnoreCase(roleName) || "Staff".equalsIgnoreCase(roleName)) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
        } else {
            // Default to customer dashboard
            response.sendRedirect(request.getContextPath() + "/customer/dashboard");
        }
    }
}

