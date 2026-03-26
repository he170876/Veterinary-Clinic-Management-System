package controller.vet;

import dao.AppointmentDAO;
import dao.NotificationDAO;
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
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Arrived Patients Queue for the veterinarian (doctor). Shows today's appointments
 * so the doctor can view the queue and start examinations. Role access enforced by RoleBasedAccessFilter.
 */
@WebServlet(name = "VetPatientsQueueServlet", urlPatterns = {"/vet/queue"})
public class VetPatientsQueueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Vet queue page controller.
        //
        // Responsibilities:
        // - ensure the user is authenticated (session currentUser)
        // - compute current veterinarianId from currentUser.userId
        // - load the shared queue model for TODAY:
        //   - Checked-in appointments (actionable)
        //   - In-Examination appointments (including resumable by current vet, plus read-only for other vets)
        // - compute a boolean flag used by UI to prevent starting a second exam in parallel
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO dao = new AppointmentDAO();
        LocalDate today = LocalDate.now();
        // Map logged-in user → veterinarian_id (FK on appointments.veterinarian_id).
        int currentVetId = dao.getVeterinarianIdByUserId(user.getUserId());
        // Shared queue model: see AppointmentDAO.getVetQueueAppointmentsForDate() for the exact rules.
        List<Appointment> appointments = dao.getVetQueueAppointmentsForDate(today, currentVetId);
        // Used in the UI to block "Start Examination" if the vet already has an In-Examination case.
        // Note: This is a UI guard only. Server-side still enforces the rule in VetExaminationServlet/AppointmentDAO.
        boolean vetHasActiveExamination = currentVetId > 0 && dao.hasActiveInExamination(currentVetId);

        request.setAttribute("user", user);
        NotificationDAO ndao = new NotificationDAO();
        request.setAttribute("notifications", ndao.getRecentForUser(user.getUserId(), 10));
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.setAttribute("appointments", appointments);
        request.setAttribute("vetHasActiveExamination", vetHasActiveExamination);
        request.setAttribute("currentVetId", currentVetId);
        request.setAttribute("queueDate", today);
        request.getRequestDispatcher("/WEB-INF/views/vet/patients-queue.jsp").forward(request, response);
    }
}
