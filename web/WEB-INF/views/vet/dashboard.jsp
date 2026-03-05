<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Appointment" %>
<%@ page import="model.LabResultSummary" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    String roleTitle = (user.getRole() != null && user.getRole().getRoleName() != null)
        ? user.getRole().getRoleName() : "Veterinarian";
    @SuppressWarnings("unchecked")
    List<Appointment> todayAppointments = (List<Appointment>) request.getAttribute("todayAppointments");
    if (todayAppointments == null) todayAppointments = java.util.Collections.emptyList();
    int totalToday = request.getAttribute("totalToday") != null ? (Integer) request.getAttribute("totalToday") : 0;
    int surgeriesToday = request.getAttribute("surgeriesToday") != null ? (Integer) request.getAttribute("surgeriesToday") : 0;
    int pendingLab = request.getAttribute("pendingLab") != null ? (Integer) request.getAttribute("pendingLab") : 0;
    int followUps = request.getAttribute("followUps") != null ? (Integer) request.getAttribute("followUps") : 0;
    @SuppressWarnings("unchecked")
    List<LabResultSummary> recentLabResults = (List<LabResultSummary>) request.getAttribute("recentLabResults");
    if (recentLabResults == null) recentLabResults = java.util.Collections.emptyList();
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("hh:mm a");
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats - Veterinarian Dashboard</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
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
              borderRadius: {"DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px"},
            },
          },
        }
    </script>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-slate-900 dark:text-slate-100 antialiased">
