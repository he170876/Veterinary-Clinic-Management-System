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
