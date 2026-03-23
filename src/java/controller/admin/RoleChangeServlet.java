package controller.admin;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.UserService;
import service.impl.UserServiceImpl;
import java.io.IOException;

@WebServlet(name = "RoleChangeServlet", urlPatterns = {"/owner/change-user-role"})
public class RoleChangeServlet extends HttpServlet {
    private UserService userService;
    private final UserDAO userDAO = new UserJdbcDAO();

    @Override
    public void init() throws ServletException {
        this.userService = new UserServiceImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // Only admin/owner can change role
        User currentUser = (User) session.getAttribute("currentUser");
        String roleName = normalizeRole(currentUser);
        if (!(roleName.equals("admin") || roleName.equals("clinicowner") || roleName.equals("clinic owner"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String userIdStr = request.getParameter("id");
        String newRoleIdStr = request.getParameter("roleId");
        if (userIdStr == null || newRoleIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }
        try {
            int userId = Integer.parseInt(userIdStr);
            int newRoleId = Integer.parseInt(newRoleIdStr);

            // Clinic owner can only edit staff; customer accounts are view-only.
            if ((roleName.equals("clinicowner") || roleName.equals("clinic owner")) && isCustomer(userId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Clinic owner cannot edit customer accounts");
                return;
            }

            boolean success = userService.changeUserRole(userId, newRoleId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/owner/user-management");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to change user role");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user or role id");
        }
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
