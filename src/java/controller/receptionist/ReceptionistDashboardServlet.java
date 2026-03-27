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
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import model.Appointment;
import model.Service;
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
        // Additional feed for "checked-in by real check-in date" (covers appointments scheduled another day
        // but checked in today by receptionist).
        List<Appointment> checkedInTodayByCheckInDate = dao.getCheckedInAppointmentsForDate(today);
        
        List<Appointment> todayAppointments = allAppointments.stream()
                .filter(a -> {
                    if (a == null) return false;

                    // Keep existing behavior: appointment scheduled in today's range.
                    boolean inAppointmentDateRange = false;
                    if (a.getAppointmentTime() != null) {
                        LocalDate d = a.getAppointmentTime().toLocalDate();
                        inAppointmentDateRange = !(rangeStart != null && d.isBefore(rangeStart))
                                && !(rangeEnd != null && d.isAfter(rangeEnd));
                    }

                    // Added behavior: checked-in appointments with arrival time today
                    // should also appear on receptionist dashboard (even if scheduled date differs).
                    boolean checkedInWithArrivalToday = false;
                    if (a.getStatus() != null
                            && "Checked-in".equalsIgnoreCase(a.getStatus().trim())
                            && a.getArrivalTime() != null) {
                        LocalDate arrivalDate = a.getArrivalTime().toLocalDate();
                        checkedInWithArrivalToday = !(rangeStart != null && arrivalDate.isBefore(rangeStart))
                                && !(rangeEnd != null && arrivalDate.isAfter(rangeEnd));
                    }

                    return inAppointmentDateRange || checkedInWithArrivalToday;
                })
                .collect(java.util.stream.Collectors.toList());

        // Merge in checked-in-by-checkin-date list, dedup by appointment_id, keep existing behavior otherwise.
        java.util.Map<Integer, Appointment> mergedToday = new LinkedHashMap<>();
        for (Appointment a : todayAppointments) {
            if (a != null) mergedToday.put(a.getAppointmentId(), a);
        }
        for (Appointment a : checkedInTodayByCheckInDate) {
            if (a != null) mergedToday.put(a.getAppointmentId(), a);
        }
        todayAppointments = new ArrayList<>(mergedToday.values());
        
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
        
        // Sort chronologically; fallback to arrivalTime when appointmentTime is null.
        todayAppointments.sort(java.util.Comparator.comparing(a -> {
            if (a == null) return java.time.LocalDateTime.MIN;
            if (a.getAppointmentTime() != null) return a.getAppointmentTime();
            if (a.getArrivalTime() != null) return a.getArrivalTime();
            return java.time.LocalDateTime.MIN;
        }));
        int pageSize = 5;
        int currentPage = 1;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                currentPage = Integer.parseInt(pageParam.trim());
            }
        } catch (NumberFormatException ignored) {}
        if (currentPage < 1) currentPage = 1;
        int totalFiltered = todayAppointments.size();
        int totalPages = totalFiltered == 0 ? 1 : (int) Math.ceil(totalFiltered / (double) pageSize);
        if (currentPage > totalPages) currentPage = totalPages;
        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalFiltered);
        List<Appointment> recentAppointments = (fromIndex >= 0 && fromIndex < toIndex)
                ? todayAppointments.subList(fromIndex, toIndex)
                : new ArrayList<>();
        
        List<User> veterinarians = dao.getAllVeterinarians();
        
        request.setAttribute("totalAppointments", totalAppointments);
        request.setAttribute("normalAppointments", normalAppointments);
        request.setAttribute("emergencyCases", emergencyCases);
        request.setAttribute("emergencyActive", emergencyActive);
        request.setAttribute("emergencyResolved", emergencyResolved);
        request.setAttribute("recentAppointments", recentAppointments);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalFiltered", totalFiltered);
        request.setAttribute("veterinarians", veterinarians);
        ServiceDAO serviceDAO = new ServiceJdbcDAO();
        List<Service> generalServices = new ArrayList<>();
        for (Service s : serviceDAO.findAll()) {
            String cat = s != null && s.getCategory() != null ? s.getCategory().trim().toLowerCase() : "";
            if ("general".equals(cat)) {
                generalServices.add(s);
            }
        }
        request.setAttribute("services", generalServices);

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
