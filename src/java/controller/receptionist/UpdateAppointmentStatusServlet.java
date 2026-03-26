package controller.receptionist;

import dao.AppointmentDAO;
import dao.NotificationDAO;
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
        // This endpoint is used by multiple receptionist screens to update an appointment's status
        // (Confirm/Reject/Cancel/Check-in/etc.). It returns JSON so the UI can toast + refresh.
        response.setContentType("application/json;charset=UTF-8");
        
        try {
            // 1) Authentication: must have a logged-in session user.
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("currentUser") == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
                return;
            }
            User user = (User) session.getAttribute("currentUser");

            // 2) Read parameters (appointmentId must be int).
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String status = request.getParameter("status");
            String reason = request.getParameter("reason");
            if (reason != null) {
                reason = reason.trim();
            }

            AppointmentDAO dao = new AppointmentDAO();
            // Capture the previous status BEFORE updating.
            // We use this to choose a correct notification title (e.g. Reschedule Confirmed vs Appointment Confirmed).
            Appointment beforeUpdate = dao.getAppointmentDetail(appointmentId);
            String previousStatus = beforeUpdate != null ? beforeUpdate.getStatus() : null;
            boolean success = dao.updateAppointmentStatus(appointmentId, status);
            
            if (success) {
                if (status != null && status.equalsIgnoreCase("Checked-in")) {
                    // Save real arrival time when receptionist checks in
                    boolean arrivalUpdated = dao.setArrivalTimeNow(appointmentId);

                    // Ensure Visits row exists so vet can load MedicalRecord + LabTestRequests
                    VisitDAO visitDao = new VisitDAO();
                    Visit existing = visitDao.getByAppointmentId(appointmentId);
                    if (existing == null) {
                        // We need pet/customer info to create a Visits row.
                        Appointment ap = dao.getAppointmentDetail(appointmentId);
                        if (ap == null
                                || ap.getPet() == null
                                || ap.getCustomer() == null) {
                            response.getWriter().write("{\"success\":false,\"message\":\"Missing appointment details to create visit.\"}");
                            return;
                        }

                        // Map current logged-in user → receptionist_id for staff_id FK.
                        int receptionistId = dao.getReceptionistIdByUserId(user.getUserId());
                        if (receptionistId <= 0) {
                            response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized receptionist.\"}");
                            return;
                        }

                        // Create the visit row at check-in time. This is required for vet examination flow.
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
                // Send customer notification for certain status transitions.
                notifyCustomerIfNeeded(appointmentId, status, reason, previousStatus, dao);
                response.getWriter().write("{\"success\": true, \"message\": \"Status updated successfully!\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Unable to update status\"}");
            }
        } catch (Exception e) {
            // Keep JSON response stable for the frontend.
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }

    private void notifyCustomerIfNeeded(int appointmentId, String status, String reason, String previousStatus, AppointmentDAO dao) {
        // Only a subset of status updates produce a customer-facing notification.
        // The notification "title" is used as the short header in the dropdown; message carries details.
        if (status == null || appointmentId <= 0) {
            return;
        }
        String s = status.trim();
        String title;
        if (s.equalsIgnoreCase("Confirmed")) {
            if (previousStatus != null && previousStatus.equalsIgnoreCase("Reschedule-Requested")) {
                title = "Reschedule Confirmed";
            } else {
                title = "Appointment Confirmed";
            }
        } else if (s.equalsIgnoreCase("Rejected")) {
            title = "Appointment Rejected";
        } else if (s.equalsIgnoreCase("Canceled") || s.equalsIgnoreCase("Cancelled")) {
            title = "Appointment Canceled";
        } else {
            return;
        }
        int userId = dao.getCustomerUserIdForAppointment(appointmentId);
        if (userId <= 0) {
            return;
        }
        String reasonText = (reason != null && !reason.isBlank()) ? reason.trim() : "No reason provided.";
        String message = "Appointment #" + appointmentId + ". Reason: " + reasonText;
        final int maxMsg = 255;
        if (message.length() > maxMsg) {
            message = message.substring(0, maxMsg - 3) + "...";
        }
        new NotificationDAO().create(userId, title, message);
    }
}
