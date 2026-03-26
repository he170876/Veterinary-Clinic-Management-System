package controller.receptionist;

import dao.AppointmentDAO;
import dao.VisitDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Appointment;
import model.User;
import model.Visit;

import java.io.IOException;

/**
 * Receptionist check-in flow (POST {@code /Receptionist/check-in}).
 */
@WebServlet(name = "ReceptionistCheckInServlet", urlPatterns = {"/Receptionist/check-in"})
public class ReceptionistCheckInServlet extends HttpServlet {

    private static final String QUEUE_URL = "/Receptionist/queue";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // This endpoint is used on the receptionist queue page ("Arrived patients queue").
        //
        // Purpose:
        // - create a Visits row (so vets can attach MedicalRecord/Lab requests)
        // - transition appointment status → "Checked-in"
        //
        // Notes:
        // - This is NOT the same as receptionist "booking" (which creates a Pending appointment).
        // - A check-in happens when the patient arrives physically.
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO appDao = new AppointmentDAO();
        // Map logged-in user → receptionist_id (FK used in Visits.staff_id).
        int receptionistId = appDao.getReceptionistIdByUserId(user.getUserId());
        if (receptionistId <= 0) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?error=notreceptionist");
            return;
        }

        // Read appointmentId from form/button.
        String idParam = request.getParameter("appointmentId");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?error=missing");
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?error=invalid");
            return;
        }

        // Load appointment detail so we can populate Visits row.
        Appointment ap = appDao.getAppointmentDetail(appointmentId);
        if (ap == null || ap.getPet() == null || ap.getCustomer() == null) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?error=notfound");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        // Avoid duplicate Visits rows (one visit per appointment).
        Visit existing = visitDao.getByAppointmentId(appointmentId);
        if (existing != null) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?already=1");
            return;
        }

        // Create visit row at the moment of check-in.
        Visit visit = visitDao.createForCheckIn(
                appointmentId,
                ap.getPet().getPetId(),
                ap.getCustomer().getCustomerId(),
                ap.getVeterinarianId(),
                receptionistId
        );
        if (visit == null) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?error=create");
            return;
        }

        // Update appointment status after the visit exists (so vet pages won't see "Checked-in" without a visit).
        appDao.updateAppointmentStatus(appointmentId, "Checked-in");
        appDao.setArrivalTimeNow(appointmentId);
        response.sendRedirect(request.getContextPath() + QUEUE_URL + "?checkedin=1");
    }
}
