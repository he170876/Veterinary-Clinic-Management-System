package controller.vet;

import dao.AppointmentDAO;
import dao.MedicalRecordDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.MedicalRecordSummary;
import model.User;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(name = "VetMedicalRecordsServlet", urlPatterns = {"/vet/records"})
public class VetMedicalRecordsServlet extends HttpServlet {

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
        int veterinarianId = appDao.getVeterinarianIdByUserId(user.getUserId());
        if (veterinarianId <= 0) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        MedicalRecordDAO recordDao = new MedicalRecordDAO();
        List<MedicalRecordSummary> records = recordDao.getRecentRecordsByVeterinarian(veterinarianId, 100);

        request.setAttribute("user", user);
        request.setAttribute("records", records);
        request.setAttribute("dateFormatter", DateTimeFormatter.ofPattern("MMM dd, yyyy"));
        request.getRequestDispatcher("/WEB-INF/views/vet/medical-records.jsp").forward(request, response);
    }
}

