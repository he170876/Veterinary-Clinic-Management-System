package controller.lab;

import dao.AppointmentDAO;
import dao.LabTestRequestDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.User;
import utils.LabResultImageUploadUtil;
import utils.ProfilePictureUploadUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Lab technician submits: <b>PDF bắt buộc</b> + <b>ghi chú text bắt buộc</b> (multipart).
 */
@MultipartConfig(
        fileSizeThreshold = 512 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 12 * 1024 * 1024
)
@WebServlet(name = "LabUploadResultServlet", urlPatterns = {"/lab/result"})
public class LabUploadResultServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();
        String q = request.getParameter("q");
        String page = request.getParameter("page");
        String keepParams = "";
        if (q != null && !q.trim().isEmpty()) {
            keepParams += "&q=" + URLEncoder.encode(q.trim(), StandardCharsets.UTF_8);
        }
        if (page != null && !page.trim().isEmpty()) {
            keepParams += "&page=" + URLEncoder.encode(page.trim(), StandardCharsets.UTF_8);
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        String requestIdParam = request.getParameter("requestId");
        if (requestIdParam == null || requestIdParam.isEmpty()) {
            redirectError(response, ctx, "Missing request ID.", keepParams);
            return;
        }

        int requestId;
        try {
            requestId = Integer.parseInt(requestIdParam);
        } catch (NumberFormatException e) {
            redirectError(response, ctx, "Invalid request ID.", keepParams);
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        LabTestRequestDAO dao = new LabTestRequestDAO();
        int labStaffId = dao.getLabStaffIdByUserId(user.getUserId());
        if (labStaffId <= 0) {
            redirectError(response, ctx, "Access denied (not LabStaff).", keepParams);
            return;
        }

        String resultNote = request.getParameter("resultNote");
        if (resultNote != null) {
            resultNote = resultNote.trim();
        } else {
            resultNote = "";
        }

        Part labPdfPart = null;
        try {
            labPdfPart = request.getPart("labPdf");
        } catch (Exception ignored) {
        }

        if (resultNote.isEmpty()) {
            redirectError(response, ctx, "Text note is required.", keepParams);
            return;
        }
        if (!ProfilePictureUploadUtil.hasNonEmptyFilePayload(labPdfPart, request)) {
            redirectError(response, ctx, "Lab result PDF is required.", keepParams);
            return;
        }

        String savedPath = LabResultImageUploadUtil.trySaveLabResultPdf(request, labPdfPart, requestId);
        if (savedPath == null || savedPath.isEmpty()) {
            redirectError(response, ctx, "Could not save file. Only PDF is allowed.", keepParams);
            return;
        }

        String resultValue = "-";
        boolean ok = dao.saveResult(requestId, resultValue, resultNote, savedPath, labStaffId);

        model.LabTestRequest req = null;
        try {
            req = dao.getById(requestId);
        } catch (Exception ignored) {
        }

        String testName = (req != null && req.getTestName() != null) ? req.getTestName() : "Lab test";
        String petName = (req != null && req.getPetName() != null) ? req.getPetName() : null;
        String patientLabel = petName != null && !petName.trim().isEmpty() ? (" for " + petName.trim()) : "";

        NotificationDAO ndao = new NotificationDAO();
        if (ok) {
            ndao.create(
                    user.getUserId(),
                    "Upload successful",
                    "You uploaded the " + testName + " report" + patientLabel + "."
            );

            try {
                if (req != null && req.getVeterinarianId() > 0) {
                    AppointmentDAO appDao = new AppointmentDAO();
                    int vetUserId = appDao.getUserIdByVeterinarianId(req.getVeterinarianId());
                    if (vetUserId > 0) {
                        String vetMsg = "The " + testName + " result is ready"
                                + (petName != null && !petName.trim().isEmpty()
                                ? " for " + petName.trim() + "." : ".")
                                + " Open the examination screen to review.";
                        ndao.create(
                                vetUserId,
                                "Lab result ready",
                                vetMsg
                        );
                    }
                }
            } catch (Exception ignored) {
            }

            response.sendRedirect(ctx + "/lab/labqueue?upload=1" + keepParams);
            return;
        } else {
            ndao.create(
                    user.getUserId(),
                    "Upload failed",
                    "Could not submit the " + testName + " result. Please try again."
            );
            redirectError(response, ctx, "Upload failed. Please try again.", keepParams);
        }
    }

    private void redirectError(HttpServletResponse response, String ctx, String message, String keepParams)
            throws IOException {
        response.sendRedirect(ctx + "/lab/labqueue?uploadError=" + URLEncoder.encode(message, StandardCharsets.UTF_8) + keepParams);
    }
}
