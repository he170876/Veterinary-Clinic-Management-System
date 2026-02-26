<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Appointment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
    String roleTitle = (user.getRole() != null && user.getRole().getRoleName() != null)
        ? user.getRole().getRoleName() : "Staff";
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
                        "primary": "#f14337",
                        "background-light": "#f8f6f6",
                        "background-dark": "#221110",
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
<!-- Sidebar -->
<aside class="w-64 border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex flex-col">
<div class="p-6 flex items-center gap-3">
<div class="size-10 bg-primary rounded-lg flex items-center justify-center text-white">
<span class="material-symbols-outlined">pets</span>
</div>
<div>
<h1 class="text-lg font-bold leading-none">Anipats</h1>
<p class="text-xs text-slate-500 dark:text-slate-400">Veterinary Clinic</p>
</div>
</div>
<nav class="flex-1 px-4 py-4 space-y-1">
<a class="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg" href="<%= ctx %>/Receptionist/ViewListAppointment">
<span class="material-symbols-outlined">dashboard</span>
<span class="text-sm font-medium">Dashboard</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 bg-primary/10 text-primary rounded-lg" href="<%= ctx %>/staff/queue">
<span class="material-symbols-outlined">group_work</span>
<span class="text-sm font-medium">Patients Queue</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg" href="<%= ctx %>/Receptionist/ViewListAppointment">
<span class="material-symbols-outlined">calendar_today</span>
<span class="text-sm font-medium">Appointments</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg" href="#">
<span class="material-symbols-outlined">description</span>
<span class="text-sm font-medium">Medical Records</span>
</a>
</nav>
<div class="p-4 border-t border-slate-200 dark:border-slate-800">
<a class="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg" href="#">
<span class="material-symbols-outlined">settings</span>
<span class="text-sm font-medium">Settings</span>
</a>
<a href="<%= ctx %>/logout" class="block mt-2 text-center text-xs text-slate-500 hover:text-primary transition-colors">Sign out</a>
</div>
</aside>
<!-- Main Content -->
<main class="flex-1 flex flex-col overflow-hidden">
<!-- Header -->
<header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-between px-8">
<div class="flex items-center gap-4">
<h2 class="text-xl font-bold tracking-tight">Arrived Patients Queue</h2>
</div>
<div class="flex items-center gap-6">
<div class="relative max-w-xs">
<span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-lg">search</span>
<input class="pl-10 pr-4 py-2 bg-slate-100 dark:bg-slate-800 border-none rounded-lg text-sm w-64 focus:ring-2 focus:ring-primary/50" placeholder="Search patients..." type="text" id="searchQueue"/>
</div>
<div class="flex items-center gap-3">
<button class="size-10 flex items-center justify-center text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-full">
<span class="material-symbols-outlined">notifications</span>
</button>
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
<!-- Table View -->
<div class="flex-1 overflow-y-auto p-8">
<div class="mb-6 flex justify-between items-end">
<div>
<h3 class="text-2xl font-bold text-slate-900 dark:text-slate-100">Checked-in Today</h3>
<p class="text-slate-500 dark:text-slate-400 text-sm mt-1">Manage patients currently in the waiting room.</p>
</div>
<div class="flex gap-2">
<span class="inline-flex items-center px-3 py-1 rounded-full bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 text-xs font-semibold">
<span class="size-1.5 rounded-full bg-green-500 mr-2"></span>
                            <%= appointments.size() %> Active Now
                        </span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
<table class="w-full text-left border-collapse">
<thead>
<tr class="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Queue No.</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Patient ID</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Pet Name</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Species/Breed</th>
<th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Owner Name</th>
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
        String petName = ap.getPet() != null ? ap.getPet().getName() : "—";
        String species = ap.getPet() != null && ap.getPet().getSpecies() != null ? ap.getPet().getSpecies() : "";
        String breed = ap.getPet() != null && ap.getPet().getBreed() != null ? ap.getPet().getBreed() : "";
        String speciesBreed = (species + " / " + breed).trim();
        if (speciesBreed.equals("/")) speciesBreed = "—";
        String timeStr = ap.getAppointmentTime() != null ? ap.getAppointmentTime().format(timeFmt) : "—";
        String service = ap.getService() != null ? ap.getService() : "—";
        String status = ap.getStatus() != null ? ap.getStatus() : "—";
        int petId = ap.getPet() != null ? ap.getPet().getPetId() : 0;
        String patientId = "P-" + petId;
        String queueNo = String.format("%03d", rowNum);
        String statusClass = "READY".equalsIgnoreCase(status) || "Confirmed".equalsIgnoreCase(status)
            ? "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
            : "bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-300";
%>
<tr class="queue-row hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors" data-pet-name="<%= petName %>" data-owner="<%= ownerName %>" data-id="<%= patientId %>">
<td class="px-6 py-4 text-sm font-semibold text-slate-900 dark:text-slate-100"><%= queueNo %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= patientId %></td>
<td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100"><%= petName %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= speciesBreed %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= ownerName %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= timeStr %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= service %></td>
<td class="px-6 py-4">
<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium <%= statusClass %>"><%= status %></span>
</td>
<td class="px-6 py-4 text-right">
<a href="<%= ctx %>/Receptionist/GetAppointmentDetail?id=<%= ap.getAppointmentId() %>" class="inline-block bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg text-sm font-bold transition-all shadow-sm">Start Examination</a>
</td>
</tr>
<%
        rowNum++;
    }
    if (appointments.isEmpty()) {
%>
<tr>
<td colspan="9" class="px-6 py-8 text-center text-slate-500 dark:text-slate-400">No appointments for today.</td>
</tr>
<%
    }
%>
</tbody>
</table>
<!-- Pagination -->
<div class="px-6 py-4 bg-slate-50 dark:bg-slate-800/50 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between">
<p class="text-sm text-slate-500 dark:text-slate-400">Showing <%= appointments.size() %> of <%= appointments.size() %> results</p>
</div>
</div>
</div>
</main>
</div>
<script>
(function() {
    var search = document.getElementById('searchQueue');
    var rows = document.querySelectorAll('.queue-row');
    if (search && rows.length) {
        search.addEventListener('input', function() {
            var q = (this.value || '').toLowerCase();
            rows.forEach(function(row) {
                var name = (row.getAttribute('data-pet-name') || '').toLowerCase();
                var owner = (row.getAttribute('data-owner') || '').toLowerCase();
                var id = (row.getAttribute('data-id') || '').toLowerCase();
                var show = !q || name.indexOf(q) >= 0 || owner.indexOf(q) >= 0 || id.indexOf(q) >= 0;
                row.style.display = show ? '' : 'none';
            });
        });
    }
})();
</script>
</body>
</html>
