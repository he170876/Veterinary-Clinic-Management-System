package controller.receptionist;

import dao.AppointmentDAO;
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
        
        AppointmentDAO dao = new AppointmentDAO();
        
        // Get today's date range (only today)
        LocalDate today = LocalDate.now();
        LocalDate fromDate = today;
        LocalDate toDate = today;
        
        final LocalDate rangeStart = fromDate;
        final LocalDate rangeEnd = toDate;
        
        // Get all appointments and filter by today
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
        
        // Count statistics - include all appointments (including Canceled) to match ViewListAppointment
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
        
        // Get all appointments for today (sorted by time)
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
        
        request.getRequestDispatcher("/WEB-INF/views/Receptionist/dashboard.jsp")
                .forward(request, response);
    }
}
