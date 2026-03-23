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
 * Serves lab result files (PDF or legacy images) under {@code /uploads/lab-results/} from the same disk root
 * as {@link utils.LabResultImageUploadUtil} (webapp {@code uploads/lab-results}).
 * Required because {@link controller.common.UploadServlet} maps {@code /uploads/*} to a different base ({@code user.dir/uploads}).
 */
@WebServlet(name = "UploadsLabResultsServlet", urlPatterns = {"/uploads/lab-results/*"})
public class UploadsLabResultsServlet extends HttpServlet {

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
        Path labRoot = base.resolve("uploads").resolve("lab-results").normalize();
        Path file = labRoot.resolve(name).normalize();
        if (!file.startsWith(labRoot)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!Files.isRegularFile(file)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String lower = name.toLowerCase();
        if (lower.endsWith(".pdf")) {
            response.setContentType("application/pdf");
        } else if (lower.endsWith(".png")) {
            response.setContentType("image/png");
        } else if (lower.endsWith(".gif")) {
            response.setContentType("image/gif");
        } else if (lower.endsWith(".webp")) {
            response.setContentType("image/webp");
        } else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            response.setContentType("image/jpeg");
        } else {
            response.setContentType("application/octet-stream");
        }
        response.setHeader("Cache-Control", "public, max-age=3600");
        response.setContentLengthLong(Files.size(file));

        try (OutputStream out = response.getOutputStream()) {
            Files.copy(file, out);
        }
    }
}
