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
import model.Service;
import model.User;
import model.Visit;
import service.ServiceService;
import service.impl.ServiceServiceImpl;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Set;

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

    private static final Set<String> CLINICAL_CONDITION_CODES = Set.of(
            "stable", "monitoring", "follow_up", "urgent", "critical");

    /** Chuẩn hóa mã condition từ form (dropdown). */
    private static String normalizeClinicalCondition(String raw) {
        if (raw == null) return "follow_up";
        String t = raw.trim();
        return CLINICAL_CONDITION_CODES.contains(t) ? t : "follow_up";
    }

    private static java.util.Map<Integer, Integer> parseServiceQuantities(String raw) {
        java.util.Map<Integer, Integer> quantities = new java.util.HashMap<>();
        if (raw == null || raw.trim().isEmpty()) {
            return quantities;
        }
        for (String token : raw.split(",")) {
            if (token == null) continue;
            String t = token.trim();
            if (t.isEmpty()) continue;
            int sep = t.indexOf(':');
            if (sep <= 0 || sep >= t.length() - 1) continue;
            String idPart = t.substring(0, sep).trim();
            String qtyPart = t.substring(sep + 1).trim();
            try {
                int sid = Integer.parseInt(idPart);
                int qty = Integer.parseInt(qtyPart);
                if (sid <= 0) continue;
                if (qty < 1) qty = 1;
                quantities.put(sid, qty);
            } catch (NumberFormatException ignored) {
            }
        }
        return quantities;
    }

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
        // ============================================================
        // Shared queue flow (Queue + Dashboard use the same behavior)
        // ============================================================
        //
        // There are only two valid entry statuses for the examination page:
        //
        // 1) Checked-in  -> "Start Examination"
        //    - first vet who opens the exam tries to atomically claim the appointment
        //      (AppointmentDAO.startExamination) and transition it to "In-Examination"
        //    - server rejects if the vet already has another "In-Examination" appointment (busy)
        //    - server rejects if another vet has already claimed it (locked)
        //
        // 2) In-Examination -> "Continue"
        //    - allowed only for the vet who owns the appointment (appointments.veterinarian_id)
        //    - any other vet gets redirected with error=locked
        //
        // Any other status is considered invalid for this page.
        if ("Checked-in".equalsIgnoreCase(apStatus)) {
            boolean claimed = appDao.startExamination(appointmentId, vetId);
            if (!claimed) {
                // Claim failed. We need to distinguish "busy" (this vet already has an active exam)
                // from "locked" (someone else claimed this appointment).
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
            // Reload after potential status/vet assignment change.
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
        if (visit == null && ap.getPet() != null && ap.getCustomer() != null) {
            String apStatusGet = ap.getStatus() != null ? ap.getStatus() : "";
            if ("Checked-in".equalsIgnoreCase(apStatusGet) || "In-Examination".equalsIgnoreCase(apStatusGet)) {
                // Safety net for emergency / legacy data: if a Visit row does not exist yet,
                // create it so the rest of the examination flow (medical record, lab requests, invoice) can work.
                visit = visitDao.ensureVisitForAppointment(
                        appointmentId,
                        ap.getPet().getPetId(),
                        ap.getCustomer().getCustomerId(),
                        ap.getVeterinarianId());
            }
        }

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
        List<Service> allServices = serviceService.getAllServices();
        List<Service> labTestServices = new java.util.ArrayList<>();
        for (Service s : allServices) {
            String c = s.getCategory() != null ? s.getCategory().trim().toLowerCase() : "";
            if ("labtest".equals(c)) {
                labTestServices.add(s);
            }
        }
        List<LabResultSummary> recentLabResults = (ap != null && ap.getPet() != null)
                ? labDao.getRecentResultsByPetId(ap.getPet().getPetId(), 14) : List.of();
        List<LabTestRequest> labRequests = (visit != null)
                ? labDao.getByVisitId(visit.getVisitId())
                : List.of();

        // Pre-populate the "Services" section in the examination UI:
        // - Prefer the normalized list from appointment_service (one row per service).
        // - If legacy data has no appointment_service rows, we'll fall back in the JSP.
        List<Service> appointmentServices = appDao.getServicesForAppointment(appointmentId);
        if (appointmentServices.isEmpty() && ap != null && ap.getService() != null) {
            // If Appointment.service is a merged label like "A, B, C", try to resolve each name back to a service_id
            // using the current services catalog (best-effort). This prevents the UI from showing one merged row.
            java.util.Map<String, Service> byNormName = new java.util.HashMap<>();
            for (Service s : allServices) {
                if (s == null || s.getName() == null) continue;
                byNormName.put(s.getName().trim().toLowerCase(), s);
            }
            java.util.LinkedHashMap<Integer, Service> resolved = new java.util.LinkedHashMap<>();
            for (String part : ap.getService().split(",")) {
                String name = part != null ? part.trim() : "";
                if (name.isEmpty()) continue;
                Service matched = byNormName.get(name.toLowerCase());
                if (matched != null && matched.getServiceId() > 0) {
                    resolved.putIfAbsent(matched.getServiceId(), matched);
                }
            }
            if (!resolved.isEmpty()) {
                appointmentServices = new java.util.ArrayList<>(resolved.values());
            }
        }

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
        request.setAttribute("appointmentServices", appointmentServices);
        request.setAttribute("prescriptions", prescriptions);
        request.setAttribute("recentLabResults", recentLabResults);
        request.setAttribute("labResultDetail", labResultDetail);
        request.setAttribute("labRequests", labRequests);
        request.setAttribute("clinicServices", allServices);
        request.setAttribute("labTestServices", labTestServices);
        request.setAttribute("labTests", labDao.getAllLabTests());
        if ("pendingLab".equals(request.getParameter("error"))) {
            request.setAttribute("examCompleteBlocked",
                    "Cannot complete examination while lab requests are still pending. Complete them in the lab queue first.");
        } else if ("missingConclusion".equals(request.getParameter("error"))) {
            request.setAttribute("examCompleteBlocked",
                    "Conclusion is required to complete the examination.");
        } else if ("missingDiagnosisObservation".equals(request.getParameter("error"))) {
            request.setAttribute("examCompleteBlocked",
                    "Diagnosis and Observation are required to complete the examination.");
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
            // Server-side ownership guard: only the assigned vet can submit POST updates.
            // (The UI also hides "Start/Continue" for locked rows, but we never rely on UI.)
            response.sendRedirect(request.getContextPath() + "/vet/queue");
            return;
        }

        VisitDAO visitDao = new VisitDAO();
        Visit visit = visitDao.getByAppointmentId(appointmentId);
        if (visit == null && ap.getPet() != null && ap.getCustomer() != null) {
            String apStatus = ap.getStatus() != null ? ap.getStatus() : "";
            if ("Checked-in".equalsIgnoreCase(apStatus) || "In-Examination".equalsIgnoreCase(apStatus)) {
                // Safety net: ensure there is a Visit row before saving medical record / completing exam.
                visit = visitDao.ensureVisitForAppointment(
                        appointmentId,
                        ap.getPet().getPetId(),
                        ap.getCustomer().getCustomerId(),
                        ap.getVeterinarianId());
            }
        }
        // Read user inputs for the medical record.
        // (Existing code uses Vietnamese inline comments; we keep logic intact.)
        String diagnosis = request.getParameter("diagnosis");
        String conclusion = request.getParameter("conclusion");
        String note = request.getParameter("note");
        String clinicalCondition = normalizeClinicalCondition(request.getParameter("clinicalCondition"));
        if (diagnosis == null) diagnosis = "";
        if (conclusion == null) conclusion = "";
        if (note == null) note = "";

        // UI requirement: Diagnosis & Observation are the same textarea.
        // If note is missing, fallback to diagnosis to keep server-side guard consistent.
        if (note.trim().isEmpty() && diagnosis != null && !diagnosis.trim().isEmpty()) {
            note = diagnosis;
        }
        // Create or update the medical record for this visit.
        VetMedicalRecordDAO recordDao = new VetMedicalRecordDAO();
        MedicalRecord record = null;
        if (visit != null) {
            int effectiveVetId = visit.getVeterinarianId() != null && visit.getVeterinarianId() > 0
                    ? visit.getVeterinarianId()
                    : vetId;
            record = recordDao.getByVisitId(visit.getVisitId());
            if (record == null) {
                record = recordDao.create(visit.getVisitId(), effectiveVetId, diagnosis, conclusion, note, clinicalCondition);
            } else {
                recordDao.update(record.getRecordId(), diagnosis, conclusion, note, clinicalCondition);
            }
        }

        if (record != null) {
            recordDao.deleteRecordServices(record.getRecordId());
            String serviceIdsParam = request.getParameter("serviceIds");
            String serviceQuantitiesParam = request.getParameter("serviceQuantities");
            java.util.Map<Integer, Integer> quantityByServiceId = parseServiceQuantities(serviceQuantitiesParam);
            if (serviceIdsParam != null && !serviceIdsParam.trim().isEmpty()) {
                ServiceService svc = new ServiceServiceImpl();
                java.util.LinkedHashSet<Integer> distinctIds = new java.util.LinkedHashSet<>();
                for (String s : serviceIdsParam.split(",")) {
                    s = s.trim();
                    if (s.isEmpty()) continue;
                    try {
                        distinctIds.add(Integer.parseInt(s));
                    } catch (NumberFormatException ignored) {}
                }

                if (!distinctIds.isEmpty()) {
                    var services = svc.getAllServices();
                    java.util.Set<String> seenServiceNameKeys = new java.util.HashSet<>();

                    for (Integer sid : distinctIds) {
                        if (sid == null) continue;
                        // find service by id (small list, acceptable)
                        var matched = (Object) null;
                        Double price = null;
                        String name = null;
                        for (var sv : services) {
                            if (sv.getServiceId() == sid) {
                                price = sv.getPrice();
                                name = sv.getName();
                                matched = sv;
                                break;
                            }
                        }
                        if (matched == null) continue;

                        String normName = (name != null) ? name.trim().toLowerCase() : "";
                        String key = !normName.isEmpty() ? normName : ("id:" + sid);
                        if (seenServiceNameKeys.contains(key)) continue;
                        seenServiceNameKeys.add(key);

                        double safePrice = price != null ? price : 0.0;
                        int qty = quantityByServiceId.getOrDefault(sid, 1);
                        if (qty < 1) qty = 1;
                        recordDao.addService(record.getRecordId(), sid, qty, safePrice);
                    }
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
        // Action routing:
        // - default: save + reload the examination page
        // - complete: perform server-side guards (required fields + no pending labs),
        //   close the visit, move appointment to "Waiting-for-Payment", generate invoice lines, notify receptionist.
        String action = request.getParameter("action");

        // Server-side guard for required fields when user completes the examination.
        if ("complete".equals(action) && conclusion.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath()
                    + "/vet/examination?id=" + appointmentId + "&error=missingConclusion");
            return;
        }
        if ("complete".equals(action) && (diagnosis.trim().isEmpty() || note.trim().isEmpty())) {
            response.sendRedirect(request.getContextPath()
                    + "/vet/examination?id=" + appointmentId + "&error=missingDiagnosisObservation");
            return;
        }

        if ("complete".equals(action) && visit != null) {
            LabTestRequestDAO labDao = new LabTestRequestDAO();
            // Do not allow completion while lab requests are still pending.
            // This prevents billing/closing the case before lab workflow is finished.
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
                // Aggregate services by (name, unit price) so the invoice does not show duplicates.
                // Key format uses a null separator to avoid accidental collisions.
                java.util.Map<String, int[]> aggregated = new java.util.LinkedHashMap<>();
                double total = 0;
                for (RecordServiceLine line : lines) {
                    if (line.getPrice() == null || line.getQuantity() <= 0 || line.getServiceName() == null) {
                        continue;
                    }
                    double unit = line.getPrice();
                    int qty = line.getQuantity();
                    String key = line.getServiceName().trim() + "\0" + unit;
                    int[] bucket = aggregated.computeIfAbsent(key, k -> new int[]{0});
                    bucket[0] += qty;
                    total += unit * qty;
                }
                if (total > 0) {
                    InvoiceDAO invoiceDao = new InvoiceDAO();
                    int invoiceId = invoiceDao.create(visit.getVisitId(), total, "Recorded");
                    if (invoiceId > 0) {
                        // Create invoice line items based on the aggregated map.
                        for (java.util.Map.Entry<String, int[]> e : aggregated.entrySet()) {
                            int sep = e.getKey().indexOf('\0');
                            String name = sep >= 0 ? e.getKey().substring(0, sep) : e.getKey();
                            double unit = sep >= 0 ? Double.parseDouble(e.getKey().substring(sep + 1)) : 0;
                            int qty = e.getValue()[0];
                            if (qty > 0 && unit > 0) {
                                invoiceDao.addItem(invoiceId, "Service", name, unit, qty, unit * qty);
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
