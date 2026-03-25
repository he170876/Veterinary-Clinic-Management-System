package controller.admin;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "ChangeUserStatusServlet", urlPatterns = {"/admin/change-user-status"})
public class ChangeUserStatusServlet extends HttpServlet {

    private final UserDAO userDAO = new UserJdbcDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String actorRole = normalizeRole(currentUser);
        if (!("admin".equals(actorRole) || "clinicowner".equals(actorRole) || "clinic owner".equals(actorRole))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        /* ===== USER UPDATE PARAM ===== */
        String idRaw = request.getParameter("id");
        String newStatus = request.getParameter("status"); // status của user

        if (idRaw == null || newStatus == null || newStatus.isBlank()) {
            response.sendRedirect("user-management");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(idRaw);
        } catch (NumberFormatException e) {
            response.sendRedirect("user-management");
            return;
        }

        if (("clinicowner".equals(actorRole) || "clinic owner".equals(actorRole)) && isCustomer(userId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Clinic owner cannot edit customer accounts");
            return;
        }

        /* ===== UPDATE STATUS ===== */
        userDAO.updateUserStatus(userId, newStatus);

        /* ===== GIỮ FILTER + SORT + PAGE ===== */
        String keyword = request.getParameter("keyword");
        String roleId = request.getParameter("filterRoleId");
        String filterStatus = request.getParameter("filterStatus");
        String sort = request.getParameter("sort");
        String page = request.getParameter("page");

        /* ===== REDIRECT BACK ===== */
        StringBuilder redirect = new StringBuilder("user-management?");

        append(redirect, "keyword", keyword);
        append(redirect, "filterRoleId", roleId);
        append(redirect, "filterStatus", filterStatus);
        append(redirect, "sort", sort);
        append(redirect, "page", page);

        response.sendRedirect(redirect.toString());
    }

    private void append(StringBuilder sb, String key, String value) {
        if (value != null && !value.isBlank()) {
            sb.append(key).append("=")
                    .append(encode(value)).append("&");
        }
    }

    private String encode(String value) {
        return value.replace(" ", "%20");
    }

    private String normalizeRole(User user) {
        if (user == null || user.getRole() == null || user.getRole().getRoleName() == null) {
            return "";
        }
        return user.getRole().getRoleName().trim().toLowerCase();
    }

    private boolean isCustomer(int userId) {
        return userDAO.findById(userId)
                .map(u -> u.getRole() != null && "customer".equalsIgnoreCase(u.getRole().getRoleName()))
                .orElse(false);
    }

}
