package controller.lab;

import dao.LabTestRequestDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.LabTestRequest;
import model.User;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
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
        NotificationDAO ndao = new NotificationDAO();
        request.setAttribute("notifications", ndao.getRecentForUser(user.getUserId(), 10));
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.setAttribute("pendingRequests", pendingRequests);
        request.getRequestDispatcher("/WEB-INF/views/lab/dashboard.jsp").forward(request, response);
    }
}
