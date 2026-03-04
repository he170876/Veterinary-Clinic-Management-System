package controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import model.User;
import service.AuthService;
import service.impl.AuthServiceImpl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Optional;

/**
 * Handles Google OAuth 2.0 login.
 * GET with no params: redirect to Google. GET with code: exchange token, find/create user, redirect to dashboard.
 */
@WebServlet(name = "GoogleLoginServlet", urlPatterns = {"/google-login"})
public class GoogleLoginServlet extends HttpServlet {

    private static final String CLIENT_ID = "69122699637-3bnfnc6vgctdfe1dgagc29eop3nq59nr.apps.googleusercontent.com";
    private static final String CLIENT_SECRET = "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";
    private static final String REDIRECT_URI_TEMPLATE = "%s://%s:%d%s/google-login";
    private static final String SCOPE = "openid email profile";

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        String state = request.getParameter("state");
        String error = request.getParameter("error");

        if (error != null) {
            response.sendRedirect(request.getContextPath() + "/login?error=google_denied");
            return;
        }

        String ctx = request.getContextPath();

        if (code == null || code.isEmpty()) {
            // Step 1: redirect to Google
            String redirectUri = buildRedirectUri(request);
            String stateToken = generateStateToken();
            HttpSession session = request.getSession(true);
            session.setAttribute("google_oauth_state", stateToken);

            String authUrl = "https://accounts.google.com/o/oauth2/v2/auth"
                    + "?client_id=" + encode(CLIENT_ID)
                    + "&redirect_uri=" + encode(redirectUri)
                    + "&response_type=code"
                    + "&scope=" + encode(SCOPE)
                    + "&state=" + encode(stateToken);

            response.sendRedirect(authUrl);
            return;
        }

