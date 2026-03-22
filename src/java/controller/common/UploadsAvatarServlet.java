package controller.common;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.ProfilePictureUploadUtil;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Serves files under {@code /uploads/avatars/} from the webapp directory on disk.
 * Fixes cases where the container default servlet does not expose newly written uploads.
 */
@WebServlet(name = "UploadsAvatarServlet", urlPatterns = {"/uploads/avatars/*"})
public class UploadsAvatarServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String name = pathInfo.substring(1);
        if (name.isEmpty() || name.contains("..") || name.indexOf('/') >= 0 || name.indexOf('\\') >= 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path base = ProfilePictureUploadUtil.webappRootDirectory(request);
        if (base == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        Path avatarsRoot = base.resolve("uploads").resolve("avatars").normalize();
        Path file = avatarsRoot.resolve(name).normalize();
        if (!file.startsWith(avatarsRoot)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if (!Files.isRegularFile(file)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String lower = name.toLowerCase();
        if (lower.endsWith(".png")) {
            response.setContentType("image/png");
        } else if (lower.endsWith(".gif")) {
            response.setContentType("image/gif");
        } else if (lower.endsWith(".webp")) {
            response.setContentType("image/webp");
        } else {
            response.setContentType("image/jpeg");
        }
        response.setHeader("Cache-Control", "public, max-age=3600");
        long len = Files.size(file);
        response.setContentLengthLong(len);

        try (OutputStream out = response.getOutputStream()) {
            Files.copy(file, out);
        }
    }
}
