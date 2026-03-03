package controller.vet;

import dao.AppointmentDAO;
import dao.InvoiceDAO;
import dao.MedicalRecordDAO;
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
import java.util.List;

/**
 * Vet examination: GET loads (or creates) visit, medical record, services; POST saves diagnosis, treatment, services, prescription.
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
        AppointmentDAO appDao = new AppointmentDAO();
        Appointment ap = appDao.getAppointmentDetail(appointmentId);

        if (ap == null) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?error=notfound");
            return;
        }

        int vetId = appDao.getVeterinarianIdByUserId(user.getUserId());
        if (vetId > 0 && ap.getVeterinarianId() != vetId) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?error=notassigned");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit visit = visitDao.getByAppointmentId(appointmentId);
        if (visit == null) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?error=notcheckedin");
            return;
        }
        if ("Checked-in".equals(visit.getVisitStatus())) {
            visitDao.updateStatus(visit.getVisitId(), "In-Examination");
            visit.setVisitStatus("In-Examination");
        }

        MedicalRecord record = null;
        List<RecordServiceLine> recordServices = List.of();
        List<Prescription> prescriptions = List.of();
        if (visit != null) {
            MedicalRecordDAO recordDao = new MedicalRecordDAO();
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
        if (vetId <= 0 || ap.getVeterinarianId() != vetId) {
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit visit = visitDao.getByAppointmentId(appointmentId);
        if (visit == null) {
            response.sendRedirect(request.getContextPath() + "/vet/queue?error=notcheckedin");
            return;
        }

        String diagnosis = request.getParameter("diagnosis");
        String treatment = request.getParameter("treatment");
        String note = request.getParameter("note");
        if (diagnosis == null) diagnosis = "";
        if (treatment == null) treatment = "";
        if (note == null) note = "";

        MedicalRecordDAO recordDao = new MedicalRecordDAO();
        MedicalRecord record = recordDao.getByVisitId(visit.getVisitId());
        if (record == null) {
            record = recordDao.create(visit.getVisitId(), visit.getVeterinarianId(), diagnosis, treatment, note);
        } else {
            recordDao.update(record.getRecordId(), diagnosis, treatment, note);
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

        String action = request.getParameter("action");
        if ("complete".equals(action) && visit != null) {
            visitDao.completeVisit(visit.getVisitId());
            appDao.updateAppointmentStatus(appointmentId, "Completed");
            // Record amount spent (from medical record services)
            if (record != null) {
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
            response.sendRedirect(request.getContextPath() + "/vet/queue?completed=1");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/vet/examination?id=" + appointmentId);
    }
}
