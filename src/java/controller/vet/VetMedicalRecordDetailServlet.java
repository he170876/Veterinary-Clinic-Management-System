package controller.vet;

import dao.AppointmentDAO;
import dao.NotificationDAO;
import dao.CustomerDAO;
import dao.LabTestRequestDAO;
import dao.VetMedicalRecordDAO;
import dao.VisitDAO;
import dao.impl.CustomerJdbcDAO;
import dao.impl.PetJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.LabTestRequest;
import model.MedicalRecord;
import model.Pet;
import model.Prescription;
import model.RecordServiceLine;
import model.User;
import model.Visit;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

/**
 * Read‑only view for a single medical record (Examination Report).
 * <ul>
 *   <li>Nhận <code>recordId</code> từ query string.</li>
 *   <li>Xác thực bác sĩ hiện tại là chủ của record (so sánh với <code>record.veterinarianId</code>).</li>
 *   <li>Load Visit, Pet, Customer, danh sách dịch vụ {@link RecordServiceLine} và toa thuốc {@link Prescription}.</li>
 *   <li>Tính thời lượng khám (từ check-in/check-out), thời điểm kết thúc và tổng chi phí từ các dịch vụ.</li>
 *   <li>Gửi toàn bộ sang <code>vet/medical-record-view.jsp</code> để render report giống file thiết kế (PDF‑style).</li>
 * </ul>
 */
@WebServlet(name = "VetMedicalRecordDetailServlet", urlPatterns = {"/vet/record"})
public class VetMedicalRecordDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("currentUser");

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/vet/records");
            return;
        }

        int recordId;
        try {
            recordId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vet/records");
            return;
        }

        AppointmentDAO appDao = new AppointmentDAO();
        int veterinarianId = appDao.getVeterinarianIdByUserId(user.getUserId());
        if (veterinarianId <= 0) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        VetMedicalRecordDAO recordDao = new VetMedicalRecordDAO();
        MedicalRecord record = recordDao.getByRecordId(recordId);
        if (record == null || record.getVeterinarianId() != veterinarianId) {
            response.sendRedirect(request.getContextPath() + "/vet/records");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit visit = visitDao.getByVisitId(record.getVisitId());
        if (visit == null) {
            response.sendRedirect(request.getContextPath() + "/vet/records");
            return;
        }

        // Load patient and owner
        PetJdbcDAO petDao = new PetJdbcDAO();
        Optional<Pet> petOpt = petDao.findById(visit.getPetId());
        Pet pet = petOpt.orElse(null);

        CustomerDAO customerDao = new CustomerJdbcDAO();
        Optional<Customer> custOpt = customerDao.findById(visit.getCustomerId());
        Customer customer = custOpt.orElse(null);

        // Services and prescriptions
        List<RecordServiceLine> services = recordDao.getServicesForRecord(record.getRecordId());
        List<Prescription> prescriptions = recordDao.getPrescriptionsByRecordId(record.getRecordId());
        LabTestRequestDAO labTestRequestDAO = new LabTestRequestDAO();
        List<LabTestRequest> labRequests = labTestRequestDAO.getByVisitId(record.getVisitId());

        // Compute duration from visit times if available
        String durationLabel = "—";
        LocalDateTime in = visit.getCheckInTime();
        LocalDateTime out = visit.getCheckOutTime();
        if (in != null && out != null && !out.isBefore(in)) {
            Duration d = Duration.between(in, out);
            long minutes = d.toMinutes();
            if (minutes > 0) {
                durationLabel = minutes + " Minutes";
            }
        }

        DateTimeFormatter fullDateTimeFmt = DateTimeFormatter.ofPattern("EEEE, MMMM dd, yyyy 'at' hh:mm a");
        String concludedAt = (out != null) ? out.format(fullDateTimeFmt)
                : (record.getCreatedAt() != null ? record.getCreatedAt().format(fullDateTimeFmt) : "");

        LocalDate recordDate = null;
        if (record.getCreatedAt() != null) {
            recordDate = record.getCreatedAt().toLocalDate();
        }
        request.setAttribute("recordDate", recordDate);

        double totalAmount = 0;
        for (RecordServiceLine line : services) {
            if (line.getPrice() != null && line.getQuantity() > 0) {
                totalAmount += line.getPrice() * line.getQuantity();
            }
        }

        request.setAttribute("user", user);
        NotificationDAO ndao = new NotificationDAO();
        request.setAttribute("notifications", ndao.getRecentForUser(user.getUserId(), 10));
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        request.setAttribute("record", record);
        request.setAttribute("visit", visit);
        request.setAttribute("pet", pet);
        request.setAttribute("customer", customer);
        request.setAttribute("labRequests", labRequests);
        request.setAttribute("services", services);
        request.setAttribute("prescriptions", prescriptions);
        request.setAttribute("durationLabel", durationLabel);
        request.setAttribute("concludedAt", concludedAt);
        request.setAttribute("totalAmount", totalAmount);

        request.getRequestDispatcher("/WEB-INF/views/vet/medical-record-view.jsp").forward(request, response);
    }
}

