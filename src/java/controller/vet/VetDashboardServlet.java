package controller.vet;

import dao.AppointmentDAO;
import dao.LabTestRequestDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Appointment;
import model.LabResultSummary;
import model.User;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;

/**
 * Serves the veterinarian dashboard at /vet/dashboard.
 * Loads today's appointments, stats, and recent lab results from database.
 */
@WebServlet(name = "VetDashboardServlet", urlPatterns = {"/vet/dashboard"})
public class VetDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO appDao = new AppointmentDAO();
        LabTestRequestDAO labDao = new LabTestRequestDAO();
        int vetId = appDao.getVeterinarianIdByUserId(user.getUserId());

        List<Appointment> todayAppointments = vetId > 0 ? appDao.getTodayAppointmentsByVeterinarianForDashboard(vetId) : Collections.emptyList();
        int totalToday = vetId > 0 ? appDao.countTodayAppointmentsByVet(vetId) : 0;
        int surgeriesToday = vetId > 0 ? appDao.countSurgeriesTodayByVet(vetId) : 0;
        int pendingLab = vetId > 0 ? labDao.countPendingByVeterinarian(vetId) : 0;
        int followUps = vetId > 0 ? appDao.countFollowUpsThisWeek(vetId) : 0;
        List<LabResultSummary> recentLabResults = vetId > 0 ? labDao.getRecentResultsForVeterinarian(vetId, 5) : Collections.emptyList();

        request.setAttribute("user", user);
        NotificationDAO ndao = new NotificationDAO();
        request.setAttribute("notifications", ndao.getRecentForUser(user.getUserId(), 10));
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.setAttribute("todayAppointments", todayAppointments);
        request.setAttribute("totalToday", totalToday);
        request.setAttribute("surgeriesToday", surgeriesToday);
        request.setAttribute("pendingLab", pendingLab);
        request.setAttribute("followUps", followUps);
        request.setAttribute("recentLabResults", recentLabResults);
        request.getRequestDispatcher("/WEB-INF/views/vet/dashboard.jsp").forward(request, response);
    }
}
