<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User,model.MedicalRecord,model.LabTestRequest,model.Prescription,model.RecordServiceLine,java.time.format.DateTimeFormatter,java.util.List" %>
<%
    User user = (User) request.getAttribute("user");
    MedicalRecord record = (MedicalRecord) request.getAttribute("medicalRecord");
    
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (record == null) {
        response.sendRedirect(request.getContextPath() + "/customer/medical-history");
        return;
    }
    
    String ctx = request.getContextPath();
    String visitDate = record.getVisitDate() != null
            ? record.getVisitDate().format(DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' hh:mm a"))
            : "N/A";
    String petName = (record.getPet() != null && record.getPet().getName() != null)
            ? record.getPet().getName() : "N/A";
    String species = (record.getPet() != null && record.getPet().getSpecies() != null)
            ? record.getPet().getSpecies() : "N/A";
    String breed = (record.getPet() != null && record.getPet().getBreed() != null)
            ? record.getPet().getBreed() : "N/A";
    String vetName = (record.getVeterinarianName() != null && !record.getVeterinarianName().trim().isEmpty())
            ? record.getVeterinarianName() : "N/A";
    String diagnosis = (record.getDiagnosis() != null && !record.getDiagnosis().trim().isEmpty())
            ? record.getDiagnosis() : "No diagnosis recorded";
    String treatment = (record.getTreatment() != null && !record.getTreatment().trim().isEmpty())
            ? record.getTreatment() : "No treatment recorded";
    String note = (record.getNote() != null && !record.getNote().trim().isEmpty())
            ? record.getNote() : "No additional notes";
    String visitStatus = record.getVisitStatus() != null ? record.getVisitStatus() : "Unknown";
        @SuppressWarnings("unchecked")
        List<LabTestRequest> labRequests = (List<LabTestRequest>) request.getAttribute("labRequests");
        if (labRequests == null) labRequests = java.util.Collections.emptyList();
        @SuppressWarnings("unchecked")
        List<Prescription> prescriptions = (List<Prescription>) request.getAttribute("prescriptions");
        if (prescriptions == null) prescriptions = java.util.Collections.emptyList();
        @SuppressWarnings("unchecked")
        List<RecordServiceLine> services = (List<RecordServiceLine>) request.getAttribute("services");
        if (services == null) services = java.util.Collections.emptyList();
    request.setAttribute("customerHeaderTitle", "Medical Record Details");
    request.setAttribute("customerHeaderSubtitle", "Record #" + record.getRecordId());
    request.setAttribute("customerHeaderBackUrl", ctx + "/customer/medical-history");
    request.setAttribute("customerHeaderDisplayName", user.getFullName() != null ? user.getFullName() : user.getEmail());
    request.setAttribute("customerHeaderRoleText", "Pet Owner");
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Medical Record Details - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700;900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#ff7b00",
                        "background-light": "#f8f7f5",
                        "background-dark": "#23190f",
                    },
                    fontFamily: { "display": ["Public Sans", "sans-serif"] },
                },
            },
        }
    </script>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-[#f8f7f5]">
<div class="flex h-screen overflow-hidden">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    
    <main class="flex-1 flex flex-col overflow-y-auto">
        <jsp:include page="/WEB-INF/includes/customer-header.jsp"/>

        <div class="p-8 max-w-5xl mx-auto w-full space-y-6">
            <!-- Visit Info Card -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-start justify-between mb-6">
                    <div>
                        <h3 class="text-lg font-bold mb-1">Visit Information</h3>
                        <p class="text-sm text-[#8d755e]"><%= visitDate %></p>
                    </div>
                    <span class="px-3 py-1.5 rounded-full text-xs font-bold <%= visitStatus.equals("Completed") ? "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" : "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400" %>">
                        <%= visitStatus %>
                    </span>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="flex items-start gap-3">
                        <div class="p-2 bg-primary/10 rounded-lg">
                            <span class="material-symbols-outlined text-primary">pets</span>
                        </div>
                        <div>
                            <p class="text-xs text-[#8d755e] uppercase font-bold mb-1">Patient</p>
                            <p class="font-semibold"><%= petName %></p>
                            <p class="text-sm text-[#8d755e]"><%= species %> • <%= breed %></p>
                        </div>
                    </div>
                    
                    <div class="flex items-start gap-3">
                        <div class="p-2 bg-primary/10 rounded-lg">
                            <span class="material-symbols-outlined text-primary">medical_services</span>
                        </div>
                        <div>
                            <p class="text-xs text-[#8d755e] uppercase font-bold mb-1">Veterinarian</p>
                            <p class="font-semibold"><%= vetName %></p>
                            <p class="text-sm text-[#8d755e]">Attending Doctor</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 1. Lab Test Results -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary">biotech</span>
                    <h3 class="text-lg font-bold">1. Lab Test Results</h3>
                </div>
                <% if (labRequests.isEmpty()) { %>
                    <p class="text-sm text-[#8d755e]">No lab tests for this medical record.</p>
                <% } else { %>
                    <div class="space-y-3">
                        <% for (LabTestRequest req : labRequests) {
                               String testName = req.getTestName() != null ? req.getTestName() : "Lab Test";
                               String status = req.getStatus() != null ? req.getStatus() : "Pending";
                        %>
                        <div class="flex items-center justify-between rounded-lg border border-[#f5f2f0] dark:border-[#3d2f23] p-3 bg-[#fcfbf9] dark:bg-[#34281d]">
                            <p class="font-semibold text-sm"><%= testName %></p>
                            <span class="px-3 py-1 rounded-full text-xs font-bold <%= "Completed".equalsIgnoreCase(status) ? "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" : "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400" %>">
                                <%= status %>
                            </span>
                        </div>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <!-- 2. Observations (3 items) -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary">visibility</span>
                    <h3 class="text-lg font-bold">2. Observations (3 Items)</h3>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div class="rounded-lg border border-blue-200 dark:border-blue-900/30 bg-blue-50 dark:bg-blue-900/10 p-4">
                        <p class="text-xs uppercase font-bold text-[#8d755e] mb-1">Observation 1: Diagnosis</p>
                        <p class="text-sm leading-relaxed"><%= diagnosis %></p>
                    </div>
                    <div class="rounded-lg border border-[#f5f2f0] dark:border-[#3d2f23] bg-[#fcfbf9] dark:bg-[#34281d] p-4">
                        <p class="text-xs uppercase font-bold text-[#8d755e] mb-1">Observation 2: Clinical Notes</p>
                        <p class="text-sm text-[#8d755e] leading-relaxed whitespace-pre-line"><%= note %></p>
                    </div>
                    <div class="rounded-lg border border-[#f5f2f0] dark:border-[#3d2f23] bg-[#fcfbf9] dark:bg-[#34281d] p-4">
                        <p class="text-xs uppercase font-bold text-[#8d755e] mb-1">Observation 3: Visit Status</p>
                        <p class="text-sm leading-relaxed"><%= visitStatus %></p>
                    </div>
                </div>
            </div>

            <!-- 3. Medications -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary">medication</span>
                    <h3 class="text-lg font-bold">3. Medications</h3>
                </div>
                <% if (prescriptions.isEmpty()) { %>
                    <p class="text-sm text-[#8d755e]">No prescribed medicine in this record.</p>
                <% } else { %>
                    <div class="space-y-3">
                        <% for (Prescription pr : prescriptions) {
                               String med = pr.getMedicineName() != null ? pr.getMedicineName() : "Medicine";
                               String dose = pr.getDosage() != null ? pr.getDosage() : "-";
                               String duration = pr.getDuration() != null ? pr.getDuration() : "-";
                        %>
                        <div class="rounded-lg border border-[#f5f2f0] dark:border-[#3d2f23] p-4 bg-[#fcfbf9] dark:bg-[#34281d]">
                            <p class="font-semibold"><%= med %></p>
                            <p class="text-sm text-[#8d755e]">Dosage: <%= dose %></p>
                            <p class="text-sm text-[#8d755e]">Duration: <%= duration %></p>
                        </div>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <!-- 4. Treatment Plan -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary">assignment</span>
                    <h3 class="text-lg font-bold">4. Treatment Plan</h3>
                </div>
                <div class="rounded-lg border border-green-200 dark:border-green-900/30 bg-green-50 dark:bg-green-900/10 p-4 mb-4">
                    <p class="text-sm leading-relaxed whitespace-pre-line"><%= treatment %></p>
                </div>
                <div class="rounded-lg border border-[#f5f2f0] dark:border-[#3d2f23] overflow-hidden">
                    <% if (services.isEmpty()) { %>
                        <p class="p-4 text-sm text-[#8d755e]">No procedure lines attached.</p>
                    <% } else {
                        for (RecordServiceLine line : services) {
                            String serviceName = line.getServiceName() != null ? line.getServiceName() : "Service";
                            int qty = line.getQuantity();
                    %>
                    <div class="p-3 border-b border-[#f5f2f0] dark:border-[#3d2f23] bg-[#fcfbf9] dark:bg-[#34281d] last:border-b-0">
                        <p class="text-sm"><%= serviceName %><% if (qty > 1) { %> (x<%= qty %>)<% } %></p>
                    </div>
                    <%  }
                       } %>
                </div>
            </div>

            <!-- Actions -->
            <div class="flex justify-between items-center pt-4">
                <a href="<%= ctx %>/customer/medical-history" 
                   class="inline-flex items-center gap-2 px-6 py-3 bg-white dark:bg-[#2d2116] border border-[#f5f2f0] dark:border-[#3d2f23] rounded-xl hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors font-medium">
                    <span class="material-symbols-outlined">arrow_back</span>
                    Back to History
                </a>
                
                <button onclick="window.print()" 
                        class="inline-flex items-center gap-2 px-6 py-3 bg-primary text-white rounded-xl hover:bg-orange-600 transition-colors font-medium">
                    <span class="material-symbols-outlined">print</span>
                    Print Record
                </button>
            </div>
        </div>
    </main>
</div>
</body>
</html>
