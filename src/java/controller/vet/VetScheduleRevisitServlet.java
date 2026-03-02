package controller.vet;

import dao.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * POST: Schedule a follow-up appointment (revisit) for the current patient.
 * Params: petId, customerId, veterinarianId, revisitDate (yyyy-MM-dd), revisitTime (HH:mm), serviceId (optional).
 */
@WebServlet(name = "VetScheduleRevisitServlet", urlPatterns = {"/vet/schedule-revisit"})
public class VetScheduleRevisitServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO appDao = new AppointmentDAO();
        int vetId = appDao.getVeterinarianIdByUserId(user.getUserId());
        if (vetId <= 0) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        String petIdParam = request.getParameter("petId");
        String customerIdParam = request.getParameter("customerId");
        String vetIdParam = request.getParameter("veterinarianId");
        String revisitDateStr = request.getParameter("revisitDate");
        String revisitTimeStr = request.getParameter("revisitTime");
        String serviceIdParam = request.getParameter("serviceId");

        if (petIdParam == null || customerIdParam == null || revisitDateStr == null || revisitTimeStr == null
                || petIdParam.isEmpty() || customerIdParam.isEmpty() || revisitDateStr.isEmpty() || revisitTimeStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?revisit=missing");
            return;
        }

        int petId, customerId, veterinarianId;
        try {
            petId = Integer.parseInt(petIdParam);
            customerId = Integer.parseInt(customerIdParam);
            veterinarianId = vetIdParam != null && !vetIdParam.isEmpty() ? Integer.parseInt(vetIdParam) : vetId;
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?revisit=invalid");
            return;
        }

        if (veterinarianId != vetId) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?revisit=unauthorized");
            return;
        }

        LocalDate date;
        LocalTime time;
        try {
            date = LocalDate.parse(revisitDateStr);
            time = LocalTime.parse(revisitTimeStr.trim(), DateTimeFormatter.ofPattern("HH:mm"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?revisit=invalid");
            return;
        }

        Integer serviceId = null;
        if (serviceIdParam != null && !serviceIdParam.isEmpty()) {
            try {
                serviceId = Integer.parseInt(serviceIdParam);
            } catch (NumberFormatException ignored) {}
        }

        LocalDateTime appointmentTime = LocalDateTime.of(date, time);
        int newId = appDao.create(petId, customerId, veterinarianId, appointmentTime, "Confirmed", serviceId);
        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?revisit=ok");
        } else {
            response.sendRedirect(request.getContextPath() + "/vet/queue?revisit=error");
        }
    }
}
