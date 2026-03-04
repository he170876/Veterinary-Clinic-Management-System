package controller.receptionist;

import dao.AppointmentDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/Receptionist/UpdateAppointmentDoctor")
public class UpdateAppointmentDoctorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            int veterinarianId = Integer.parseInt(request.getParameter("veterinarianId"));
            
            AppointmentDAO dao = new AppointmentDAO();
            boolean success = dao.updateAppointmentDoctor(appointmentId, veterinarianId);
            
            if (success) {
                // Notify assigned veterinarian (system notification)
                int vetUserId = dao.getUserIdByVeterinarianId(veterinarianId);
                if (vetUserId > 0) {
                    NotificationDAO ndao = new NotificationDAO();
                    ndao.create(
                            vetUserId,
                            "Appointment assigned",
                            "You have been assigned to appointment #" + appointmentId + "."
                    );
                }
                response.getWriter().write("{\"success\": true, \"message\": \"Đổi bác sỹ thành công!\"}");
            }else {
                response.getWriter().write("{\"success\": false, \"message\": \"Không thể đổi bác sỹ\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
