package controller.admin;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.User;
import utils.ProfilePictureUploadUtil;
import utils.ValidationUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

@MultipartConfig(fileSizeThreshold = 512 * 1024, maxFileSize = 2 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
@WebServlet(name = "AdminEditProfileServlet", urlPatterns = {"/owner/edit-profile"})
public class AdminEditProfileServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserJdbcDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("currentUser");
        User user = userDAO.findById(sessionUser.getUserId()).orElse(sessionUser);
        session.setAttribute("currentUser", user);

        // Same behavior as other profile pages: force phone if missing
        if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
            session.setAttribute("pendingPhoneRequired", Boolean.TRUE);
            response.sendRedirect(request.getContextPath() + "/owner/edit-profile?required=phone");
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/admin/edit-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        String ctx = request.getContextPath();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");

        // Read multipart file FIRST so multipart parsing doesn't break parameter reading
        Part profilePart = ProfilePictureUploadUtil.findPart(request, "profilePicture");

        String fullName = ValidationUtil.normalizeFullName(request.getParameter("fullName"));
        String phone = ValidationUtil.trim(request.getParameter("phone"));
        String address = ValidationUtil.normalizeAddress(request.getParameter("address"));

        boolean pendingPhone = session.getAttribute("pendingPhoneRequired") != null;
        String redirectSuffix = pendingPhone ? "?required=phone" : "";

        if (request.getParameter("phone") != null
                && ValidationUtil.hasLeadingOrTrailingSpaces(request.getParameter("phone"))) {
            response.sendRedirect(ctx + "/owner/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&") + "error="
                    + URLEncoder.encode("Phone must not contain leading or trailing spaces.", StandardCharsets.UTF_8));
            return;
        }

        if (fullName == null || fullName.isEmpty()) {
            response.sendRedirect(ctx + "/owner/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&") + "error="
                    + URLEncoder.encode("Full name is required.", StandardCharsets.UTF_8));
            return;
        }

        if (!ValidationUtil.isValidFullName(fullName)) {
            response.sendRedirect(ctx + "/owner/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&") + "error="
                    + URLEncoder.encode("Full name must be 1-30 characters, letters and spaces only (any language).", StandardCharsets.UTF_8));
            return;
        }

        if (pendingPhone && (phone == null || phone.isEmpty())) {
            response.sendRedirect(ctx + "/owner/edit-profile?required=phone&error="
                    + URLEncoder.encode("Phone number is required to continue.", StandardCharsets.UTF_8));
            return;
        }

        if (phone != null && !phone.isEmpty() && !ValidationUtil.isValidPhone(phone)) {
            response.sendRedirect(ctx + "/owner/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&") + "error="
                    + URLEncoder.encode("Phone must be 10 digits starting with 0 (e.g. 0123456789).", StandardCharsets.UTF_8));
            return;
        }

        if (!ValidationUtil.isValidAddress(address)) {
            response.sendRedirect(ctx + "/owner/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&") + "error="
                    + URLEncoder.encode("Address must be at most " + ValidationUtil.ADDRESS_MAX_LENGTH + " characters.", StandardCharsets.UTF_8));
            return;
        }

        user.setFullName(fullName);
        user.setPhone(phone != null && phone.isEmpty() ? null : phone);
        user.setAddress(address != null && address.isEmpty() ? null : address);

        boolean hadNonEmptyProfilePicture = ProfilePictureUploadUtil.hasNonEmptyFilePayload(profilePart, request);
        String savedAvatarPath = null;
        if (hadNonEmptyProfilePicture) {
            savedAvatarPath = ProfilePictureUploadUtil.trySaveAvatarPart(request, profilePart, user.getUserId(), "");
            if (savedAvatarPath != null) {
                deleteProfilePictureIfExists(request, user.getProfilePictureUrl());
                user.setProfilePictureUrl(savedAvatarPath);
            }
        }

        boolean ok = userDAO.updateUser(user);
        ProfilePictureUploadUtil.logEditProfilePostSummary(request, "AdminEditProfileServlet", user.getUserId(),
                profilePart, hadNonEmptyProfilePicture, savedAvatarPath, user.getProfilePictureUrl(), ok);
        if (ok) {
            userDAO.findById(user.getUserId()).ifPresent(u -> session.setAttribute("currentUser", u));
            session.removeAttribute("pendingPhoneRequired");
            response.sendRedirect(ctx + "/owner/profile" + (pendingPhone ? "" : "?updated=1"));
        } else {
            response.sendRedirect(ctx + "/owner/edit-profile"
                    + (pendingPhone ? "?required=phone&" : "?")
                    + "error=" + URLEncoder.encode("Could not save. Please try again.", StandardCharsets.UTF_8));
        }
    }

    private void deleteProfilePictureIfExists(HttpServletRequest request, String profilePictureUrl) {
        if (profilePictureUrl == null || profilePictureUrl.isEmpty()) return;
        Path base = ProfilePictureUploadUtil.webappRootDirectory(request);
        if (base == null) return;
        try {
            Path file = base.resolve(profilePictureUrl.replaceFirst("^/", "")
                    .replace("/", java.io.File.separator));
            if (Files.exists(file)) Files.delete(file);
        } catch (IOException ignored) {
            // no-op
        }
    }
}

