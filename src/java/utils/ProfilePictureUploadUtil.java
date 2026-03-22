package utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;

/**
 * Helpers for saving profile pictures under webapp {@code /uploads/avatars/}.
 * <p>Debug logs (prefix {@code [PFP]}): set JVM flag {@code -Dvcms.debug.pfp=false} to disable.</p>
 */
public final class ProfilePictureUploadUtil {

    /** Per Servlet API, {@link Part#getSize()} may be {@code -1} when size is not known yet (e.g. temp file on disk). */
    public static final long PART_SIZE_UNKNOWN = -1L;

    private ProfilePictureUploadUtil() {
    }

    /** When {@code false}, no {@code [PFP]} lines are written (default {@code true} while diagnosing uploads). */
    public static boolean isPfpDebugEnabled() {
        return !"false".equalsIgnoreCase(System.getProperty("vcms.debug.pfp", "true"));
    }

    private static void dbg(HttpServletRequest request, String message) {
        if (!isPfpDebugEnabled() || request == null) {
            return;
        }
        request.getServletContext().log("[PFP] " + message);
    }

    /**
     * Call at end of edit-profile POST to correlate multipart + DB in server logs.
     */
    public static void logEditProfilePostSummary(HttpServletRequest request, String servletTag, int userId,
            Part profilePart, boolean hadNonEmptyPayload, String savedRelativePath,
            String profilePictureUrlSetOnUser, boolean updateUserOk) {
        if (!isPfpDebugEnabled() || request == null) {
            return;
        }
        StringBuilder sb = new StringBuilder(256);
        sb.append("POST summary [").append(servletTag).append("] userId=").append(userId);
        sb.append(" partFound=").append(profilePart != null);
        if (profilePart != null) {
            sb.append(" partSize=").append(profilePart.getSize());
            sb.append(" ct=").append(profilePart.getContentType());
            sb.append(" file=").append(profilePart.getSubmittedFileName());
        }
        sb.append(" hadNonEmptyPayload=").append(hadNonEmptyPayload);
        sb.append(" savedRelativePath=").append(savedRelativePath);
        sb.append(" profilePictureUrlOnUser=").append(profilePictureUrlSetOnUser);
        sb.append(" updateUserOk=").append(updateUserOk);
        request.getServletContext().log("[PFP] " + sb);
    }

    /**
     * True if the multipart part likely contains a non-empty file upload.
     * Rejects empty parts ({@code size == 0}); accepts {@code size &gt; 0} or {@code size == -1} (unknown).
     */
    public static boolean hasNonEmptyFilePayload(Part part) {
        return hasNonEmptyFilePayload(part, null);
    }

    /**
     * @param request optional; if non-null and debug on, logs when part is skipped (size 0)
     */
    public static boolean hasNonEmptyFilePayload(Part part, HttpServletRequest request) {
        if (part == null) {
            dbg(request, "hasNonEmptyFilePayload: part=null");
            return false;
        }
        long sz = part.getSize();
        boolean ok = sz > 0 || sz == PART_SIZE_UNKNOWN;
        if (!ok) {
            dbg(request, "hasNonEmptyFilePayload: skip empty part name=" + part.getName() + " size=" + sz
                    + " ct=" + part.getContentType() + " file=" + part.getSubmittedFileName());
        }
        return ok;
    }

    /**
     * Returns file extension for stored filename (jpg, png, gif, webp), or null if not allowed.
     */
    public static String extensionForImageContentType(String contentType) {
        if (contentType == null) {
            return null;
        }
        String ct = contentType.toLowerCase(Locale.ROOT).trim();
        if (ct.startsWith("image/jpeg") || "image/jpg".equals(ct) || ct.startsWith("image/pjpeg")) {
            return "jpg";
        }
        if (ct.startsWith("image/png")) {
            return "png";
        }
        if (ct.startsWith("image/gif")) {
            return "gif";
        }
        if (ct.startsWith("image/webp")) {
            return "webp";
        }
        return null;
    }

