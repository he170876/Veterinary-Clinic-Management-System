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
 * Lab Queue (FIFO) for lab technicians.
 * Primary URL: /lab/labqueue, kept legacy alias: /lab/dashboard.
 */
@WebServlet(name = "LabDashboardServlet", urlPatterns = {"/lab/labqueue", "/lab/dashboard"})
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
        String q = request.getParameter("q");
        int pageSize = 10;
        int page = 1;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException ignored) {}
        if (page < 1) page = 1;

        int total = dao.countPendingRequests(q);
        int totalPages = total == 0 ? 1 : (int) Math.ceil(total / (double) pageSize);
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * pageSize;

        List<LabTestRequest> pendingRequests = dao.getPendingRequestsPage(offset, pageSize, q);

        request.setAttribute("user", user);
        NotificationDAO ndao = new NotificationDAO();
        request.setAttribute("notifications", ndao.getRecentForUser(user.getUserId(), 10));
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.setAttribute("pendingRequests", pendingRequests);
        request.setAttribute("q", q == null ? "" : q.trim());
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalRecords", total);
        request.getRequestDispatcher("/WEB-INF/views/lab/labqueue.jsp").forward(request, response);
    }
}
