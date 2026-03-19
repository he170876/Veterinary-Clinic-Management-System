package controller.owner;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.DashboardStatsDAO;
import dao.impl.DashboardStatsJdbcDAO;
import dao.AppointmentDAO;
import model.Appointment;
import java.util.List;
import java.io.IOException;

@WebServlet(name = "DashboardStatsServlet", urlPatterns = {"/owner/dashboard"})
public class DashboardStatsServlet extends HttpServlet {
    private DashboardStatsDAO statsDAO;
    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        statsDAO = new DashboardStatsJdbcDAO();
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int newCustomers = statsDAO.countNewCustomersThisMonth();
        int newAppointments = statsDAO.countNewAppointmentsThisMonth();
        int totalUsers = statsDAO.countTotalUsers();
        int totalPatients = statsDAO.countTotalPatients();
        int newRegistrations7Days = statsDAO.countNewRegistrationsLast7Days();
        int totalAppointments = statsDAO.countTotalAppointments();

        // Pagination for appointments
        int pageSize = 5;
        int appPage = 1;
        String appPageParam = request.getParameter("appPage");
        if (appPageParam != null) {
            try {
                appPage = Integer.parseInt(appPageParam);
                if (appPage < 1) appPage = 1;
            } catch (NumberFormatException ignored) {}
        }
        int appOffset = (appPage - 1) * pageSize;
        int appTotal = appointmentDAO.getAllAppointments().size();
        int appTotalPages = (int) Math.ceil((double) appTotal / pageSize);
        List<Appointment> appointments = appointmentDAO.getAllAppointments().subList(
                Math.min(appOffset, appTotal),
                Math.min(appOffset + pageSize, appTotal)
        );

        request.setAttribute("newCustomers", newCustomers);
        request.setAttribute("newAppointments", newAppointments);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalPatients", totalPatients);
        request.setAttribute("newRegistrations7Days", newRegistrations7Days);
        request.setAttribute("totalAppointments", totalAppointments);
        request.setAttribute("appointments", appointments);
        request.setAttribute("appPage", appPage);
        request.setAttribute("appTotal", appTotal);
        request.setAttribute("appTotalPages", appTotalPages);
        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard-stats.jsp").forward(request, response);
    }
}