    /**
     * Infer extension from client filename (e.g. {@code photo.PNG}).
     */
    public static String extensionFromFileName(String fileName) {
        if (fileName == null) {
            return null;
        }
        int dot = fileName.lastIndexOf('.');
        if (dot < 0 || dot >= fileName.length() - 1) {
            return null;
        }
        String ext = fileName.substring(dot + 1).toLowerCase(Locale.ROOT).trim();
        if ("jpeg".equals(ext)) {
            return "jpg";
        }
        if ("jpg".equals(ext) || "png".equals(ext) || "gif".equals(ext) || "webp".equals(ext)) {
            return ext;
        }
        return null;
    }

    /**
     * Resolves extension from MIME type and/or filename (handles empty filename,
     * {@code application/octet-stream} when filename has extension).
     */
    public static String resolveImageExtension(String contentType, String submittedFileName) {
        String ext = extensionForImageContentType(contentType);
        if (ext != null) {
            return ext;
        }
        if (contentType != null && contentType.toLowerCase(Locale.ROOT).startsWith("application/octet-stream")) {
            ext = extensionFromFileName(submittedFileName);
            if (ext != null) {
                return ext;
            }
        }
        return extensionFromFileName(submittedFileName);
    }

    /**
     * Saves multipart part to {@code /uploads/avatars/{prefix}{userId}-{millis}.{ext}}.
     * A new unique name on each upload forces a new {@code profile_picture_url} in DB and avoids browser cache
     * showing the previous file when the path string used to stay identical (e.g. always {@code vet-3.png}).
     *
     * @param fileNamePrefix e.g. {@code "vet-"} or {@code ""} for {@code 5-173....jpg}
     * @return relative path starting with {@code /uploads/avatars/}, or null on failure
     */
    public static String trySaveAvatarPart(HttpServletRequest request, Part part,
            int userId, String fileNamePrefix) {
        dbg(request, "trySaveAvatarPart: userId=" + userId + " prefix=" + fileNamePrefix
                + " part=" + (part == null ? "null" : ("size=" + part.getSize() + " ct=" + part.getContentType()
                + " file=" + part.getSubmittedFileName())));
        if (!hasNonEmptyFilePayload(part)) {
            return null;
        }
        String ext = resolveImageExtension(part.getContentType(), part.getSubmittedFileName());
        if (ext == null) {
            String msg = "unsupported image ct=" + part.getContentType() + " file=" + part.getSubmittedFileName();
            request.getServletContext().log("ProfilePictureUpload: " + msg);
            dbg(request, "trySaveAvatarPart: " + msg);
            return null;
        }
        dbg(request, "trySaveAvatarPart: resolved ext=" + ext);
        Path baseDir = webappRootDirectory(request);
        if (baseDir == null) {
            request.getServletContext().log("ProfilePictureUploadUtil: webapp root unavailable; cannot store avatar.");
            dbg(request, "trySaveAvatarPart: webappRootDirectory=null (cannot write file)");
            return null;
        }
        dbg(request, "trySaveAvatarPart: webappRoot=" + baseDir.toAbsolutePath());
        String prefix = fileNamePrefix == null ? "" : fileNamePrefix;
        String fileName = prefix + userId + "-" + System.currentTimeMillis() + "." + ext;
        String relativePath = "/uploads/avatars/" + fileName;
        Path uploadDir = baseDir.resolve("uploads").resolve("avatars");
        try {
            Files.createDirectories(uploadDir);
            Path targetFile = uploadDir.resolve(fileName);
            try (InputStream in = part.getInputStream()) {
                Files.copy(in, targetFile, StandardCopyOption.REPLACE_EXISTING);
            }
            dbg(request, "trySaveAvatarPart: OK wrote " + targetFile.toAbsolutePath() + " -> " + relativePath);
            return relativePath;
        } catch (IOException e) {
            e.printStackTrace();
            dbg(request, "trySaveAvatarPart: IOException " + e.getMessage());
            return null;
        }
    }

