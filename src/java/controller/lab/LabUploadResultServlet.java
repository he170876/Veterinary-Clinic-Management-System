package controller.lab;

import dao.LabTestRequestDAO;
import dao.NotificationDAO;
import dao.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Lab result submission:
 * <ul>
 *   <li>Được gọi từ form bên phải trên màn <code>/lab/labqueue</code> khi kỹ thuật viên nhấn
 *       “Submit Result to Doctor”.</li>
 *   <li>Xác thực user là LabStaff, map sang <code>lab_staff_id</code> qua
 *       {@link LabTestRequestDAO#getLabStaffIdByUserId(int)}.</li>
 *   <li>Ghép <code>resultValue</code>, <code>resultNote</code> và <code>techNotes</code> thành một
 *       chuỗi note duy nhất (thêm prefix "[Tech notes]" cho phần nội bộ).</li>
 *   <li>Gọi {@link LabTestRequestDAO#saveResult(int, String, String, int)} để:
 *     <ul>
 *       <li>Insert bản ghi vào bảng <code>LabTestResults</code>.</li>
 *       <li>Đổi trạng thái <code>LabTestRequests.status</code> sang <code>Completed</code>.</li>
 *     </ul>
 *   </li>
 *   <li>Cuối cùng redirect về <code>/lab/labqueue</code> để thấy request biến mất khỏi hàng đợi
 *       và xuất hiện ở các màn vet (status Completed).</li>
 * </ul>
 */
@WebServlet(name = "LabUploadResultServlet", urlPatterns = {"/lab/result"})
public class LabUploadResultServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
            response.sendRedirect(ctx + "/lab/labqueue?uploadError=" + URLEncoder.encode("Missing request ID.", StandardCharsets.UTF_8) + keepParams);
            return;
        }

        int requestId;
        try {
            requestId = Integer.parseInt(requestIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/lab/labqueue?uploadError=" + URLEncoder.encode("Invalid request ID.", StandardCharsets.UTF_8) + keepParams);
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        LabTestRequestDAO dao = new LabTestRequestDAO();
        int labStaffId = dao.getLabStaffIdByUserId(user.getUserId());
        if (labStaffId <= 0) {
            response.sendRedirect(ctx + "/lab/labqueue?uploadError=" + URLEncoder.encode("Access denied (not LabStaff).", StandardCharsets.UTF_8) + keepParams);
            return;
        }

        String resultValue = request.getParameter("resultValue");
        String resultNote = request.getParameter("resultNote");
        String techNotes = request.getParameter("techNotes");
        if (resultValue == null) resultValue = "";
        if (resultNote == null) resultNote = "";
        if (techNotes != null && !techNotes.isEmpty()) {
            resultNote = resultNote.isEmpty() ? techNotes : resultNote + "\n[Tech notes] " + techNotes;
        }

        boolean ok = dao.saveResult(requestId, resultValue, resultNote, labStaffId);

        // Notify veterinarian that lab result is completed
        model.LabTestRequest req = null;
        try { req = dao.getById(requestId); } catch (Exception ignored) {}

        String testName = (req != null && req.getTestName() != null) ? req.getTestName() : "Lab test";
        String petName = (req != null && req.getPetName() != null) ? req.getPetName() : null;
        String patientLabel = petName != null && !petName.trim().isEmpty() ? (" for " + petName.trim()) : "";

        NotificationDAO ndao = new NotificationDAO();
        if (ok) {
            // Notify current lab user
            ndao.create(
                    user.getUserId(),
                    "Upload successful",
                    testName + " result" + patientLabel + " was submitted (Request #" + requestId + ")."
            );

            // Notify veterinarian that lab result is completed
            try {
                if (req != null && req.getVeterinarianId() > 0) {
                    AppointmentDAO appDao = new AppointmentDAO();
                    int vetUserId = appDao.getUserIdByVeterinarianId(req.getVeterinarianId());
                    if (vetUserId > 0) {
                        ndao.create(
                                vetUserId,
                                "Lab result completed",
                                testName + " result has been uploaded for request #" + requestId + "."
                        );
                    }
                }
            } catch (Exception ignored) {}

            response.sendRedirect(ctx + "/lab/labqueue?upload=1" + keepParams);
            return;
        } else {
            ndao.create(
                    user.getUserId(),
                    "Upload failed",
                    "Could not submit " + testName + " result (Request #" + requestId + "). Please try again."
            );
            response.sendRedirect(ctx + "/lab/labqueue?uploadError=" + URLEncoder.encode("Upload failed. Please try again.", StandardCharsets.UTF_8) + keepParams);
        }
    }
}
