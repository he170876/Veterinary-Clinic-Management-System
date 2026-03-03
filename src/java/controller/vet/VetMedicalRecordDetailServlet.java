package controller.vet;

import dao.AppointmentDAO;
import dao.CustomerDAO;
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
import model.MedicalRecord;
import model.Pet;
import model.Prescription;
import model.RecordServiceLine;
import model.User;
import model.Visit;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

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

        double totalAmount = 0;
        for (RecordServiceLine line : services) {
            if (line.getPrice() != null && line.getQuantity() > 0) {
                totalAmount += line.getPrice() * line.getQuantity();
            }
        }

        request.setAttribute("user", user);
        request.setAttribute("record", record);
        request.setAttribute("visit", visit);
        request.setAttribute("pet", pet);
        request.setAttribute("customer", customer);
        request.setAttribute("services", services);
        request.setAttribute("prescriptions", prescriptions);
        request.setAttribute("durationLabel", durationLabel);
        request.setAttribute("concludedAt", concludedAt);
        request.setAttribute("totalAmount", totalAmount);

        request.getRequestDispatcher("/WEB-INF/views/vet/medical-record-view.jsp").forward(request, response);
    }
}

