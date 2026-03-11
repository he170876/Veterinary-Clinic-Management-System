package controller.receptionist;

import dao.AppointmentDAO;
import dao.NotificationDAO;
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
                response.getWriter().write("{\"success\": false, \"message\": \"Missing request data\"}");
                return;
            }

            boolean approve = "approve".equalsIgnoreCase(decision);
            AppointmentDAO dao = new AppointmentDAO();
            boolean success;

            if ("reschedule".equalsIgnoreCase(requestType)) {
                success = dao.processRescheduleRequest(appointmentId, approve);
            } else if ("doctor-change".equalsIgnoreCase(requestType)) {
                Integer veterinarianId = null;
                String vetIdRaw = request.getParameter("veterinarianId");
                if (vetIdRaw != null && !vetIdRaw.isBlank()) {
                    try {
                        veterinarianId = Integer.parseInt(vetIdRaw);
                    } catch (Exception ignore) {
                        veterinarianId = null;
                    }
                }

                success = dao.processDoctorChangeRequest(appointmentId, approve, veterinarianId);

                // After approval, send notification to the assigned veterinarian
                if (success && approve) {
                    int assignedVetId = dao.getVeterinarianIdByAppointmentId(appointmentId);
                    if (assignedVetId > 0) {
                        int vetUserId = dao.getUserIdByVeterinarianId(assignedVetId);
                        if (vetUserId > 0) {
                            NotificationDAO ndao = new NotificationDAO();
                            ndao.create(vetUserId, "Appointment assigned", "You have been assigned to appointment #" + appointmentId + ".");
                        }
                    }
                }
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid request type\"}");
                return;
            }

            if (success) {
                String actionMessage = approve ? "Request approved successfully" : "Request rejected successfully";
                response.getWriter().write("{\"success\": true, \"message\": \"" + actionMessage + "\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Unable to process the request\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
}
