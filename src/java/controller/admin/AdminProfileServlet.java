package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Serves the logged-in Admin's profile page.
 */
@WebServlet(name = "AdminProfileServlet", urlPatterns = {"/admin/profile"})
public class AdminProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");

        // Force phone to be present (e.g., Google accounts)
        if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
            session.setAttribute("pendingPhoneRequired", Boolean.TRUE);
            response.sendRedirect(request.getContextPath() + "/admin/edit-profile?required=phone");
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/admin/profile.jsp").forward(request, response);
    }
}

