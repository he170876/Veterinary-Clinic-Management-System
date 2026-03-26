package controller.receptionist;

import dao.AppointmentDAO;
import dao.NotificationDAO;
import dao.ServiceDAO;
import dao.impl.ServiceJdbcDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import model.Appointment;
import model.User;

@WebServlet("/Receptionist/Dashboard")
public class ReceptionistDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Receptionist dashboard shows today's high-level stats + recent appointment list.
        // It also provides entry points to modals (Book Appointment, Emergency Appointment, Invoice view).
        AppointmentDAO dao = new AppointmentDAO();
        
        // Get today's date range (only today)
        LocalDate today = LocalDate.now();
        LocalDate fromDate = today;
        LocalDate toDate = today;
        
        final LocalDate rangeStart = fromDate;
        final LocalDate rangeEnd = toDate;
        
        // Load all appointments, then filter to today for dashboard counters.
        List<Appointment> allAppointments = dao.getAllAppointments();
        
        List<Appointment> todayAppointments = allAppointments.stream()
                .filter(a -> a.getAppointmentTime() != null)
                .filter(a -> {
                    LocalDate d = a.getAppointmentTime().toLocalDate();
                    if (rangeStart != null && d.isBefore(rangeStart)) return false;
                    if (rangeEnd != null && d.isAfter(rangeEnd)) return false;
                    return true;
                })
                .collect(java.util.stream.Collectors.toList());
        
        // Count statistics:
        // - Total includes everything within today's range
        // - "Normal" vs "Emergency" depends on the appointment type/status fields used by DAO
        //   (this code currently checks status string; keep consistent with existing UI logic).
        // Total = all appointments today
        int totalAppointments = todayAppointments.size();
        
        // Normal = non-Emergency appointments
        int normalAppointments = (int) todayAppointments.stream()
                .filter(a -> {
                    String status = a.getStatus();
                    return status != null && !status.equalsIgnoreCase("Emergency");
                })
                .count();
        
        // Emergency = only Emergency status
        int emergencyCases = (int) todayAppointments.stream()
                .filter(a -> {
                    String status = a.getStatus();
                    return status != null && status.equalsIgnoreCase("Emergency");
                })
                .count();
        
        // Active emergency = Emergency status
        int emergencyActive = emergencyCases;
        int emergencyResolved = 0;
        
        // Sort by appointment time so the "recent appointments" table is chronological.
        todayAppointments.sort(java.util.Comparator.comparing(Appointment::getAppointmentTime));
        List<Appointment> recentAppointments = todayAppointments;
        
        List<User> veterinarians = dao.getAllVeterinarians();
        
        request.setAttribute("totalAppointments", totalAppointments);
        request.setAttribute("normalAppointments", normalAppointments);
        request.setAttribute("emergencyCases", emergencyCases);
        request.setAttribute("emergencyActive", emergencyActive);
        request.setAttribute("emergencyResolved", emergencyResolved);
        request.setAttribute("recentAppointments", recentAppointments);
        request.setAttribute("veterinarians", veterinarians);
        ServiceDAO serviceDAO = new ServiceJdbcDAO();
        request.setAttribute("services", serviceDAO.findAll());

        // Notifications for header dropdown (if session exists).
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session != null) {
            Object currentUserObj = session.getAttribute("currentUser");
            if (currentUserObj instanceof User) {
                User currentUser = (User) currentUserObj;
                NotificationDAO ndao = new NotificationDAO();
                request.setAttribute("notifications", ndao.getRecentForUser(currentUser.getUserId(), 10));
                request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
            }
        }
        
        request.getRequestDispatcher("/WEB-INF/views/Receptionist/dashboard.jsp")
                .forward(request, response);
    }
}
