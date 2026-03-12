package controller.vet;

import dao.AppointmentDAO;
import dao.VetMedicalRecordDAO;
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

/**
 * Shows the "Medical Records History" list for a veterinarian.
 * <p>
 * Dùng {@link AppointmentDAO#getVeterinarianIdByUserId(int)} để tìm <code>veterinarian_id</code> cho user hiện tại,
 * sau đó gọi {@link MedicalRecordDAO#getRecentRecordsByVeterinarian(int, int)} để lấy tối đa N bản ghi
 * (record_id, pet, ngày khám, chẩn đoán) và forward sang <code>vet/medical-records.jsp</code>.
 * </p>
 */
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

        VetMedicalRecordDAO recordDao = new VetMedicalRecordDAO();
        String q = request.getParameter("q");
        int pageSize = 10;
        int page = 1;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException ignored) {}
        if (page < 1) page = 1;

        int total = recordDao.countRecordsByVeterinarian(veterinarianId, q);
        int totalPages = total == 0 ? 1 : (int) Math.ceil(total / (double) pageSize);
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * pageSize;

        List<MedicalRecordSummary> records = recordDao.getRecordsPageByVeterinarian(veterinarianId, offset, pageSize, q);

        request.setAttribute("user", user);
        request.setAttribute("records", records);
        request.setAttribute("q", q == null ? "" : q.trim());
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalRecords", total);
        request.setAttribute("dateFormatter", DateTimeFormatter.ofPattern("MMM dd, yyyy"));
        request.getRequestDispatcher("/WEB-INF/views/vet/medical-records.jsp").forward(request, response);
    }
}

