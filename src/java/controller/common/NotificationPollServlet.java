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
import java.io.PrintWriter;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;

/**
 * Lightweight JSON endpoint that returns the latest notifications for the current user.
 * Used by the notification dropdown to poll without reloading the whole page.
 */
@WebServlet(name = "NotificationPollServlet", urlPatterns = {"/notifications/poll"})
public class NotificationPollServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            writeEmpty(response);
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            writeEmpty(response);
            return;
        }

        NotificationDAO dao = new NotificationDAO();
        List<Notification> notifications = dao.getRecentForUser(user.getUserId(), 3);
        if (notifications == null) {
            notifications = Collections.emptyList();
        }
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM dd, HH:mm");

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print('[');
            for (int i = 0; i < notifications.size(); i++) {
                Notification n = notifications.get(i);
                if (i > 0) {
                    out.print(',');
                }
                String time = n.getCreatedAt() != null ? n.getCreatedAt().format(fmt) : "";
                out.print('{');
                out.print("\"id\":").print(n.getNotificationId());
                out.print(",\"title\":\"").print(escape(n.getTitle()));
                out.print("\",\"message\":\"").print(escape(n.getMessage()));
                out.print("\",\"time\":\"").print(escape(time)).print("\"");
                out.print('}');
            }
            out.print(']');
        }
    }

    private void writeEmpty(HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("[]");
        }
    }

    private String escape(String value) {
        if (value == null) return "";
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}

