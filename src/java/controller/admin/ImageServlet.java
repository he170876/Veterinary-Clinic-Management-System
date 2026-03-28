package controller.admin;

import java.io.IOException;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
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

    /**
     * Xu ly POST:
     * - Kiem tra dang nhap va quyen truy cap.
     * - Chi cho phep upload o endpoint goc /owner/images.
     * - action mac dinh la create de tao anh moi.
     */
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
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    /**
     * Lay danh sach anh tu service, dua vao request scope va forward sang trang JSP.
     */
    private void listImages(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Image> images = imageService.getAllImagesOrderedBySort();
        request.setAttribute("images", images);
        request.getRequestDispatcher("/WEB-INF/views/admin/images.jsp").forward(request, response);
    }

    /**
     * Tao ban ghi anh moi:
     * - Nhan file tu form multipart.
     * - Kiem tra file hop le (MIME + phan mo rong).
     * - Luu file vao o dia.
     * - Tao doi tuong Image va luu DB.
     */
    private void createImage(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        // Bao toan bo logic de bat loi runtime/DB/file va tra HTTP 500 thay vi vo servlet.
        try {
            // Lay part file tu form multipart voi name="imageFile".
            Part filePart = request.getPart("imageFile");
            // Neu khong co file hoac file rong, tra ve 400 (yeu cau khong hop le).
            if (filePart == null || filePart.getSize() == 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "No image file provided");
                // Dung ham ngay sau khi da tra loi loi.
                return;
            }

            // Lay ten file goc nguoi dung upload (de check duoi mo rong).
            String fileName = filePart.getSubmittedFileName();
            // Lay MIME type browser/gui len (de check loai noi dung).
            String contentType = filePart.getContentType();
            // Chi cho phep anh jpg/png/gif/webp; neu sai thi tra 400.
            if (!isValidImageType(contentType, fileName)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file type. Only JPG, PNG, GIF, WebP allowed");
                // Ket thuc som neu file khong hop le.
                return;
            }

            // Luu file xuong o dia, nhan lai duong dan tuong doi de luu DB.
            String uploadedPath = saveUploadedFile(request, filePart);
            // Neu khong luu duoc file thi tra loi 500.
            if (uploadedPath == null) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to save file");
                // Dung ham vi khong the tiep tuc tao ban ghi anh.
                return;
            }

            // Tao object Image de map du lieu truoc khi ghi vao database.
            Image image = new Image();
            // Tieu de anh lay tu input title.
            image.setTitle(request.getParameter("title"));
            // URL anh su dung duong dan file da upload thanh cong.
            image.setUrl(uploadedPath);
            // Alt text phuc vu SEO va kha nang truy cap.
            image.setAltText(request.getParameter("altText"));
            // Section de phan loai anh theo khu vuc/noi dung su dung.
            image.setSection(request.getParameter("section"));
            // Gia tri sort mac dinh = 0 (co the sap xep lai sau).
            image.setSortOrder(0);

            // Goi service de insert ban ghi Image vao DB.
            Image created = imageService.createImage(image);
            // Neu tao thanh cong, dieu huong ve trang danh sach anh.
            if (created != null) {
                response.sendRedirect(request.getContextPath() + "/owner/images");
            } else {
                // Service tra null => xem nhu that bai luu DB.
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to create image");
            }
        } catch (Exception e) {
            // Ghi log chi tiet de debug tren server.
            System.err.println("CreateImage ERROR: " + e.getMessage());
            e.printStackTrace();
            // Tra loi loi 500 kem message hien tai.
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    /**
     * Kiem tra file anh hop le dua tren content-type va duoi ten file.
     * Chi chap nhan: jpg/jpeg/png/gif/webp.
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
     * Luu file upload vao thu muc uploads/images va tra ve duong dan tuong doi
     * de luu vao DB (dang /uploads/images/<file>). Tra ve null neu that bai.
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

    /**
     * Xac dinh thu muc goc de luu upload:
     * - Neu co cau hinh init-param uploadDir thi uu tien dung cau hinh.
     * - Neu uploadDir la duong dan tuong doi thi doi sang tuyet doi theo project root.
     * - Neu khong cau hinh thi mac dinh la <project>/uploads.
     */
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

    /**
     * Kiem tra nguoi dung co quyen quan ly anh hay khong.
     * Chap nhan cac role sau (sau khi chuan hoa): admin, clinicowner, owner.
     */
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
