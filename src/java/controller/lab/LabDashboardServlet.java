package controller.lab;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Lab Technician Dashboard – FIFO Lab Queue at /lab/dashboard.
 * Role access enforced by RoleBasedAccessFilter (LabStaff).
 */
@WebServlet(name = "LabDashboardServlet", urlPatterns = {"/lab/dashboard"})
public class LabDashboardServlet extends HttpServlet {

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
        request.getRequestDispatcher("/WEB-INF/views/lab/dashboard.jsp").forward(request, response);
    }
}
