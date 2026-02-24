package controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.AuthService;
import service.impl.AuthServiceImpl;
import utils.MailSender;
import utils.ValidationUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

/**
 * GET: show forgot-password form. POST: accept email, create token, send reset link by email (or show link if mail not configured).
 */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

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
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        String ctx = request.getContextPath();
        String email = ValidationUtil.trim(request.getParameter("email"));

        if (email == null || email.isEmpty()) {
            response.sendRedirect(ctx + "/forgot-password?error=" + URLEncoder.encode("Please enter your email.", StandardCharsets.UTF_8));
            return;
        }
        if (ValidationUtil.hasLeadingOrTrailingSpaces(request.getParameter("email"))) {
            response.sendRedirect(ctx + "/forgot-password?error=" + URLEncoder.encode("Email must not contain leading or trailing spaces.", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidGmail(email)) {
            response.sendRedirect(ctx + "/forgot-password?error=" + URLEncoder.encode("Email must be a Gmail address (@gmail.com).", StandardCharsets.UTF_8));
            return;
        }

        String normalizedEmail = email.trim().toLowerCase();
        java.util.logging.Logger.getLogger(ForgotPasswordServlet.class.getName())
                .info("Forgot password request for email: " + normalizedEmail);
        Optional<String> tokenOpt = authService.createPasswordResetToken(email);
        if (!tokenOpt.isPresent()) {
            // Don't reveal whether email exists or is Google user; same message
            response.sendRedirect(ctx + "/forgot-password?sent=1");
            return;
        }

        String token = tokenOpt.get();
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int port = request.getServerPort();
        String baseUrl = scheme + "://" + serverName + (port == 80 || port == 443 ? "" : ":" + port) + ctx;
        String resetLink = baseUrl + "/reset-password?token=" + URLEncoder.encode(token, StandardCharsets.UTF_8);

        boolean mailEnabled = "true".equalsIgnoreCase(getServletContext().getInitParameter("mail.enabled"));
        boolean sent = false;
        if (mailEnabled) {
            String smtpHost = getServletContext().getInitParameter("mail.smtp.host");
            String smtpPortStr = getServletContext().getInitParameter("mail.smtp.port");
            String smtpUser = getServletContext().getInitParameter("mail.smtp.user");
            String smtpPass = getServletContext().getInitParameter("mail.smtp.password");
            String from = getServletContext().getInitParameter("mail.from");
            boolean useTls = "true".equalsIgnoreCase(getServletContext().getInitParameter("mail.smtp.starttls"));
            int portNum = 587;
            if (smtpPortStr != null && !smtpPortStr.isEmpty()) {
                try { portNum = Integer.parseInt(smtpPortStr); } catch (NumberFormatException ignored) { }
            }
            if (smtpHost != null && from != null) {
                String subject = "Reset your Anipats password";
                String body = "Hi,\n\nUse this link to reset your password (valid for 1 hour):\n\n" + resetLink + "\n\nIf you didn't request this, ignore this email.\n\n— Anipats";
                sent = MailSender.send(smtpHost, portNum, smtpUser, smtpPass, useTls, from, email.trim().toLowerCase(), subject, body);
            }
        }
        // When mail is disabled or send failed, show link on success page (e.g. for dev)
        String redirectUrl = ctx + "/forgot-password?sent=1";
        if (!sent) {
            redirectUrl += "&devLink=" + URLEncoder.encode(resetLink, StandardCharsets.UTF_8);
        }
        response.sendRedirect(redirectUrl);
    }
}
