package controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.AuthService;
import service.impl.AuthServiceImpl;
import utils.ValidationUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * GET: show reset-password form if token valid. POST: reset password with token.
 */
@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard");
            return;
        }
        String token = ValidationUtil.trim(request.getParameter("token"));
        if (token == null || token.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/forgot-password?error=" + URLEncoder.encode("Invalid or missing reset link.", StandardCharsets.UTF_8));
            return;
        }
        // Token validity is checked on POST; here we just show the form with token in hidden field
        request.setAttribute("token", token);
        request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        String ctx = request.getContextPath();
        String token = ValidationUtil.trim(request.getParameter("token"));
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (token == null || token.isEmpty()) {
            response.sendRedirect(ctx + "/login?error=" + URLEncoder.encode("Invalid reset link. Please request a new one.", StandardCharsets.UTF_8));
            return;
        }
        if (newPassword == null || confirmPassword == null || !newPassword.equals(confirmPassword)) {
            response.sendRedirect(ctx + "/reset-password?token=" + URLEncoder.encode(token, StandardCharsets.UTF_8) + "&error=" + URLEncoder.encode("Passwords do not match.", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidPassword(newPassword)) {
            response.sendRedirect(ctx + "/reset-password?token=" + URLEncoder.encode(token, StandardCharsets.UTF_8) + "&error=" + URLEncoder.encode("Password must be 6-128 characters with 1 uppercase letter and 1 number.", StandardCharsets.UTF_8));
            return;
        }

        boolean ok = authService.resetPasswordWithToken(token, newPassword);
        if (ok) {
            response.sendRedirect(ctx + "/login?reset=1");
        } else {
            response.sendRedirect(ctx + "/login?error=" + URLEncoder.encode("Reset link expired or invalid. Please request a new one.", StandardCharsets.UTF_8));
        }
    }
}
