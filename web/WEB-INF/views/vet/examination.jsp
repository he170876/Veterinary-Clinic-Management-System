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
<%@ page import="java.util.List" %>
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
    int petId = (pet != null) ? pet.getPetId() : 0;
    String patientId = "#ANP-" + petId;
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
    List<LabTest> labTests = (List<LabTest>) request.getAttribute("labTests");
    if (labTests == null) labTests = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<Prescription> prescriptions = (List<Prescription>) request.getAttribute("prescriptions");
    if (prescriptions == null) prescriptions = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<LabResultSummary> recentLabResults = (List<LabResultSummary>) request.getAttribute("recentLabResults");
    if (recentLabResults == null) recentLabResults = java.util.Collections.emptyList();
    String diagnosisText = (medicalRecord != null && medicalRecord.getDiagnosis() != null) ? medicalRecord.getDiagnosis() : "";
    String treatmentText = (medicalRecord != null && medicalRecord.getTreatment() != null) ? medicalRecord.getTreatment() : "";
    String noteText = (medicalRecord != null && medicalRecord.getNote() != null) ? medicalRecord.getNote() : "";
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
<main class="flex-1 flex flex-col">
<header class="h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-8 shrink-0">
<div class="flex items-center gap-4">
<h2 class="text-slate-800 dark:text-white font-bold text-lg">Current Examination</h2>
</div>
<div class="flex items-center gap-6">
<div class="relative w-64">
<span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xl">search</span>
<input class="w-full pl-10 pr-4 py-1.5 bg-slate-100 dark:bg-slate-800 border-none rounded-lg text-sm focus:ring-2 focus:ring-primary/20" placeholder="Search patient or owner..." type="text"/>
</div>
<div class="flex items-center gap-3">
<%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
<div class="flex items-center gap-2 pl-3 border-l border-slate-200 dark:border-slate-800">
<div class="text-right hidden sm:block">
<p class="text-xs font-bold text-slate-900 dark:text-white leading-none"><%= user.getFullName() %></p>
<p class="text-[10px] text-slate-500"><%= roleTitle %></p>
</div>
<div class="relative">
    <button type="button"
            id="vet-profile-toggle"
            class="size-9 rounded-full bg-slate-200 dark:bg-slate-700 overflow-hidden flex items-center justify-center text-primary font-bold hover:brightness-95 transition-colors">
        <% if (user.getProfilePictureUrl() != null && !user.getProfilePictureUrl().isEmpty()) { %>
        <img alt="Doctor Profile" class="w-full h-full object-cover" src="<%= ctx %><%= user.getProfilePictureUrl() %>"/>
        <% } else { %>
        <%= (user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "?" %>
        <% } %>
    </button>
    <div id="vet-profile-menu"
         class="absolute right-0 mt-2 w-56 origin-top-right rounded-xl bg-white dark:bg-slate-900 shadow-lg border border-slate-200 dark:border-slate-800 z-50"
         style="display:none;">
        <a href="<%= ctx %>/vet/profile"
           class="block px-4 py-3 text-sm font-bold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors rounded-t-xl flex items-center gap-2">
            <span class="material-symbols-outlined text-base text-primary">person</span>
            <span>My Profile</span>
        </a>
        <a href="<%= ctx %>/logout"
           class="block px-4 py-3 text-sm font-bold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors rounded-b-xl flex items-center gap-2">
            <span class="material-symbols-outlined text-base text-primary">logout</span>
            <span>Sign out</span>
        </a>
    </div>
</div>
</div>
</div>
</div>
</header>
<form id="examination-form" action="<%= ctx %>/vet/examination" method="post">
<input type="hidden" name="appointmentId" value="<%= ap.getAppointmentId() %>"/>
<input type="hidden" name="serviceIds" id="serviceIds" value=""/>
<div class="flex-1 overflow-y-auto px-8 py-8">
<div class="max-w-6xl mx-auto space-y-6">
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
<p class="text-slate-500">Patient ID: <span class="font-mono text-slate-700 dark:text-slate-300"><%= patientId %></span> | Owner: <%= ownerName %></p>
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
<span class="px-2 py-0.5 bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300 text-[10px] font-bold rounded uppercase">Follow-up Required</span>
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
    Diagnosis &amp; Observation is required to complete the examination.
</p>
</div>
<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
<div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
<h4 class="text-md font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
<span class="material-symbols-outlined text-primary text-xl">payments</span>
                                Services
                            </h4>
<div class="space-y-3" id="examination-services-list">
<% if (!recordServices.isEmpty()) {
    for (RecordServiceLine line : recordServices) { %>
<div class="flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row" data-service-id="<%= line.getServiceId() %>" data-service-name="<%= line.getServiceName() != null ? line.getServiceName() : "" %>">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span>
<span class="text-sm font-semibold text-slate-700 dark:text-slate-200"><%= line.getServiceName() != null ? line.getServiceName() : "" %></span>
</div>
<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
</div>
</div>
<% }
} else if (ap.getServiceId() != null && ap.getService() != null) { %>
<div class="flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row" data-service-id="<%= ap.getServiceId() %>" data-service-name="<%= ap.getService() %>">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span>
<span class="text-sm font-semibold text-slate-700 dark:text-slate-200"><%= ap.getService() %></span>
</div>
<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
</div>
</div>
<% } else { %>
<div class="flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row" data-service-id="" data-service-name="General Consultation">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span>
<span class="text-sm font-semibold text-slate-700 dark:text-slate-200">General Consultation</span>
</div>
<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
</div>
</div>
<% } %>
</div>
<button type="button" id="add-service-btn" class="w-full py-2 border-2 border-dashed border-slate-200 dark:border-slate-700 rounded-lg text-slate-400 text-xs font-bold hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                                    + ADD SERVICE
                                </button>
<% if (!clinicServices.isEmpty()) { %>
<div id="add-service-dropdown" class="hidden mt-2 p-2 bg-slate-50 dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 max-h-48 overflow-y-auto">
<%
    java.util.Set<Integer> seenServiceIds = new java.util.HashSet<>();
    for (Service svc : clinicServices) {
        if (svc == null) continue;
        int sid = svc.getServiceId();
        if (seenServiceIds.contains(sid)) continue;
        seenServiceIds.add(sid);
%>
<button type="button" class="add-service-option w-full text-left px-3 py-2 text-sm text-slate-700 dark:text-slate-200 hover:bg-primary/10 rounded-lg flex justify-between items-center" data-id="<%= sid %>" data-name="<%= svc.getName() %>"><span><%= svc.getName() %></span><span class="text-xs text-slate-400"><%= String.format("%.2f", svc.getPrice()) %> </span></button>
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
<div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm md:col-span-2 lg:col-span-1">
<h4 class="text-md font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
<span class="material-symbols-outlined text-primary text-xl">vaccines</span>
                                Treatment Plan
                            </h4>
<div class="space-y-3">
<textarea name="treatment" class="w-full rounded-lg border border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm" placeholder="Step-by-step treatment instructions..." rows="3"><%= treatmentText %></textarea>
</div>
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
<p class="text-center text-[10px] text-slate-400 italic">Completing will finalize the medical record and generate billing charges.</p>
</div>
    </div>
    <div class="bg-primary/5 rounded-xl p-6 border border-primary/10">
<h4 class="text-sm font-bold text-primary mb-3 flex items-center gap-2">
<span class="material-symbols-outlined text-sm">history</span>
                            Lab Requests Status
                        </h4>
<ul class="space-y-3 text-xs">
<%
    @SuppressWarnings("unchecked")
    java.util.List<LabTestRequest> labRequests = (java.util.List<LabTestRequest>) request.getAttribute("labRequests");
    if (labRequests == null) labRequests = java.util.Collections.emptyList();
    int pendingLabCount = 0;
    for (LabTestRequest _lr : labRequests) {
        if (visit != null && _lr.getVisitId() == visit.getVisitId()
                && !"Completed".equalsIgnoreCase(_lr.getStatus() != null ? _lr.getStatus() : "")) {
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
       String techNote = "";
       String marker = "[Tech notes]";
       int markerIdx = fullNote.indexOf(marker);
       if (markerIdx >= 0) {
           clinicalNote = fullNote.substring(0, markerIdx).trim();
           techNote = fullNote.substring(markerIdx + marker.length()).trim();
       }
       String resultTime = labResultDetail.getResultDate() != null ? labResultDetail.getResultDate().format(labResultFmt) : "";
       String resultValue = labResultDetail.getResultValue() != null ? labResultDetail.getResultValue() : "-";
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
        <div class="p-8 grid grid-cols-12 gap-8 max-h-[70vh] overflow-y-auto">
            <div class="col-span-12 lg:col-span-5 space-y-8">
                <section>
                    <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">1. Test Summary</h3>
                    <div class="p-4 bg-slate-50 dark:bg-slate-900/50 border border-slate-100 dark:border-slate-800/50 space-y-4">
                        <div>
                            <p class="text-[9px] text-slate-400 uppercase tracking-wider mb-1">Examination Procedure</p>
                            <p class="text-xs font-bold text-slate-800 dark:text-slate-200">
                                <%= labResultDetail.getTestName() != null ? labResultDetail.getTestName() : "Lab Test" %>
                            </p>
                        </div>
                        <div>
                            <p class="text-[9px] text-slate-400 uppercase tracking-wider mb-1">Requesting Veterinarian</p>
                            <p class="text-xs font-bold text-slate-800 dark:text-slate-200">
                                <%= labResultDetail.getVeterinarianName() != null ? labResultDetail.getVeterinarianName() : user.getFullName() %>
                            </p>
                        </div>
                    </div>
                </section>
                <section>
                    <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">2. Quantitative Findings</h3>
                    <div class="border border-slate-100 dark:border-slate-800/50">
                        <table class="w-full text-xs">
                            <thead>
                            <tr class="bg-slate-50 dark:bg-slate-900/80">
                                <th class="px-3 py-2 text-left font-bold text-slate-400 uppercase text-[9px]">Parameter</th>
                                <th class="px-3 py-2 text-right font-bold text-slate-400 uppercase text-[9px]">Value</th>
                            </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
                            <tr>
                                <td class="px-3 py-3 text-slate-600 dark:text-slate-400">Primary Result</td>
                                <td class="px-3 py-3 text-right font-bold text-primary">
                                    <%= resultValue %>
                                </td>
                            </tr>
                            <% if (!resultTime.isEmpty()) { %>
                            <tr>
                                <td class="px-3 py-3 text-slate-600 dark:text-slate-400">Reported At</td>
                                <td class="px-3 py-3 text-right font-bold text-slate-800 dark:text-slate-200">
                                    <%= resultTime %>
                                </td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
            <div class="col-span-12 lg:col-span-7 space-y-8">
                <section>
                    <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">3. Clinical Observations</h3>
                    <div class="p-4 bg-slate-50 dark:bg-slate-900/50 border border-slate-100 dark:border-slate-800/50 min-h-[140px]">
                        <p class="text-xs leading-relaxed text-slate-700 dark:text-slate-300">
                            <%= !clinicalNote.isEmpty() ? clinicalNote : "No detailed clinical observations recorded for this result." %>
                        </p>
                    </div>
                </section>
                <section>
                    <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">4. Technician Notes</h3>
                    <div class="p-4 bg-slate-100/50 dark:bg-slate-900/30 border-l-2 border-slate-300 dark:border-slate-700">
                        <p class="text-[11px] italic text-slate-500 dark:text-slate-400">
                            <%= !techNote.isEmpty() ? techNote : "No separate technician notes were captured for this result." %>
                        </p>
                    </div>
                </section>
            </div>
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
    var addBtn = document.getElementById('add-service-btn');
    var dropdown = document.getElementById('add-service-dropdown');
    var list = document.getElementById('examination-services-list');
    var form = document.getElementById('examination-form');
    var serviceIdsInput = document.getElementById('serviceIds');

    function updateServiceIds() {
        if (!serviceIdsInput) return;
        var ids = [];
        document.querySelectorAll('#examination-services-list .service-row').forEach(function(row) {
            var id = row.getAttribute('data-service-id');
            if (id && id !== '') ids.push(id);
        });
        serviceIdsInput.value = ids.join(',');
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
                var row = document.createElement('div');
                row.className = 'flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row';
                row.setAttribute('data-service-id', id);
                row.setAttribute('data-service-name', name);
                row.innerHTML = '<div class="flex items-center gap-3"><span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span><span class="text-sm font-semibold text-slate-700 dark:text-slate-200">' + (name || '').replace(/</g, '&lt;') + '</span></div>' +
                    '<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">' +
                    '<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button></div>';
                row.querySelector('.service-remove').addEventListener('click', function() { row.remove(); });
                list.appendChild(row);
                dropdown.classList.add('hidden');
            });
        });
    }
    document.querySelectorAll('#examination-services-list .service-remove').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var row = this.closest('.service-row');
            if (row) row.remove();
        });
    });

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
<select class="w-full h-11 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-4 text-slate-900 dark:text-slate-100 focus:ring-2 focus:ring-primary focus:border-transparent appearance-none cursor-pointer text-sm" name="testId" required>
<option disabled selected value="">Select examination type...</option>
<%
    java.util.Set<String> seenLabTestNames = new java.util.HashSet<>();
    for (LabTest lt : labTests) {
        String ltName = lt.getTestName();
        if (ltName == null || ltName.isEmpty()) continue;
        if (seenLabTestNames.contains(ltName)) continue;
        seenLabTestNames.add(ltName);
%>
<option value="<%= lt.getTestId() %>"><%= ltName %></option>
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
        const treatmentEl     = document.querySelector('textarea[name="treatment"]');
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
                treatment:     treatmentEl  ? treatmentEl.value  : '',
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
                if (treatmentEl && draft.treatment !== undefined)
                    treatmentEl.value = draft.treatment;

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
        if (treatmentEl)      treatmentEl.addEventListener('input', debouncedSave);
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

        // Nếu user chọn Lab Test Type trước khi submit, auto-add service vào Services (UI)
        (function () {
            const testSelect = labForm.querySelector('select[name="testId"]');
            const servicesList = document.getElementById('examination-services-list');
            const serviceIdsInput = document.getElementById('serviceIds');
            if (!testSelect || !servicesList || !serviceIdsInput) return;

            const norm = (s) => String(s || '').trim().toLowerCase();

            function updateServiceIds() {
                const ids = [];
                servicesList.querySelectorAll('.service-row').forEach(function (r) {
                    const id = r.getAttribute('data-service-id');
                    if (id && id !== '') ids.push(id);
                });
                serviceIdsInput.value = ids.join(',');
            }

            async function ensureServiceForSelectedTest() {
                const testId = testSelect.value;
                const testName = (testSelect.options[testSelect.selectedIndex] && testSelect.options[testSelect.selectedIndex].text) || '';
                const testNorm = norm(testName);
                if (!testId || !testNorm) return;

                // Avoid duplicates by service name
                let exists = false;
                servicesList.querySelectorAll('.service-row').forEach(function (row) {
                    if (norm(row.getAttribute('data-service-name')) === testNorm) exists = true;
                });
                if (exists) return;

                try {
                    const r = await fetch('<%= ctx %>/vet/lab-service?testId=' + encodeURIComponent(testId), {
                        credentials: 'same-origin'
                    });
                    if (!r.ok) return;
                    const json = await r.json();
                    if (!json || !json.success || !json.serviceId) return;

                    const displayName = String(json.serviceName || testName);
                    const row = document.createElement('div');
                    row.className = 'flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row';
                    row.setAttribute('data-service-id', String(json.serviceId));
                    row.setAttribute('data-service-name', displayName);
                    row.innerHTML =
                        '<div class="flex items-center gap-3">' +
                        '<span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span>' +
                        '<span class="text-sm font-semibold text-slate-700 dark:text-slate-200">' + escHtml(displayName) + '</span>' +
                        '</div>' +
                        '<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">' +
                        '<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove" aria-label="Remove">' +
                        '<span class="material-symbols-outlined text-lg">delete</span></button></div>';
                    row.querySelector('.service-remove').addEventListener('click', function () { row.remove(); updateServiceIds(); });
                    servicesList.appendChild(row);
                    updateServiceIds();
                } catch (e) {
                    // ignore
                }
            }

            testSelect.addEventListener('change', function () {
                ensureServiceForSelectedTest();
            });
        })();

        let isSubmitting = false;
        labForm.addEventListener('submit', async function (e) {
            if (isSubmitting) return;
            e.preventDefault();

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

<!-- Pending Lab Requests Warning Modal -->
<div id="pending-lab-modal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 items-center justify-center p-4">
    <div class="bg-white dark:bg-slate-900 w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
        <div class="p-6 border-b border-slate-100 dark:border-slate-800 flex items-start gap-4">
            <div class="shrink-0 size-10 rounded-full bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
                <span class="material-symbols-outlined text-amber-500 text-xl">warning</span>
            </div>
            <div>
                <h3 class="text-base font-bold text-slate-900 dark:text-white">Pending Lab Requests</h3>
                <p class="text-sm text-slate-500 dark:text-slate-400 mt-1">
                    There <span id="pending-lab-word">are</span>
                    <span class="font-bold text-amber-600" id="pending-lab-count"><%= pendingLabCount %></span>
                    pending lab request<span id="pending-lab-plural">s</span> that have not been completed yet.
                    These requests will remain open but the examination record will be finalized.
                </p>
            </div>
        </div>
        <div class="p-5 bg-slate-50/60 dark:bg-slate-900/50 flex items-center justify-end gap-3">
            <button type="button" id="pending-lab-cancel"
                    class="px-5 py-2 rounded-lg text-slate-600 dark:text-slate-400 font-bold text-sm hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors">
                Go Back
            </button>
            <button type="button" id="pending-lab-confirm"
                    class="px-6 py-2.5 rounded-lg bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 font-bold text-sm hover:brightness-110 transition-all shadow-md">
                Complete Anyway
            </button>
        </div>
    </div>
</div>

<script>
(function () {
    const PENDING_LAB_COUNT = <%= pendingLabCount %>;
    const completeBtn   = document.getElementById('complete-exam-btn');
    const modal         = document.getElementById('pending-lab-modal');
    const cancelBtn     = document.getElementById('pending-lab-cancel');
    const confirmBtn    = document.getElementById('pending-lab-confirm');
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

    /* ── modal ── */
    function showCompleteModal() {
        if (!modal) return;
        var word   = document.getElementById('pending-lab-word');
        var plural = document.getElementById('pending-lab-plural');
        if (word)   word.textContent   = PENDING_LAB_COUNT === 1 ? 'is' : 'are';
        if (plural) plural.textContent = PENDING_LAB_COUNT === 1 ? ''   : 's';
        modal.classList.remove('hidden');
        modal.classList.add('flex');
    }

    function hideModal() {
        if (!modal) return;
        modal.classList.add('hidden');
        modal.classList.remove('flex');
    }

    /* ── actual submit ── */
    function doComplete() {
        hideModal();
        if (!runValidations()) return;

        var serviceIdsInput = document.getElementById('serviceIds');
        if (serviceIdsInput) {
            var ids = [];
            document.querySelectorAll('#examination-services-list .service-row').forEach(function (r) {
                var id = r.getAttribute('data-service-id');
                if (id && id !== '') ids.push(id);
            });
            serviceIdsInput.value = ids.join(',');
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
                showCompleteModal();
            } else {
                doComplete();
            }
        });
    }

    if (cancelBtn)  cancelBtn.addEventListener('click', hideModal);
    if (confirmBtn) confirmBtn.addEventListener('click', doComplete);

    if (modal) {
        modal.addEventListener('click', function (e) {
            if (e.target === modal) hideModal();
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
        });
    }

    // Profile dropdown toggle (header)
    var vetToggle = document.getElementById('vet-profile-toggle');
    var vetMenu = document.getElementById('vet-profile-menu');
    if (vetToggle && vetMenu) {
        vetToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            vetMenu.style.display = (vetMenu.style.display === 'none' || vetMenu.style.display === '') ? 'block' : 'none';
        });
        document.addEventListener('click', function(e) {
            if (!vetMenu.contains(e.target) && !vetToggle.contains(e.target)) {
                vetMenu.style.display = 'none';
            }
        });
    }
})();
</script>

</body>
</html>
