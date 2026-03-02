package controller.lab;

import dao.LabTestRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.LabTestRequest;
import model.User;

import java.io.IOException;
import java.util.List;

/**
 * Lab Technician Dashboard – FIFO Lab Queue at /lab/dashboard.
 * Loads pending lab requests from DB.
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
        LabTestRequestDAO dao = new LabTestRequestDAO();
        List<LabTestRequest> pendingRequests = dao.getPendingRequests();

        request.setAttribute("user", user);
        request.setAttribute("pendingRequests", pendingRequests);
        request.getRequestDispatcher("/WEB-INF/views/lab/dashboard.jsp").forward(request, response);
    }
}
