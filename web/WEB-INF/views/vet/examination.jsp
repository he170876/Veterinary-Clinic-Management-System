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
        #revisit-modal:target { display: flex; }
        #lab-request-modal:target { display: flex; }
        .revisit-time.revisit-time-selected { border-color: #f14437; color: #f14437; background: rgba(241,68,55,0.08); }
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
<div class="size-9 rounded-full bg-slate-200 dark:bg-slate-700 overflow-hidden flex items-center justify-center text-primary font-bold">
<% if (user.getProfilePictureUrl() != null && !user.getProfilePictureUrl().isEmpty()) { %>
<img alt="Doctor Profile" class="w-full h-full object-cover" src="<%= ctx %><%= user.getProfilePictureUrl() %>"/>
<% } else { %>
<%= (user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "?" %>
<% } %>
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
<textarea name="diagnosis" class="w-full rounded-xl border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white focus:ring-primary focus:border-primary placeholder:text-slate-400 p-4" placeholder="Describe symptoms, physical exam findings, and preliminary diagnosis..." rows="6"><%= diagnosisText %></textarea>
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
<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-edit" aria-label="Edit"><span class="material-symbols-outlined text-lg">edit</span></button>
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
<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-edit" aria-label="Edit"><span class="material-symbols-outlined text-lg">edit</span></button>
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
<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-edit" aria-label="Edit"><span class="material-symbols-outlined text-lg">edit</span></button>
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
<% for (Service svc : clinicServices) { %>
<button type="button" class="add-service-option w-full text-left px-3 py-2 text-sm text-slate-700 dark:text-slate-200 hover:bg-primary/10 rounded-lg flex justify-between items-center" data-id="<%= svc.getServiceId() %>" data-name="<%= svc.getName() %>"><span><%= svc.getName() %></span><span class="text-xs text-slate-400"><%= String.format("%.2f", svc.getPrice()) %> </span></button>
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
<input name="dosage" class="w-24 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Dose" type="text" value="<%= d %>"/>
<input name="duration" class="flex-1 min-w-[100px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Frequency" type="text" value="<%= du %>"/>
<button type="button" class="prescription-remove p-2 text-slate-400 hover:text-primary" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
</div>
<% } %>
<div class="prescription-row flex flex-wrap items-center gap-2">
<input name="medication_name" class="flex-1 min-w-[120px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Medication name" type="text"/>
<input name="dosage" class="w-24 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Dose" type="text"/>
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
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-slate-400 text-lg">event_repeat</span>
<select class="flex-1 rounded-lg border border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2">
<option>Schedule next checkup</option>
<option>In 3 days</option>
<option>In 1 week</option>
<option>In 2 weeks</option>
</select>
</div>
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
<a class="w-full border-2 border-primary text-primary py-3 rounded-xl font-bold text-sm flex items-center justify-center gap-2 hover:bg-primary/5 transition-all text-center cursor-pointer" href="#revisit-modal">
<span class="material-symbols-outlined text-xl">event_available</span>
                                Schedule Revisit
                            </a>
</div>
<div class="space-y-3">
<hr class="border-slate-100 dark:border-slate-800 my-4"/>
<button type="submit" form="examination-form" name="action" value="complete" class="w-full bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 py-4 rounded-xl font-bold text-lg hover:scale-[1.02] transition-transform shadow-lg shadow-slate-900/10">
                                Complete Examination
                            </button>
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
    if (labRequests.isEmpty()) {
%>
<li class="text-slate-500 dark:text-slate-400">No lab requests have been created for this visit.</li>
<%
    } else {
        for (LabTestRequest lr : labRequests) {
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
    <div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
        <h4 class="text-sm font-bold text-slate-400 uppercase tracking-widest mb-4 flex items-center gap-2">
            <span class="material-symbols-outlined text-sm text-primary">science</span>
            Recent Lab Results
        </h4>
        <%
            if (recentLabResults.isEmpty()) {
        %>
        <p class="text-xs text-slate-500 dark:text-slate-400">No lab results available for this patient in the last 14 days.</p>
        <%
            } else {
        %>
        <ul class="space-y-3 text-xs">
            <%
                for (LabResultSummary res : recentLabResults) {
                    String testName = res.getTestName() != null ? res.getTestName() : "—";
                    String value = res.getResultValue() != null ? res.getResultValue() : "";
                    String note = res.getResultNote() != null ? res.getResultNote() : "";
                    String when = res.getResultDate() != null ? res.getResultDate().format(labResultFmt) : "";
            %>
            <li class="flex flex-col gap-1 p-3 bg-slate-50 dark:bg-slate-900/40 rounded-lg">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-sm font-bold text-slate-900 dark:text-white"><%= testName %></p>
                        <p class="text-[10px] text-slate-500"><%= when %></p>
                    </div>
                </div>
                <%
                    if (!value.isEmpty()) {
                %>
                <p class="text-xs text-slate-700 dark:text-slate-200"><span class="font-semibold">Value:</span> <%= value %></p>
                <%
                    }
                    if (!note.isEmpty()) {
                %>
                <p class="text-[11px] text-slate-500 dark:text-slate-400 line-clamp-3"><%= note %></p>
                <%
                    }
                %>
            </li>
            <%
                }
            %>
        </ul>
        <%
            }
        %>
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
<div class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 items-center justify-center p-4" id="revisit-modal">
<div class="bg-white dark:bg-slate-900 w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
<div class="p-6 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center">
<h3 class="text-lg font-bold text-slate-900 dark:text-white flex items-center gap-2">
<span class="material-symbols-outlined text-primary">calendar_month</span>
                Schedule Follow-up
            </h3>
<a class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200" href="#" aria-label="Close"><span class="material-symbols-outlined">close</span></a>
</div>
<form id="revisit-form" action="<%= ctx %>/vet/schedule-revisit" method="post" class="p-8 space-y-6">
<input type="hidden" name="petId" value="<%= petId %>"/>
<input type="hidden" name="customerId" value="<%= cust != null ? cust.getCustomerId() : "" %>"/>
<input type="hidden" name="veterinarianId" value="<%= ap.getVeterinarianId() %>"/>
<input type="hidden" name="revisitTime" id="revisitTimeInput" value="10:30"/>
<div>
<label class="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2" for="revisitDateInput">Preferred Date</label>
<input id="revisitDateInput" class="w-full rounded-xl border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white focus:ring-primary focus:border-primary p-3" type="date" name="revisitDate" required/>
</div>
<div>
<label class="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Preferred Time</label>
<div class="grid grid-cols-3 gap-2" id="revisit-time-buttons">
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors" data-time="09:00">09:00 AM</button>
<button type="button" class="revisit-time revisit-time-selected py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors" data-time="10:30">10:30 AM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors" data-time="13:00">01:00 PM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors" data-time="14:30">02:30 PM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors" data-time="16:00">04:00 PM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors" data-time="17:30">05:30 PM</button>
</div>
</div>
<div class="pt-2">
<button type="submit" form="revisit-form" class="w-full bg-primary text-white py-3.5 rounded-xl font-bold text-sm flex items-center justify-center gap-2 shadow-lg shadow-primary/20 hover:bg-primary/90 transition-all">
                    Confirm Appointment
                </button>
</div>
</form>
</div>
</div>

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
                    '<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-edit" aria-label="Edit"><span class="material-symbols-outlined text-lg">edit</span></button>' +
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

    // Revisit modal: time selection and prescription add/remove
    var revisitTimeInput = document.getElementById('revisitTimeInput');
    document.querySelectorAll('.revisit-time').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var time = this.getAttribute('data-time');
            if (time && revisitTimeInput) {
                revisitTimeInput.value = time;
                document.querySelectorAll('.revisit-time').forEach(function(b) { b.classList.remove('revisit-time-selected'); });
                this.classList.add('revisit-time-selected');
            }
        });
    });
    var addMedBtn = document.getElementById('add-medication-btn');
    var prescriptionsList = document.getElementById('prescriptions-list');
    if (addMedBtn && prescriptionsList) {
        addMedBtn.addEventListener('click', function() {
            var row = document.createElement('div');
            row.className = 'prescription-row flex flex-wrap items-center gap-2';
            row.innerHTML = '<input name="medication_name" class="flex-1 min-w-[120px] rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Medication name" type="text"/>' +
                '<input name="dosage" class="w-24 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Dose" type="text"/>' +
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
<div class="relative z-20 w-full max-w-xl bg-white dark:bg-slate-900 rounded-xl shadow-2xl overflow-hidden flex flex-col">
<div class="flex items-center justify-between px-8 py-5 border-b border-slate-100 dark:border-slate-800">
<div>
<h2 class="text-slate-900 dark:text-slate-100 text-xl font-bold tracking-tight">New Lab Request</h2>
<p class="text-slate-500 text-xs mt-0.5">Fill in the clinical details for the examination</p>
</div>
<a href="#" class="text-slate-400 hover:text-primary transition-colors p-1" aria-label="Close">
<span class="material-symbols-outlined">close</span>
</a>
</div>
<div class="px-8 py-6 space-y-6">
<div class="bg-slate-50 dark:bg-slate-800/50 rounded-lg p-4 border border-slate-100 dark:border-slate-800">
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
<% for (LabTest lt : labTests) { %>
<option value="<%= lt.getTestId() %>"><%= lt.getTestName() != null ? lt.getTestName() : "" %></option>
<% } %>
</select>
<span class="material-symbols-outlined absolute right-3 top-2.5 text-slate-400 pointer-events-none">expand_more</span>
</div>
</div>
<div class="space-y-1.5">
<label class="text-slate-700 dark:text-slate-300 text-xs font-bold uppercase tracking-wide flex items-center gap-1.5">
<span class="material-symbols-outlined text-primary text-base">priority_high</span>
                    Priority Level
                </label>
<div class="flex h-10 bg-slate-100 dark:bg-slate-800 rounded-lg p-1 gap-1">
<label class="flex-1 flex items-center justify-center cursor-pointer rounded-md transition-all has-[:checked]:bg-white dark:has-[:checked]:bg-slate-700 has-[:checked]:shadow-sm has-[:checked]:text-slate-900 text-slate-500 font-semibold text-xs">
<input checked class="hidden" name="priority" type="radio" value="normal"/>
<span>Normal</span>
</label>
<label class="flex-1 flex items-center justify-center cursor-pointer rounded-md transition-all has-[:checked]:bg-primary has-[:checked]:text-white text-slate-500 font-semibold text-xs">
<input class="hidden" name="priority" type="radio" value="urgent"/>
<span>Urgent</span>
</label>
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
<div class="px-8 py-5 border-t border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/50 flex items-center justify-end gap-3">
<a href="#" class="px-5 py-2 rounded-lg text-slate-600 dark:text-slate-400 font-bold text-sm hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors">
            Cancel
        </a>
<button type="submit" form="lab-request-form" class="px-7 py-2.5 rounded-lg bg-primary text-white font-bold text-sm shadow-md shadow-primary/20 hover:brightness-110 active:scale-[0.98] transition-all flex items-center gap-2">
<span>Submit Request</span>
<span class="material-symbols-outlined text-base">send</span>
</button>
</div>
</div>
</div>
</div>

</body>
</html>
