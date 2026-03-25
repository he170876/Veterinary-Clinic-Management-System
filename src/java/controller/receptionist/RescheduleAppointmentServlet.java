package controller.receptionist;

import dao.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

@WebServlet("/Receptionist/RescheduleAppointment")
public class RescheduleAppointmentServlet extends HttpServlet {

    private static final int NOON_HOUR_24 = 12;
    private static final int EVENING_CUTOFF_HOUR_12 = 8;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String newDateStr = request.getParameter("newDate");
            String timeSlot = request.getParameter("timeSlot");

            if (newDateStr == null || newDateStr.isBlank() || timeSlot == null || timeSlot.isBlank()) {
                writeJson(response, false, "Date and time slot are required.");
                return;
            }

            LocalDate newDate;
            try {
                newDate = LocalDate.parse(newDateStr);
            } catch (DateTimeParseException e) {
                writeJson(response, false, "Invalid date format.");
                return;
            }

            String validationError = validateRescheduleSlot(newDate, timeSlot);
            if (validationError != null) {
                writeJson(response, false, validationError);
                return;
            }

            AppointmentDAO dao = new AppointmentDAO();
            boolean success = dao.rescheduleAppointment(appointmentId, newDate, timeSlot);

            if (success) {
                writeJson(response, true, "Appointment rescheduled successfully.");
            } else {
                writeJson(response, false, "Unable to reschedule appointment.");
            }
        } catch (NumberFormatException e) {
            writeJson(response, false, "Invalid appointment id.");
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, false, "An error occurred.");
        }
    }

    /** Same rules as receptionist book modal: same-day AM disabled after noon; PM after 8 PM. */
    static String validateRescheduleSlot(LocalDate date, String timeSlot) {
        if (timeSlot == null) {
            return "Time slot is required.";
        }
        String slot = timeSlot.trim();
        if (!"AM".equalsIgnoreCase(slot) && !"PM".equalsIgnoreCase(slot)) {
            return "Time slot must be AM or PM.";
        }
        LocalDate today = LocalDate.now();
        if (date.isBefore(today)) {
            return "Date must be today or a future date.";
        }
        if (date.equals(today)) {
            LocalTime now = LocalTime.now();
            int currentTotalMinutes = now.getHour() * 60 + now.getMinute();
            int noonTotalMinutes = NOON_HOUR_24 * 60;
            int eveningCutoffHour24 = NOON_HOUR_24 + EVENING_CUTOFF_HOUR_12;
            int cutoffTotalMinutes = eveningCutoffHour24 * 60;
            boolean isAm = slot.equalsIgnoreCase("AM");
            if (isAm && currentTotalMinutes > noonTotalMinutes) {
                return "The morning slot is no longer available today. Choose another date or PM.";
            }
            if (!isAm && currentTotalMinutes > cutoffTotalMinutes) {
                return "The afternoon slot is no longer available today. Choose another date.";
            }
        }
        return null;
    }

    private static void writeJson(HttpServletResponse response, boolean success, String message) throws IOException {
        String safe = message == null ? "" : message.replace("\\", "\\\\").replace("\"", "\\\"");
        response.getWriter().write("{\"success\": " + success + ", \"message\": \"" + safe + "\"}");
    }
}
