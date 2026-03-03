package controller.receptionist;

import dao.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/Receptionist/HandleAppointmentRequest")
public class HandleAppointmentRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String requestType = request.getParameter("requestType");
            String decision = request.getParameter("decision");

            if (requestType == null || requestType.isBlank() || decision == null || decision.isBlank()) {
                response.getWriter().write("{\"success\": false, \"message\": \"Thiếu dữ liệu yêu cầu\"}");
                return;
            }

            boolean approve = "approve".equalsIgnoreCase(decision);
            AppointmentDAO dao = new AppointmentDAO();
            boolean success;

            if ("reschedule".equalsIgnoreCase(requestType)) {
                success = dao.processRescheduleRequest(appointmentId, approve);
            } else if ("doctor-change".equalsIgnoreCase(requestType)) {
                success = dao.processDoctorChangeRequest(appointmentId, approve);
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Loại yêu cầu không hợp lệ\"}");
                return;
            }

            if (success) {
                String action = approve ? "duyệt" : "từ chối";
                response.getWriter().write("{\"success\": true, \"message\": \"Đã " + action + " yêu cầu thành công\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Không thể xử lý yêu cầu\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
