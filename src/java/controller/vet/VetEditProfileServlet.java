package controller.vet;

import dao.NotificationDAO;
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

/**
 * Vet edit profile: reuse same validations as customer edit-profile.
 */
@MultipartConfig(fileSizeThreshold = 512 * 1024, maxFileSize = 2 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
@WebServlet(name = "VetEditProfileServlet", urlPatterns = {"/vet/edit-profile"})
public class VetEditProfileServlet extends HttpServlet {

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
        request.setAttribute("user", user);
        NotificationDAO ndao = new NotificationDAO();
        request.setAttribute("notifications", ndao.getRecentForUser(user.getUserId(), 10));
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.getRequestDispatcher("/WEB-INF/views/vet/edit-profile.jsp").forward(request, response);
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

        Part profilePart = ProfilePictureUploadUtil.findPart(request, "profilePicture");

        String fullName = ValidationUtil.normalizeFullName(request.getParameter("fullName"));
        String phone = ValidationUtil.trim(request.getParameter("phone"));
        String address = ValidationUtil.normalizeAddress(request.getParameter("address"));

        if (request.getParameter("phone") != null && ValidationUtil.hasLeadingOrTrailingSpaces(request.getParameter("phone"))) {
            response.sendRedirect(ctx + "/vet/edit-profile?error=" + URLEncoder.encode("Phone must not contain leading or trailing spaces.", StandardCharsets.UTF_8));
            return;
        }

        if (fullName == null || fullName.isEmpty()) {
            response.sendRedirect(ctx + "/vet/edit-profile?error=" + URLEncoder.encode("Full name is required.", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidFullName(fullName)) {
            response.sendRedirect(ctx + "/vet/edit-profile?error=" + URLEncoder.encode("Full name must be 1-30 characters, letters and spaces only (any language).", StandardCharsets.UTF_8));
            return;
        }
        if (phone != null && !phone.isEmpty() && !ValidationUtil.isValidPhone(phone)) {
            response.sendRedirect(ctx + "/vet/edit-profile?error=" + URLEncoder.encode("Phone must be 10 digits starting with 0 (e.g. 0123456789).", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidAddress(address)) {
            response.sendRedirect(ctx + "/vet/edit-profile?error=" + URLEncoder.encode("Address must be at most " + ValidationUtil.ADDRESS_MAX_LENGTH + " characters.", StandardCharsets.UTF_8));
            return;
        }

        user.setFullName(fullName);
        user.setPhone(phone != null && phone.isEmpty() ? null : phone);
        user.setAddress(address != null && address.isEmpty() ? null : address);

        boolean hadNonEmptyProfilePicture = ProfilePictureUploadUtil.hasNonEmptyFilePayload(profilePart, request);
        String savedAvatarPath = null;
        if (hadNonEmptyProfilePicture) {
            savedAvatarPath = ProfilePictureUploadUtil.trySaveAvatarPart(request, profilePart, user.getUserId(), "vet-");
            if (savedAvatarPath != null) {
                deleteProfilePictureIfExists(request, user.getProfilePictureUrl());
                user.setProfilePictureUrl(savedAvatarPath);
            }
        }

        boolean ok = userDAO.updateUser(user);
        ProfilePictureUploadUtil.logEditProfilePostSummary(request, "VetEditProfileServlet", user.getUserId(),
                profilePart, hadNonEmptyProfilePicture, savedAvatarPath, user.getProfilePictureUrl(), ok);
        if (ok) {
            userDAO.findById(user.getUserId()).ifPresent(u -> session.setAttribute("currentUser", u));
            response.sendRedirect(ctx + "/vet/profile?updated=1");
        } else {
            response.sendRedirect(ctx + "/vet/edit-profile?error=" + URLEncoder.encode("Could not save. Please try again.", StandardCharsets.UTF_8));
        }
    }

    private void deleteProfilePictureIfExists(HttpServletRequest request, String profilePictureUrl) {
        if (profilePictureUrl == null || profilePictureUrl.isEmpty()) return;
        Path base = ProfilePictureUploadUtil.webappRootDirectory(request);
        if (base == null) return;
        try {
            Path file = base.resolve(profilePictureUrl.replaceFirst("^/", "").replace("/", java.io.File.separator));
            if (Files.exists(file)) Files.delete(file);
        } catch (IOException ignored) { }
    }
}

