package controller.receptionist;

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
import utils.ValidationUtil;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;

/**
 * Receptionist edits basic profile information (name/phone/address) and avatar.
 */
@MultipartConfig(fileSizeThreshold = 0, maxFileSize = 2 * 1024 * 1024, maxRequestSize = 3 * 1024 * 1024)
@WebServlet(name = "ReceptionistEditProfileServlet", urlPatterns = {"/Receptionist/edit-profile"})
public class ReceptionistEditProfileServlet extends HttpServlet {

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
        User user = (User) session.getAttribute("currentUser");
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/Receptionist/edit-profile.jsp").forward(request, response);
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

        // Read multipart part first (helps some containers parse multipart reliably)
        Part profilePart = null;
        try {
            profilePart = request.getPart("profilePicture");
        } catch (Exception ignored) {
            // no multipart / no file
        }

        String fullName = ValidationUtil.normalizeFullName(request.getParameter("fullName"));
        String phone = ValidationUtil.trim(request.getParameter("phone"));
        String address = ValidationUtil.normalizeAddress(request.getParameter("address"));

        boolean pendingPhone = session.getAttribute("pendingPhoneRequired") != null;
        String redirectSuffix = pendingPhone ? "?required=phone" : "";

        if (request.getParameter("phone") != null
                && ValidationUtil.hasLeadingOrTrailingSpaces(request.getParameter("phone"))) {
            response.sendRedirect(ctx + "/Receptionist/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&")
                    + "error=" + URLEncoder.encode("Phone must not contain leading or trailing spaces.", StandardCharsets.UTF_8));
            return;
        }

        if (fullName == null || fullName.isEmpty()) {
            response.sendRedirect(ctx + "/Receptionist/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&")
                    + "error=" + URLEncoder.encode("Full name is required.", StandardCharsets.UTF_8));
            return;
        }

        if (!ValidationUtil.isValidFullName(fullName)) {
            response.sendRedirect(ctx + "/Receptionist/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&")
                    + "error=" + URLEncoder.encode("Full name must be 1-30 characters, letters and spaces only (any language).", StandardCharsets.UTF_8));
            return;
        }

        if (pendingPhone && (phone == null || phone.isEmpty())) {
            response.sendRedirect(ctx + "/Receptionist/edit-profile?required=phone&error="
                    + URLEncoder.encode("Phone number is required to continue.", StandardCharsets.UTF_8));
            return;
        }

        if (phone != null && !phone.isEmpty() && !ValidationUtil.isValidPhone(phone)) {
            response.sendRedirect(ctx + "/Receptionist/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&")
                    + "error=" + URLEncoder.encode("Phone must be 10 digits starting with 0 (e.g. 0123456789).", StandardCharsets.UTF_8));
            return;
        }

        if (!ValidationUtil.isValidAddress(address)) {
            response.sendRedirect(ctx + "/Receptionist/edit-profile" + redirectSuffix
                    + (redirectSuffix.isEmpty() ? "?" : "&")
                    + "error=" + URLEncoder.encode("Address must be at most " + ValidationUtil.ADDRESS_MAX_LENGTH + " characters.", StandardCharsets.UTF_8));
            return;
        }

        user.setFullName(fullName);
        user.setPhone(phone != null && phone.isEmpty() ? null : phone);
        user.setAddress(address != null && address.isEmpty() ? null : address);

        // Remove photo if requested
        if ("1".equals(ValidationUtil.trim(request.getParameter("removePhoto")))) {
            deleteProfilePictureIfExists(request, user.getProfilePictureUrl());
            user.setProfilePictureUrl(null);
        } else if (profilePart != null && profilePart.getSize() > 0) {
            String submittedFileName = profilePart.getSubmittedFileName();
            if (submittedFileName != null && !submittedFileName.isEmpty()) {
                String contentType = profilePart.getContentType();
                if (contentType != null) {
                    String ct = contentType.toLowerCase(Locale.ROOT);
                    if (ct.startsWith("image/jpeg") || ct.startsWith("image/png") || ct.startsWith("image/gif")) {
                        String ext = ct.contains("png") ? "png" : ct.contains("gif") ? "gif" : "jpg";
                        String fileName = user.getUserId() + "." + ext;
                        String relativePath = "/uploads/avatars/" + fileName;

                        Path baseDir = Paths.get(request.getServletContext().getRealPath("/"));
                        Path uploadDir = baseDir.resolve("uploads").resolve("avatars");

                        try {
                            Files.createDirectories(uploadDir);
                            Path targetFile = uploadDir.resolve(fileName);
                            try (InputStream in = profilePart.getInputStream()) {
                                Files.copy(in, targetFile.toAbsolutePath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                            }

                            deleteProfilePictureIfExists(request, user.getProfilePictureUrl());
                            user.setProfilePictureUrl(relativePath);
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }

        boolean ok = userDAO.updateUser(user);
        if (ok) {
            session.setAttribute("currentUser", user);
            if (pendingPhone) {
                session.removeAttribute("pendingPhoneRequired");
                    response.sendRedirect(ctx + "/Receptionist/Dashboard");
            } else {
                response.sendRedirect(ctx + "/Receptionist/profile?updated=1");
            }
        } else {
            response.sendRedirect(ctx + "/Receptionist/edit-profile"
                    + (pendingPhone ? "?required=phone&" : "?")
                    + "error=" + URLEncoder.encode("Could not save. Please try again.", StandardCharsets.UTF_8));
        }
    }

    private void deleteProfilePictureIfExists(HttpServletRequest request, String profilePictureUrl) {
        if (profilePictureUrl == null || profilePictureUrl.isEmpty()) return;
        try {
            Path base = Paths.get(request.getServletContext().getRealPath("/"));
            Path file = base.resolve(profilePictureUrl.replaceFirst("^/", "").replace("/", java.io.File.separator));
            if (Files.exists(file)) Files.delete(file);
        } catch (IOException ignored) {
        }
    }
}

