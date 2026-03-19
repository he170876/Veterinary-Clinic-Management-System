package controller.vet;

import dao.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Appointment;
import model.User;

import java.io.IOException;

/**
 * AJAX endpoint for vet queue start/continue examination without page reload.
 */
@WebServlet(name = "VetStartExaminationServlet", urlPatterns = {"/vet/start-examination"})
public class VetStartExaminationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
        } catch (Exception e) {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid appointment id.\"}");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO appDao = new AppointmentDAO();
        int vetId = appDao.getVeterinarianIdByUserId(user.getUserId());
        if (vetId <= 0) {
            response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized veterinarian.\"}");
            return;
        }

        Appointment ap = appDao.getAppointmentDetail(appointmentId);
        if (ap == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Appointment not found.\"}");
            return;
        }

        String status = ap.getStatus() != null ? ap.getStatus() : "";
        if ("Checked-in".equalsIgnoreCase(status)) {
            boolean claimed = appDao.startExamination(appointmentId, vetId);
            if (!claimed) {
                if (appDao.hasActiveInExamination(vetId)) {
                    response.getWriter().write("{\"success\":false,\"message\":\"You already have an appointment in examination. Complete it before starting another one.\"}");
                    return;
                }
                Appointment latest = appDao.getAppointmentDetail(appointmentId);
                if (latest != null
                        && "In-Examination".equalsIgnoreCase(latest.getStatus())
                        && latest.getVeterinarianId() != null
                        && latest.getVeterinarianId() != vetId) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Another veterinarian has already started this examination.\"}");
                    return;
                }
                response.getWriter().write("{\"success\":false,\"message\":\"Could not start examination.\"}");
                return;
            }
        } else if ("In-Examination".equalsIgnoreCase(status)) {
            if (ap.getVeterinarianId() != null && ap.getVeterinarianId() > 0 && ap.getVeterinarianId() != vetId) {
                response.getWriter().write("{\"success\":false,\"message\":\"Another veterinarian has already started this examination.\"}");
                return;
            }
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Appointment is not in a startable state.\"}");
            return;
        }

        String redirectUrl = request.getContextPath() + "/vet/examination?id=" + appointmentId;
        response.getWriter().write("{\"success\":true,\"redirectUrl\":\"" + redirectUrl + "\"}");
    }
}

