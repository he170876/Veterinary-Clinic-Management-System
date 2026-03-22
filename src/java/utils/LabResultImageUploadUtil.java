package utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

/**
 * Lưu ảnh kết quả xét nghiệm dưới {@code /uploads/lab-results/}.
 */
public final class LabResultImageUploadUtil {

    private LabResultImageUploadUtil() {
    }

    /**
     * @return đường dẫn web bắt đầu bằng {@code /uploads/lab-results/...} hoặc null nếu lỗi
     */
    public static String trySaveLabResultImage(HttpServletRequest request, Part part, int labRequestId) {
        if (!ProfilePictureUploadUtil.hasNonEmptyFilePayload(part, request)) {
            return null;
        }
        String ext = ProfilePictureUploadUtil.resolveImageExtension(part.getContentType(), part.getSubmittedFileName());
        if (ext == null) {
            return null;
        }
        Path baseDir = ProfilePictureUploadUtil.webappRootDirectory(request);
        if (baseDir == null) {
            return null;
        }
        String fileName = "lab-" + labRequestId + "-" + System.currentTimeMillis() + "." + ext;
        String relativePath = "/uploads/lab-results/" + fileName;
        Path uploadDir = baseDir.resolve("uploads").resolve("lab-results");
        try {
            Files.createDirectories(uploadDir);
            Path targetFile = uploadDir.resolve(fileName);
            try (InputStream in = part.getInputStream()) {
                Files.copy(in, targetFile, StandardCopyOption.REPLACE_EXISTING);
            }
            return relativePath;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
