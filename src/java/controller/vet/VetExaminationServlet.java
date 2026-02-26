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
import service.ServiceService;
import service.impl.ServiceServiceImpl;

import java.io.IOException;

/**
 * Serves the vet's Current Examination page for a given appointment.
 * Only the assigned vet should see this (optional: verify in servlet).
 */
@WebServlet(name = "VetExaminationServlet", urlPatterns = {"/vet/examination"})
public class VetExaminationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO dao = new AppointmentDAO();
        Appointment ap = dao.getAppointmentDetail(appointmentId);

        if (ap == null) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        // Optional: only allow the assigned vet to view this examination
        int vetId = dao.getVeterinarianIdByUserId(user.getUserId());
        if (vetId > 0 && ap.getVeterinarianId() != vetId) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        ServiceService serviceService = new ServiceServiceImpl();
        request.setAttribute("user", user);
        request.setAttribute("appointment", ap);
        request.setAttribute("clinicServices", serviceService.getAllServices());
        request.getRequestDispatcher("/WEB-INF/views/vet/examination.jsp").forward(request, response);
    }
}
