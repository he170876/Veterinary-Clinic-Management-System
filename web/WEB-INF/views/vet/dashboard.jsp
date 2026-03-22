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
    int currentVetId = request.getAttribute("currentVetId") != null ? (Integer) request.getAttribute("currentVetId") : 0;
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
<%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
<div class="relative">
    <button type="button"
            id="vet-profile-toggle"
            class="size-10 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold overflow-hidden hover:brightness-95 transition-colors">
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
</header>
<!-- Dashboard Grid -->
<div class="flex-1 overflow-y-auto p-8 space-y-8">
<!-- Shared toast like queue page -->
<div id="vetDashboardToast" class="fixed top-6 right-6 bg-amber-500 text-white px-6 py-3 rounded-xl shadow-lg hidden items-center gap-2 z-[3000]">
    <span class="material-symbols-outlined">info</span>
    <span id="vetDashboardToastMessage">Message</span>
</div>
<script>
    (function() {
        var msg = '';
        var isError = false;
        var params = new URLSearchParams(window.location.search);
        var error = params.get('error');
        var completed = params.get('completed');
        var revisit = params.get('revisit');

        if (error === 'notfound') {
            msg = 'Could not open examination: appointment not found.';
            isError = true;
        } else if (error === 'locked') {
            msg = 'Another veterinarian has already started this examination.';
            isError = true;
        } else if (error === 'busy') {
            msg = 'You already have an appointment in examination. Complete it before starting another one.';
            isError = true;
        } else if (error === 'notcheckedin') {
            msg = 'Patient must be checked in by receptionist first. They will appear in the queue after check-in.';
            isError = true;
        } else if (completed === '1') {
            msg = 'Examination completed. Visit and appointment have been marked as completed.';
            isError = false;
        } else if (revisit === 'ok') {
            msg = 'Follow-up appointment scheduled successfully.';
            isError = false;
        } else if (revisit === 'error') {
            msg = 'Could not create follow-up appointment. Please try again.';
            isError = true;
        } else if (revisit === 'missing' || revisit === 'invalid') {
            msg = 'Please provide a valid date and time for the follow-up appointment.';
            isError = true;
        } else if (revisit === 'unauthorized') {
            msg = 'You can only schedule follow-ups for your own patients.';
            isError = true;
        }

        if (msg) {
            var toast = document.getElementById('vetDashboardToast');
            var span = document.getElementById('vetDashboardToastMessage');
            if (toast && span) {
                span.textContent = msg;
                toast.classList.remove('hidden', 'bg-amber-500', 'bg-green-500');
                toast.classList.add('flex');
                toast.classList.add(isError ? 'bg-amber-500' : 'bg-green-500');
                setTimeout(function() {
                    toast.classList.add('hidden');
                    toast.classList.remove('flex');
                }, 2500);
            }
        }
    })();
</script>
<%
    int emergencyCount = 0;
    for (Appointment apCount : todayAppointments) {
        String t = apCount.getType();
        if (t != null && "Emergency".equalsIgnoreCase(t.trim())) {
            emergencyCount++;
        }
    }
%>
<!-- Stats Row -->
<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Total Appointments</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold"><%= totalToday %></h3>
<span class="text-green-500 text-xs font-bold flex items-center bg-green-50 dark:bg-green-900/20 px-2 py-1 rounded-full">Today</span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Emergency</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold"><%= emergencyCount %></h3>
<span class="text-red-500 text-xs font-bold flex items-center bg-red-50 dark:bg-red-900/20 px-2 py-1 rounded-full">Today</span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Pending Lab Results</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold"><%= pendingLab %></h3>
<span class="text-slate-400 text-xs font-bold flex items-center">In progress</span>
</div>
</div>
</div>
<div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
<!-- Today's Appointments (full width on desktop minus stats) -->
<%
    boolean hasEmergencyToday = false;
    for (Appointment apCheck : todayAppointments) {
        String t = apCheck.getType();
        if (t != null && "Emergency".equalsIgnoreCase(t.trim())) {
            hasEmergencyToday = true;
            break;
        }
    }
