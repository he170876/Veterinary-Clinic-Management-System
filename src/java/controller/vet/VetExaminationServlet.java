package controller.vet;

import dao.AppointmentDAO;
import dao.InvoiceDAO;
import dao.VetMedicalRecordDAO;
import dao.NotificationDAO;
import dao.VisitDAO;
import dao.LabTestRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Appointment;
import model.LabResultSummary;
import model.LabTestRequest;
import model.MedicalRecord;
import model.Prescription;
import model.RecordServiceLine;
import model.User;
import model.Visit;
import service.ServiceService;
import service.impl.ServiceServiceImpl;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Vet examination flow:
 * <ul>
 *   <li><b>GET /vet/examination?id=appointmentId</b> – đảm bảo appointment thuộc đúng bác sĩ,
 *       kiểm tra đã được receptionist check‑in (có Visit), chuyển trạng thái Visit sang
 *       "In-Examination" nếu cần, load MedicalRecord, services, prescriptions và các LabRequests /
 *       LabResults để hiển thị trên màn hình.</li>
 *   <li><b>POST /vet/examination</b> – lưu chẩn đoán, treatment, ghi lại các dịch vụ đã dùng và toa thuốc.
 *       Khi action = "complete" thì đánh dấu Visit/Appointment là đã khám xong và sinh Invoice từ
 *       các dịch vụ trong MedicalRecordServices. Không cho complete nếu còn LabTestRequest Pending.</li>
 * </ul>
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
        // Load latest notifications (top 3) for dropdown
        NotificationDAO ndao = new NotificationDAO();
        request.setAttribute("notifications", ndao.getRecentForUser(user.getUserId(), 10));
        request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
        AppointmentDAO appDao = new AppointmentDAO();
        Appointment ap = appDao.getAppointmentDetail(appointmentId);

        if (ap == null) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?error=notfound");
            return;
        }

        int vetId = appDao.getVeterinarianIdByUserId(user.getUserId());
        if (vetId <= 0) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?error=unauthorized");
            return;
        }

        String apStatus = ap.getStatus() != null ? ap.getStatus() : "";
        // Shared queue flow:
        // - First vet who starts from Checked-in will atomically claim and move to In-Examination.
        // - If already In-Examination and assigned to another vet, deny.
        if ("Checked-in".equalsIgnoreCase(apStatus)) {
            boolean claimed = appDao.startExamination(appointmentId, vetId);
            if (!claimed) {
                if (appDao.hasActiveInExamination(vetId)) {
                    response.sendRedirect(request.getContextPath() + "/vet/queue?error=busy");
                    return;
                }
                Appointment latest = appDao.getAppointmentDetail(appointmentId);
                if (latest != null
                        && "In-Examination".equalsIgnoreCase(latest.getStatus())
                        && latest.getVeterinarianId() != null
                        && latest.getVeterinarianId() != vetId) {
                    response.sendRedirect(request.getContextPath() + "/vet/queue?error=locked");
                    return;
                }
            }
            ap = appDao.getAppointmentDetail(appointmentId);
        } else if ("In-Examination".equalsIgnoreCase(apStatus)) {
            if (ap.getVeterinarianId() != null && ap.getVeterinarianId() > 0 && ap.getVeterinarianId() != vetId) {
                response.sendRedirect(request.getContextPath() + "/vet/queue?error=locked");
                return;
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/vet/queue?error=invalidstatus");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit visit = visitDao.getByAppointmentId(appointmentId);

        MedicalRecord record = null;
        List<RecordServiceLine> recordServices = List.of();
        List<Prescription> prescriptions = List.of();
        if (visit != null) {
            VetMedicalRecordDAO recordDao = new VetMedicalRecordDAO();
            record = recordDao.getByVisitId(visit.getVisitId());
            if (record != null) {
                recordServices = recordDao.getServicesForRecord(record.getRecordId());
                prescriptions = recordDao.getPrescriptionsByRecordId(record.getRecordId());
            }
        }

        LabTestRequestDAO labDao = new LabTestRequestDAO();
        ServiceService serviceService = new ServiceServiceImpl();
        List<LabResultSummary> recentLabResults = (ap != null && ap.getPet() != null)
                ? labDao.getRecentResultsByPetId(ap.getPet().getPetId(), 14) : List.of();
        List<LabTestRequest> labRequests = (visit != null)
                ? labDao.getByVisitId(visit.getVisitId())
                : List.of();

        // Optional: detailed viewer for a specific completed lab request
        String viewReqParam = request.getParameter("viewLabRequestId");
        model.LabResultDetail labResultDetail = null;
        if (viewReqParam != null && !viewReqParam.isEmpty()) {
            try {
                int viewReqId = Integer.parseInt(viewReqParam);
                labResultDetail = labDao.getResultDetailByRequestId(viewReqId);
            } catch (NumberFormatException ignored) {
            }
        }

        request.setAttribute("user", user);
        request.setAttribute("appointment", ap);
        request.setAttribute("visit", visit);
        request.setAttribute("medicalRecord", record);
        request.setAttribute("recordServices", recordServices);
        request.setAttribute("prescriptions", prescriptions);
        request.setAttribute("recentLabResults", recentLabResults);
        request.setAttribute("labResultDetail", labResultDetail);
        request.setAttribute("labRequests", labRequests);
        request.setAttribute("clinicServices", serviceService.getAllServices());
        request.setAttribute("labTests", labDao.getAllLabTests());
        if ("pendingLab".equals(request.getParameter("error"))) {
            request.setAttribute("examCompleteBlocked",
                    "Cannot complete examination while lab requests are still pending. Complete them in the lab queue first.");
        }
        request.getRequestDispatcher("/WEB-INF/views/vet/examination.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("appointmentId");
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
        AppointmentDAO appDao = new AppointmentDAO();
        Appointment ap = appDao.getAppointmentDetail(appointmentId);
        if (ap == null) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        int vetId = appDao.getVeterinarianIdByUserId(user.getUserId());
        Integer appointmentVetId = ap.getVeterinarianId();
        if (vetId <= 0 || (appointmentVetId != null && appointmentVetId > 0 && appointmentVetId != vetId)) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit visit = visitDao.getByAppointmentId(appointmentId);
//  lưu lại diagnosis, treatment, note
        String diagnosis = request.getParameter("diagnosis");
        String treatment = request.getParameter("treatment");
        String note = request.getParameter("note");
        if (diagnosis == null) diagnosis = "";
        if (treatment == null) treatment = "";
        if (note == null) note = "";
// tạo ra medical record theo visitid, nếu đã có sẽ update
        VetMedicalRecordDAO recordDao = new VetMedicalRecordDAO();
        MedicalRecord record = null;
        if (visit != null) {
            int effectiveVetId = visit.getVeterinarianId() != null && visit.getVeterinarianId() > 0
                    ? visit.getVeterinarianId()
                    : vetId;
            record = recordDao.getByVisitId(visit.getVisitId());
            if (record == null) {
                record = recordDao.create(visit.getVisitId(), effectiveVetId, diagnosis, treatment, note);
            } else {
                recordDao.update(record.getRecordId(), diagnosis, treatment, note);
            }
        }

        if (record != null) {
            recordDao.deleteRecordServices(record.getRecordId());
            String serviceIdsParam = request.getParameter("serviceIds");
            if (serviceIdsParam != null && !serviceIdsParam.trim().isEmpty()) {
                ServiceService svc = new ServiceServiceImpl();
                for (String s : serviceIdsParam.split(",")) {
                    s = s.trim();
                    if (s.isEmpty()) continue;
                    try {
                        int sid = Integer.parseInt(s);
                        var services = svc.getAllServices();
                        for (var sv : services) {
                            if (sv.getServiceId() == sid) {
                                recordDao.addService(record.getRecordId(), sid, 1, sv.getPrice());
                                break;
                            }
                        }
                    } catch (NumberFormatException ignored) {}
                }
            }
//Prescriptions validation
            recordDao.deletePrescriptionsByRecordId(record.getRecordId());
            String[] medNames = request.getParameterValues("medication_name");
            String[] dosages = request.getParameterValues("dosage");
            String[] durations = request.getParameterValues("duration");
            if (medNames != null) {
                for (int i = 0; i < medNames.length; i++) {
                    String name = medNames[i] != null ? medNames[i].trim() : "";
                    if (name.isEmpty()) continue;
                    String dose = (dosages != null && i < dosages.length) ? (dosages[i] != null ? dosages[i].trim() : "") : "";
                    String dur = (durations != null && i < durations.length) ? (durations[i] != null ? durations[i].trim() : "") : "";
                    recordDao.addPrescription(record.getRecordId(), name, dose, dur);
                }
            }
        }
//sau khi hoàn thành examation sẽ xóa cái recordservices đi và tính số tiền 
        String action = request.getParameter("action");
        if ("complete".equals(action) && visit != null) {
            LabTestRequestDAO labDao = new LabTestRequestDAO();
            if (labDao.countPendingByVisitId(visit.getVisitId()) > 0) {
                response.sendRedirect(request.getContextPath() + "/vet/examination?id=" + appointmentId + "&error=pendingLab");
                return;
            }
            visitDao.completeVisit(visit.getVisitId());
            // After vet completes examination, receptionist must confirm payment.
            // UI/flow expects "Waiting-for-Payment" before it becomes "Done".
            appDao.updateAppointmentStatus(appointmentId, "Waiting-for-Payment");
            // Record amount spent (from medical record services)
            if (record != null && visit != null) {
                List<RecordServiceLine> lines = recordDao.getServicesForRecord(record.getRecordId());
                double total = 0;
                for (RecordServiceLine line : lines) {
                    if (line.getPrice() != null && line.getQuantity() > 0) {
                        total += line.getPrice() * line.getQuantity();
                    }
                }
                if (total > 0) {
                    InvoiceDAO invoiceDao = new InvoiceDAO();
                    int invoiceId = invoiceDao.create(visit.getVisitId(), total, "Recorded");
                    if (invoiceId > 0) {
                        for (RecordServiceLine line : lines) {
                            if (line.getPrice() != null && line.getQuantity() > 0 && line.getServiceName() != null) {
                                invoiceDao.addItem(invoiceId, "Service", line.getServiceName(),
                                        line.getPrice(), line.getQuantity(), line.getPrice() * line.getQuantity());
                            }
                        }
                    }
                }
            }

            // Notify receptionist for billing (even if UI is status-driven)
            NotificationDAO ndao = new NotificationDAO();
            ndao.createForRole(
                    "Receptionist",
                    "Billing confirmation needed",
                    "Appointment #" + appointmentId + " has been completed by the veterinarian. Please confirm payment."
            );
            response.sendRedirect(request.getContextPath() + "/vet/queue?completed=1");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/vet/examination?id=" + appointmentId);
    }
}
