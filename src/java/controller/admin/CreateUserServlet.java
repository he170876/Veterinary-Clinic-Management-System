package controller.admin;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import model.Role;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

@WebServlet(name = "CreateUserServlet", urlPatterns = {"/admin/create-user"})
public class CreateUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserJdbcDAO();

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$");

    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^0[0-9]{9}$");

    // Ít nhất 6 ký tự, có chữ và số
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{6,}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ================= GET PARAM ================= */

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String roleIdRaw = request.getParameter("roleId");
        String status = request.getParameter("status");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        Map<String, String> errors = new HashMap<>();

        /* ================= TRIM ================= */

        fullName = fullName != null ? fullName.trim() : "";
        email = email != null ? email.trim() : "";
        phone = phone != null ? phone.trim() : "";
        address = address != null ? address.trim() : "";
        status = status != null ? status.trim() : "";

        int roleId = 0;

        try {
            roleId = Integer.parseInt(roleIdRaw);
        } catch (Exception e) {
            errors.put("roleId", "Invalid role selected");
        }

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
        } else if (userDAO.existsByEmail(email)) {
            errors.put("email", "Email already exists");
        }

        /* ================= VALIDATE PASSWORD ================= */

        if (password == null || password.isBlank()) {
            errors.put("password", "Password cannot be empty");
        } else if (!PASSWORD_PATTERN.matcher(password).matches()) {
            errors.put("password", "Password must be at least 6 characters and contain letters and numbers");
        }

        if (confirmPassword == null || confirmPassword.isBlank()) {
            errors.put("confirmPassword", "Please re-enter password");
        } else if (password != null && !password.equals(confirmPassword)) {
            errors.put("confirmPassword", "Passwords do not match");
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

        if (roleId > 0 && !userDAO.existsRoleById(roleId)) {
            errors.put("roleId", "Invalid role selected");
        }

        /* ================= VALIDATE STATUS ================= */

        if (!status.equals("Active") &&
            !status.equals("Inactive") &&
            !status.equals("Blocked")) {
            errors.put("status", "Status must be Active, Inactive or Blocked");
        }

        /* ================= IF ERROR ================= */

        if (!errors.isEmpty()) {

            request.setAttribute("errors", errors);
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("address", address);
            request.setAttribute("roleId", roleId);
            request.setAttribute("status", status);
            request.setAttribute("openCreateModal", true);

            request.getRequestDispatcher("/admin/user-management")
                    .forward(request, response);
            return;
        }

        /* ================= CREATE USER ================= */

        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setAddress(address);
        user.setStatus(status);
        user.setPasswordHash(utils.PasswordUtil.hashPassword(password));
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        Role role = new Role();
        role.setRoleId(roleId);
        user.setRole(role);

        boolean success = userDAO.create(user);

        if (!success) {
            response.sendRedirect("user-management?error=createFailed");
            return;
        }

        /* ================= REDIRECT KEEP FILTER ================= */

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