%>
<div class="lg:col-span-2 space-y-4">
<div class="flex flex-col gap-3">
    <div class="flex items-center justify-between gap-4">
        <div class="flex items-center gap-2">
            <h2 class="text-xl font-bold">Today's Appointments</h2>
            <a href="<%= ctx %>/vet/queue" class="text-sm font-semibold text-primary hover:underline">View full schedule</a>
        </div>
        <div class="relative w-64">
            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm">search</span>
            <input
                id="vetDashboardSearch"
                class="w-full pl-10 pr-4 py-2 text-sm bg-slate-100 dark:bg-slate-800 border-none rounded-xl focus:ring-2 focus:ring-primary/50 transition-all"
                type="text"
                placeholder="Search by pet or owner"/>
        </div>
    </div>
    <% if (hasEmergencyToday) { %>
    <div class="mt-1">
        <h4 class="text-sm font-bold text-red-700 dark:text-red-300 mb-2 flex items-center gap-2">
            <span class="material-symbols-outlined text-red-500 text-base">emergency</span>
            Emergency Appointments Today
        </h4>
        <div class="bg-red-50 dark:bg-red-900/20 rounded-xl border border-red-200 dark:border-red-700 overflow-hidden">
            <table class="w-full text-left border-collapse">
                <thead class="bg-red-100/70 dark:bg-red-900/40">
                <tr class="text-xs font-bold uppercase text-red-800 dark:text-red-200">
                    <th class="px-6 py-3">Queue No.</th>
                    <th class="px-6 py-3">Pet Name</th>
                    <th class="px-6 py-3">Species/Breed</th>
                    <th class="px-6 py-3">Owner Name</th>
                    <th class="px-6 py-3">Phone</th>
                    <th class="px-6 py-3">Arrival Time</th>
                    <th class="px-6 py-3">Service/Reason</th>
                    <th class="px-6 py-3">Status</th>
                    <th class="px-6 py-3 text-right">Action</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-red-100 dark:divide-red-800">
                <%
                    int emergencyIdx = 1;
                    for (Appointment ap : todayAppointments) {
                        String t = ap.getType();
                        boolean isEmergency = t != null && "Emergency".equalsIgnoreCase(t.trim());
                        if (!isEmergency) continue;

                        String ownerName = ap.getCustomer() != null && ap.getCustomer().getUser() != null ? ap.getCustomer().getUser().getFullName() : "—";
                        String phone = ap.getCustomerPhone() != null ? ap.getCustomerPhone() : "—";
                        String petName = ap.getPet() != null ? ap.getPet().getName() : "—";
                        String species = ap.getPet() != null && ap.getPet().getSpecies() != null ? ap.getPet().getSpecies() : "";
                        String breed = ap.getPet() != null && ap.getPet().getBreed() != null ? ap.getPet().getBreed() : "";
                        String speciesBreed = (species + " / " + breed).trim();
                        if (speciesBreed.equals("/")) speciesBreed = "—";
                        String timeStr = ap.getArrivalTime() != null ? ap.getArrivalTime().format(timeFmt) : "—";
                        String apStatus = ap.getStatus() != null ? ap.getStatus() : "—";
                        boolean isInExam = "In-Examination".equalsIgnoreCase(apStatus);
                        String actionLabel = isInExam ? "Continue" : "Start";
                        Integer rowVetId = ap.getVeterinarianId();
                        boolean lockedByOtherVet = isInExam && rowVetId != null && rowVetId > 0 && rowVetId != currentVetId;
                        String queueNo = String.format("E%02d", emergencyIdx);
                %>
                <tr class="dash-row hover:bg-red-100/60 dark:hover:bg-red-900/40 transition-colors <%= lockedByOtherVet ? "opacity-40" : "" %>"
                    data-pet-name="<%= petName %>" data-owner-name="<%= ownerName %>" data-phone="<%= phone %>">
                    <td class="px-6 py-3 text-sm font-semibold text-red-900 dark:text-red-100"><%= queueNo %></td>
                    <td class="px-6 py-3 text-sm font-bold text-red-900 dark:text-red-100"><%= petName %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= speciesBreed %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= ownerName %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= phone %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= timeStr %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= ap.getService() != null ? ap.getService() : "—" %></td>
                    <td class="px-6 py-3 text-sm text-red-900/80 dark:text-red-200"><%= apStatus %></td>
                    <td class="px-6 py-3 text-right">
                        <% if (lockedByOtherVet) { %>
                        <span class="text-xs font-bold text-red-700 dark:text-red-200">In progress</span>
                        <% } else { %>
                        <button type="button"
                                class="text-xs font-bold text-red-600 dark:text-red-200 hover:underline"
                            data-appointment-id="<%= ap.getAppointmentId() %>"
                            onclick="startExaminationFromDashboard(this.getAttribute('data-appointment-id'))"><%= actionLabel %></button>
                        <% } %>
                    </td>
                </tr>
                <%
                        emergencyIdx++;
                    }
                    if (emergencyIdx == 1) {
                %>
                <tr>
                    <td colspan="9" class="px-6 py-4 text-xs text-red-800/80 dark:text-red-200 text-center">
                        No emergency appointments today.
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
<div class="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
<table class="w-full text-left border-collapse">
<thead>
<tr class="bg-slate-50 dark:bg-slate-800/50 text-slate-500 text-xs font-bold uppercase">
<th class="px-6 py-4">Queue No.</th>
<th class="px-6 py-4">Pet Name</th>
<th class="px-6 py-4">Species/Breed</th>
<th class="px-6 py-4">Owner Name</th>
<th class="px-6 py-4">Phone</th>
<th class="px-6 py-4">Arrival Time</th>
<th class="px-6 py-4">Service/Reason</th>
<th class="px-6 py-4">Status</th>
<th class="px-6 py-4 text-right">Action</th>
</tr>
</thead>
<tbody class="divide-y divide-slate-100 dark:divide-slate-800">
<%
    int normalIdx = 1;
    for (Appointment ap : todayAppointments) {
        String ownerName = ap.getCustomer() != null && ap.getCustomer().getUser() != null ? ap.getCustomer().getUser().getFullName() : "—";
        String phone = ap.getCustomerPhone() != null
                ? ap.getCustomerPhone()
                : (ap.getCustomer() != null && ap.getCustomer().getUser() != null && ap.getCustomer().getUser().getPhone() != null
                    ? ap.getCustomer().getUser().getPhone()
                    : "—");
        String petName = ap.getPet() != null ? ap.getPet().getName() : "—";
        String species = ap.getPet() != null && ap.getPet().getSpecies() != null ? ap.getPet().getSpecies() : "";
        String breed = ap.getPet() != null && ap.getPet().getBreed() != null ? ap.getPet().getBreed() : "";
        String speciesBreed = (species + " / " + breed).trim();
        if (speciesBreed.equals("/")) speciesBreed = "—";
        String service = ap.getService() != null ? ap.getService() : "—";
        String timeStr = ap.getArrivalTime() != null
                ? ap.getArrivalTime().format(timeFmt)
                : (ap.getAppointmentTime() != null ? ap.getAppointmentTime().format(timeFmt) : "—");
        String apStatus = ap.getStatus() != null ? ap.getStatus() : "—";
        boolean isCheckedIn = "Checked-in".equalsIgnoreCase(apStatus);
        boolean isInExam = "In-Examination".equalsIgnoreCase(apStatus);
        String actionLabel = isInExam ? "Continue" : "Start";
        boolean canStartExam = isCheckedIn || isInExam;
        Integer rowVetId = ap.getVeterinarianId();
        boolean lockedByOtherVet = isInExam && rowVetId != null && rowVetId > 0 && rowVetId != currentVetId;
        String type = ap.getType();
        boolean isEmergencyRow = type != null && "Emergency".equalsIgnoreCase(type.trim());
        if (isEmergencyRow) continue;
        String queueNo = String.format("%03d", normalIdx);
%>
<tr class="dash-row hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors <%= lockedByOtherVet ? "opacity-40" : "" %>"
    data-pet-name="<%= petName %>" data-owner-name="<%= ownerName %>" data-phone="<%= phone %>">
<td class="px-6 py-4 text-sm font-semibold"><%= queueNo %></td>
<td class="px-6 py-4 text-sm font-bold"><%= petName %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= speciesBreed %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= ownerName %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= phone %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= timeStr %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= service %></td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= apStatus %></td>
<td class="px-6 py-4 text-right">
<% if (!canStartExam) { %>
<span class="text-xs font-bold text-amber-600">Awaiting check-in</span>
<% } else if (lockedByOtherVet) { %>
<span class="text-xs font-bold text-slate-400">In progress</span>
<% } else { %>
<button type="button"
        class="text-xs font-bold text-primary hover:underline"
    data-appointment-id="<%= ap.getAppointmentId() %>"
    onclick="startExaminationFromDashboard(this.getAttribute('data-appointment-id'))"><%= actionLabel %></button>
<% } %>
</td>
</tr>
<%
        normalIdx++;
    }
    if (normalIdx == 1) {
%>
<tr><td colspan="9" class="px-6 py-8 text-center text-slate-500 dark:text-slate-400">No appointments for today.</td></tr>
<% } %>
</tbody>
</table>
</div>
</div>
</div>
</div>
</main>
</div>
<script>
    (function() {
        var search = document.getElementById('vetDashboardSearch');
        if (!search) return;
        search.addEventListener('input', function() {
            var q = (this.value || '').toLowerCase();
            var rows = document.querySelectorAll('.dash-row');
            rows.forEach(function(row) {
                var pet = (row.getAttribute('data-pet-name') || '').toLowerCase();
                var owner = (row.getAttribute('data-owner-name') || '').toLowerCase();
                var phone = (row.getAttribute('data-phone') || '').toLowerCase();
                var show = !q || pet.indexOf(q) >= 0 || owner.indexOf(q) >= 0 || phone.indexOf(q) >= 0;
                row.style.display = show ? '' : 'none';
            });
        });
    })();
</script>
<script>
    function showVetDashboardToast(message, isError) {
        var toast = document.getElementById('vetDashboardToast');
        var span = document.getElementById('vetDashboardToastMessage');
        if (!toast || !span) return;
        span.textContent = message || 'Done';
        toast.classList.remove('hidden', 'bg-amber-500', 'bg-green-500');
        toast.classList.add('flex');
        toast.classList.add(isError ? 'bg-amber-500' : 'bg-green-500');
        setTimeout(function() {
            toast.classList.add('hidden');
            toast.classList.remove('flex');
        }, 2500);
    }

    function startExaminationFromDashboard(appointmentId) {
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
            showVetDashboardToast(data.message || 'Could not start examination.', true);
        })
        .catch(function() {
            showVetDashboardToast('An error occurred. Please try again.', true);
        });
    }
</script>
<script>
    (function() {
        var toggle = document.getElementById('vet-profile-toggle');
        var menu = document.getElementById('vet-profile-menu');
        if (!toggle || !menu) return;
        toggle.addEventListener('click', function(e) {
            e.stopPropagation();
            menu.style.display = (menu.style.display === 'none' || menu.style.display === '') ? 'block' : 'none';
        });
        document.addEventListener('click', function(e) {
            if (!menu.contains(e.target) && !toggle.contains(e.target)) {
                menu.style.display = 'none';
            }
        });
    })();
</script>
</body>
</html>
