package controller.admin;

import java.io.IOException;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
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
import model.Role;
import service.ImageService;
import service.impl.ImageServiceImpl;

/**
 * Servlet handling CRUD operations for Images with file upload support.
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

        // Check admin or clinic owner role (case-insensitive)
        User currentUser = (User) session.getAttribute("currentUser");
        String roleName = currentUser.getRole() != null && currentUser.getRole().getRoleName() != null
                ? currentUser.getRole().getRoleName().trim().toLowerCase() : "";
        if (!(roleName.equals("admin") || roleName.equals("clinicowner"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            listImages(request, response);
        } 
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Check admin role
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser.getRole() == null || !"admin".equalsIgnoreCase(currentUser.getRole().getRoleName())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo != null && pathInfo.startsWith("/delete/")) {
            try {
                long id = Long.parseLong(pathInfo.substring(8));
                deleteImage(request, response, id);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid image ID");
            }
            return;
        }

        String action = request.getParameter("action");
        if ("create".equals(action)) {
            createImage(request, response);
        } else if ("update".equals(action)) {
            updateImage(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    private void listImages(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Image> images = imageService.getAllImagesOrderedBySort();
        
        // Group images by section
        Map<String, List<Image>> imagesBySection = new LinkedHashMap<>();
        if (images != null) {
            for (Image img : images) {
                String section = img.getSection();
                if (section == null || section.trim().isEmpty()) {
                    section = "Uncategorized";
                } else {
                    // Capitalize first letter for display
                    section = section.substring(0, 1).toUpperCase() + section.substring(1).toLowerCase();
                }
                imagesBySection.computeIfAbsent(section, k -> new ArrayList<>()).add(img);
            }
        }
        
        request.setAttribute("images", images); // Keep for total count
        request.setAttribute("imagesBySection", imagesBySection); // For grouped display
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

            // Parse sort order
            String sortStr = request.getParameter("sortOrder");
            try {
                int sortOrder = sortStr != null && !sortStr.isEmpty() ? Integer.parseInt(sortStr) : 0;
                image.setSortOrder(sortOrder);
            } catch (NumberFormatException e) {
                image.setSortOrder(0);
            }

            Image created = imageService.createImage(image);
            if (created != null) {
                response.sendRedirect(request.getContextPath() + "/admin/images");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to create image");
            }
        } catch (Exception e) {
            System.err.println("CreateImage ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void updateImage(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        try {
            String idStr = request.getParameter("imageId");
            if (idStr == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Image ID required");
                return;
            }

            long id = Long.parseLong(idStr);
            Image image = imageService.getImageById(id).orElse(null);
            if (image == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
                return;
            }

            image.setTitle(request.getParameter("title"));
            image.setAltText(request.getParameter("altText"));
            image.setSection(request.getParameter("section"));

            // Check if new file is uploaded
            Part filePart = request.getPart("imageFile");
            if (filePart != null && filePart.getSize() > 0) {
                // Validate file type
                String fileName = filePart.getSubmittedFileName();
                String contentType = filePart.getContentType();
                if (!isValidImageType(contentType, fileName)) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file type. Only JPG, PNG, GIF, WebP allowed");
                    return;
                }

                // Save new file
                String uploadedPath = saveUploadedFile(request, filePart);
                if (uploadedPath == null) {
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to save file");
                    return;
                }
                image.setUrl(uploadedPath);
            }

            // Parse sort order
            String sortStr = request.getParameter("sortOrder");
            try {
                int sortOrder = sortStr != null && !sortStr.isEmpty() ? Integer.parseInt(sortStr) : 0;
                image.setSortOrder(sortOrder);
            } catch (NumberFormatException e) {
                image.setSortOrder(0);
            }

            if (imageService.updateImage(image)) {
                response.sendRedirect(request.getContextPath() + "/admin/images");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to update image");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID format");
        } catch (Exception e) {
            System.err.println("UpdateImage ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void deleteImage(HttpServletRequest request, HttpServletResponse response, long id)
            throws IOException {
        try {
            if (imageService.deleteImage(id)) {
                response.sendRedirect(request.getContextPath() + "/admin/images");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found or already deleted");
            }
        } catch (Exception e) {
            System.err.println("DeleteImage ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
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
            String uploadPath = getUploadBaseDir(request) + File.separator + "images";
            Files.createDirectories(Paths.get(uploadPath));

            // Generate unique filename
            String submitted = filePart.getSubmittedFileName();
            String originalFileName = submitted == null ? "" : Paths.get(submitted).getFileName().toString();
            String fileExtension = "";
            int dot = originalFileName.lastIndexOf('.');
            if (dot >= 0) {
                fileExtension = originalFileName.substring(dot);
            }
            String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

            // Save file
            Path filePath = Paths.get(uploadPath, uniqueFileName);
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
        String configured = request.getServletContext().getInitParameter("uploadDir");
        if (configured != null && !configured.trim().isEmpty()) {
            String path = configured.trim();
            if (!new File(path).isAbsolute()) {
                File projectRoot = new File(System.getProperty("user.dir"));
                path = new File(projectRoot, path).getAbsolutePath();
            }
            return path;
        }

        return System.getProperty("user.dir") + File.separator + "uploads";
    }
}
