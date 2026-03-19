package controller.admin;

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
        String roleName = currentUser.getRole() != null && currentUser.getRole().getRoleName() != null
                ? currentUser.getRole().getRoleName().trim().toLowerCase() : "";
        if (!(roleName.equals("admin") || roleName.equals("clinicowner"))) {
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
}
