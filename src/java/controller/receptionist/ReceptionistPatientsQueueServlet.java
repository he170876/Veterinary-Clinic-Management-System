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

import java.io.IOException;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Arrived patients queue for receptionists at {@code /Receptionist/queue}.
 */
@WebServlet(name = "ReceptionistPatientsQueueServlet", urlPatterns = {"/Receptionist/queue"})
public class ReceptionistPatientsQueueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Receptionist queue shows appointments for TODAY and indicates whether they were checked-in already.
        //
        // Data shown includes:
        // - appointment basics (pet, owner, slot, service, status)
        // - whether a Visits row exists (used to show "Check-in" vs "Checked-in" state reliably)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO dao = new AppointmentDAO();
        VisitDAO visitDao = new VisitDAO();
        LocalDate today = LocalDate.now();
        // appointmentsForDate() returns the appointment list for the calendar day (schema-aware inside DAO).
        List<Appointment> appointments = dao.getAppointmentsForDate(today);
        // We batch-check which appointment IDs already have a Visits row to avoid querying per appointment.
        Set<Integer> appointmentIdsWithVisit = appointments.isEmpty() ? Collections.emptySet()
                : visitDao.getAppointmentIdsWithVisit(appointments.stream().map(Appointment::getAppointmentId).collect(Collectors.toSet()));

        request.setAttribute("user", user);
        request.setAttribute("appointments", appointments);
        request.setAttribute("appointmentIdsWithVisit", appointmentIdsWithVisit);
        request.setAttribute("queueDate", today);
        request.getRequestDispatcher("/WEB-INF/views/Receptionist/patients-queue.jsp").forward(request, response);
    }
}