<div class="flex h-screen overflow-hidden">
<%@ include file="/WEB-INF/views/vet/_sidebar.jspf" %>
<!-- Main Content Area -->
<main class="flex-1 flex flex-col overflow-hidden">
<!-- Top Header -->
<header class="h-16 flex items-center justify-between px-8 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 z-10">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-primary">stethoscope</span>
<h2 class="text-lg font-bold">Welcome, <%= user.getFullName() %></h2>
</div>
<div class="flex items-center gap-4">
<div class="relative w-64">
<span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm">search</span>
<input class="w-full pl-10 pr-4 py-2 text-sm bg-slate-100 dark:bg-slate-800 border-none rounded-xl focus:ring-2 focus:ring-primary/50 transition-all" placeholder="Search patient or ID..." type="text"/>
</div>
<%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
<button class="p-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors">
<span class="material-symbols-outlined">settings</span>
</button>
</div>
</header>
<!-- Dashboard Grid -->
<div class="flex-1 overflow-y-auto p-8 space-y-8">
<!-- Stats Row -->
<div class="grid grid-cols-1 md:grid-cols-4 gap-6">
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Total Appointments</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold"><%= totalToday %></h3>
<span class="text-green-500 text-xs font-bold flex items-center bg-green-50 dark:bg-green-900/20 px-2 py-1 rounded-full">Today</span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Surgeries Today</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold"><%= surgeriesToday %></h3>
<span class="text-primary text-xs font-bold flex items-center bg-primary/10 px-2 py-1 rounded-full">High Priority</span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Pending Lab Results</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold"><%= pendingLab %></h3>
<span class="text-slate-400 text-xs font-bold flex items-center">In progress</span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Follow-ups</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold"><%= followUps %></h3>
<span class="text-slate-400 text-xs font-bold flex items-center">This week</span>
</div>
</div>
</div>
<div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
<!-- Today's Appointments -->
<div class="lg:col-span-2 space-y-4">
<div class="flex items-center justify-between">
<h2 class="text-xl font-bold">Today's Appointments</h2>
<a href="<%= ctx %>/vet/queue" class="text-sm font-semibold text-primary hover:underline">View full schedule</a>
</div>
<div class="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
<table class="w-full text-left border-collapse">
<thead>
<tr class="bg-slate-50 dark:bg-slate-800/50 text-slate-500 text-xs font-bold uppercase">
<th class="px-6 py-4">Patient ID</th>
<th class="px-6 py-4">Name</th>
<th class="px-6 py-4">Owner</th>
<th class="px-6 py-4">Service</th>
<th class="px-6 py-4">Time</th>
<th class="px-6 py-4 text-right">Action</th>
</tr>
</thead>
<tbody class="divide-y divide-slate-100 dark:divide-slate-800">
<% for (Appointment ap : todayAppointments) {
    String ownerName = ap.getCustomer() != null && ap.getCustomer().getUser() != null ? ap.getCustomer().getUser().getFullName() : "—";
    String petName = ap.getPet() != null ? ap.getPet().getName() : "—";
    int petId = ap.getPet() != null ? ap.getPet().getPetId() : 0;
    String patientId = "P-" + petId;
    String service = ap.getService() != null ? ap.getService() : "—";
    String timeStr = ap.getAppointmentTime() != null ? ap.getAppointmentTime().format(timeFmt) : "—";
    boolean isSurgery = service != null && service.toLowerCase().contains("surgery");
    String serviceClass = isSurgery ? "bg-primary/10 text-primary" : "bg-slate-100 dark:bg-slate-800";
%>
<tr class="hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
<td class="px-6 py-4 text-sm font-medium text-slate-400"><%= patientId %></td>
<td class="px-6 py-4 text-sm font-bold"><%= petName %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= ownerName %></td>
<td class="px-6 py-4">
<span class="px-3 py-1 <%= serviceClass %> rounded-full text-xs font-bold"><%= service %></span>
</td>
<td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100"><%= timeStr %></td>
<td class="px-6 py-4 text-right">
<a href="<%= ctx %>/vet/examination?id=<%= ap.getAppointmentId() %>" class="text-xs font-bold text-primary hover:underline">Start</a>
</td>
</tr>
<% } %>
<% if (todayAppointments.isEmpty()) { %>
<tr><td colspan="6" class="px-6 py-8 text-center text-slate-500 dark:text-slate-400">No appointments for today.</td></tr>
<% } %>
</tbody>
</table>
</div>
</div>
<!-- Side Grid (Lab Results & Quick Actions) -->
<div class="space-y-8">
<!-- Quick Actions -->
<div class="space-y-4">
<h2 class="text-xl font-bold">Quick Actions</h2>
<div class="grid grid-cols-1 gap-3">
<a href="<%= ctx %>/vet/queue" class="w-full flex items-center justify-between px-4 py-3 bg-primary text-white rounded-xl font-bold hover:bg-primary/90 transition-all shadow-lg shadow-primary/20 no-underline">
<span>New Examination</span>
<span class="material-symbols-outlined">add_circle</span>
</a>
<button class="w-full flex items-center justify-between px-4 py-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-900 dark:text-white rounded-xl font-bold hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
<span>Schedule Revisit</span>
<span class="material-symbols-outlined text-primary">event_repeat</span>
</button>
<button class="w-full flex items-center justify-between px-4 py-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-900 dark:text-white rounded-xl font-bold hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
<span>Request Lab Test</span>
<span class="material-symbols-outlined text-primary">science</span>
</button>
</div>
</div>
<!-- Recent Lab Results -->
<div class="space-y-4">
<h2 class="text-xl font-bold">Recent Lab Results</h2>
<div class="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm divide-y divide-slate-100 dark:divide-slate-800">
<% for (LabResultSummary r : recentLabResults) {
    String p = r.getPetName() != null ? r.getPetName() : "—";
    String t = r.getTestName() != null ? r.getTestName() : "—";
    String st = r.getStatus() != null ? r.getStatus() : "Normal";
    String statusClass = "Critical".equals(st) ? "text-primary" : ("Normal".equals(st) ? "text-green-500" : "text-slate-500");
    String dateStr = r.getResultDate() != null ? r.getResultDate().format(dateFmt) : "—";
%>
<div class="p-4 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer">
<div>
<p class="text-sm font-bold"><%= p %></p>
<p class="text-xs text-slate-500"><%= t %></p>
</div>
<div class="text-right">
<p class="text-xs font-bold <%= statusClass %>"><%= st %></p>
<p class="text-[10px] text-slate-400 uppercase"><%= dateStr %></p>
</div>
</div>
<% } %>
<% if (recentLabResults.isEmpty()) { %>
<div class="p-6 text-center text-slate-500 dark:text-slate-400 text-sm">No recent lab results.</div>
<% } %>
</div>
<button class="w-full py-2 text-sm font-bold text-slate-400 hover:text-primary transition-colors">View All Lab Reports</button>
</div>
</div>
</div>
</div>
</main>
</div>
</body>
</html>
