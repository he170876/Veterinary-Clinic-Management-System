<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Appointment" %>
<%@ page import="model.Pet" %>
<%@ page import="model.Customer" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.Period" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="model.Service" %>
<%@ page import="model.Visit" %>
<%@ page import="model.MedicalRecord" %>
<%@ page import="model.RecordServiceLine" %>
<%@ page import="model.LabTest" %>
<%@ page import="model.Prescription" %>
<%@ page import="model.LabResultSummary" %>
<%@ page import="model.LabTestRequest" %>
<%@ page import="model.Service" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%
    User user = (User) request.getAttribute("user");
    Appointment ap = (Appointment) request.getAttribute("appointment");
    if (user == null || ap == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    String roleTitle = (user.getRole() != null && user.getRole().getRoleName() != null)
    ? user.getRole().getRoleName() : "Veterinarian";
    Pet pet = ap.getPet();
    Customer cust = ap.getCustomer();
    String ownerName = (cust != null && cust.getUser() != null) ? cust.getUser().getFullName() : "—";
    String petName = (pet != null) ? pet.getName() : "—";
    String species = (pet != null && pet.getSpecies() != null) ? pet.getSpecies() : "";
    String breed = (pet != null && pet.getBreed() != null) ? pet.getBreed() : "";
    String breedAge = breed != null ? breed : "";
    if (pet != null && pet.getBirthDate() != null) {
        Period period = Period.between(pet.getBirthDate(), LocalDate.now());
        int years = period.getYears();
        String agePart = (years > 0) ? (years + " yrs") : (period.getMonths() + " mo");
        breedAge = breedAge.isEmpty() ? agePart : (breedAge + " / " + agePart);
    }
    if (breedAge.isEmpty()) breedAge = "—";
    String weightStr = (pet != null && pet.getWeight() != null) ? pet.getWeight() + " kg" : "—";
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    DateTimeFormatter labResultFmt = DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");
    String lastVisit = (ap.getAppointmentTime() != null) ? ap.getAppointmentTime().format(dateFmt) : "—";
    @SuppressWarnings("unchecked")
    List<Service> clinicServices = (List<Service>) request.getAttribute("clinicServices");
    if (clinicServices == null) clinicServices = java.util.Collections.emptyList();
    Visit visit = (Visit) request.getAttribute("visit");
    MedicalRecord medicalRecord = (MedicalRecord) request.getAttribute("medicalRecord");
    @SuppressWarnings("unchecked")
    List<RecordServiceLine> recordServices = (List<RecordServiceLine>) request.getAttribute("recordServices");
    if (recordServices == null) recordServices = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<Service> appointmentServices = (List<Service>) request.getAttribute("appointmentServices");
    if (appointmentServices == null) appointmentServices = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<LabTest> labTests = (List<LabTest>) request.getAttribute("labTests");
    if (labTests == null) labTests = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<Service> labTestServices = (List<Service>) request.getAttribute("labTestServices");
    if (labTestServices == null) labTestServices = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<Prescription> prescriptions = (List<Prescription>) request.getAttribute("prescriptions");
    if (prescriptions == null) prescriptions = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<LabResultSummary> recentLabResults = (List<LabResultSummary>) request.getAttribute("recentLabResults");
    if (recentLabResults == null) recentLabResults = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<LabTestRequest> labRequests = (List<LabTestRequest>) request.getAttribute("labRequests");
    if (labRequests == null) labRequests = java.util.Collections.emptyList();
    java.util.Map<String, Integer> requestedLabServiceCounts = new java.util.HashMap<>();
    if (visit != null) {
        for (LabTestRequest lr : labRequests) {
            if (lr == null || lr.getVisitId() != visit.getVisitId()) continue;
            String tn = lr.getTestName();
            if (tn == null || tn.trim().isEmpty()) continue;
            String key = tn.trim().toLowerCase();
            requestedLabServiceCounts.put(key, requestedLabServiceCounts.getOrDefault(key, 0) + 1);
        }
    }
    String diagnosisText = (medicalRecord != null && medicalRecord.getDiagnosis() != null) ? medicalRecord.getDiagnosis() : "";
    String conclusionText = (medicalRecord != null && medicalRecord.getConclusion() != null) ? medicalRecord.getConclusion() : "";
    String noteText = (medicalRecord != null && medicalRecord.getNote() != null) ? medicalRecord.getNote() : "";
    String clinicalCondition = (medicalRecord != null && medicalRecord.getClinicalCondition() != null && !medicalRecord.getClinicalCondition().isEmpty())
    ? medicalRecord.getClinicalCondition().trim() : "follow_up";
    if (!"stable".equals(clinicalCondition) && !"monitoring".equals(clinicalCondition) && !"follow_up".equals(clinicalCondition)
    && !"urgent".equals(clinicalCondition) && !"critical".equals(clinicalCondition)) {
        clinicalCondition = "follow_up";
    }
%>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Current Examination - Anipats</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200;300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
        <script id="tailwind-config">
            tailwind.config = {
                darkMode: "class",
                theme: {
                    extend: {
                        colors: {
                            "primary": "#ff7b00",
                            "background-light": "#f8f7f5",
                            "background-dark": "#23190f",
                        },
                        fontFamily: { "display": ["Manrope"] },
                        borderRadius: { "DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px" },
                    },
                },
            }
        </script>
        <style>
            body { font-family: 'Manrope', sans-serif; }
            .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
            #lab-request-modal:target { display: flex; }
        </style>
    </head>
    <body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 min-h-screen">
        <div class="flex min-h-screen overflow-x-hidden">
            <%@ include file="/WEB-INF/views/vet/_sidebar.jspf" %>
            <main class="flex-1 flex flex-col overflow-hidden">
                <header class="h-16 flex items-center justify-between px-8 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 z-10">
                    <div class="flex items-center gap-2">
                        <span class="material-symbols-outlined text-primary">stethoscope</span>
                        <h2 class="text-lg font-bold">Current Examination</h2>
                    </div>
                    <%@ include file="/WEB-INF/includes/vet-header-right.jspf" %>
                </header>
                <form id="examination-form" action="<%= ctx %>/vet/examination" method="post">
                    <input type="hidden" name="appointmentId" value="<%= ap.getAppointmentId() %>"/>
                    <input type="hidden" name="serviceIds" id="serviceIds" value=""/>
                    <input type="hidden" name="serviceQuantities" id="serviceQuantities" value=""/>
                    <div class="flex-1 overflow-y-auto px-8 py-8">
                        <div class="max-w-6xl mx-auto space-y-6">
                            <% String examCompleteBlocked = (String) request.getAttribute("examCompleteBlocked");
                            if (examCompleteBlocked != null && !examCompleteBlocked.isEmpty()) { %>
                            <div class="rounded-xl border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-900 dark:text-amber-100 font-semibold flex items-start gap-2">
                                <span class="material-symbols-outlined shrink-0">warning</span>
                                <span><%= examCompleteBlocked.replace("&", "&amp;").replace("<", "&lt;") %></span>
                            </div>
                            <% } %>
                            <div class="flex items-center justify-between">
                                <div>
                                    <div class="flex items-center gap-2 text-sm text-slate-400 mb-1">
                                        <span>Dashboard</span>
                                        <span class="material-symbols-outlined text-sm">chevron_right</span>
                                        <a href="<%= ctx %>/vet/queue" class="text-slate-400 hover:text-primary">Appointments</a>
                                        <span class="material-symbols-outlined text-sm">chevron_right</span>
                                        <span class="text-primary font-medium">Patient Examination</span>
                                    </div>
                                    <h3 class="text-3xl font-black text-slate-900 dark:text-white"><%= petName %> <span class="text-slate-400 font-light">(<%= species.isEmpty() ? "—" : species %>)</span></h3>
                                    <p class="text-slate-500">Owner: <%= ownerName %></p>
                                </div>
                                <div class="flex items-center gap-3">
                                    <span class="px-4 py-1.5 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300 text-xs font-black rounded-full tracking-widest flex items-center gap-2">
                                        <span class="size-2 rounded-full bg-green-500 animate-pulse"></span>
                                        OPEN
                                    </span>
                                    <button type="submit" name="action" value="save" class="px-6 py-2 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200 font-bold rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 transition-all">
                                        Save Progress
                                    </button>
                                </div>
                            </div>
                            <div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 grid grid-cols-2 lg:grid-cols-4 gap-8">
                                <div>
                                    <p class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Breed / Age</p>
                                    <p class="text-slate-900 dark:text-white font-semibold"><%= breedAge %></p>
                                </div>
                                <div>
                                    <p class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Weight</p>
                                    <p class="text-slate-900 dark:text-white font-semibold"><%= weightStr %></p>
                                </div>
                                <div>
                                    <p class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Last Visit</p>
                                    <p class="text-slate-900 dark:text-white font-semibold"><%= lastVisit %></p>
                                </div>
                                <div>
                                    <p class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Condition</p>
                                    <label class="sr-only" for="clinical-condition-select">Patient condition</label>
                                    <select name="clinicalCondition" id="clinical-condition-select" form="examination-form"
                                    class="mt-1 w-full max-w-[260px] rounded-full text-[10px] font-bold uppercase tracking-wide px-3 py-2 border-0 cursor-pointer focus:ring-2 focus:ring-primary/30 bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-200">
                                    <option value="stable" <%= "stable".equals(clinicalCondition) ? "selected" : "" %>>Stable / doing well</option>
                                    <option value="monitoring" <%= "monitoring".equals(clinicalCondition) ? "selected" : "" %>>Monitoring</option>
                                    <option value="follow_up" <%= "follow_up".equals(clinicalCondition) ? "selected" : "" %>>Follow-up required</option>
                                    <option value="urgent" <%= "urgent".equals(clinicalCondition) ? "selected" : "" %>>Urgent</option>
                                    <option value="critical" <%= "critical".equals(clinicalCondition) ? "selected" : "" %>>Critical</option>
                                </select>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
                            <div class="lg:col-span-2 space-y-6">
                                <div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
                                    <h4 class="text-lg font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
                                        <span class="material-symbols-outlined text-primary">medical_information</span>
                                        Diagnosis &amp; Observation
                                    </h4>
                                    <textarea id="diagnosis-textarea" name="diagnosis" class="w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white focus:ring-primary focus:border-primary placeholder:text-slate-400 p-4 transition-colors" placeholder="Describe symptoms, physical exam findings, and preliminary diagnosis..." rows="6"><%= diagnosisText %></textarea>
                                    <p id="diagnosis-error" class="hidden mt-1.5 text-xs text-red-500 font-semibold flex items-center gap-1">
                                        <span class="material-symbols-outlined text-sm">error</span>
                                        Diagnosis is required to complete the examination.
                                    </p>

                                    <!-- Hidden field: Observation is the same as the Diagnosis textarea (per UI requirement). -->
                                    <textarea id="observation-textarea" name="note" class="hidden" rows="1"><%= diagnosisText %></textarea>

                                </div>
                                <div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
                                    <h4 class="text-md font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
                                        <span class="material-symbols-outlined text-primary text-xl">vaccines</span>
                                        Conclusion
                                    </h4>
                                    <div class="space-y-3">
                                        <textarea id="conclusion-textarea" name="conclusion" class="w-full rounded-lg border border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm" placeholder="Kết luận / conclusion for this visit..." rows="3"><%= conclusionText %></textarea>
                                        <p id="conclusion-error" class="hidden mt-1.5 text-xs text-red-500 font-semibold flex items-center gap-1">
                                            <span class="material-symbols-outlined text-sm">error</span>
                                            Conclusion is required to complete the examination.
                                        </p>
                                    </div>
                                </div>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
                                        <h4 class="text-md font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
                                            <span class="material-symbols-outlined text-primary text-xl">payments</span>
                                            Services
                                        </h4>
                                        <div class="space-y-3" id="examination-services-list">
                                            <% if (!recordServices.isEmpty()) {
                                                java.util.Set<Integer> seenServiceIds = new java.util.HashSet<>();
                                                java.util.Set<String> seenServiceNames = new java.util.HashSet<>();
                                                for (RecordServiceLine line : recordServices) {
                                                    if (line == null) continue;
                                                    int sid = line.getServiceId();
                                                    String sname = line.getServiceName();
                                                    String normName = sname != null ? sname.trim().toLowerCase() : "";
                                                    int requestedCount = !normName.isEmpty() ? requestedLabServiceCounts.getOrDefault(normName, 0) : 0;
                                                    boolean labLocked = requestedCount > 0;
                                                    int displayQty = line.getQuantity() > 0 ? line.getQuantity() : 1;
                                                    if (requestedCount > displayQty) displayQty = requestedCount;
                                                    if (seenServiceIds.contains(sid)) continue;
                                                    if (!normName.isEmpty() && seenServiceNames.contains(normName)) continue;
                                                    seenServiceIds.add(sid);
                                                    if (!normName.isEmpty()) seenServiceNames.add(normName);
                                                %>
                                                <div class="flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row" data-service-id="<%= sid %>" data-service-name="<%= sname != null ? sname : "" %>" data-lab-locked="<%= labLocked ? "true" : "false" %>">
                                                    <div class="flex items-center gap-3">
                                                        <span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span>
                                                        <span class="text-sm font-semibold text-slate-700 dark:text-slate-200"><%= sname != null ? sname : "" %></span>
                                                        <% if (labLocked) { %><span class="text-[10px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-200">Lab Requested</span><% } %>
                                                    </div>
                                                    <div class="flex items-center gap-2">
                                                        <div class="inline-flex items-center rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 overflow-hidden" data-role="service-qty-box">
                                                            <button type="button" class="service-qty-dec px-2 py-1 text-slate-500 hover:text-primary hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors <%= labLocked ? "pointer-events-none opacity-40" : "" %>" <%= labLocked ? "disabled" : "" %> aria-label="Decrease quantity"><span class="material-symbols-outlined text-base">remove</span></button>
                                                            <span class="service-qty min-w-[26px] text-center text-xs font-bold text-slate-700 dark:text-slate-200" data-role="service-qty"><%= displayQty %></span>
                                                            <button type="button" class="service-qty-inc px-2 py-1 text-slate-500 hover:text-primary hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors <%= labLocked ? "pointer-events-none opacity-40" : "" %>" <%= labLocked ? "disabled" : "" %> aria-label="Increase quantity"><span class="material-symbols-outlined text-base">add</span></button>
                                                        </div>
                                                        <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                                            <button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove <%= labLocked ? "pointer-events-none opacity-30" : "" %>" <%= labLocked ? "disabled" : "" %> aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
                                                        </div>
                                                    </div>
                                                </div>
                                                <% }
                                            } else if (!appointmentServices.isEmpty()) {
                                                // When there is no saved medical record yet, pre-fill from the appointment's booked services.
                                                // This list is resolved from appointment_service (one row per service) in VetExaminationServlet.
                                                java.util.Set<Integer> seenServiceIds = new java.util.HashSet<>();
                                                java.util.Set<String> seenServiceNames = new java.util.HashSet<>();
                                                for (Service svc : appointmentServices) {
                                                    if (svc == null) continue;
                                                    int sid = svc.getServiceId();
                                                    String sname = svc.getName();
                                                    String normName = sname != null ? sname.trim().toLowerCase() : "";
                                                    int requestedCount = !normName.isEmpty() ? requestedLabServiceCounts.getOrDefault(normName, 0) : 0;
                                                    boolean labLocked = requestedCount > 0;
                                                    int displayQty = requestedCount > 0 ? requestedCount : 1;
                                                    if (sid > 0 && seenServiceIds.contains(sid)) continue;
                                                    if (!normName.isEmpty() && seenServiceNames.contains(normName)) continue;
                                                    if (sid > 0) seenServiceIds.add(sid);
                                                    if (!normName.isEmpty()) seenServiceNames.add(normName);
                                            %>
                                            <div class="flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row" data-service-id="<%= sid > 0 ? sid : "" %>" data-service-name="<%= sname != null ? sname : "" %>" data-lab-locked="<%= labLocked ? "true" : "false" %>">
                                                <div class="flex items-center gap-3">
                                                    <span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span>
                                                    <span class="text-sm font-semibold text-slate-700 dark:text-slate-200"><%= sname != null ? sname : "" %></span>
                                                    <% if (labLocked) { %><span class="text-[10px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-200">Lab Requested</span><% } %>
                                                </div>
                                                <div class="flex items-center gap-2">
                                                    <div class="inline-flex items-center rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 overflow-hidden" data-role="service-qty-box">
                                                        <button type="button" class="service-qty-dec px-2 py-1 text-slate-500 hover:text-primary hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors <%= labLocked ? "pointer-events-none opacity-40" : "" %>" <%= labLocked ? "disabled" : "" %> aria-label="Decrease quantity"><span class="material-symbols-outlined text-base">remove</span></button>
                                                        <span class="service-qty min-w-[26px] text-center text-xs font-bold text-slate-700 dark:text-slate-200" data-role="service-qty"><%= displayQty %></span>
                                                        <button type="button" class="service-qty-inc px-2 py-1 text-slate-500 hover:text-primary hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors <%= labLocked ? "pointer-events-none opacity-40" : "" %>" <%= labLocked ? "disabled" : "" %> aria-label="Increase quantity"><span class="material-symbols-outlined text-base">add</span></button>
                                                    </div>
                                                    <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                                        <button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove <%= labLocked ? "pointer-events-none opacity-30" : "" %>" <%= labLocked ? "disabled" : "" %> aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
                                                    </div>
                                                </div>
                                            </div>
                                            <%   } %>
                                            <% } %>
                                        </div>
                                        <button type="button" id="add-service-btn" class="w-full py-2 border-2 border-dashed border-slate-200 dark:border-slate-700 rounded-lg text-slate-400 text-xs font-bold hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                                            + ADD SERVICE
                                        </button>
                                        <% if (!clinicServices.isEmpty()) { %>
                                        <div id="add-service-dropdown" class="hidden mt-2 p-2 bg-slate-50 dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 max-h-48 overflow-y-auto">
                                            <%
                                                java.util.Set<Integer> seenServiceIds = new java.util.HashSet<>();
                                                java.util.Set<String> seenServiceNames = new java.util.HashSet<>();
                                                for (Service svc : clinicServices) {
                                                    if (svc == null) continue;
                                                    String cat = svc.getCategory() != null ? svc.getCategory().trim().toLowerCase() : "";
                                                    if (!"general".equals(cat)) continue;
                                                    int sid = svc.getServiceId();
                                                    String svcName = svc.getName();
                                                    String normName = svcName != null ? svcName.trim().toLowerCase() : "";
                                                    if (seenServiceIds.contains(sid)) continue;
                                                    if (!normName.isEmpty() && seenServiceNames.contains(normName)) continue;
                                                    seenServiceIds.add(sid);
                                                    if (!normName.isEmpty()) seenServiceNames.add(normName);
                                                %>
                                                <button type="button" class="add-service-option w-full text-left px-3 py-2 text-sm text-slate-700 dark:text-slate-200 hover:bg-primary/10 rounded-lg flex justify-between items-center" data-id="<%= sid %>" data-name="<%= svcName %>"><span><%= svcName %></span><span class="text-xs text-slate-400"><%= String.format("%.2f", svc.getPrice()) %> </span></button>
                                                <% } %>
                                            </div>
                                            <% } %>
                                        </div>
                                    </div>
                                    <div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
                                        <h4 class="text-md font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
                                            <span class="material-symbols-outlined text-primary text-xl">prescriptions</span>
                                            Prescription
                                        </h4>
                                        <div class="space-y-3" id="prescriptions-list">
                                            <% for (Prescription pr : prescriptions) {
                                                String m = pr.getMedicineName() != null ? pr.getMedicineName().replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;") : "";
                                                String d = pr.getDosage() != null ? pr.getDosage().replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;") : "";
                                                String du = pr.getDuration() != null ? pr.getDuration().replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;") : "";
                                            %>
                                            <div class="prescription-row flex flex-wrap items-center gap-2">
                                                <input name="medication_name" class="flex-1 min-w-[120px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Medication name" type="text" value="<%= m %>"/>
                                                <input name="dosage" class="dosage-field w-24 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Dose" type="text" value="<%= d %>"/>
                                                <input name="duration" class="flex-1 min-w-[100px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Frequency" type="text" value="<%= du %>"/>
                                                <button type="button" class="prescription-remove p-2 text-slate-400 hover:text-primary" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
                                            </div>
                                            <% } %>
                                            <div class="prescription-row flex flex-wrap items-center gap-2">
                                                <input name="medication_name" class="flex-1 min-w-[120px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Medication name" type="text"/>
                                                <input name="dosage" class="dosage-field w-24 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Dose" type="text"/>
                                                <input name="duration" class="flex-1 min-w-[100px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Frequency" type="text"/>
                                                <button type="button" class="prescription-remove p-2 text-slate-400 hover:text-primary" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
                                            </div>
                                        </div>
                                        <button type="button" id="add-medication-btn" class="w-full mt-2 py-2 border-2 border-dashed border-slate-200 dark:border-slate-700 rounded-lg text-slate-400 text-xs font-bold hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                                            + ADD MEDICATION
                                        </button>
                                    </div>
                                </div>
                                <div class="space-y-6">
                                    <div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
                                        <h4 class="text-sm font-bold text-slate-400 uppercase tracking-widest mb-6">Action Panel</h4>
                                        <div class="space-y-4 mb-8">
                                            <p class="text-sm text-slate-600 dark:text-slate-400">Clinical investigations and follow-ups:</p>
                                            <a href="#lab-request-modal" class="w-full bg-primary text-white py-3.5 rounded-xl font-bold text-sm flex items-center justify-center gap-2 shadow-lg shadow-primary/20 hover:bg-primary/90 transition-all text-center no-underline">
                                                <span class="material-symbols-outlined text-xl">biotech</span>
                                                Request Lab Test
                                            </a>
                                        </div>
                                        <div class="space-y-3">
                                            <hr class="border-slate-100 dark:border-slate-800 my-4"/>
                                            <button type="button" id="complete-exam-btn" class="w-full bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 py-4 rounded-xl font-bold text-lg hover:scale-[1.02] transition-transform shadow-lg shadow-slate-900/10">
                                                Complete Examination
                                            </button>
                                            <p id="complete-error" class="hidden text-center text-xs text-red-500 font-semibold mt-1"></p>
                                            <p class="text-center text-[10px] text-slate-400 italic">Completing will finalize the medical record and generate billing charges. All pending lab requests for this visit must be completed first.</p>
                                        </div>
                                    </div>
                                    <div class="bg-primary/5 rounded-xl p-6 border border-primary/10">
                                        <h4 class="text-sm font-bold text-primary mb-3 flex items-center gap-2">
                                            <span class="material-symbols-outlined text-sm">history</span>
                                            Lab Requests Status
                                        </h4>
                                        <ul class="space-y-3 text-xs">
                                            <%
                                                int pendingLabCount = 0;
                                                for (LabTestRequest _lr : labRequests) {
                                                    if (visit != null && _lr.getVisitId() == visit.getVisitId()
                                                    && "Pending".equalsIgnoreCase(_lr.getStatus() != null ? _lr.getStatus() : "")) {
                                                        pendingLabCount++;
                                                    }
                                                }
                                                if (labRequests.isEmpty()) {
                                                %>
                                                <li class="text-slate-500 dark:text-slate-400">No lab requests have been created for this visit.</li>
                                                <%
                                                    } else {
                                                        for (LabTestRequest lr : labRequests) {
                                                            if (visit == null || lr.getVisitId() != visit.getVisitId()) continue;
                                                            String testName = lr.getTestName() != null ? lr.getTestName() : "—";
                                                            String status = lr.getStatus() != null ? lr.getStatus() : "Pending";
                                                            String statusLabel = status.toUpperCase();
                                                            String statusClass;
                                                            String btnText;
                                                            boolean btnDisabled = false;
                                                            if ("Completed".equalsIgnoreCase(status)) {
                                                                statusClass = "text-white bg-emerald-500";
                                                                btnText = "View Result";
                                                                } else if ("In-Progress".equalsIgnoreCase(status) || "In Progress".equalsIgnoreCase(status)) {
                                                                    statusClass = "text-status-progress bg-blue-50";
                                                                    btnText = "Processing...";
                                                                    btnDisabled = true;
                                                                    } else {
                                                                        statusClass = "text-status-pending bg-slate-200";
                                                                        btnText = "Awaiting Lab";
                                                                        btnDisabled = true;
                                                                    }
                                                                %>
                                                                <li class="flex flex-col gap-2 p-3 bg-white/60 dark:bg-slate-900/40 rounded-lg">
                                                                    <div class="flex justify-between items-start">
                                                                        <div>
                                                                            <p class="text-sm font-bold text-slate-900 dark:text-white"><%= testName %></p>
                                                                            <p class="text-[10px] text-slate-500">REQ #<%= lr.getRequestId() %></p>
                                                                        </div>
                                                                        <span class="text-[10px] font-black px-2 py-0.5 rounded <%= statusClass %>"><%= statusLabel %></span>
                                                                    </div>
                                                                    <%
                                                                        if ("Completed".equalsIgnoreCase(status) && !btnDisabled) {
                                                                        %>
                                                                        <a href="<%= ctx %>/vet/examination?id=<%= ap.getAppointmentId() %>&viewLabRequestId=<%= lr.getRequestId() %>"
                                                                            class="w-full py-2 rounded-lg text-xs font-bold text-center block
                                                                            bg-primary text-white hover:bg-primary/90 transition-all no-underline">
                                                                            View Result
                                                                        </a>
                                                                        <%
                                                                            } else {
                                                                            %>
                                                                            <button type="button"
                                                                            class="w-full py-2 rounded-lg text-xs font-bold transition-all bg-slate-200 text-slate-400 cursor-not-allowed"
                                                                            disabled>
                                                                            <%= btnText %>
                                                                        </button>
                                                                        <%
                                                                        }
                                                                    %>
                                                                </li>
                                                                <%
                                                                }
                                                            }
                                                        %>
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </main>
                </div>
                <%
                    model.LabResultDetail labResultDetail = (model.LabResultDetail) request.getAttribute("labResultDetail");
                    boolean showLabViewer = (labResultDetail != null);
                %>
                <% if (showLabViewer) {
                    String fullNote = labResultDetail.getResultNote() != null ? labResultDetail.getResultNote() : "";
                    String clinicalNote = fullNote;
                    String marker = "[Tech notes]";
                    int markerIdx = fullNote.indexOf(marker);
                    if (markerIdx >= 0) {
                        clinicalNote = fullNote.substring(0, markerIdx).trim();
                    }
                    String resultTime = labResultDetail.getResultDate() != null ? labResultDetail.getResultDate().format(labResultFmt) : "";
                %>
                <!-- Lab Result Viewer Modal (read-only) -->
                <div class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
                    <div class="bg-white dark:bg-slate-900 w-full max-w-4xl shadow-2xl overflow-hidden border border-slate-200 dark:border-slate-800">
                        <div class="px-8 py-6 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between">
                            <div class="space-y-1">
                                <h2 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-[0.25em]">
                                    Laboratory Examination Report
                                </h2>
                                <div class="flex items-center gap-3">
                                    <span class="text-xs font-bold text-slate-400 tracking-wider">
                                        PATIENT ID: <%= labResultDetail.getPatientCode() %>
                                    </span>
                                    <span class="px-2 py-0.5 bg-primary/10 text-primary text-[9px] font-black uppercase tracking-widest rounded-sm border border-primary/20">
                                        Completed
                                    </span>
                                </div>
                            </div>
                            <a href="<%= ctx %>/vet/examination?id=<%= ap.getAppointmentId() %>"
                                class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors">
                                <span class="material-symbols-outlined">close</span>
                            </a>
                        </div>
                        <div class="p-8 max-h-[70vh] overflow-y-auto space-y-6">
                            <div class="flex flex-wrap gap-4 text-xs text-slate-500 dark:text-slate-400 border-b border-slate-100 dark:border-slate-800 pb-4">
                                <span><span class="font-bold text-slate-700 dark:text-slate-200">Test:</span> <%= labResultDetail.getTestName() != null ? labResultDetail.getTestName() : "Lab Test" %></span>
                                <span><span class="font-bold text-slate-700 dark:text-slate-200">Vet:</span> <%= labResultDetail.getVeterinarianName() != null ? labResultDetail.getVeterinarianName() : "—" %></span>
                                <% if (!resultTime.isEmpty()) { %>
                                <span><span class="font-bold text-slate-700 dark:text-slate-200">Reported:</span> <%= resultTime %></span>
                                <% } %>
                            </div>
                            <%
                                String resultImg = labResultDetail.getResultFileUrl();
                                boolean hasFile = resultImg != null && !resultImg.trim().isEmpty();
                                boolean isPdf = hasFile && resultImg.toLowerCase(Locale.ROOT).endsWith(".pdf");
                            %>
                            <% if (hasFile) { %>
                            <section>
                                <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3"><%= isPdf ? "Result (PDF)" : "Result file" %></h3>
                                <div class="rounded-xl border border-slate-200 dark:border-slate-700 overflow-hidden bg-slate-50 dark:bg-slate-900/50 p-2">
                                    <% if (isPdf) { %>
                                    <iframe src="<%= ctx %><%= resultImg %>" title="Lab result PDF" class="w-full min-h-[480px] rounded-lg border-0 bg-white"></iframe>
                                    <p class="text-[10px] text-slate-400 mt-2 px-2"><a href="<%= ctx %><%= resultImg %>" target="_blank" rel="noopener" class="text-primary font-semibold underline">Open PDF in new tab</a></p>
                                    <% } else { %>
                                    <div class="flex justify-center p-4">
                                        <img src="<%= ctx %><%= resultImg %>" alt="Lab result" class="max-w-full max-h-[420px] object-contain rounded-lg"/>
                                    </div>
                                    <% } %>
                                </div>
                            </section>
                            <% } %>
                            <section>
                                <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">Text note</h3>
                                <div class="p-4 bg-slate-50 dark:bg-slate-900/50 border border-slate-100 dark:border-slate-800/50 rounded-xl min-h-[100px]">
                                    <p class="text-sm leading-relaxed text-slate-700 dark:text-slate-300 whitespace-pre-wrap">
                                        <%= !clinicalNote.isEmpty() ? clinicalNote : "—" %>
                                    </p>
                                </div>
                            </section>
                        </div>
                        <div class="px-8 py-6 bg-slate-50 dark:bg-slate-900/50 border-t border-slate-200 dark:border-slate-800 flex items-center justify-end">
                            <a href="<%= ctx %>/vet/examination?id=<%= ap.getAppointmentId() %>"
                                class="bg-primary text-white text-[11px] font-bold px-8 py-2.5 uppercase tracking-[0.15em] hover:brightness-110 transition-all shadow-lg shadow-primary/20">
                                Close
                            </a>
                        </div>
                    </div>
                </div>
                <% } %>
                <!-- Revisit schedule modal removed by design -->

                <script>
                    (function() {
                        var sel = document.getElementById('clinical-condition-select');
                        if (sel) {
                            var base = 'mt-1 w-full max-w-[260px] rounded-full text-[10px] font-bold uppercase tracking-wide px-3 py-2 border-0 cursor-pointer focus:ring-2 focus:ring-primary/30 ';
                            var variants = {
                                stable: 'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-200',
                                monitoring: 'bg-sky-100 text-sky-800 dark:bg-sky-900/40 dark:text-sky-200',
                                follow_up: 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-200',
                                urgent: 'bg-orange-100 text-orange-900 dark:bg-orange-900/40 dark:text-orange-200',
                                critical: 'bg-red-100 text-red-800 dark:bg-red-900/40 dark:text-red-200'
                            };
                            function applyClinicalStyle() {
                                var v = sel.value;
                                sel.className = base + (variants[v] || variants.follow_up);
                            }
                            sel.addEventListener('change', applyClinicalStyle);
                            applyClinicalStyle();
                        }
                    })();
                    (function() {
                        var addBtn = document.getElementById('add-service-btn');
                        var dropdown = document.getElementById('add-service-dropdown');
                        var list = document.getElementById('examination-services-list');
                        var form = document.getElementById('examination-form');
                        var serviceIdsInput = document.getElementById('serviceIds');
                        var serviceQuantitiesInput = document.getElementById('serviceQuantities');
                        
                        function norm(s) {
                            return String(s || '').trim().toLowerCase();
                        }
                        
                        function updateServiceIds() {
                            if (!serviceIdsInput) return;
                            var ids = [];
                            var quantities = [];
                            var seenKeys = new Set();
                            document.querySelectorAll('#examination-services-list .service-row').forEach(function(row) {
                                var id = row.getAttribute('data-service-id');
                                if (!id || id === '') return;
                                var nameKey = norm(row.getAttribute('data-service-name'));
                                if (!nameKey) nameKey = 'id:' + id; // fallback
                                if (seenKeys.has(nameKey)) return;
                                seenKeys.add(nameKey);
                                ids.push(id);
                                var qtyEl = row.querySelector('.service-qty');
                                var qty = qtyEl ? parseInt(qtyEl.textContent, 10) : 1;
                                if (isNaN(qty) || qty < 1) qty = 1;
                                quantities.push(id + ':' + qty);
                            });
                            serviceIdsInput.value = ids.join(',');
                            if (serviceQuantitiesInput) {
                                serviceQuantitiesInput.value = quantities.join(',');
                            }
                        }
                        
                        function bindServiceQuantityControls(row) {
                            if (!row) return;
                            var decBtn = row.querySelector('.service-qty-dec');
                            var incBtn = row.querySelector('.service-qty-inc');
                            var qtyEl = row.querySelector('.service-qty');
                            if (!decBtn || !incBtn || !qtyEl) return;
                            
                            var current = parseInt(qtyEl.textContent, 10);
                            if (isNaN(current) || current < 1) current = 1;
                            qtyEl.textContent = String(current);
                            
                            decBtn.addEventListener('click', function() {
                                var q = parseInt(qtyEl.textContent, 10);
                                if (isNaN(q) || q <= 1) {
                                    qtyEl.textContent = '1';
                                    updateServiceIds();
                                    return;
                                }
                                qtyEl.textContent = String(q - 1);
                                updateServiceIds();
                            });
                            
                            incBtn.addEventListener('click', function() {
                                var q = parseInt(qtyEl.textContent, 10);
                                if (isNaN(q) || q < 1) q = 1;
                                qtyEl.textContent = String(q + 1);
                                updateServiceIds();
                            });
                        }
                        
                        if (form) {
                            form.addEventListener('submit', function() { updateServiceIds(); });
                        }
                        
                        if (addBtn && dropdown) {
                            addBtn.addEventListener('click', function() {
                                dropdown.classList.toggle('hidden');
                            });
                        }
                        if (list && dropdown) {
                            document.querySelectorAll('.add-service-option').forEach(function(btn) {
                                btn.addEventListener('click', function() {
                                    var id = this.getAttribute('data-id');
                                    var name = this.getAttribute('data-name');
                                    
                                    // Prevent duplicates by service name (case-insensitive)
                                    var incomingKey = norm(name);
                                    if (!incomingKey) incomingKey = 'id:' + id;
                                    var exists = false;
                                    list.querySelectorAll('.service-row').forEach(function(row) {
                                        var existingKey = norm(row.getAttribute('data-service-name'));
                                        var existingId = row.getAttribute('data-service-id');
                                        if (!existingKey) existingKey = 'id:' + existingId;
                                        if (existingKey === incomingKey) exists = true;
                                    });
                                    if (exists) {
                                        dropdown.classList.add('hidden');
                                        return;
                                    }
                                    
                                    var row = document.createElement('div');
                                    row.className = 'flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row';
                                    row.setAttribute('data-service-id', id);
                                    row.setAttribute('data-service-name', name);
                                    row.innerHTML = '<div class="flex items-center gap-3"><span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span><span class="text-sm font-semibold text-slate-700 dark:text-slate-200">' + (name || '').replace(/</g, '&lt;') + '</span></div>' +
                                    '<div class="flex items-center gap-2">' +
                                    '<div class="inline-flex items-center rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 overflow-hidden" data-role="service-qty-box">' +
                                    '<button type="button" class="service-qty-dec px-2 py-1 text-slate-500 hover:text-primary hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors" aria-label="Decrease quantity"><span class="material-symbols-outlined text-base">remove</span></button>' +
                                    '<span class="service-qty min-w-[26px] text-center text-xs font-bold text-slate-700 dark:text-slate-200" data-role="service-qty">1</span>' +
                                    '<button type="button" class="service-qty-inc px-2 py-1 text-slate-500 hover:text-primary hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors" aria-label="Increase quantity"><span class="material-symbols-outlined text-base">add</span></button>' +
                                    '</div>' +
                                    '<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">' +
                                    '<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button></div></div>';
                                    row.querySelector('.service-remove').addEventListener('click', function() { row.remove(); });
                                    bindServiceQuantityControls(row);
                                    list.appendChild(row);
                                    dropdown.classList.add('hidden');
                                    updateServiceIds();
                                });
                            });
                        }
                        document.querySelectorAll('#examination-services-list .service-row').forEach(function(row) {
                            bindServiceQuantityControls(row);
                        });
                        document.querySelectorAll('#examination-services-list .service-remove').forEach(function(btn) {
                            btn.addEventListener('click', function() {
                                var row = this.closest('.service-row');
                                if (row) row.remove();
                                updateServiceIds();
                            });
                        });
                        updateServiceIds();
                        
                        // Prescription add/remove
                        var addMedBtn = document.getElementById('add-medication-btn');
                        var prescriptionsList = document.getElementById('prescriptions-list');
                        
                        /* delegated dosage input restriction — works for static + dynamic rows */
                        if (prescriptionsList) {
                            prescriptionsList.addEventListener('input', function(e) {
                                var el = e.target;
                                if (!el.classList.contains('dosage-field')) return;
                                var v = el.value.replace(/[^\d.]/g, '');
                                /* allow only one dot */
                                var parts = v.split('.');
                                if (parts.length > 2) v = parts[0] + '.' + parts.slice(1).join('');
                                el.value = v;
                                el.classList.toggle('border-red-400', v !== '' && !/^\d+(\.\d+)?$/.test(v));
                            });
                        }
                        
                        if (addMedBtn && prescriptionsList) {
                            addMedBtn.addEventListener('click', function() {
                                var row = document.createElement('div');
                                row.className = 'prescription-row flex flex-wrap items-center gap-2';
                                row.innerHTML = '<input name="medication_name" class="flex-1 min-w-[120px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Medication name" type="text"/>' +
                                '<input name="dosage" class="dosage-field w-24 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Dose" type="text"/>' +
                                '<input name="duration" class="flex-1 min-w-[100px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Frequency" type="text"/>' +
                                '<button type="button" class="prescription-remove p-2 text-slate-400 hover:text-primary" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>';
                                row.querySelector('.prescription-remove').addEventListener('click', function() { row.remove(); });
                                prescriptionsList.appendChild(row);
                            });
                        }
                        document.querySelectorAll('#prescriptions-list .prescription-remove').forEach(function(btn) {
                            btn.addEventListener('click', function() {
                                var row = this.closest('.prescription-row');
                                if (row && document.querySelectorAll('#prescriptions-list .prescription-row').length > 1) row.remove();
                            });
                        });
                    })();
                </script>

                <!-- Lab Request Modal -->
                <div class="hidden fixed inset-0 bg-slate-900/70 backdrop-blur-sm z-50 items-center justify-center p-4" id="lab-request-modal">
                    <div class="relative z-20 w-full max-w-xl bg-white dark:bg-slate-900 rounded-2xl shadow-2xl border border-slate-200 dark:border-slate-700 overflow-hidden flex flex-col">
                        <div class="flex items-center justify-between px-8 py-5 border-b border-slate-200 dark:border-slate-800">
                            <div>
                                <h2 class="text-slate-900 dark:text-slate-100 text-xl font-bold tracking-tight">New Lab Request</h2>
                                <p class="text-slate-500 text-xs mt-0.5">Fill in the clinical details for the examination</p>
                            </div>
                            <a href="#" class="text-slate-400 hover:text-primary transition-colors p-1" aria-label="Close">
                                <span class="material-symbols-outlined">close</span>
                            </a>
                        </div>
                        <div class="px-8 py-6 space-y-6">
                            <div class="bg-white dark:bg-slate-900 rounded-2xl p-4 border border-slate-200 dark:border-slate-800 shadow-sm">
                                <div class="grid grid-cols-3 gap-4">
                                    <div>
                                        <p class="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-0.5">Patient</p>
                                        <div class="flex items-center gap-2">
                                            <span class="material-symbols-outlined text-primary text-sm">pets</span>
                                            <p class="text-slate-900 dark:text-slate-100 font-semibold text-sm"><%= petName %></p>
                                        </div>
                                    </div>
                                    <div>
                                        <p class="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-0.5">Breed</p>
                                        <p class="text-slate-900 dark:text-slate-100 font-semibold text-sm"><%= breed.isEmpty() ? "—" : breed %></p>
                                    </div>
                                    <div>
                                        <p class="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-0.5">Owner</p>
                                        <p class="text-slate-900 dark:text-slate-100 font-semibold text-sm"><%= ownerName %></p>
                                    </div>
                                </div>
                            </div>
                            <form class="space-y-5" id="lab-request-form" action="<%= ctx %>/vet/lab-request" method="post">
                                <input type="hidden" name="appointmentId" value="<%= ap.getAppointmentId() %>"/>
                                <div class="space-y-1.5">
                                    <label class="text-slate-700 dark:text-slate-300 text-xs font-bold uppercase tracking-wide flex items-center gap-1.5">
                                        <span class="material-symbols-outlined text-primary text-base">biotech</span>
                                        Lab Test Type
                                    </label>
                                    <div class="relative">
                                        <select class="w-full h-11 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-4 text-slate-900 dark:text-slate-100 focus:ring-2 focus:ring-primary focus:border-transparent appearance-none cursor-pointer text-sm" name="serviceId" required>
                                            <option disabled selected value="">Select examination type...</option>
                                            <%
                                                java.util.Set<String> seenLabServiceNames = new java.util.HashSet<>();
                                                for (Service svc : labTestServices) {
                                                    String svcName = svc.getName();
                                                    if (svcName == null || svcName.isEmpty()) continue;
                                                    if (seenLabServiceNames.contains(svcName)) continue;
                                                    seenLabServiceNames.add(svcName);
                                                %>
                                                <option value="<%= svc.getServiceId() %>"><%= svcName %></option>
                                                <% } %>
                                            </select>
                                            <span class="material-symbols-outlined absolute right-3 top-2.5 text-slate-400 pointer-events-none">expand_more</span>
                                        </div>
                                    </div>
                                    <div class="space-y-1.5">
                                        <label class="text-slate-700 dark:text-slate-300 text-xs font-bold uppercase tracking-wide flex items-center gap-1.5">
                                            <span class="material-symbols-outlined text-primary text-base">description</span>
                                            Clinical Notes
                                        </label>
                                        <textarea class="w-full min-h-[120px] bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg p-3 text-slate-900 dark:text-slate-100 text-sm focus:ring-2 focus:ring-primary focus:border-transparent placeholder:text-slate-400 resize-none" name="clinicalNotes" placeholder="Provide clinical observations or reason for request..."></textarea>
                                    </div>
                                </form>
                            </div>
                            <div class="px-8 py-5 border-t border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-end gap-3">
                                <a href="#" class="px-5 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-sm font-semibold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                                    Cancel
                                </a>
                                <button type="submit" form="lab-request-form" class="px-7 py-2.5 rounded-lg bg-primary text-white font-semibold text-sm shadow-lg shadow-primary/20 hover:brightness-110 active:scale-[0.98] transition-all flex items-center gap-2">
                                    <span>Submit Request</span>
                                    <span class="material-symbols-outlined text-base">send</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <script>
                    (function () {
                        /* ── localStorage autosave ── */
                        const STORAGE_KEY = 'exam_draft_<%= ap.getAppointmentId() %>';
                        
                        const diagnosisEl     = document.querySelector('textarea[name="diagnosis"]');
                        const conclusionEl    = document.querySelector('textarea[name="conclusion"]');
                        const noteEl          = document.querySelector('textarea[name="note"]');
                        const prescriptionsList = document.getElementById('prescriptions-list');
                        const examForm        = document.getElementById('examination-form');
                        const labForm         = document.getElementById('lab-request-form');
                        
                        function escHtml(s) {
                            return String(s || '')
                            .replace(/&/g, '&amp;').replace(/</g, '&lt;')
                            .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
                        }
                        
                        function makePrescriptionRow(name, dosage, duration) {
                            const row = document.createElement('div');
                            row.className = 'prescription-row flex flex-wrap items-center gap-2';
                            row.innerHTML =
                            '<input name="medication_name" class="flex-1 min-w-[120px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Medication name" type="text" value="' + escHtml(name) + '"/>' +
                            '<input name="dosage" class="dosage-field w-24 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Dose" type="text" value="' + escHtml(dosage) + '"/>' +
                            '<input name="duration" class="flex-1 min-w-[100px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Frequency" type="text" value="' + escHtml(duration) + '"/>' +
                            '<button type="button" class="prescription-remove p-2 text-slate-400 hover:text-primary" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>';
                            row.querySelector('.prescription-remove').addEventListener('click', function () {
                                if (prescriptionsList && prescriptionsList.querySelectorAll('.prescription-row').length > 1) row.remove();
                                saveDraft();
                            });
                            return row;
                        }
                        
                        function collectDraft() {
                            const prescriptions = [];
                            if (prescriptionsList) {
                                prescriptionsList.querySelectorAll('.prescription-row').forEach(function (row) {
                                    const n = (row.querySelector('input[name="medication_name"]') || {}).value || '';
                                    const d = (row.querySelector('input[name="dosage"]') || {}).value || '';
                                    const u = (row.querySelector('input[name="duration"]') || {}).value || '';
                                    prescriptions.push({ n: n, d: d, u: u });
                                });
                            }
                            return {
                                diagnosis:     diagnosisEl  ? diagnosisEl.value  : '',
                                conclusion:    conclusionEl ? conclusionEl.value : '',
                                note:          noteEl       ? noteEl.value       : '',
                                prescriptions: prescriptions
                            };
                        }
                        
                        function saveDraft() {
                            try { localStorage.setItem(STORAGE_KEY, JSON.stringify(collectDraft())); } catch (e) {}
                        }
                        
                        function clearDraft() {
                            try { localStorage.removeItem(STORAGE_KEY); } catch (e) {}
                        }
                        window._examClearDraft = clearDraft;
                        
                        function restoreDraft() {
                            try {
                                const raw = localStorage.getItem(STORAGE_KEY);
                                if (!raw) return;
                                const draft = JSON.parse(raw);
                                
                                if (diagnosisEl && draft.diagnosis !== undefined)
                                diagnosisEl.value = draft.diagnosis;
                                if (conclusionEl && draft.conclusion !== undefined)
                                conclusionEl.value = draft.conclusion;
                                // Observation is the same as Diagnosis.
                                if (noteEl && diagnosisEl)
                                noteEl.value = diagnosisEl.value;
                                
                                if (Array.isArray(draft.prescriptions) && draft.prescriptions.length > 0 && prescriptionsList) {
                                    prescriptionsList.querySelectorAll('.prescription-row').forEach(function (r) { r.remove(); });
                                    draft.prescriptions.forEach(function (p) {
                                        prescriptionsList.appendChild(makePrescriptionRow(p.n, p.d, p.u));
                                    });
                                }
                            } catch (e) {}
                        }
                        
                        /* debounced autosave on every keystroke */
                        let saveTimer;
                        function debouncedSave() {
                            clearTimeout(saveTimer);
                            saveTimer = setTimeout(saveDraft, 700);
                        }
                        
                        if (diagnosisEl)      diagnosisEl.addEventListener('input', debouncedSave);
                        if (conclusionEl)    conclusionEl.addEventListener('input', debouncedSave);
                        if (noteEl)           noteEl.addEventListener('input', debouncedSave);
                        if (prescriptionsList) prescriptionsList.addEventListener('input', debouncedSave);
                        
                        /* track which exam-form button was clicked */
                        let pendingAction = null;
                        document.querySelectorAll('button[name="action"]').forEach(function (btn) {
                            btn.addEventListener('click', function () { pendingAction = this.value; });
                        });
                        
                        if (examForm) {
                            examForm.addEventListener('submit', function () {
                                if (pendingAction === 'complete') {
                                    clearDraft();
                                    } else {
                                        saveDraft();
                                    }
                                    pendingAction = null;
                                });
                            }
                            
                            /* restore saved draft immediately on page load */
                            restoreDraft();
                            
                            /* ── server autosave + lab request submit ── */
                            if (!examForm || !labForm) return;
                            
                            // Add/increment lab service only when user submits lab request.
                            const ensureSelectedLabServiceInExam = (function () {
                                const testSelect = labForm.querySelector('select[name="serviceId"]');
                                const servicesList = document.getElementById('examination-services-list');
                                const serviceIdsInput = document.getElementById('serviceIds');
                                const serviceQuantitiesInput = document.getElementById('serviceQuantities');
                                if (!testSelect || !servicesList || !serviceIdsInput) return function () {};
                                
                                const norm = (s) => String(s || '').trim().toLowerCase();
                                
                                function updateServiceIds() {
                                    const ids = [];
                                    const quantities = [];
                                    const seenKeys = new Set();
                                    servicesList.querySelectorAll('.service-row').forEach(function (r) {
                                        const id = r.getAttribute('data-service-id');
                                        if (!id || id === '') return;
                                        const nameKey = String(r.getAttribute('data-service-name') || '').trim().toLowerCase();
                                        const key = nameKey ? nameKey : ('id:' + id);
                                        if (seenKeys.has(key)) return;
                                        seenKeys.add(key);
                                        ids.push(id);
                                        const qtyEl = r.querySelector('.service-qty');
                                        let qty = qtyEl ? parseInt(qtyEl.textContent, 10) : 1;
                                        if (Number.isNaN(qty) || qty < 1) qty = 1;
                                        quantities.push(id + ':' + qty);
                                    });
                                    serviceIdsInput.value = ids.join(',');
                                    if (serviceQuantitiesInput) serviceQuantitiesInput.value = quantities.join(',');
                                }
                                
                                function lockLabRow(row) {
                                    if (!row) return;
                                    row.setAttribute('data-lab-locked', 'true');
                                    row.querySelectorAll('.service-qty-dec, .service-qty-inc, .service-remove').forEach(function (btn) {
                                        btn.disabled = true;
                                        btn.classList.add('pointer-events-none', 'opacity-40');
                                    });
                                    if (!row.querySelector('.lab-locked-tag')) {
                                        const nameWrap = row.querySelector('.flex.items-center.gap-3');
                                        if (nameWrap) {
                                            const tag = document.createElement('span');
                                            tag.className = 'lab-locked-tag text-[10px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-200';
                                            tag.textContent = 'Lab Requested';
                                            nameWrap.appendChild(tag);
                                        }
                                    }
                                }

                                function ensureServiceForSelectedTest() {
                                    const serviceId = testSelect.value;
                                    const testName = (testSelect.options[testSelect.selectedIndex] && testSelect.options[testSelect.selectedIndex].text) || '';
                                    const testNorm = norm(testName);
                                    if (!serviceId || !testNorm) return;
                                    
                                    // If row already exists, +1 quantity and lock it.
                                    let existingRow = null;
                                    servicesList.querySelectorAll('.service-row').forEach(function (row) {
                                        if (norm(row.getAttribute('data-service-name')) === testNorm) existingRow = row;
                                    });
                                    if (existingRow) {
                                        const qtyEl = existingRow.querySelector('.service-qty');
                                        let qty = qtyEl ? parseInt(qtyEl.textContent, 10) : 1;
                                        if (Number.isNaN(qty) || qty < 1) qty = 1;
                                        if (qtyEl) qtyEl.textContent = String(qty + 1);
                                        lockLabRow(existingRow);
                                        updateServiceIds();
                                        return;
                                    }
                                    
                                    const displayName = String(testName);
                                    const row = document.createElement('div');
                                    row.className = 'flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row';
                                    row.setAttribute('data-service-id', String(serviceId));
                                    row.setAttribute('data-service-name', displayName);
                                    row.innerHTML =
                                    '<div class="flex items-center gap-3">' +
                                    '<span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span>' +
                                    '<span class="text-sm font-semibold text-slate-700 dark:text-slate-200">' + escHtml(displayName) + '</span>' +
                                    '<span class="lab-locked-tag text-[10px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-200">Lab Requested</span>' +
                                    '</div>' +
                                    '<div class="flex items-center gap-2">' +
                                    '<div class="inline-flex items-center rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 overflow-hidden" data-role="service-qty-box">' +
                                    '<button type="button" class="service-qty-dec px-2 py-1 text-slate-500 transition-colors pointer-events-none opacity-40" disabled aria-label="Decrease quantity"><span class="material-symbols-outlined text-base">remove</span></button>' +
                                    '<span class="service-qty min-w-[26px] text-center text-xs font-bold text-slate-700 dark:text-slate-200" data-role="service-qty">1</span>' +
                                    '<button type="button" class="service-qty-inc px-2 py-1 text-slate-500 transition-colors pointer-events-none opacity-40" disabled aria-label="Increase quantity"><span class="material-symbols-outlined text-base">add</span></button>' +
                                    '</div>' +
                                    '<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">' +
                                    '<button type="button" class="p-1 text-slate-400 transition-colors service-remove pointer-events-none opacity-40" disabled aria-label="Remove">' +
                                    '<span class="material-symbols-outlined text-lg">delete</span></button></div></div>';
                                    servicesList.appendChild(row);
                                    lockLabRow(row);
                                    updateServiceIds();
                                }

                                return function () {
                                    ensureServiceForSelectedTest();
                                    updateServiceIds();
                                };
                            })();
                            
                            // Ensure hidden serviceIds is always synced from current DOM rows.
                            function syncServiceIdsFromRows() {
                                const serviceIdsInput = document.getElementById('serviceIds');
                                const serviceQuantitiesInput = document.getElementById('serviceQuantities');
                                const servicesList = document.getElementById('examination-services-list');
                                if (!serviceIdsInput || !servicesList) return;
                                const ids = [];
                                const quantities = [];
                                const seenKeys = new Set();
                                servicesList.querySelectorAll('.service-row').forEach(function (r) {
                                    const id = r.getAttribute('data-service-id');
                                    if (!id || id === '') return;
                                    const nameKey = String(r.getAttribute('data-service-name') || '').trim().toLowerCase();
                                    const key = nameKey ? nameKey : ('id:' + id);
                                    if (seenKeys.has(key)) return;
                                    seenKeys.add(key);
                                    ids.push(id);
                                    const qtyEl = r.querySelector('.service-qty');
                                    let qty = qtyEl ? parseInt(qtyEl.textContent, 10) : 1;
                                    if (Number.isNaN(qty) || qty < 1) qty = 1;
                                    quantities.push(id + ':' + qty);
                                });
                                serviceIdsInput.value = ids.join(',');
                                if (serviceQuantitiesInput) {
                                    serviceQuantitiesInput.value = quantities.join(',');
                                }
                            }
                            
                            let isSubmitting = false;
                            labForm.addEventListener('submit', async function (e) {
                                if (isSubmitting) return;
                                e.preventDefault();
                                
                                // Guarantee selected lab service appears in Services before autosave.
                                ensureSelectedLabServiceInExam();
                                syncServiceIdsFromRows();
                                
                                saveDraft(); /* persist to localStorage before any network call */
                                
                                const submitBtn = document.querySelector('button[type="submit"][form="lab-request-form"]');
                                if (submitBtn) submitBtn.disabled = true;
                                
                                try {
                                    const saveData = new FormData(examForm);
                                    saveData.set('action', 'save');
                                    const saveResp = await fetch('<%= ctx %>/vet/examination', {
                                        method: 'POST',
                                        body: saveData,
                                        credentials: 'same-origin'
                                    });
                                    
                                    if (!saveResp.ok) throw new Error('Autosave failed');
                                    
                                    isSubmitting = true;
                                    labForm.submit();
                                    } catch (err) {
                                        if (submitBtn) submitBtn.disabled = false;
                                        alert('Could not save examination draft before sending lab request. Please try again.');
                                    }
                                });
                            })();
                        </script>

                        <input type="hidden" id="pending-lab-count" value="<%= pendingLabCount %>"/>

                        <script>
                            (function () {
                                const PENDING_LAB_COUNT = parseInt(
                                (document.getElementById('pending-lab-count') || {}).value || '0',
                                10
                                );
                                const completeBtn   = document.getElementById('complete-exam-btn');
                                const examForm      = document.getElementById('examination-form');
                                const completeError = document.getElementById('complete-error');
                                
                                /* ── helpers ── */
                                function setFieldError(el, hasError) {
                                    if (!el) return;
                                    if (hasError) {
                                        el.classList.add('border-red-400', 'ring-1', 'ring-red-300');
                                        el.classList.remove('border-slate-200', 'dark:border-slate-700');
                                        } else {
                                            el.classList.remove('border-red-400', 'ring-1', 'ring-red-300');
                                            el.classList.add('border-slate-200', 'dark:border-slate-700');
                                        }
                                    }
                                    
                                    function showBanner(msg) {
                                        if (!completeError) return;
                                        completeError.textContent = msg;
                                        completeError.classList.remove('hidden');
                                        clearTimeout(completeError._timer);
                                        completeError._timer = setTimeout(function () {
                                            completeError.classList.add('hidden');
                                        }, 5000);
                                    }
                                    
                                    /* ── full validation — returns true if valid ── */
                                    function runValidations() {
                                        var valid = true;
                                        var firstInvalidEl = null;
                                        
                                        /* 1. Diagnosis required */
                                        var diagnosisEl    = document.getElementById('diagnosis-textarea');
                                        var diagnosisErrEl = document.getElementById('diagnosis-error');
                                        var diagnosisEmpty = diagnosisEl && !diagnosisEl.value.trim();
                                        setFieldError(diagnosisEl, diagnosisEmpty);
                                        if (diagnosisErrEl) diagnosisErrEl.classList.toggle('hidden', !diagnosisEmpty);
                                        if (diagnosisEmpty) {
                                            valid = false;
                                            if (!firstInvalidEl) firstInvalidEl = diagnosisEl;
                                        }

                                        /* 1.5 Conclusion required */
                                        var conclusionEl = document.getElementById('conclusion-textarea');
                                        var conclusionErrEl = document.getElementById('conclusion-error');
                                        var conclusionEmpty = conclusionEl && !conclusionEl.value.trim();
                                        setFieldError(conclusionEl, conclusionEmpty);
                                        if (conclusionErrEl) conclusionErrEl.classList.toggle('hidden', !conclusionEmpty);
                                        if (conclusionEmpty) {
                                            valid = false;
                                            if (!firstInvalidEl) firstInvalidEl = conclusionEl;
                                            showBanner('Conclusion is required to complete the examination.');
                                        }
                                        
                                        /* 2. At least one service */
                                        var serviceRows = document.querySelectorAll('#examination-services-list .service-row');
                                        if (serviceRows.length === 0) {
                                            valid = false;
                                            showBanner('Please add at least one service before completing the examination.');
                                        }
                                        
                                        /* 3. Prescription rows: if name filled → dosage (required + numeric) + duration required */
                                        var rxBannerMsg = null;
                                        document.querySelectorAll('#prescriptions-list .prescription-row').forEach(function (row) {
                                            var nameEl     = row.querySelector('input[name="medication_name"]');
                                            var dosageEl   = row.querySelector('.dosage-field');
                                            var durationEl = row.querySelector('input[name="duration"]');
                                            
                                            if (!nameEl || !nameEl.value.trim()) {
                                                /* empty row — clear any previous errors */
                                                setFieldError(dosageEl,   false);
                                                setFieldError(durationEl, false);
                                                return;
                                            }
                                            
                                            /* dosage: required */
                                            var dosageVal     = dosageEl   ? dosageEl.value.trim()   : '';
                                            var durationVal   = durationEl ? durationEl.value.trim() : '';
                                            var dosageEmpty   = !dosageVal;
                                            var dosageNaN     = dosageVal && !/^\d+(\.\d+)?$/.test(dosageVal);
                                            var durationEmpty = !durationVal;
                                            
                                            setFieldError(dosageEl,   dosageEmpty || dosageNaN);
                                            setFieldError(durationEl, durationEmpty);
                                            
                                            if (dosageEmpty || durationEmpty) {
                                                valid = false;
                                                rxBannerMsg = 'Please fill in dosage and frequency for all medications.';
                                                if (!firstInvalidEl) firstInvalidEl = dosageEmpty ? dosageEl : durationEl;
                                                } else if (dosageNaN) {
                                                    valid = false;
                                                    rxBannerMsg = 'Dosage must be a number (e.g. 100 or 2.5).';
                                                    if (!firstInvalidEl) firstInvalidEl = dosageEl;
                                                }
                                            });
                                            if (rxBannerMsg && serviceRows.length > 0) showBanner(rxBannerMsg);
                                            
                                            /* scroll to first problem */
                                            if (firstInvalidEl) {
                                                firstInvalidEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                                firstInvalidEl.focus();
                                            }
                                            
                                            return valid;
                                        }
                                        
                                        /* ── actual submit ── */
                                        function doComplete() {
                                            if (!runValidations()) return;
                                            
                                            // Ensure backend "note/observation" (hidden textarea) matches Diagnosis.
                                            var diagnosisEl = document.getElementById('diagnosis-textarea');
                                            var noteHiddenEl = document.getElementById('observation-textarea');
                                            if (noteHiddenEl && diagnosisEl) noteHiddenEl.value = diagnosisEl.value;
                                            
                                            var serviceIdsInput = document.getElementById('serviceIds');
                                            var serviceQuantitiesInput = document.getElementById('serviceQuantities');
                                            if (serviceIdsInput) {
                                                var ids = [];
                                                var quantities = [];
                                                var seenKeys = new Set();
                                                document.querySelectorAll('#examination-services-list .service-row').forEach(function (r) {
                                                    var id = r.getAttribute('data-service-id');
                                                    if (!id || id === '') return;
                                                    var nameKey = String(r.getAttribute('data-service-name') || '').trim().toLowerCase();
                                                    var key = nameKey ? nameKey : ('id:' + id);
                                                    if (seenKeys.has(key)) return;
                                                    seenKeys.add(key);
                                                    ids.push(id);
                                                    var qtyEl = r.querySelector('.service-qty');
                                                    var qty = qtyEl ? parseInt(qtyEl.textContent, 10) : 1;
                                                    if (isNaN(qty) || qty < 1) qty = 1;
                                                    quantities.push(id + ':' + qty);
                                                });
                                                serviceIdsInput.value = ids.join(',');
                                                if (serviceQuantitiesInput) {
                                                    serviceQuantitiesInput.value = quantities.join(',');
                                                }
                                            }
                                            
                                            if (window._examClearDraft) window._examClearDraft();
                                            var actionInput   = document.createElement('input');
                                            actionInput.type  = 'hidden';
                                            actionInput.name  = 'action';
                                            actionInput.value = 'complete';
                                            examForm.appendChild(actionInput);
                                            examForm.submit();
                                        }
                                        
                                        /* ── complete button click ── */
                                        if (completeBtn) {
                                            completeBtn.addEventListener('click', function () {
                                                if (!runValidations()) return;
                                                if (PENDING_LAB_COUNT > 0) {
                                                    showBanner('Cannot complete examination while lab requests are still pending. Complete them in the lab queue first.');
                                                    return;
                                                }
                                                doComplete();
                                            });
                                        }
                                        
                                        /* clear field errors when user starts correcting */
                                        var diagnosisEl = document.getElementById('diagnosis-textarea');
                                        if (diagnosisEl) {
                                            diagnosisEl.addEventListener('input', function () {
                                                var errEl = document.getElementById('diagnosis-error');
                                                if (this.value.trim()) {
                                                    setFieldError(this, false);
                                                    if (errEl) errEl.classList.add('hidden');
                                                }
                                                // Observation is the same field (hidden) as Diagnosis.
                                                if (noteEl) noteEl.value = this.value;
                                            });
                                        }
                                        
                                    })();
                                </script>
                                <%@ include file="/WEB-INF/includes/vet-header-right-script.jspf" %>

                            </body>
                        </html>
