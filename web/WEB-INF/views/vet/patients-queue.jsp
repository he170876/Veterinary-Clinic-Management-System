<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Appointment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    if (appointments == null) appointments = java.util.Collections.emptyList();
    int currentVetId = request.getAttribute("currentVetId") != null ? (Integer) request.getAttribute("currentVetId") : 0;
    String roleTitle = (user.getRole() != null && user.getRole().getRoleName() != null)
        ? user.getRole().getRoleName() : "Veterinarian";
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats - Arrived Patients Queue</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700,0..1&amp;display=swap" rel="stylesheet"/>
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
                    borderRadius: { "DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px" },
                },
            },
        }
    </script>
    <style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-slate-900 dark:text-slate-100">
<div class="flex h-screen overflow-hidden">
<%@ include file="/WEB-INF/views/vet/_sidebar.jspf" %>
<!-- Main Content -->
<main class="flex-1 flex flex-col overflow-hidden">
<header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-between px-8">
<div class="flex items-center gap-4">
<h2 class="text-xl font-bold tracking-tight">Arrived Patients Queue</h2>
</div>
<div class="flex items-center gap-6">
<div class="flex items-center gap-3">
<%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
<div class="h-8 w-[1px] bg-slate-200 dark:bg-slate-800 mx-2"></div>
<div class="flex items-center gap-3">
<div class="text-right hidden sm:block">
<p class="text-sm font-semibold leading-none"><%= user.getFullName() %></p>
<p class="text-xs text-slate-500"><%= roleTitle %></p>
</div>
<div class="size-10 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold overflow-hidden">
<% if (user.getProfilePictureUrl() != null && !user.getProfilePictureUrl().isEmpty()) { %>
<img class="w-full h-full object-cover" src="<%= ctx %><%= user.getProfilePictureUrl() %>" alt="Profile"/>
<% } else { %>
<%= (user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "?" %>
<% } %>
</div>
</div>
</div>
</div>
</header>
<div class="flex-1 overflow-y-auto p-8">
<%
    String examError = request.getParameter("error");
    String completed = request.getParameter("completed");
    String revisit = request.getParameter("revisit");
    if ("notfound".equals(examError)) {
%>
<div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">Could not open examination: appointment not found.</div>
<% } else if ("locked".equals(examError)) { %>
<div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">Another veterinarian has already started this examination.</div>
<% } else if ("busy".equals(examError)) { %>
<div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">You already have an appointment in examination. Complete it before starting another one.</div>
<% } else if ("1".equals(completed)) { %>
<div class="mb-4 rounded-lg border border-green-300 bg-green-50 dark:bg-green-900/20 dark:border-green-700 px-4 py-3 text-sm text-green-800 dark:text-green-200">Examination completed. Visit and appointment have been marked as completed.</div>
<% } else if ("ok".equals(revisit)) { %>
<div class="mb-4 rounded-lg border border-green-300 bg-green-50 dark:bg-green-900/20 dark:border-green-700 px-4 py-3 text-sm text-green-800 dark:text-green-200">Follow-up appointment scheduled successfully.</div>
<% } else if ("error".equals(revisit)) { %>
<div class="mb-4 rounded-lg border border-red-300 bg-red-50 dark:bg-red-900/20 dark:border-red-700 px-4 py-3 text-sm text-red-800 dark:text-red-200">Could not create follow-up appointment. Please try again.</div>
<% } else if ("missing".equals(revisit) || "invalid".equals(revisit)) { %>
<div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">Please provide a valid date and time for the follow-up appointment.</div>
<% } else if ("unauthorized".equals(revisit)) { %>
<div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">You can only schedule follow-ups for your own patients.</div>
<% } else if ("notcheckedin".equals(request.getParameter("error"))) { %>
<div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">Patient must be checked in by receptionist first. They will appear here after check-in.</div>
<% } %>
<%
    boolean hasEmergencyInQueue = false;
    for (Appointment apCheck : appointments) {
        String t = apCheck.getType();
        if (t != null && "Emergency".equalsIgnoreCase(t.trim())) {
            hasEmergencyInQueue = true;
            break;
        }
    }
%>
<div class="mb-6 flex flex-col gap-3">
    <div class="flex justify-between items-end gap-4">
        <div>
            <h3 class="text-2xl font-bold text-slate-900 dark:text-slate-100">Checked-in Today</h3>
            <p class="text-slate-500 dark:text-slate-400 text-sm mt-1">Patients currently in the waiting room. Start examination when ready.</p>
        </div>
        <div class="flex items-center gap-3">
            <div class="relative w-64">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm">search</span>
                <input
                    id="vetQueueSearch"
                    class="w-full pl-10 pr-4 py-2 bg-slate-100 dark:bg-slate-800 border-none rounded-lg text-sm focus:ring-2 focus:ring-primary/50"
                    type="text"
                    placeholder="Search by pet or owner"/>
            </div>
            <span class="inline-flex items-center px-3 py-1 rounded-full bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 text-xs font-semibold">
                <span class="size-1.5 rounded-full bg-green-500 mr-2"></span>
                <%= appointments.size() %> Active Now
            </span>
        </div>
    </div>
    <% if (hasEmergencyInQueue) { %>
    <div class="mt-3">
        <h4 class="text-sm font-bold text-red-700 dark:text-red-300 mb-2 flex items-center gap-2">
            <span class="material-symbols-outlined text-red-500 text-base">emergency</span>
            Emergency Cases in Queue
        </h4>
        <div class="bg-red-50 dark:bg-red-900/20 rounded-xl border border-red-200 dark:border-red-700 overflow-hidden">
            <table class="w-full text-left border-collapse">
                <thead class="bg-red-100/70 dark:bg-red-900/40">
                <tr class="text-xs font-bold uppercase text-red-800 dark:text-red-200">
                    <th class="px-6 py-3">Queue No.</th>
                    <th class="px-6 py-3">Pet Name</th>
                    <th class="px-6 py-3">Species/Breed</th>
                    <th class="px-6 py-3">Owner Name</th>
                    <th class="px-6 py-3">Arrival Time</th>
                    <th class="px-6 py-3">Service/Reason</th>
                    <th class="px-6 py-3">Status</th>
                    <th class="px-6 py-3 text-right">Action</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-red-100 dark:divide-red-800">
                <%
                    int emergencyIndex = 1;
                    for (Appointment ap : appointments) {
                        String type = ap.getType();
                        boolean isEmergency = type != null && "Emergency".equalsIgnoreCase(type.trim());
                        if (!isEmergency) continue;

                        String ownerName = ap.getCustomer() != null && ap.getCustomer().getUser() != null ? ap.getCustomer().getUser().getFullName() : "—";
                        String phone = ap.getCustomerPhone() != null ? ap.getCustomerPhone() : "—";
                        String petName = ap.getPet() != null ? ap.getPet().getName() : "—";
                        String species = ap.getPet() != null && ap.getPet().getSpecies() != null ? ap.getPet().getSpecies() : "";
                        String breed = ap.getPet() != null && ap.getPet().getBreed() != null ? ap.getPet().getBreed() : "";
                        String speciesBreed = (species + " / " + breed).trim();
                        if (speciesBreed.equals("/")) speciesBreed = "—";
                        String timeStr = ap.getArrivalTime() != null ? ap.getArrivalTime().format(timeFmt) : "—";
                        String service = ap.getService() != null ? ap.getService() : "—";
                        String queueNo = String.format("E%02d", emergencyIndex);
                        String status = ap.getStatus() != null ? ap.getStatus() : "—";
                        boolean isInExam = "In-Examination".equalsIgnoreCase(status);
                        Integer rowVetId = ap.getVeterinarianId();
                        boolean lockedByOtherVet = isInExam && rowVetId != null && rowVetId > 0 && rowVetId != currentVetId;
                %>
                <tr class="queue-row hover:bg-red-100/60 dark:hover:bg-red-900/40 transition-colors <%= lockedByOtherVet ? "opacity-40" : "" %>"
                    data-pet-name="<%= petName %>" data-owner="<%= ownerName %>" data-phone="<%= phone %>">
                    <td class="px-6 py-3 text-sm font-semibold text-red-900 dark:text-red-100"><%= queueNo %></td>
                    <td class="px-6 py-3 text-sm font-bold text-red-900 dark:text-red-100"><%= petName %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= speciesBreed %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= ownerName %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= phone %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= timeStr %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= service %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= status %></td>
                    <td class="px-6 py-3 text-right space-x-2">
                        <% if (lockedByOtherVet) { %>
                        <span class="inline-block bg-red-200/80 dark:bg-red-800 text-red-800 dark:text-red-100 px-4 py-1.5 rounded-lg text-xs font-bold">In Progress</span>
                        <% } else { %>
                        <button type="button"
                                class="inline-block bg-red-500 hover:bg-red-600 text-white px-4 py-1.5 rounded-lg text-xs font-bold transition-all shadow-sm"
                                onclick="startExaminationAjax(<%= ap.getAppointmentId() %>)"><%= isInExam ? "Continue" : "Start Examination" %></button>
                        <% } %>
                        <button type="button"
                                class="inline-block bg-white/80 dark:bg-red-950/40 hover:bg-red-50 dark:hover:bg-red-900 text-red-800 dark:text-red-100 px-4 py-1.5 rounded-lg text-xs font-semibold transition-all shadow-sm"
                                onclick="openAppointmentDetail(<%= ap.getAppointmentId() %>)">
                            Details
                        </button>
                    </td>
                </tr>
                <%
                        emergencyIndex++;
                    }
                    if (emergencyIndex == 1) {
                %>
                <tr>
                    <td colspan="6" class="px-6 py-4 text-xs text-red-800/80 dark:text-red-200 text-center">
                        No emergency cases in queue.
                    </td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>
</div>
<div class="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
<table class="w-full text-left border-collapse">
<thead>
<tr class="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Queue No.</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Pet Name</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Species/Breed</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Owner Name</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Phone</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Arrival Time</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Service/Reason</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Status</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider text-right">Action</th>
</tr>
</thead>
<tbody class="divide-y divide-slate-100 dark:divide-slate-800" id="queueTableBody">
<%
    int rowNum = 1;
    for (Appointment ap : appointments) {
        String ownerName = ap.getCustomer() != null && ap.getCustomer().getUser() != null ? ap.getCustomer().getUser().getFullName() : "—";
        String phone = ap.getCustomerPhone() != null ? ap.getCustomerPhone() : "—";
        String petName = ap.getPet() != null ? ap.getPet().getName() : "—";
        String species = ap.getPet() != null && ap.getPet().getSpecies() != null ? ap.getPet().getSpecies() : "";
        String breed = ap.getPet() != null && ap.getPet().getBreed() != null ? ap.getPet().getBreed() : "";
        String speciesBreed = (species + " / " + breed).trim();
        if (speciesBreed.equals("/")) speciesBreed = "—";
        String timeStr = ap.getArrivalTime() != null ? ap.getArrivalTime().format(timeFmt) : "—";
        String service = ap.getService() != null ? ap.getService() : "—";
        String status = ap.getStatus() != null ? ap.getStatus() : "—";
        int petId = ap.getPet() != null ? ap.getPet().getPetId() : 0;
        String patientId = "P-" + petId;
        String queueNo = String.format("%03d", rowNum);
        String type = ap.getType();
        boolean isEmergencyRow = type != null && "Emergency".equalsIgnoreCase(type.trim());
        if (isEmergencyRow) continue;

        String statusClass = "Checked-in".equalsIgnoreCase(status)
            ? "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
            : "bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-300";
%>
<%
        boolean isInExam = "In-Examination".equalsIgnoreCase(status);
        Integer rowVetId = ap.getVeterinarianId();
        boolean lockedByOtherVet = isInExam && rowVetId != null && rowVetId > 0 && rowVetId != currentVetId;
%>
                <tr class="queue-row hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors <%= lockedByOtherVet ? "opacity-40" : "" %>" data-pet-name="<%= petName %>" data-owner="<%= ownerName %>" data-id="<%= patientId %>" data-phone="<%= phone %>">
<td class="px-6 py-4 text-sm font-semibold text-slate-900 dark:text-slate-100"><%= queueNo %></td>
<td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100"><%= petName %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= speciesBreed %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= ownerName %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= phone %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= timeStr %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= service %></td>
<td class="px-6 py-4">
<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium <%= statusClass %>"><%= status %></span>
</td>
<td class="px-6 py-4 text-right space-x-2">
<% if (lockedByOtherVet) { %>
<span class="inline-block bg-slate-200 dark:bg-slate-700 text-slate-500 dark:text-slate-400 px-4 py-2 rounded-lg text-sm font-bold">In Progress</span>
<% } else { %>
<button type="button"
        class="inline-block bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg text-sm font-bold transition-all shadow-sm"
        onclick="startExaminationAjax(<%= ap.getAppointmentId() %>)"><%= isInExam ? "Continue" : "Start Examination" %></button>
<% } %>
<button type="button" class="inline-block bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 px-4 py-2 rounded-lg text-sm font-semibold transition-all shadow-sm"
        onclick="openAppointmentDetail(<%= ap.getAppointmentId() %>)">
    Details
</button>
</td>
</tr>
<%
        rowNum++;
    }
    if (appointments.isEmpty()) {
%>
<tr>
<td colspan="9" class="px-6 py-8 text-center text-slate-500 dark:text-slate-400">No checked-in patients for today. Patients appear here after receptionist checks them in.</td>
</tr>
<%
    }
%>
</tbody>
</table>
<div class="px-6 py-4 bg-slate-50 dark:bg-slate-800/50 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between">
<p class="text-sm text-slate-500 dark:text-slate-400">Showing <%= appointments.size() %> of <%= appointments.size() %> results</p>
</div>
</div>
</div>
</main>
</div>
<div id="vetQueueToast" class="fixed top-6 right-6 bg-amber-500 text-white px-6 py-3 rounded-xl shadow-lg hidden items-center gap-2 z-[3000]">
    <span class="material-symbols-outlined">info</span>
    <span id="vetQueueToastMessage">Message</span>
</div>

<!-- Appointment Detail Panel (vet) – same layout & info as Receptionist detail popup, slide-in from right -->
<div id="vetAppointmentDetailModal" class="hidden fixed inset-0 bg-black/40 backdrop-blur-sm z-[2000] flex items-center justify-end">
    <div class="bg-white dark:bg-slate-900 w-full max-w-xl h-full shadow-2xl flex flex-col relative">
        <div class="flex items-center justify-between p-6 border-b border-slate-200 dark:border-slate-800">
            <h2 class="text-xl font-bold text-slate-800 dark:text-white">Appointment Details</h2>
            <button type="button" class="p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400" onclick="closeVetDetailModal()">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <!-- Loading state -->
        <div id="v-detail-loading" class="flex-1 flex items-center justify-center">
            <div class="text-center">
                <span class="material-symbols-outlined text-4xl text-slate-300 animate-spin">progress_activity</span>
                <p class="mt-2 text-sm text-slate-400">Loading...</p>
            </div>
        </div>
        <!-- Detail content (same structure / ids as Receptionist popup) -->
        <div id="v-detail-content" class="hidden flex-1 overflow-y-auto custom-scrollbar p-6 space-y-6">
            <section>
                <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Pet Profile</h3>
                <div class="flex items-start gap-5">
                    <img id="d-pet-photo" alt="Pet" class="w-24 h-24 rounded-2xl object-cover ring-4 ring-primary/5" src=""/>
                    <div id="d-pet-no-photo" class="hidden w-24 h-24 rounded-2xl bg-slate-200 dark:bg-slate-700 flex items-center justify-center ring-4 ring-primary/5">
                        <span class="material-symbols-outlined text-slate-400 text-4xl">pets</span>
                    </div>
                    <div class="space-y-3 flex-1">
                        <div class="flex items-center justify-between">
                            <h4 id="d-pet-name" class="text-2xl font-bold text-slate-800 dark:text-white"></h4>
                            <span id="d-status-badge" class="px-3 py-1 bg-primary/10 text-primary text-xs font-bold rounded-full"></span>
                        </div>
                        <div class="grid grid-cols-2 gap-y-2 text-sm">
                            <div>
                                <p class="text-slate-400">Species/Breed</p>
                                <p id="d-species-breed" class="font-medium text-slate-700 dark:text-slate-300"></p>
                            </div>
                            <div>
                                <p class="text-slate-400">Age</p>
                                <p id="d-age" class="font-medium text-slate-700 dark:text-slate-300"></p>
                            </div>
                            <div>
                                <p class="text-slate-400">Gender</p>
                                <p id="d-gender" class="font-medium text-slate-700 dark:text-slate-300"></p>
                            </div>
                            <div>
                                <p class="text-slate-400">Weight</p>
                                <p id="d-weight" class="font-medium text-slate-700 dark:text-slate-300"></p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            <section class="bg-slate-50 dark:bg-slate-800/50 p-5 rounded-2xl border border-slate-100 dark:border-slate-800">
                <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Owner Information</h3>
                <div class="grid grid-cols-2 gap-6 text-sm">
                    <div class="flex gap-3">
                        <span class="material-symbols-outlined text-primary/60">person</span>
                        <div>
                            <p class="text-slate-400 text-xs">Name</p>
                            <p id="d-owner-name" class="font-semibold text-slate-700 dark:text-slate-300"></p>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <span class="material-symbols-outlined text-primary/60">phone</span>
                        <div>
                            <p class="text-slate-400 text-xs">Phone</p>
                            <p id="d-owner-phone" class="font-semibold text-slate-700 dark:text-slate-300"></p>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <span class="material-symbols-outlined text-primary/60">mail</span>
                        <div>
                            <p class="text-slate-400 text-xs">Email</p>
                            <p id="d-owner-email" class="font-semibold text-slate-700 dark:text-slate-300"></p>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <span class="material-symbols-outlined text-primary/60">location_on</span>
                        <div>
                            <p class="text-slate-400 text-xs">Address</p>
                            <p id="d-owner-address" class="font-semibold text-slate-700 dark:text-slate-300"></p>
                        </div>
                    </div>
                </div>
            </section>
            <section>
                <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Appointment Data</h3>
                <div class="space-y-4">
                    <div class="grid grid-cols-2 gap-4">
                        <div class="space-y-1">
                            <label class="text-xs font-medium text-slate-500">Date</label>
                            <div class="flex items-center gap-2 px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm">
                                <span class="material-symbols-outlined text-sm text-primary">calendar_today</span>
                                <span id="d-date"></span>
                            </div>
                        </div>
                        <div class="space-y-1">
                            <label class="text-xs font-medium text-slate-500">Time</label>
                            <div class="flex items-center gap-2 px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm">
                                <span class="material-symbols-outlined text-sm text-primary">schedule</span>
                                <span id="d-time"></span>
                            </div>
                        </div>
                    </div>
                    <div class="space-y-1">
                        <label class="text-xs font-medium text-slate-500">Service</label>
                        <div class="flex items-center gap-2 px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm">
                            <span class="material-symbols-outlined text-sm text-primary">medical_services</span>
                            <span id="d-service"></span>
                        </div>
                    </div>
                    <div class="space-y-1">
                        <label class="text-xs font-medium text-slate-500">Assigned Doctor</label>
                        <div class="flex items-center gap-2 px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm">
                            <span class="material-symbols-outlined text-sm text-primary opacity-60">stethoscope</span>
                            <span id="d-doctor-name">N/A</span>
                        </div>
                    </div>
                    <div class="space-y-1">
                        <label class="text-xs font-medium text-slate-500">Notes</label>
                        <div class="px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm min-h-[80px]">
                            <span id="d-notes"></span>
                        </div>
                    </div>
                </div>
            </section>
        </div>
        <div class="p-6 border-t border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900 flex items-center justify-end">
            <button type="button" class="px-4 py-2 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90" onclick="closeVetDetailModal()">Close</button>
        </div>
    </div>
</div>

<script>
(function() {
    var search = document.getElementById('vetQueueSearch');
    if (!search) return;
    search.addEventListener('input', function() {
        var q = (this.value || '').toLowerCase();
        var rows = document.querySelectorAll('.queue-row');
        rows.forEach(function(row) {
            var name = (row.getAttribute('data-pet-name') || '').toLowerCase();
            var owner = (row.getAttribute('data-owner') || '').toLowerCase();
            var phone = (row.getAttribute('data-phone') || '').toLowerCase();
            var show = !q || name.indexOf(q) >= 0 || owner.indexOf(q) >= 0 || phone.indexOf(q) >= 0;
            row.style.display = show ? '' : 'none';
        });
    });
})();

function showQueueToast(message, isError) {
    var toast = document.getElementById('vetQueueToast');
    var msg = document.getElementById('vetQueueToastMessage');
    if (!toast || !msg) return;
    msg.textContent = message || 'Done';
    toast.classList.remove('hidden', 'bg-amber-500', 'bg-green-500');
    toast.classList.add('flex');
    toast.classList.add(isError ? 'bg-amber-500' : 'bg-green-500');
    setTimeout(function() {
        toast.classList.add('hidden');
        toast.classList.remove('flex');
    }, 2500);
}

function startExaminationAjax(appointmentId) {
    fetch('<%= ctx %>/vet/start-examination', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'appointmentId=' + encodeURIComponent(appointmentId)
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.success && data.redirectUrl) {
            window.location.href = data.redirectUrl;
            return;
        }
        showQueueToast(data.message || 'Could not start examination.', true);
    })
    .catch(function() {
        showQueueToast('An error occurred. Please try again.', true);
    });
}

function openAppointmentDetail(appointmentId) {
    var modal = document.getElementById('vetAppointmentDetailModal');
    var loading = document.getElementById('v-detail-loading');
    var content = document.getElementById('v-detail-content');

    if (!modal || !loading || !content) return;

    modal.classList.remove('hidden');
    modal.classList.add('flex');
    loading.classList.remove('hidden');
    content.classList.add('hidden');

    fetch('<%= ctx %>/vet/GetAppointmentDetail?appointmentId=' + appointmentId)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.success) {
                showQueueToast(data.message || 'Could not load appointment detail.', true);
                modal.classList.add('hidden');
                modal.classList.remove('flex');
                return;
            }

            var d = data || {};
            var pet = d.pet || {};
            var owner = d.owner || {};

            var photoEl = document.getElementById('d-pet-photo');
            var noPhotoEl = document.getElementById('d-pet-no-photo');
            if (pet.photoUrl) {
                photoEl.src = pet.photoUrl;
                photoEl.classList.remove('hidden');
                noPhotoEl.classList.add('hidden');
            } else {
                photoEl.classList.add('hidden');
                noPhotoEl.classList.remove('hidden');
            }

            document.getElementById('d-pet-name').textContent = pet.name || '';

            var sb = document.getElementById('d-status-badge');
            var statusText = d.status || '';
            sb.textContent = statusText;
            var s = statusText.toLowerCase();
            sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-primary/10 text-primary';
            if (s === 'pending' || s === 'scheduled') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-yellow-100 text-yellow-600';
            else if (s === 'confirmed') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-emerald-100 text-emerald-600';
            else if (s === 'checked-in') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-blue-100 text-blue-600';
            else if (s === 'in-examination') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-orange-100 text-orange-600';
            else if (s === 'completed' || s === 'done') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-green-100 text-green-600';
            else if (s === 'canceled' || s === 'cancelled') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-red-100 text-red-600';

            var sp = pet.species || '';
            var br = pet.breed || '';
            document.getElementById('d-species-breed').textContent = sp && br ? sp + ' / ' + br : (sp || br || 'N/A');
            document.getElementById('d-age').textContent = pet.age || 'N/A';
            document.getElementById('d-gender').textContent = pet.gender || 'N/A';
            document.getElementById('d-weight').textContent = pet.weight || 'N/A';

            document.getElementById('d-owner-name').textContent = owner.name || 'N/A';
            document.getElementById('d-owner-phone').textContent = owner.phone || 'N/A';
            document.getElementById('d-owner-email').textContent = owner.email || 'N/A';
            document.getElementById('d-owner-address').textContent = owner.address || 'N/A';

            document.getElementById('d-date').textContent = d.date || 'N/A';
            document.getElementById('d-time').textContent = d.time || 'N/A';
            document.getElementById('d-service').textContent = d.service || 'N/A';
            document.getElementById('d-doctor-name').textContent = d.veterinarianName || 'N/A';
            document.getElementById('d-notes').textContent = d.notes || 'N/A';

            loading.classList.add('hidden');
            content.classList.remove('hidden');
        })
        .catch(function() {
            showQueueToast('An error occurred while loading details.', true);
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        });
}

function closeVetDetailModal() {
    var modal = document.getElementById('vetAppointmentDetailModal');
    modal.classList.add('hidden');
    modal.classList.remove('flex');
}
</script>
</body>
</html>
