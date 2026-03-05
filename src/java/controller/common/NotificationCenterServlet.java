package controller.common;

import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Notification;
import model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;

/**
 * Simple notification center that lists notifications for the current user.
 * Uses a shared JSP with the designer-provided HTML template.
 */
@WebServlet(name = "NotificationCenterServlet", urlPatterns = {"/notifications"})
public class NotificationCenterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        NotificationDAO dao = new NotificationDAO();
        List<Notification> notifications = dao.getRecentForUser(user.getUserId(), 50);
        if (notifications == null) {
            notifications = Collections.emptyList();
        }

        request.setAttribute("user", user);
        request.setAttribute("notifications", notifications);
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.setAttribute("today", LocalDate.now());

        request.getRequestDispatcher("/WEB-INF/views/common/notifications.jsp")
                .forward(request, response);
    }
}

