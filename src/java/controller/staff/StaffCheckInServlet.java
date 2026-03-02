package controller.staff;

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
 * POST: Receptionist checks in a patient. Creates Visit with staff_id and sets appointment status to Checked-in.
 * Requires appointmentId. Redirects to /staff/queue with checkedin=1, already=1, or error params.
 */
@WebServlet(name = "StaffCheckInServlet", urlPatterns = {"/staff/check-in"})
public class StaffCheckInServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO appDao = new AppointmentDAO();
        int receptionistId = appDao.getReceptionistIdByUserId(user.getUserId());
        if (receptionistId <= 0) {
            response.sendRedirect(request.getContextPath() + "/staff/queue?error=notstaff");
            return;
        }

        String idParam = request.getParameter("appointmentId");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/queue?error=missing");
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/staff/queue?error=invalid");
            return;
        }

        Appointment ap = appDao.getAppointmentDetail(appointmentId);
        if (ap == null) {
            response.sendRedirect(request.getContextPath() + "/staff/queue?error=notfound");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit existing = visitDao.getByAppointmentId(appointmentId);
        if (existing != null) {
            response.sendRedirect(request.getContextPath() + "/staff/queue?already=1");
            return;
        }

        Visit visit = visitDao.createForCheckIn(
                appointmentId,
                ap.getPet().getPetId(),
                ap.getCustomer().getCustomerId(),
                ap.getVeterinarianId(),
                receptionistId
        );
        if (visit == null) {
            response.sendRedirect(request.getContextPath() + "/staff/queue?error=create");
            return;
        }

        appDao.updateAppointmentStatus(appointmentId, "Checked-in");
        response.sendRedirect(request.getContextPath() + "/staff/queue?checkedin=1");
    }
}
