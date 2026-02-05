package controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.AuthService;
import service.impl.AuthServiceImpl;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import utils.ValidationUtil;

/**
 * Handles POST from profile Change Password form.
 */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/customer/change-password"})
public class ChangePasswordServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthServiceImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        String ctx = request.getContextPath();
        String redirect = ctx + "/customer/profile";

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user != null && user.isGoogleUser()) {
            response.sendRedirect(redirect + "?pwError=" + URLEncoder.encode("Google account cannot change password. Use Google to sign in.", StandardCharsets.UTF_8));
            return;
        }
        String currentPassword = trim(request.getParameter("currentPassword"));
        String newPassword = trim(request.getParameter("newPassword"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        if (currentPassword == null || currentPassword.isEmpty()) {
            response.sendRedirect(redirect + "?pwError=" + URLEncoder.encode("Please enter your current password.", StandardCharsets.UTF_8));
            return;
        }
        if (newPassword == null || newPassword.isEmpty()) {
            response.sendRedirect(redirect + "?pwError=" + URLEncoder.encode("Please enter a new password.", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidPassword(newPassword)) {
            response.sendRedirect(redirect + "?pwError=" + URLEncoder.encode("New password must be 6-128 characters with 1 uppercase letter and 1 number.", StandardCharsets.UTF_8));
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect(redirect + "?pwError=" + URLEncoder.encode("New password and confirmation do not match.", StandardCharsets.UTF_8));
            return;
        }

        boolean ok = authService.changePassword(user.getUserId(), currentPassword, newPassword);
        if (ok) {
            response.sendRedirect(redirect + "?pw=1");
        } else {
            response.sendRedirect(redirect + "?pwError=" + URLEncoder.encode("Current password is incorrect. Please try again.", StandardCharsets.UTF_8));
        }
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }
}
