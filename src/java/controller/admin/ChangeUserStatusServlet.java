package controller.admin;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ChangeUserStatusServlet", urlPatterns = {"/admin/change-user-status"})
public class ChangeUserStatusServlet extends HttpServlet {

    private final UserDAO userDAO = new UserJdbcDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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
        append(redirect, "status", filterStatus); // filter status
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

}
