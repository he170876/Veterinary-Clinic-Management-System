package controller.receptionist;

import dao.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/Receptionist/UpdateAppointmentStatus")
public class UpdateAppointmentStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String status = request.getParameter("status");
            
            AppointmentDAO dao = new AppointmentDAO();
            boolean success = dao.updateAppointmentStatus(appointmentId, status);
            
            if (success) {
                response.getWriter().write("{\"success\": true, \"message\": \"Cập nhật trạng thái thành công!\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Không thể cập nhật trạng thái\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
