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

import java.io.IOException;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Serves the Arrived Patients Queue at /staff/queue.
 * Shows today's appointments for receptionist/staff. Role access enforced by RoleBasedAccessFilter.
 */
@WebServlet(name = "StaffPatientsQueueServlet", urlPatterns = {"/staff/queue"})
public class StaffPatientsQueueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO dao = new AppointmentDAO();
        VisitDAO visitDao = new VisitDAO();
        LocalDate today = LocalDate.now();
        List<Appointment> appointments = dao.getAppointmentsForDate(today);
        Set<Integer> appointmentIdsWithVisit = appointments.isEmpty() ? Collections.emptySet()
                : visitDao.getAppointmentIdsWithVisit(appointments.stream().map(Appointment::getAppointmentId).collect(Collectors.toSet()));

        request.setAttribute("user", user);
        request.setAttribute("appointments", appointments);
        request.setAttribute("appointmentIdsWithVisit", appointmentIdsWithVisit);
        request.setAttribute("queueDate", today);
        request.getRequestDispatcher("/WEB-INF/views/staff/patients-queue.jsp").forward(request, response);
    }
}
