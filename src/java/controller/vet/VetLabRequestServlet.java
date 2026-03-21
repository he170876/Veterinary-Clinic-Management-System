package controller.vet;

import dao.AppointmentDAO;
import dao.LabTestRequestDAO;
import dao.NotificationDAO;
import dao.VisitDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Appointment;
import model.User;
import model.Visit;

import java.io.IOException;

/**
 * POST: Create a lab test request for the current examination (visit).
 * Expects appointmentId, testId (LabTests.test_id). Creates visit if needed.
 */
@WebServlet(name = "VetLabRequestServlet", urlPatterns = {"/vet/lab-request"})
public class VetLabRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String appointmentIdParam = request.getParameter("appointmentId");
        String testIdParam = request.getParameter("testId");
        if (appointmentIdParam == null || testIdParam == null || appointmentIdParam.isEmpty() || testIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        int appointmentId;
        int testId;
        try {
            appointmentId = Integer.parseInt(appointmentIdParam);
            testId = Integer.parseInt(testIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        AppointmentDAO appDao = new AppointmentDAO();
        Appointment ap = appDao.getAppointmentDetail(appointmentId);
        if (ap == null) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        int vetId = appDao.getVeterinarianIdByUserId(user.getUserId());
        if (vetId <= 0 || ap.getVeterinarianId() != vetId) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit visit = visitDao.getByAppointmentId(appointmentId);
        // Visit should already exist from receptionist check-in / vet examination.
        // If not, ask user to check-in first.
        if (visit == null) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?error=notcheckedin");
            return;
        }
        //tạo lab request
        LabTestRequestDAO labDao = new LabTestRequestDAO();
        String clinicalNotes = request.getParameter("clinicalNotes");
        labDao.createRequest(visit.getVisitId(), testId, visit.getVeterinarianId(), clinicalNotes);

        // Notify Lab Technician(s) that a new lab request was created
        NotificationDAO ndao = new NotificationDAO();
        ndao.createForRole(
                "LabStaff",
                "New lab request",
                "A new lab request was created for visit #" + visit.getVisitId() + " (testId=" + testId + ")."
        );

        response.sendRedirect(request.getContextPath() + "/vet/examination?id=" + appointmentId);
    }
}
