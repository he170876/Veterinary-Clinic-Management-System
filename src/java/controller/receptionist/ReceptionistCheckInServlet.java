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
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO appDao = new AppointmentDAO();
        int receptionistId = appDao.getReceptionistIdByUserId(user.getUserId());
        if (receptionistId <= 0) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?error=notreceptionist");
            return;
        }

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

        Appointment ap = appDao.getAppointmentDetail(appointmentId);
        if (ap == null || ap.getPet() == null || ap.getCustomer() == null) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?error=notfound");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit existing = visitDao.getByAppointmentId(appointmentId);
        if (existing != null) {
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?already=1");
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
            response.sendRedirect(request.getContextPath() + QUEUE_URL + "?error=create");
            return;
        }

        appDao.updateAppointmentStatus(appointmentId, "Checked-in");
        response.sendRedirect(request.getContextPath() + QUEUE_URL + "?checkedin=1");
    }
}
