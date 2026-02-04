package controller.admin;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "EditUserServlet", urlPatterns = {"/admin/edit-user"})
public class EditUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserJdbcDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ===== USER UPDATE PARAM ===== */
        String idRaw = request.getParameter("id");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String roleIdRaw = request.getParameter("roleId");
        String status = request.getParameter("status");

        if (idRaw == null || roleIdRaw == null || status == null
                || fullName == null || email == null) {
            response.sendRedirect("user-management");
            return;
        }

        int userId;
        int roleId;
        try {
            userId = Integer.parseInt(idRaw);
            roleId = Integer.parseInt(roleIdRaw);
        } catch (NumberFormatException e) {
            response.sendRedirect("user-management");
            return;
        }

        /* ===== UPDATE USER ===== */
        userDAO.updateUserByAdmin(
                userId,
                fullName,
                email,
                phone,
                address,
                roleId,
                status
        );

        /* ===== GIỮ FILTER + SORT + PAGE ===== */
        String keyword = request.getParameter("keyword");
        String filterRoleId = request.getParameter("filterRoleId");
        String filterStatus = request.getParameter("filterStatus");
        String sort = request.getParameter("sort");
        String page = request.getParameter("page");

        /* ===== REDIRECT BACK ===== */
        StringBuilder redirect = new StringBuilder("user-management?");

        append(redirect, "keyword", keyword);
        append(redirect, "filterRoleId", filterRoleId);
        append(redirect, "status", filterStatus);
        append(redirect, "sort", sort);
        append(redirect, "page", page);

        response.sendRedirect(redirect.toString());
    }

    private void append(StringBuilder sb, String key, String value) {
        if (value != null && !value.isBlank()) {
            sb.append(key)
                    .append("=")
                    .append(encode(value))
                    .append("&");
        }
    }

    private String encode(String value) {
        return value.replace(" ", "%20");
    }
}
