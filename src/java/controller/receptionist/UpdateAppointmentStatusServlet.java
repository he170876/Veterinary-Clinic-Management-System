package controller.receptionist;

import dao.AppointmentDAO;
import dao.VisitDAO;
import model.Appointment;
import model.User;
import model.Visit;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/Receptionist/UpdateAppointmentStatus")
public class UpdateAppointmentStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("currentUser") == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
                return;
            }
            User user = (User) session.getAttribute("currentUser");

            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String status = request.getParameter("status");
            
            AppointmentDAO dao = new AppointmentDAO();
            boolean success = dao.updateAppointmentStatus(appointmentId, status);
            
            if (success) {
                if (status != null && status.equalsIgnoreCase("Checked-in")) {
                    // Save real arrival time when receptionist checks in
                    dao.setArrivalTimeNow(appointmentId);

                    // Ensure Visits row exists so vet can load MedicalRecord + LabTestRequests
                    VisitDAO visitDao = new VisitDAO();
                    Visit existing = visitDao.getByAppointmentId(appointmentId);
                    if (existing == null) {
                        Appointment ap = dao.getAppointmentDetail(appointmentId);
                        if (ap == null
                                || ap.getPet() == null
                                || ap.getCustomer() == null
                                || ap.getVeterinarianId() == null
                                || ap.getVeterinarianId() <= 0) {
                            response.getWriter().write("{\"success\":false,\"message\":\"Missing appointment details to create visit.\"}");
                            return;
                        }

                        int receptionistId = dao.getReceptionistIdByUserId(user.getUserId());
                        if (receptionistId <= 0) {
                            response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized receptionist.\"}");
                            return;
                        }

                        Visit created = visitDao.createForCheckIn(
                                appointmentId,
                                ap.getPet().getPetId(),
                                ap.getCustomer().getCustomerId(),
                                ap.getVeterinarianId(),
                                receptionistId
                        );

                        if (created == null) {
                            response.getWriter().write("{\"success\":false,\"message\":\"Unable to create Visits row for this check-in.\"}");
                            return;
                        }
                    }
                }
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
