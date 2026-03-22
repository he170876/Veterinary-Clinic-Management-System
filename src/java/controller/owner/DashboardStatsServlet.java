package controller.owner;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.AppointmentDAO;
import dao.DashboardStatsDAO;
import dao.impl.DashboardStatsJdbcDAO;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import model.Appointment;

@WebServlet(name = "DashboardStatsServlet", urlPatterns = {"/owner/dashboard"})
public class DashboardStatsServlet extends HttpServlet {
    private DashboardStatsDAO statsDAO;
    private AppointmentDAO appointmentDAO;
    private static final int APPOINTMENT_PAGE_SIZE = 5;

    @Override
    public void init() throws ServletException {
        statsDAO = new DashboardStatsJdbcDAO();
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate today = LocalDate.now();
        String appScope = normalizeScope(request.getParameter("appScope"));

        int appPage = parsePositiveInt(request.getParameter("appPage"), 1);
        LocalDate fromDate;
        LocalDate toDate;

        switch (appScope) {
            case "week":
                fromDate = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
                toDate = fromDate.plusDays(6);
                break;
            case "month":
                fromDate = today.withDayOfMonth(1);
                toDate = today.withDayOfMonth(today.lengthOfMonth());
                break;
            case "today":
            default:
                fromDate = today;
                toDate = today;
                break;
        }

        int appTotal = appointmentDAO.countAppointmentsByDateRange(fromDate, toDate);
        int appTotalPages = (int) Math.ceil((double) appTotal / APPOINTMENT_PAGE_SIZE);
        if (appTotalPages == 0) {
            appTotalPages = 1;
        }
        if (appPage > appTotalPages) {
            appPage = appTotalPages;
        }

        int offset = (appPage - 1) * APPOINTMENT_PAGE_SIZE;
        List<Appointment> appointments = appointmentDAO.getAppointmentsByDateRange(
                fromDate,
                toDate,
                offset,
                APPOINTMENT_PAGE_SIZE
        );

        int newCustomers = statsDAO.countNewCustomersThisMonth();
        int newAppointments = statsDAO.countNewAppointmentsThisMonth();
        int totalUsers = statsDAO.countTotalUsers();
        int totalPatients = statsDAO.countTotalPatients();
        int newRegistrations7Days = statsDAO.countNewRegistrationsLast7Days();
        int totalAppointments = statsDAO.countTotalAppointments();

        request.setAttribute("newCustomers", newCustomers);
        request.setAttribute("newAppointments", newAppointments);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalPatients", totalPatients);
        request.setAttribute("newRegistrations7Days", newRegistrations7Days);
        request.setAttribute("totalAppointments", totalAppointments);
        request.setAttribute("appointments", appointments);
        request.setAttribute("appTotal", appTotal);
        request.setAttribute("appPage", appPage);
        request.setAttribute("appTotalPages", appTotalPages);
        request.setAttribute("appScope", appScope);

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard-stats.jsp").forward(request, response);
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String normalizeScope(String rawScope) {
        if (rawScope == null) {
            return "today";
        }
        String normalized = rawScope.trim().toLowerCase();
        if ("week".equals(normalized) || "month".equals(normalized)) {
            return normalized;
        }
        return "today";
    }
}
