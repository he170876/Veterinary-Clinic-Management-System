package controller.admin;

import java.io.IOException;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Image;
import model.User;
import service.ImageService;
import service.impl.ImageServiceImpl;

/**
 * Servlet handling upload and listing operations for image library.
 */
@WebServlet(name = "ImageServlet", urlPatterns = {"/owner/images/*"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 10 * 1024 * 1024,  // 10MB
    maxRequestSize = 50 * 1024 * 1024 // 50MB
)
public class ImageServlet extends HttpServlet {

    private ImageService imageService;

    @Override
    public void init() throws ServletException {
        this.imageService = new ImageServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Check admin or clinic owner role (accept both "ClinicOwner" and "Clinic Owner")
        User currentUser = (User) session.getAttribute("currentUser");
        if (!hasImageManagementAccess(currentUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            listImages(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Keep same access policy as GET to avoid owner being blocked on form submit
        User currentUser = (User) session.getAttribute("currentUser");
        if (!hasImageManagementAccess(currentUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo != null && !pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Upload only endpoint");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || "create".equals(action)) {
            createImage(request, response);
        } else if ("delete".equals(action)) {
            deleteImage(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    private void listImages(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Image> images = imageService.getAllImagesOrderedBySort();
        request.setAttribute("images", images);
        request.getRequestDispatcher("/WEB-INF/views/admin/images.jsp").forward(request, response);
    }

    private void createImage(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        try {
            Part filePart = request.getPart("imageFile");
            if (filePart == null || filePart.getSize() == 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "No image file provided");
                return;
            }

            // Validate file type
            String fileName = filePart.getSubmittedFileName();
            // get file content MIME
            String contentType = filePart.getContentType();
            if (!isValidImageType(contentType, fileName)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file type. Only JPG, PNG, GIF, WebP allowed");
                return;
            }

            // Save file
            String uploadedPath = saveUploadedFile(request, filePart);
            if (uploadedPath == null) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to save file");
                return;
            }

            Image image = new Image();
            image.setTitle(request.getParameter("title"));
            image.setUrl(uploadedPath);
            image.setAltText(request.getParameter("altText"));
            image.setSection(request.getParameter("section"));
            image.setSortOrder(0);

            Image created = imageService.createImage(image);
            if (created != null) {
                response.sendRedirect(request.getContextPath() + "/owner/images");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to create image");
            }
        } catch (Exception e) {
            System.err.println("CreateImage ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void deleteImage(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idRaw = request.getParameter("imageId");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing image id");
            return;
        }

        final long imageId;
        try {
            imageId = Long.parseLong(idRaw.trim());
            if (imageId <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid image id");
                return;
            }
        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid image id");
            return;
        }

        Optional<Image> existingOpt = imageService.getImageById(imageId);
        if (!existingOpt.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
            return;
        }

        boolean deleted = imageService.deleteImage(imageId);
        if (!deleted) {
            response.sendError(HttpServletResponse.SC_CONFLICT,
                    "Could not delete image. It may be referenced by other content.");
            return;
        }

        // Best-effort cleanup of uploaded file. Keep DB success even if file is already missing.
        deletePhysicalFile(request, existingOpt.get().getUrl());

        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write("Image deleted");
    }

    /**
     * Validates if the uploaded file is a valid image type.
     */
    private boolean isValidImageType(String contentType, String fileName) {
        if (contentType == null || fileName == null) return false;
        
        String lowerContentType = contentType.toLowerCase();
        String lowerFileName = fileName.toLowerCase();
        
        boolean isValidType = lowerContentType.contains("image/jpeg") || 
                              lowerContentType.contains("image/png") || 
                              lowerContentType.contains("image/gif") || 
                              lowerContentType.contains("image/webp");
        
        boolean isValidExtension = lowerFileName.endsWith(".jpg") || 
                                   lowerFileName.endsWith(".jpeg") || 
                                   lowerFileName.endsWith(".png") || 
                                   lowerFileName.endsWith(".gif") || 
                                   lowerFileName.endsWith(".webp");
        
        return isValidType && isValidExtension;
    }

    /**
     * Saves the uploaded file to disk and returns the relative path.
     */
    private String saveUploadedFile(HttpServletRequest request, Part filePart) {
        try {
            //tao file ví dụ project/uploads/images/unique-filename.jpg
            String uploadPath = getUploadBaseDir(request) + File.separator + "images";
            //tạo nếu chưa tồn tại
            Files.createDirectories(Paths.get(uploadPath));

            // Generate unique filename
            String submitted = filePart.getSubmittedFileName();
            String originalFileName = submitted == null ? "" : Paths.get(submitted).getFileName().toString();
            String fileExtension = "";
            int dot = originalFileName.lastIndexOf('.');
            if (dot >= 0) {
                //lấy đuôi file để giữ nguyên định dạng khi lưu
                fileExtension = originalFileName.substring(dot);
            }
            String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

            // Save file
            Path filePath = Paths.get(uploadPath, uniqueFileName);
            //ghi file xuống disk
            filePart.write(filePath.toString());

            // Return relative path for storing in database
            return "/uploads/images/" + uniqueFileName;
        } catch (Exception e) {
            System.err.println("File upload ERROR: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    private String getUploadBaseDir(HttpServletRequest request) {
        // lấy config từ web.xml nếu có
        String configured = request.getServletContext().getInitParameter("uploadDir");
        if (configured != null && !configured.trim().isEmpty()) {
            String path = configured.trim();
            if (!new File(path).isAbsolute()) {
                File projectRoot = new File(System.getProperty("user.dir"));
                path = new File(projectRoot, path).getAbsolutePath();
            }
            return path;
        }
        //mặc định nếu ko có config
        return System.getProperty("user.dir") + File.separator + "uploads";
    }

    private void deletePhysicalFile(HttpServletRequest request, String imageUrl) {
        if (imageUrl == null || imageUrl.trim().isEmpty()) {
            return;
        }
        String normalized = imageUrl.trim().replace('\\', '/');
        if (!normalized.startsWith("/uploads/")) {
            return;
        }

        String relative = normalized.substring("/uploads/".length());
        if (relative.isEmpty()) {
            return;
        }

        try {
            Path uploadRoot = Paths.get(getUploadBaseDir(request)).toAbsolutePath().normalize();
            Path target = uploadRoot.resolve(relative).normalize();
            if (!target.startsWith(uploadRoot)) {
                return;
            }
            Files.deleteIfExists(target);
        } catch (IOException ex) {
            System.err.println("Delete file WARN: " + ex.getMessage());
        }
    }

    private boolean hasImageManagementAccess(User user) {
        if (user == null || user.getRole() == null || user.getRole().getRoleName() == null) {
            return false;
        }
        String normalizedRole = user.getRole().getRoleName()
                .trim()
                .toLowerCase()
                .replace("_", "")
                .replace(" ", "");

        return "admin".equals(normalizedRole)
                || "clinicowner".equals(normalizedRole)
                || "owner".equals(normalizedRole);
    }
}
