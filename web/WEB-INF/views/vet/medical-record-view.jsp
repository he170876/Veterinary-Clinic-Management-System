<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.MedicalRecord" %>
<%@ page import="model.Visit" %>
<%@ page import="model.Pet" %>
<%@ page import="model.Customer" %>
<%@ page import="model.RecordServiceLine" %>
<%@ page import="model.Prescription" %>
<%@ page import="model.LabTestRequest" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) request.getAttribute("user");
    MedicalRecord record = (MedicalRecord) request.getAttribute("record");
    Visit visit = (Visit) request.getAttribute("visit");
    Pet pet = (Pet) request.getAttribute("pet");
    Customer customer = (Customer) request.getAttribute("customer");
    @SuppressWarnings("unchecked")
    List<RecordServiceLine> services = (List<RecordServiceLine>) request.getAttribute("services");
    if (services == null) services = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<Prescription> prescriptions = (List<Prescription>) request.getAttribute("prescriptions");
    if (prescriptions == null) prescriptions = java.util.Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<LabTestRequest> labRequests = (List<LabTestRequest>) request.getAttribute("labRequests");
    if (labRequests == null) labRequests = java.util.Collections.emptyList();
    String durationLabel = (String) request.getAttribute("durationLabel");
    if (durationLabel == null) durationLabel = "—";
    String concludedAt = (String) request.getAttribute("concludedAt");
    if (concludedAt == null) concludedAt = "";
    String ctx = request.getContextPath();
    String recordCode = "MR-" + (record != null ? record.getRecordId() : 0);
    int petId = (visit != null) ? visit.getPetId() : (pet != null ? pet.getPetId() : 0);
    String patientId = "PA-" + petId;
    String petName = pet != null && pet.getName() != null ? pet.getName() : "—";
    String species = pet != null && pet.getSpecies() != null ? pet.getSpecies() : "—";
    String breed = pet != null && pet.getBreed() != null ? pet.getBreed() : "—";
    String ownerName = (customer != null && customer.getUser() != null && customer.getUser().getFullName() != null)
            ? customer.getUser().getFullName() : "—";
    String diagnosis = record != null && record.getDiagnosis() != null ? record.getDiagnosis() : "—";
    String note = record != null && record.getNote() != null ? record.getNote() : "";
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats Medical Record - Read Only View</title>
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
                    fontFamily: {
                        "display": ["Manrope"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"},
                },
            },
        }
    </script>
    <style>
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 font-display">
<div class="flex min-h-screen">
    <%@ include file="/WEB-INF/views/vet/_sidebar.jspf" %>
    <main class="flex-1 flex flex-col h-screen overflow-hidden">
        <header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 flex items-center justify-between px-8 shrink-0 gap-4">
            <div class="flex items-center gap-3 min-w-0">
                <h2 class="text-xl font-bold text-slate-900 dark:text-slate-100 truncate">Medical Record Detail</h2>
                <span class="text-xs px-2 py-1 rounded-full bg-primary/10 text-primary font-bold shrink-0">#<%= recordCode %></span>
            </div>
            <div class="flex items-center gap-3 flex-wrap justify-end">
                <a class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-slate-700 dark:text-slate-300 bg-slate-100 dark:bg-slate-800 rounded-lg hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors shrink-0"
                   href="<%= ctx %>/vet/records">
                    <span class="material-symbols-outlined text-sm">arrow_back</span>
                    Back to List
                </a>
                <button class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-white bg-primary rounded-lg hover:bg-primary/90 shadow-sm transition-colors shrink-0" type="button">
                    <span class="material-symbols-outlined text-sm">print</span>
                    Print Record
                </button>
                <%@ include file="/WEB-INF/includes/vet-header-right.jspf" %>
            </div>
        </header>
        <div class="flex-1 overflow-y-auto p-8 bg-slate-50 dark:bg-slate-900/50">
            <div class="max-w-5xl mx-auto space-y-6">
                <div class="bg-white dark:bg-slate-950 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm p-6">
                    <div class="flex items-center justify-between mb-5">
                        <div>
                            <h3 class="text-lg font-bold">Visit Summary</h3>
                            <p class="text-sm text-slate-500"><% if (!concludedAt.isEmpty()) { %>Concluded on <%= concludedAt %><% } else { %>No conclusion time<% } %></p>
                        </div>
                        <span class="inline-flex px-3 py-1 rounded-full text-xs font-bold bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400">Completed</span>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 bg-slate-50 dark:bg-slate-900/30 border border-slate-200 dark:border-slate-800 rounded-xl p-4">
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Patient ID</label>
                                <p class="text-sm font-semibold text-slate-900 dark:text-slate-100"><%= patientId %></p>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Name</label>
                                <p class="text-sm font-semibold text-slate-900 dark:text-slate-100"><%= petName %></p>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Species / Breed</label>
                                <p class="text-sm font-semibold text-slate-900 dark:text-slate-100"><%= species %> / <%= breed %></p>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Owner</label>
                                <p class="text-sm font-semibold text-slate-900 dark:text-slate-100"><%= ownerName %></p>
                            </div>
                        </div>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Attending Doctor</label>
                                <div class="flex items-center gap-2">
                                    <span class="material-symbols-outlined text-slate-400 text-lg">medical_services</span>
                                    <p class="text-sm font-semibold text-slate-900 dark:text-slate-100"><%= user != null ? user.getFullName() : "" %></p>
                                </div>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Duration</label>
                                <p class="text-sm font-semibold text-slate-900 dark:text-slate-100"><%= durationLabel %></p>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Referral</label>
                                <p class="text-sm font-semibold text-slate-900 dark:text-slate-100">N/A</p>
                            </div>
                    </div>
                </div>

                <div class="bg-white dark:bg-slate-950 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm p-6">
                    <h3 class="text-lg font-bold text-primary mb-4">1. Observation</h3>
                    <div class="rounded-lg border border-primary/20 bg-primary/5 p-4">
                        <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Clinical Observation</p>
                        <p class="text-sm text-slate-700 dark:text-slate-300 leading-relaxed whitespace-pre-line"><%= !note.isEmpty() ? note : diagnosis %></p>
                    </div>
                </div>

                <div class="bg-white dark:bg-slate-950 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm p-6">
                    <h3 class="text-lg font-bold text-primary mb-4">2. Lab Test Results</h3>
                        <% if (labRequests.isEmpty()) { %>
                            <p class="text-sm text-slate-500 dark:text-slate-400">No lab tests for this record.</p>
                        <% } else { %>
                            <div class="space-y-2">
                                <% for (LabTestRequest req : labRequests) {
                                       String testName = req.getTestName() != null ? req.getTestName() : "Lab Test";
                                       String status = req.getStatus() != null ? req.getStatus() : "Pending";
                                       String resultNote = req.getResultNote() != null ? req.getResultNote() : "";
                                       String resultFileUrl = req.getResultFileUrl() != null ? req.getResultFileUrl().trim() : "";
                                       String resolvedFileUrl = "";
                                       if (!resultFileUrl.isEmpty()) {
                                           resolvedFileUrl = resultFileUrl.startsWith("http://") || resultFileUrl.startsWith("https://")
                                                   ? resultFileUrl
                                                   : ctx + (resultFileUrl.startsWith("/") ? resultFileUrl : "/" + resultFileUrl);
                                       }
                                %>
                                <div class="p-3 rounded-lg border border-slate-100 dark:border-slate-800 space-y-2">
                                    <div class="flex items-center justify-between">
                                        <p class="text-sm font-semibold text-slate-900 dark:text-slate-100"><%= testName %></p>
                                        <span class="px-2 py-1 rounded-full text-[10px] font-bold <%= "Completed".equalsIgnoreCase(status) ? "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" : "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400" %>"><%= status %></span>
                                    </div>
                                    <div class="text-xs text-slate-600 dark:text-slate-300">
                                        <span class="font-semibold">Note:</span>
                                        <span><%= !resultNote.isEmpty() ? resultNote : "No note." %></span>
                                    </div>
                                    <div class="text-xs">
                                        <% if (!resolvedFileUrl.isEmpty()) { %>
                                            <a class="text-primary font-semibold hover:underline" href="<%= resolvedFileUrl %>" target="_blank" rel="noopener">Open Uploaded Result File</a>
                                        <% } else { %>
                                            <span class="text-slate-500 dark:text-slate-400">No uploaded file.</span>
                                        <% } %>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        <% } %>
                </div>

                <div class="bg-white dark:bg-slate-950 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm p-6">
                    <h3 class="text-lg font-bold text-primary mb-4">3. Medications</h3>
                        <div class="space-y-3">
                            <%
                                for (Prescription pr : prescriptions) {
                                    String medName = pr.getMedicineName() != null ? pr.getMedicineName() : "";
                                    String dose = pr.getDosage() != null ? pr.getDosage() : "";
                                    String dur = pr.getDuration() != null ? pr.getDuration() : "";
                            %>
                            <div class="flex items-start gap-4 p-4 border border-slate-100 dark:border-slate-800 rounded-lg">
                                <span class="material-symbols-outlined text-primary">pill</span>
                                <div>
                                    <p class="text-sm font-bold text-slate-900 dark:text-slate-100"><%= medName %></p>
                                    <p class="text-xs text-slate-500 font-medium">Dosage: <%= dose %></p>
                                    <p class="text-xs text-slate-400 mt-2">Instructions: <%= dur %></p>
                                </div>
                            </div>
                            <%
                                }
                                if (prescriptions.isEmpty()) {
                            %>
                            <p class="text-sm text-slate-500 dark:text-slate-400">No prescriptions were recorded for this visit.</p>
                            <%
                                }
                            %>
                        </div>
                </div>

                <div class="bg-white dark:bg-slate-950 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm p-6">
                    <h3 class="text-lg font-bold text-primary mb-4">4. Conclusion</h3>
                        <%
                            String conclusion = record != null && record.getConclusion() != null ? record.getConclusion() : "No conclusion recorded.";
                        %>
                        <div class="mb-4 p-4 border border-primary/20 bg-primary/5 rounded-lg">
                            <p class="text-sm text-slate-700 dark:text-slate-300 whitespace-pre-line"><%= conclusion %></p>
                        </div>
                        <ul class="divide-y divide-slate-100 dark:divide-slate-900">
                            <%
                                if (services.isEmpty()) {
                            %>
                            <li class="py-3 text-sm text-slate-500 dark:text-slate-400">No procedure lines were attached to this record.</li>
                            <%
                                } else {
                                    for (RecordServiceLine line : services) {
                                        String svcName = line.getServiceName() != null ? line.getServiceName() : "Service";
                                        int qty = line.getQuantity();
                            %>
                            <li class="py-2 text-sm">
                                <span class="text-slate-600 dark:text-slate-400">
                                    <%= svcName %><% if (qty > 1) { %> (x<%= qty %>)<% } %>
                                </span>
                            </li>
                            <%
                                    }
                                }
                            %>
                        </ul>
                </div>
                <div class="text-center pb-12">
                    <p class="text-[10px] text-slate-400 uppercase tracking-widest font-bold">Official Medical Document - Confidential</p>
                    <p class="text-[10px] text-slate-400 mt-1">
                        Electronically signed by <%= user != null ? user.getFullName() : "" %>
                    </p>
                </div>
            </div>
        </div>
    </main>
</div>
<%@ include file="/WEB-INF/includes/vet-header-right-script.jspf" %>
</body>
</html>

