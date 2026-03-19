package controller.owner;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.DashboardStatsDAO;
import dao.impl.DashboardStatsJdbcDAO;
import java.io.IOException;

@WebServlet(name = "DashboardStatsServlet", urlPatterns = {"/owner/dashboard"})
public class DashboardStatsServlet extends HttpServlet {
    private DashboardStatsDAO statsDAO;

    @Override
    public void init() throws ServletException {
        statsDAO = new DashboardStatsJdbcDAO();
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

        request.setAttribute("newCustomers", newCustomers);
        request.setAttribute("newAppointments", newAppointments);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalPatients", totalPatients);
        request.setAttribute("newRegistrations7Days", newRegistrations7Days);
        request.setAttribute("totalAppointments", totalAppointments);
        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard-stats.jsp").forward(request, response);
    }
}
