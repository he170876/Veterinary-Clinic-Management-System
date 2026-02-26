package controller.vet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Serves the veterinarian dashboard at /vet/dashboard.
 * Role access is enforced by RoleBasedAccessFilter.
 */
@WebServlet(name = "VetDashboardServlet", urlPatterns = {"/vet/dashboard"})
public class VetDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/vet/dashboard.jsp").forward(request, response);
    }
}