    /**
     * Absolute path to web application root (directory containing WEB-INF).
     */
    public static Path webappRootDirectory(HttpServletRequest request) {
        String rp = request.getServletContext().getRealPath("/");
        if (rp != null) {
            return Paths.get(rp);
        }
        try {
            java.net.URL root = request.getServletContext().getResource("/");
            if (root != null && "file".equals(root.getProtocol())) {
                Path p = Paths.get(root.toURI());
                if (Files.isDirectory(p)) {
                    return p;
                }
            }
        } catch (Exception ignored) {
            // ignore
        }
        String catalina = System.getProperty("catalina.base");
        if (catalina != null && !catalina.isEmpty()) {
            String ctx = request.getContextPath();
            String folder = (ctx == null || ctx.isEmpty() || "/".equals(ctx)) ? "ROOT" : ctx.substring(1);
            Path candidate = Paths.get(catalina, "webapps", folder);
            if (Files.isDirectory(candidate)) {
                return candidate;
            }
        }
        Path external = externalUploadsFallback(request);
        if (external != null) {
            request.getServletContext().log("[PFP] webappRootDirectory: using external fallback (getRealPath was null): "
                    + external.toAbsolutePath());
            dbg(request, "webappRootDirectory: fallback=" + external.toAbsolutePath());
            return external;
        }
        return null;
    }

    /**
     * When {@code getRealPath("/")} is null (e.g. packed WAR) and catalina webapps path is missing,
     * store uploads under {@code java.io.tmpdir/vcms-uploads/&lt;context&gt;/uploads/avatars}.
     * Same resolution must be used when serving files (UploadsAvatarServlet uses webappRootDirectory too).
     */
    public static Path externalUploadsFallback(HttpServletRequest request) {
        String tmp = System.getProperty("java.io.tmpdir");
        if (tmp == null || tmp.isEmpty()) {
            return null;
        }
        String sub = safeContextFolder(request.getContextPath());
        Path base = Paths.get(tmp, "vcms-uploads", sub);
        try {
            Files.createDirectories(base.resolve("uploads").resolve("avatars"));
        } catch (IOException e) {
            return null;
        }
        return base;
    }

    private static String safeContextFolder(String ctx) {
        if (ctx == null || ctx.isEmpty() || "/".equals(ctx)) {
            return "ROOT";
        }
        String s = ctx.replaceFirst("^/+", "");
        return s.replaceAll("[^a-zA-Z0-9._-]", "_");
    }

    /**
     * Resolves a multipart part by name after the container has parsed the request.
     * Prefer over {@link HttpServletRequest#getPart(String)} alone — some containers parse parts more reliably after iterating.
     */
    public static Part findPart(HttpServletRequest request, String partName) {
        if (partName == null || partName.isEmpty()) {
            dbg(request, "findPart: empty partName");
            return null;
        }
        try {
            StringBuilder scan = new StringBuilder();
            int n = 0;
            Part found = null;
            for (Part p : request.getParts()) {
                n++;
                scan.append("{name=").append(p.getName()).append(",size=").append(p.getSize())
                        .append(",ct=").append(p.getContentType()).append("} ");
                if (partName.equals(p.getName())) {
                    found = p;
                }
            }
            dbg(request, "findPart: want='" + partName + "' partsCount=" + n + " scan=" + scan);
            if (found != null) {
                return found;
            }
            dbg(request, "findPart: no matching part for name='" + partName + "'");
        } catch (Exception e) {
            request.getServletContext().log("ProfilePictureUploadUtil.findPart: " + partName, e);
            dbg(request, "findPart: exception " + e.getClass().getSimpleName() + " " + e.getMessage());
        }
        return null;
    }
}
