<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.MedicalRecord" %>
<%@ page import="model.Visit" %>
<%@ page import="model.Pet" %>
<%@ page import="model.Customer" %>
<%@ page import="model.RecordServiceLine" %>
<%@ page import="model.Prescription" %>
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
    String durationLabel = (String) request.getAttribute("durationLabel");
    if (durationLabel == null) durationLabel = "—";
    String concludedAt = (String) request.getAttribute("concludedAt");
    if (concludedAt == null) concludedAt = "";
    Double totalAmount = (Double) request.getAttribute("totalAmount");
    if (totalAmount == null) totalAmount = 0.0;

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
    <!-- Sidebar -->
    <aside class="w-64 border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 flex flex-col shrink-0">
        <div class="p-6 flex items-center gap-3">
            <div class="text-primary">
                <span class="material-symbols-outlined text-4xl">pets</span>
            </div>
            <div>
                <h1 class="text-lg font-extrabold leading-tight tracking-tight">Anipats</h1>
                <p class="text-xs text-slate-500 dark:text-slate-400 uppercase tracking-widest font-bold">Veterinary Sys</p>
            </div>
        </div>
        <nav class="flex-1 px-4 space-y-1">
            <a class="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-900 rounded-lg transition-colors" href="<%= ctx %>/vet/dashboard">
                <span class="material-symbols-outlined">dashboard</span>
                <span class="text-sm font-medium">Dashboard</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-900 rounded-lg transition-colors" href="<%= ctx %>/vet/queue">
                <span class="material-symbols-outlined">group</span>
                <span class="text-sm font-medium">Patients</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 bg-primary/10 text-primary rounded-lg transition-colors" href="<%= ctx %>/vet/records">
                <span class="material-symbols-outlined">description</span>
                <span class="text-sm font-bold">Medical Records</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-900 rounded-lg transition-colors" href="#">
                <span class="material-symbols-outlined">inventory_2</span>
                <span class="text-sm font-medium">Inventory</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-900 rounded-lg transition-colors" href="#">
                <span class="material-symbols-outlined">settings</span>
                <span class="text-sm font-medium">Settings</span>
            </a>
        </nav>
        <div class="p-4 border-t border-slate-200 dark:border-slate-800">
            <div class="flex items-center gap-3 px-2 py-2">
                <div class="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold text-xs">
                    <%= (user != null && user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "V" %>
                </div>
                <div class="overflow-hidden">
                    <p class="text-xs font-bold truncate"><%= user != null ? user.getFullName() : "" %></p>
                    <p class="text-[10px] text-slate-500 uppercase">Veterinarian</p>
                </div>
            </div>
        </div>
    </aside>
    <!-- Main Content -->
    <main class="flex-1 flex flex-col h-screen overflow-hidden">
        <!-- Header -->
        <header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 flex items-center justify-between px-8 shrink-0">
            <div class="flex items-center gap-2 text-slate-500 text-sm">
                <a class="hover:text-primary transition-colors" href="<%= ctx %>/vet/records">Medical Records</a>
                <span class="material-symbols-outlined text-sm">chevron_right</span>
                <span class="text-slate-900 dark:text-slate-100 font-medium">Record #<%= recordCode %></span>
            </div>
            <div class="flex items-center gap-3">
                <a class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-slate-700 dark:text-slate-300 bg-slate-100 dark:bg-slate-800 rounded-lg hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors"
                   href="<%= ctx %>/vet/records">
                    <span class="material-symbols-outlined text-sm">arrow_back</span>
                    Back to List
                </a>
                <button class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-white bg-primary rounded-lg hover:bg-primary/90 shadow-sm transition-colors" type="button">
                    <span class="material-symbols-outlined text-sm">print</span>
                    Print Record
                </button>
            </div>
        </header>
        <!-- Scrollable Report Area -->
        <div class="flex-1 overflow-y-auto p-8 bg-slate-50 dark:bg-slate-900/50">
            <div class="max-w-4xl mx-auto space-y-6">
                <!-- Report Title Card -->
                <div class="bg-white dark:bg-slate-950 p-8 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
                    <div class="flex justify-between items-start border-b border-slate-100 dark:border-slate-900 pb-6 mb-8">
                        <div>
                            <span class="inline-block px-2 py-1 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 text-[10px] font-bold uppercase tracking-wider rounded mb-2">Completed</span>
                            <h2 class="text-3xl font-black text-slate-900 dark:text-slate-100 tracking-tight leading-tight">
                                Examination Report: Record #<%= recordCode %>
                            </h2>
                            <p class="text-slate-500 dark:text-slate-400 mt-1">
                                <% if (!concludedAt.isEmpty()) { %>
                                Concluded on <%= concludedAt %>
                                <% } %>
                            </p>
                        </div>
                        <div class="text-right">
                            <p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Facility</p>
                            <p class="font-bold text-slate-900 dark:text-slate-100">Anipats Central Clinic</p>
                            <p class="text-sm text-slate-500">Exam Room #04</p>
                        </div>
                    </div>
                    <!-- 1. Patient Summary -->
                    <section class="mb-10">
                        <div class="flex items-center gap-2 mb-4">
                            <div class="w-1 h-6 bg-primary rounded-full"></div>
                            <h3 class="text-lg font-bold text-primary tracking-tight">1. Patient Summary</h3>
                        </div>
                        <div class="grid grid-cols-4 gap-6 bg-slate-50/50 dark:bg-slate-900/30 p-5 rounded-lg border border-slate-100 dark:border-slate-800">
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
                    </section>
                    <!-- 2. Consultation Details -->
                    <section class="mb-10">
                        <div class="flex items-center gap-2 mb-4">
                            <div class="w-1 h-6 bg-primary rounded-full"></div>
                            <h3 class="text-lg font-bold text-primary tracking-tight">2. Consultation Details</h3>
                        </div>
                        <div class="grid grid-cols-3 gap-6">
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
                    </section>
                    <!-- 3. Clinical Findings -->
                    <section class="mb-10">
                        <div class="flex items-center gap-2 mb-4">
                            <div class="w-1 h-6 bg-primary rounded-full"></div>
                            <h3 class="text-lg font-bold text-primary tracking-tight">3. Clinical Findings</h3>
                        </div>
                        <div class="space-y-4">
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Presented Symptoms / Notes</label>
                                <p class="text-sm text-slate-700 dark:text-slate-300 leading-relaxed italic bg-slate-50 dark:bg-slate-900/30 p-3 rounded-lg border-l-4 border-slate-200 dark:border-slate-800">
                                    <%= !note.isEmpty() ? note : "No additional notes were recorded for this examination." %>
                                </p>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Diagnosis</label>
                                <div class="p-3 bg-primary/5 border border-primary/20 rounded-lg">
                                    <p class="text-sm font-bold text-slate-900 dark:text-slate-100"><%= diagnosis %></p>
                                </div>
                            </div>
                        </div>
                    </section>
                    <!-- 4. Lab Results (from examination page viewer, optional) -->
                    <!-- For now we leave static placeholder or hook in later from lab results if needed -->
                    <!-- 5. Prescription & Treatment Plan -->
                    <section class="mb-10">
                        <div class="flex items-center gap-2 mb-4">
                            <div class="w-1 h-6 bg-primary rounded-full"></div>
                            <h3 class="text-lg font-bold text-primary tracking-tight">5. Prescription &amp; Treatment Plan</h3>
                        </div>
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
                            <%
                                String treatment = record != null && record.getTreatment() != null ? record.getTreatment() : "";
                                if (!treatment.isEmpty()) {
                            %>
                            <div class="flex items-start gap-4 p-4 border border-slate-100 dark:border-slate-800 rounded-lg">
                                <span class="material-symbols-outlined text-primary">potted_plant</span>
                                <div>
                                    <p class="text-sm font-bold text-slate-900 dark:text-slate-100">Treatment Plan</p>
                                    <p class="text-xs text-slate-500 font-medium"><%= treatment %></p>
                                </div>
                            </div>
                            <%
                                }
                            %>
                        </div>
                    </section>
                    <!-- 6. Services Rendered -->
                    <section>
                        <div class="flex items-center gap-2 mb-4">
                            <div class="w-1 h-6 bg-primary rounded-full"></div>
                            <h3 class="text-lg font-bold text-primary tracking-tight">6. Services Rendered</h3>
                        </div>
                        <ul class="divide-y divide-slate-100 dark:divide-slate-900">
                            <%
                                if (services.isEmpty()) {
                            %>
                            <li class="py-3 text-sm text-slate-500 dark:text-slate-400">No billable services were attached to this record.</li>
                            <%
                                } else {
                                    for (RecordServiceLine line : services) {
                                        String svcName = line.getServiceName() != null ? line.getServiceName() : "Service";
                                        int qty = line.getQuantity();
                                        Double price = line.getPrice();
                                        double lineTotal = (price != null && qty > 0) ? price * qty : 0;
                            %>
                            <li class="py-2 flex justify-between items-center text-sm">
                                <span class="text-slate-600 dark:text-slate-400">
                                    <%= svcName %><% if (qty > 1) { %> (x<%= qty %>)<% } %>
                                </span>
                                <span class="font-bold text-slate-900 dark:text-slate-100">
                                    $<%= String.format(java.util.Locale.US, "%.2f", lineTotal) %>
                                </span>
                            </li>
                            <%
                                    }
                                }
                            %>
                        </ul>
                        <div class="mt-4 pt-4 border-t border-slate-200 dark:border-slate-800 flex justify-end">
                            <div class="text-right">
                                <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Grand Total</p>
                                <p class="text-2xl font-black text-slate-900 dark:text-slate-100">
                                    $<%= String.format(java.util.Locale.US, "%.2f", totalAmount) %>
                                </p>
                            </div>
                        </div>
                    </section>
                </div>
                <!-- Footer Disclaimer -->
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
</body>
</html>

