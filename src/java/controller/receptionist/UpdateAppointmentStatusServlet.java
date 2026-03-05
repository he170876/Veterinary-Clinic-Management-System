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
                response.getWriter().write("{\"success\": true, \"message\": \"Status updated successfully!\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Unable to update status\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
}
