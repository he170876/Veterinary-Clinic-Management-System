<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User,model.Pet,model.MedicalRecord,java.util.List,java.time.format.DateTimeFormatter" %>
<%
    User user = (User) request.getAttribute("user");
    List<MedicalRecord> medicalRecords = (List<MedicalRecord>) request.getAttribute("medicalRecords");
    List<Pet> customerPets = (List<Pet>) request.getAttribute("customerPets");
    String error = (String) request.getAttribute("error");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");
    String startDateParam = (String) request.getAttribute("startDate");
    String endDateParam = (String) request.getAttribute("endDate");
    Integer selectedPetId = (Integer) request.getAttribute("selectedPetId");

    if (medicalRecords == null) medicalRecords = new java.util.ArrayList<>();
    if (customerPets == null) customerPets = new java.util.ArrayList<>();
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (totalRecords == null) totalRecords = 0;
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("customerCurrentPage", "medical-history");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Pet Medical History Records - Anipat</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
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
                        "display": ["Manrope", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"},
                },
            },
        }
    </script>
<style type="text/tailwindcss">
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-[#f8f7f5]">
<div class="flex h-screen overflow-hidden">
<jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
<main class="flex-1 flex flex-col overflow-y-auto">
<header class="flex items-center justify-between bg-white dark:bg-[#2d2116] border-b border-[#f5f2f0] dark:border-[#3d2f23] px-8 py-4 sticky top-0 z-10">
<div class="flex items-center gap-4 flex-1">
<h2 class="text-xl font-bold tracking-tight">Medical History</h2>
<div class="relative w-64 ml-4">
<span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#8d755e] text-xl">search</span>
<input class="w-full pl-10 pr-4 py-2 bg-[#f5f2f0] dark:bg-[#3d2f23] border-none rounded-lg focus:ring-2 focus:ring-primary/50 text-sm" placeholder="Search records..." type="text" disabled/>
</div>
</div>
<div class="flex items-center gap-6">
<div class="flex items-center gap-3 pl-4 border-l border-[#f5f2f0] dark:border-[#3d2f23]">
<div class="text-right">
<p class="text-sm font-bold"><%= user.getFullName() != null ? user.getFullName() : user.getEmail() %></p>
<p class="text-xs text-[#8d755e]">Pet Parent</p>
</div>
</div>
</div>
</header>
<div class="p-8 max-w-7xl mx-auto w-full">
<% if (error != null && !error.isEmpty()) { %>
<div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded">
    <p class="text-sm text-red-700"><%= error %></p>
</div>
<% } %>

<form action="<%= ctx %>/customer/medical-history" method="get" class="bg-white dark:bg-[#2d2116] p-6 rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] mb-8">
<div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
    <div class="flex flex-col gap-1">
        <label class="text-xs font-bold text-[#8d755e] uppercase">Select Pet</label>
        <select name="petId" class="form-select w-full bg-[#f5f2f0] dark:bg-[#3d2f23] border-none rounded-lg text-sm focus:ring-primary">
            <option value="">All Pets</option>
            <% for (Pet pet : customerPets) { %>
            <option value="<%= pet.getPetId() %>" <%= (selectedPetId != null && selectedPetId == pet.getPetId()) ? "selected" : "" %>>
                <%= pet.getName() %> (<%= pet.getSpecies() != null ? pet.getSpecies() : "N/A" %>)
            </option>
            <% } %>
        </select>
    </div>
    
    <div class="flex flex-col gap-1">
        <label class="text-xs font-bold text-[#8d755e] uppercase">Start Date</label>
        <input type="date" name="startDate" value="<%= startDateParam != null ? startDateParam : "" %>" 
               class="form-input w-full bg-[#f5f2f0] dark:bg-[#3d2f23] border-none rounded-lg text-sm focus:ring-primary"/>
    </div>
    
    <div class="flex flex-col gap-1">
        <label class="text-xs font-bold text-[#8d755e] uppercase">End Date</label>
        <input type="date" name="endDate" value="<%= endDateParam != null ? endDateParam : "" %>" 
               class="form-input w-full bg-[#f5f2f0] dark:bg-[#3d2f23] border-none rounded-lg text-sm focus:ring-primary"/>
    </div>
    
    <div class="flex flex-col justify-end gap-2">
        <button type="submit" class="px-4 py-2 bg-primary text-white font-bold rounded-lg hover:bg-orange-600 transition-colors text-sm flex items-center justify-center gap-2">
            <span class="material-symbols-outlined text-lg">filter_list</span>
            Apply Filters
        </button>
    </div>
</div>

<% if (selectedPetId != null || startDateParam != null || endDateParam != null) { %>
<div class="flex items-center gap-2 flex-wrap">
    <span class="text-xs text-[#8d755e]">Active filters:</span>
    <% if (selectedPetId != null) { 
        Pet selectedPet = null;
        for (Pet p : customerPets) {
            if (p.getPetId() == selectedPetId) {
                selectedPet = p;
                break;
            }
        }
        if (selectedPet != null) {
    %>
    <span class="inline-flex items-center gap-1 px-2 py-1 bg-primary/10 text-primary text-xs rounded-full">
        Pet: <%= selectedPet.getName() %>
        <a href="?<%= (startDateParam != null ? "startDate=" + startDateParam + "&" : "") + (endDateParam != null ? "endDate=" + endDateParam : "") %>" class="hover:text-primary/70">×</a>
    </span>
    <% }} %>
    
    <% if (startDateParam != null) { %>
    <span class="inline-flex items-center gap-1 px-2 py-1 bg-primary/10 text-primary text-xs rounded-full">
        From: <%= startDateParam %>
        <a href="?<%= (selectedPetId != null ? "petId=" + selectedPetId + "&" : "") + (endDateParam != null ? "endDate=" + endDateParam : "") %>" class="hover:text-primary/70">×</a>
    </span>
    <% } %>
    
    <% if (endDateParam != null) { %>
    <span class="inline-flex items-center gap-1 px-2 py-1 bg-primary/10 text-primary text-xs rounded-full">
        To: <%= endDateParam %>
        <a href="?<%= (selectedPetId != null ? "petId=" + selectedPetId + "&" : "") + (startDateParam != null ? "startDate=" + startDateParam : "") %>" class="hover:text-primary/70">×</a>
    </span>
    <% } %>
    
    <a href="<%= ctx %>/customer/medical-history" class="text-xs text-primary hover:text-primary/70 font-medium">Clear all</a>
</div>
<% } %>
</form>

<div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] overflow-hidden">
<div class="overflow-x-auto">
<table class="w-full text-left border-collapse">
<thead>
<tr class="bg-[#fcfbf9] dark:bg-[#34281d] border-b border-[#f5f2f0] dark:border-[#3d2f23]">
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Visit Date</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Pet</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Doctor</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Diagnosis</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Treatment</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a] text-right">Actions</th>
</tr>
</thead>
<tbody class="divide-y divide-[#f5f2f0] dark:divide-[#3d2f23]">
<% if (medicalRecords.isEmpty()) { %>
<tr>
    <td colspan="6" class="px-6 py-10 text-center text-[#8d755e]">
        <div class="flex flex-col items-center gap-2">
            <span class="material-symbols-outlined text-4xl opacity-50">description</span>
            <p>No medical records found.</p>
        </div>
    </td>
</tr>
<% } else {
    for (MedicalRecord record : medicalRecords) {
        String visitDate = record.getVisitDate() != null
                ? record.getVisitDate().format(DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"))
                : "N/A";
        String petName = (record.getPet() != null && record.getPet().getName() != null)
                ? record.getPet().getName() : "N/A";
        String diagnosis = (record.getDiagnosis() != null && !record.getDiagnosis().trim().isEmpty())
                ? record.getDiagnosis() : "N/A";
        String treatment = (record.getTreatment() != null && !record.getTreatment().trim().isEmpty())
                ? record.getTreatment() : "N/A";
        String vetName = (record.getVeterinarianName() != null && !record.getVeterinarianName().trim().isEmpty())
                ? record.getVeterinarianName() : "N/A";
        
        // Truncate long text
        if (diagnosis.length() > 50) {
            diagnosis = diagnosis.substring(0, 47) + "...";
        }
        if (treatment.length() > 50) {
            treatment = treatment.substring(0, 47) + "...";
        }
%>
<tr class="hover:bg-[#fcfbf9] dark:hover:bg-[#34281d] transition-colors align-top">
    <td class="px-6 py-4 text-sm font-medium"><%= visitDate %></td>
    <td class="px-6 py-4 text-sm">
        <div class="flex items-center gap-2">
            <span class="material-symbols-outlined text-primary text-lg">pets</span>
            <%= petName %>
        </div>
    </td>
    <td class="px-6 py-4 text-sm"><%= vetName %></td>
    <td class="px-6 py-4 text-sm">
        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400">
            <%= diagnosis %>
        </span>
    </td>
    <td class="px-6 py-4 text-sm text-[#8d755e]"><%= treatment %></td>
    <td class="px-6 py-4 text-sm text-right">
        <a href="<%= ctx %>/customer/medical-record-detail?id=<%= record.getRecordId() %>" 
           class="inline-flex items-center gap-1 px-3 py-1.5 bg-primary/10 text-primary hover:bg-primary hover:text-white rounded-lg transition-colors text-xs font-medium">
            <span class="material-symbols-outlined text-sm">visibility</span>
            View Details
        </a>
    </td>
</tr>
<% }
} %>
</tbody>
</table>
</div>
<div class="px-6 py-4 bg-[#fcfbf9] dark:bg-[#34281d] border-t border-[#f5f2f0] dark:border-[#3d2f23] flex items-center justify-between">
    <p class="text-sm text-[#8d755e]">
        Showing <%= ((currentPage - 1) * 10) + 1 %> - <%= Math.min(currentPage * 10, totalRecords) %> of <%= totalRecords %> record(s)
    </p>
    
    <% if (totalPages > 1) { 
        String baseUrl = ctx + "/customer/medical-history?";
        if (selectedPetId != null) baseUrl += "petId=" + selectedPetId + "&";
        if (startDateParam != null) baseUrl += "startDate=" + startDateParam + "&";
        if (endDateParam != null) baseUrl += "endDate=" + endDateParam + "&";
    %>
    <div class="flex items-center gap-2">
        <% if (currentPage > 1) { %>
        <a href="<%= baseUrl %>page=<%= currentPage - 1 %>" 
           class="px-3 py-1.5 bg-white dark:bg-[#2d2116] border border-[#f5f2f0] dark:border-[#3d2f23] text-sm rounded-lg hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors">
            Previous
        </a>
        <% } %>
        
        <% 
            int startPage = Math.max(1, currentPage - 2);
            int endPage = Math.min(totalPages, currentPage + 2);
            
            if (startPage > 1) { 
        %>
            <a href="<%= baseUrl %>page=1" class="px-3 py-1.5 bg-white dark:bg-[#2d2116] border border-[#f5f2f0] dark:border-[#3d2f23] text-sm rounded-lg hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors">1</a>
            <% if (startPage > 2) { %>
                <span class="px-2 text-[#8d755e]">...</span>
            <% } %>
        <% } %>
        
        <% for (int i = startPage; i <= endPage; i++) { %>
            <% if (i == currentPage) { %>
                <span class="px-3 py-1.5 bg-primary text-white text-sm rounded-lg font-medium"><%= i %></span>
            <% } else { %>
                <a href="<%= baseUrl %>page=<%= i %>" 
                   class="px-3 py-1.5 bg-white dark:bg-[#2d2116] border border-[#f5f2f0] dark:border-[#3d2f23] text-sm rounded-lg hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors"><%= i %></a>
            <% } %>
        <% } %>
        
        <% if (endPage < totalPages) { %>
            <% if (endPage < totalPages - 1) { %>
                <span class="px-2 text-[#8d755e]">...</span>
            <% } %>
            <a href="<%= baseUrl %>page=<%= totalPages %>" class="px-3 py-1.5 bg-white dark:bg-[#2d2116] border border-[#f5f2f0] dark:border-[#3d2f23] text-sm rounded-lg hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors"><%= totalPages %></a>
        <% } %>
        
        <% if (currentPage < totalPages) { %>
        <a href="<%= baseUrl %>page=<%= currentPage + 1 %>" 
           class="px-3 py-1.5 bg-white dark:bg-[#2d2116] border border-[#f5f2f0] dark:border-[#3d2f23] text-sm rounded-lg hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors">
            Next
        </a>
        <% } %>
    </div>
    <% } %>
</div>
</div>
</div>
</main>
</div>
</body></html>