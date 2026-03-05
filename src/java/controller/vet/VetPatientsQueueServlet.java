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
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO dao = new AppointmentDAO();
        LocalDate today = LocalDate.now();
        // Only show appointments assigned to this doctor (receptionist assigns vet per appointment)
        int veterinarianId = dao.getVeterinarianIdByUserId(user.getUserId());
        List<Appointment> appointments = dao.getAppointmentsForDateByVeterinarian(today, veterinarianId);

        request.setAttribute("user", user);
        NotificationDAO ndao = new NotificationDAO();
        request.setAttribute("notifications", ndao.getRecentForUser(user.getUserId(), 10));
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.setAttribute("appointments", appointments);
        request.setAttribute("queueDate", today);
        request.getRequestDispatcher("/WEB-INF/views/vet/patients-queue.jsp").forward(request, response);
    }
}
