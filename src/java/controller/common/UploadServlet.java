package controller.common;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@WebServlet(name = "UploadServlet", urlPatterns = {"/uploads/*"})
public class UploadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.trim().isEmpty() || "/".equals(pathInfo)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (pathInfo.contains("..")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Path baseDir = Paths.get(getUploadBaseDir()).normalize();
        Path requested = baseDir.resolve(pathInfo.substring(1)).normalize();

        if (!requested.startsWith(baseDir)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (!Files.exists(requested) || !Files.isRegularFile(requested)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = getServletContext().getMimeType(requested.getFileName().toString());
        if (mime == null) {
            mime = "application/octet-stream";
        }
        response.setContentType(mime);
        response.setHeader("Cache-Control", "public, max-age=86400");

        try (InputStream in = Files.newInputStream(requested); OutputStream out = response.getOutputStream()) {
            in.transferTo(out);
        }
    }

    private String getUploadBaseDir() {
        String configured = getServletContext().getInitParameter("uploadDir");
        if (configured != null && !configured.trim().isEmpty()) {
            String path = configured.trim();
            if (!new File(path).isAbsolute()) {
                File projectRoot = new File(System.getProperty("user.dir"));
                path = new File(projectRoot, path).getAbsolutePath();
            }
            return path;
        }

        String userDir = System.getProperty("user.dir");
        return userDir + File.separator + "uploads";
    }
}