        // Step 2: callback - verify state, exchange code
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(ctx + "/login?error=session_expired");
            return;
        }
        String savedState = (String) session.getAttribute("google_oauth_state");
        session.removeAttribute("google_oauth_state");
        if (savedState == null || !savedState.equals(state)) {
            response.sendRedirect(ctx + "/login?error=invalid_state");
            return;
        }

        String redirectUri = buildRedirectUri(request);
        String tokenResponse = exchangeCodeForTokens(code, redirectUri);
        if (tokenResponse == null) {
            response.sendRedirect(ctx + "/login?error=token_exchange_failed");
            return;
        }

        String accessToken = extractAccessToken(tokenResponse);
        String email = null;
        String fullName = null;

        // Try userinfo endpoint first (most reliable)
        if (accessToken != null) {
            String userInfoJson = fetchUserInfo(accessToken);
            if (userInfoJson != null) {
                email = extractFromJson(userInfoJson, "email");
                fullName = extractFromJson(userInfoJson, "name");
            }
        }

        // Fallback: parse id_token JWT
        if (email == null) {
            email = extractEmailFromIdToken(tokenResponse);
            fullName = extractNameFromIdToken(tokenResponse);
        }

        if (email == null || email.isEmpty()) {
            response.sendRedirect(ctx + "/login?error=no_email");
            return;
        }

        email = email.trim().toLowerCase();
        if (fullName == null) fullName = email.split("@")[0];

        // Find existing user or create new Customer (Google users get random password)
        UserDAO userDAO = new UserJdbcDAO();
        User user = userDAO.findByEmail(email).orElse(null);
        if (user == null) {
            user = authService.registerCustomer(fullName, email, "", java.util.UUID.randomUUID().toString());
            if (user != null) {
                userDAO.setGoogleUser(user.getUserId());
                user.setGoogleUser(true);
            }
        }
        if (user == null) {
            response.sendRedirect(ctx + "/login?error=create_failed");
            return;
        }

        if (!"Active".equalsIgnoreCase(user.getStatus())) {
            response.sendRedirect(ctx + "/login?error=account_inactive");
            return;
        }

        session.setAttribute("currentUser", user);
        session.setMaxInactiveInterval(30 * 60);

        // Force Google users without phone to add phone before accessing dashboard/profile
        if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
            session.setAttribute("pendingPhoneRequired", Boolean.TRUE);
            response.sendRedirect(ctx + "/customer/edit-profile?required=phone");
            return;
        }

        redirectToDashboard(request, response, user);
    }

    private String buildRedirectUri(HttpServletRequest request) {
        int port = request.getServerPort();
        String scheme = request.getScheme();
        String server = request.getServerName();
        String ctx = request.getContextPath();
        if (("http".equals(scheme) && port == 80) || ("https".equals(scheme) && port == 443)) {
            return scheme + "://" + server + ctx + "/google-login";
        }
        return String.format(REDIRECT_URI_TEMPLATE, scheme, server, port, ctx);
    }

    private String generateStateToken() {
        SecureRandom sr = new SecureRandom();
        byte[] b = new byte[24];
        sr.nextBytes(b);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }

    private String exchangeCodeForTokens(String code, String redirectUri) throws IOException {
        String body = "code=" + encode(code)
                + "&client_id=" + encode(CLIENT_ID)
                + "&client_secret=" + encode(CLIENT_SECRET)
                + "&redirect_uri=" + encode(redirectUri)
                + "&grant_type=authorization_code";

        HttpURLConnection conn = (HttpURLConnection) new URL("https://oauth2.googleapis.com/token").openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        if (conn.getResponseCode() != 200) {
            return null;
        }

        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(new java.io.InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = r.readLine()) != null) sb.append(line);
        }
        return sb.toString();
    }

    private String extractAccessToken(String tokenJson) {
        return extractFromJson(tokenJson, "access_token");
    }

    private String fetchUserInfo(String accessToken) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL("https://www.googleapis.com/oauth2/v2/userinfo").openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);

        if (conn.getResponseCode() != 200) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(new java.io.InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = r.readLine()) != null) sb.append(line);
        }
        return sb.toString();
    }

    /**
     * Simple JSON value extractor (no external library needed).
     * Works for flat JSON objects with string values.
     */
    private String extractFromJson(String json, String key) {
        if (json == null || json.isEmpty()) return null;
        try {
            // Look for "key": "value" or "key":"value"
            String pattern1 = "\"" + key + "\"";
            int keyIndex = json.indexOf(pattern1);
            if (keyIndex < 0) return null;

            int colonIndex = json.indexOf(':', keyIndex + pattern1.length());
            if (colonIndex < 0) return null;

            // Skip whitespace after colon
            int start = colonIndex + 1;
            while (start < json.length() && Character.isWhitespace(json.charAt(start))) start++;
            if (start >= json.length()) return null;

            // Check if value is null
            if (json.substring(start).startsWith("null")) return null;

            // Value should start with quote
            if (json.charAt(start) != '"') return null;
            start++;

            // Find end quote (handle escaped quotes)
            StringBuilder sb = new StringBuilder();
            for (int i = start; i < json.length(); i++) {
                char c = json.charAt(i);
                if (c == '\\' && i + 1 < json.length()) {
                    sb.append(json.charAt(i + 1));
                    i++;
                } else if (c == '"') {
                    break;
                } else {
                    sb.append(c);
                }
            }
            String value = sb.toString();
            if (value.isEmpty() || "null".equalsIgnoreCase(value)) return null;
            return value;
        } catch (Exception e) {
            return null;
        }
    }

    private String extractEmailFromIdToken(String tokenJson) {
        try {
            String idToken = extractFromJson(tokenJson, "id_token");
            if (idToken == null || idToken.isEmpty()) return null;
            return extractClaimFromJwt(idToken, "email");
        } catch (Exception e) {
            return null;
        }
    }

    private String extractNameFromIdToken(String tokenJson) {
        try {
            String idToken = extractFromJson(tokenJson, "id_token");
            if (idToken == null || idToken.isEmpty()) return null;
            return extractClaimFromJwt(idToken, "name");
        } catch (Exception e) {
            return null;
        }
    }

    private String extractClaimFromJwt(String jwt, String claim) {
        String[] parts = jwt.split("\\.");
        if (parts.length < 2) return null;
        try {
            String payloadB64 = parts[1];
            int pad = 4 - (payloadB64.length() % 4);
            if (pad < 4) payloadB64 = payloadB64 + "====".substring(0, pad);
            String payload = new String(Base64.getUrlDecoder().decode(payloadB64), StandardCharsets.UTF_8);
            return extractFromJson(payload, claim);
        } catch (Exception e) {
            return null;
        }
    }

    private String encode(String s) throws UnsupportedEncodingException {
        return URLEncoder.encode(s, StandardCharsets.UTF_8.name());
    }

    private void redirectToDashboard(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        int roleId = (user.getRole() != null) ? user.getRole().getRoleId() : 0;
        String ctx = request.getContextPath();
        switch (roleId) {
            case 5:  // Admin
                                response.sendRedirect(ctx + "/admin/dashboard");
                break;
            case 6:  // ClinicOwner
                response.sendRedirect(ctx + "/owner/dashboard");
                break;
            case 2:  // Veterinarian
                response.sendRedirect(ctx + "/vet/dashboard");
                break;
            case 3:  // Receptionist
                response.sendRedirect(ctx + "/staff/dashboard");
                break;
            case 4:  // LabStaff
                response.sendRedirect(ctx + "/lab/dashboard");
                break;
            case 1:  // Customer
            default:
                response.sendRedirect(ctx + "/customer/dashboard");
                break;
        }
    }
}
