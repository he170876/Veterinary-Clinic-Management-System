package controller.receptionist;

import dao.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Time;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/Receptionist/RescheduleAppointment")
public class RescheduleAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String newDate = request.getParameter("newDate");
            String newTime = request.getParameter("newTime");
            
            if (newDate == null || newTime == null || newDate.isEmpty() || newTime.isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"Date and time are required\"}");
                return;
            }
            
            // Parse date and time
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
            
            java.util.Date parsedDate = dateFormat.parse(newDate);
            Time parsedTime = new Time(timeFormat.parse(newTime).getTime());
            
            AppointmentDAO dao = new AppointmentDAO();
            boolean success = dao.rescheduleAppointment(appointmentId, parsedDate, parsedTime);
            
            if (success) {
                response.getWriter().write("{\"success\": true, \"message\": \"Appointment rescheduled successfully!\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Unable to reschedule appointment\"}");
            }
        } catch (ParseException e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Invalid date/time format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
}
