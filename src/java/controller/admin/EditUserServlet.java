package controller.admin;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

@WebServlet(name = "EditUserServlet", urlPatterns = {"/owner/edit-user"})
public class EditUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserJdbcDAO();

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$");

    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^0[0-9]{9}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ================= GET PARAM ================= */

        String idRaw = request.getParameter("id");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String roleIdRaw = request.getParameter("roleId");
        String status = request.getParameter("status");

        Map<String, String> errors = new HashMap<>();

        /* ================= BASIC NULL CHECK ================= */

        if (idRaw == null || roleIdRaw == null) {
            response.sendRedirect("user-management");
            return;
        }

        int userId;
        int roleId;

        try {
            userId = Integer.parseInt(idRaw);
            roleId = Integer.parseInt(roleIdRaw);

            if (userId <= 0 || roleId <= 0) {
                response.sendRedirect("user-management");
                return;
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("user-management");
            return;
        }

        // Check user exists
        if (!userDAO.existsById(userId)) {
            response.sendRedirect("user-management");
            return;
        }

        /* ================= TRIM DATA ================= */

        fullName = fullName != null ? fullName.trim() : "";
        email = email != null ? email.trim() : "";
        phone = phone != null ? phone.trim() : "";
        address = address != null ? address.trim() : "";
        status = status != null ? status.trim() : "";

        /* ================= VALIDATE FULL NAME ================= */

        if (fullName.isEmpty()) {
            errors.put("fullName", "Full name cannot be empty");
        } else if (fullName.length() > 100) {
            errors.put("fullName", "Full name must be <= 100 characters");
        }

        /* ================= VALIDATE EMAIL ================= */

        if (email.isEmpty()) {
            errors.put("email", "Email cannot be empty");
        } else if (email.length() > 150) {
            errors.put("email", "Email must be <= 150 characters");
        } else if (!EMAIL_PATTERN.matcher(email).matches()) {
            errors.put("email", "Invalid email format");
        } else if (userDAO.existsByEmailExceptId(email, userId)) {
            errors.put("email", "Email already exists");
        }

        /* ================= VALIDATE PHONE ================= */

        if (!phone.isEmpty()) {
            if (phone.length() > 20) {
                errors.put("phone", "Phone too long");
            } else if (!PHONE_PATTERN.matcher(phone).matches()) {
                errors.put("phone", "Phone must be 10 digits and start with 0");
            }
        }

        /* ================= VALIDATE ADDRESS ================= */

        if (address.length() > 255) {
            errors.put("address", "Address must be <= 255 characters");
        }

        /* ================= VALIDATE ROLE ================= */

        if (!userDAO.existsRoleById(roleId)) {
            errors.put("roleId", "Invalid role selected");
        }

        /* ================= VALIDATE STATUS ================= */

        if (!status.equals("Active") && !status.equals("Inactive") && !status.equals("Blocked")) {
            errors.put("status", "Status must be Active or Inactive or Blocked");
        }

        /* ================= IF ERROR → RETURN ================= */

        if (!errors.isEmpty()) {

            request.setAttribute("errors", errors);
            request.setAttribute("userId", userId);
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("address", address);
            request.setAttribute("roleId", roleId);
            request.setAttribute("status", status);
            request.setAttribute("openEditModal", true);

            request.getRequestDispatcher("/admin/user-management")
                    .forward(request, response);
            return;
        }

        /* ================= UPDATE USER ================= */

        userDAO.updateUserByAdmin(
                userId,
                fullName,
                email,
                phone,
                address,
                roleId,
                status
        );

        /* ================= KEEP FILTER + SORT + PAGE ================= */

        StringBuilder redirect = new StringBuilder("user-management?");

        append(redirect, "keyword", request.getParameter("keyword"));
        append(redirect, "filterRoleId", request.getParameter("filterRoleId"));
        append(redirect, "filterStatus", request.getParameter("filterStatus"));
        append(redirect, "sort", request.getParameter("sort"));
        append(redirect, "page", request.getParameter("page"));

        response.sendRedirect(redirect.toString());
    }

    private void append(StringBuilder sb, String key, String value) {
        if (value != null && !value.isBlank()) {
            sb.append(key)
                    .append("=")
                    .append(URLEncoder.encode(value, StandardCharsets.UTF_8))
                    .append("&");
        }
    }
}