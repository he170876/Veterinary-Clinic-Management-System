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
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "NotificationDropdownServlet", urlPatterns = {"/notifications/dropdown"})
public class NotificationDropdownServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            forwardEmpty(request, response);
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            forwardEmpty(request, response);
            return;
        }

        NotificationDAO dao = new NotificationDAO();
        List<Notification> notifications = dao.getRecentForUser(user.getUserId(), 10);
        if (notifications == null) {
            notifications = Collections.emptyList();
        }

        request.setAttribute("notifications", notifications);
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.getRequestDispatcher("/WEB-INF/includes/notifications-dropdown.jsp")
                .forward(request, response);
    }

    private void forwardEmpty(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("notifications", Collections.emptyList());
        request.getRequestDispatcher("/WEB-INF/includes/notifications-dropdown.jsp")
                .forward(request, response);
    }
}

