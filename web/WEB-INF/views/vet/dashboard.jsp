<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    String roleTitle = (user.getRole() != null && user.getRole().getRoleName() != null)
        ? user.getRole().getRoleName() : "Veterinarian";
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
                "primary": "#f14337",
                "background-light": "#f8f6f6",
                "background-dark": "#221110",
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
<!-- Sidebar Navigation -->
<aside class="w-64 flex-shrink-0 border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex flex-col">
<div class="p-6 flex items-center gap-3">
<div class="size-10 bg-primary rounded-lg flex items-center justify-center text-white">
<span class="material-symbols-outlined text-2xl">pets</span>
</div>
<div>
<h1 class="text-xl font-bold tracking-tight text-slate-900 dark:text-white">Anipats</h1>
<p class="text-xs text-slate-500 dark:text-slate-400 font-medium">Veterinary Care</p>
</div>
</div>
<nav class="flex-1 px-4 space-y-2 mt-4">
<a class="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary/10 text-primary font-semibold" href="<%= ctx %>/vet/dashboard">
<span class="material-symbols-outlined">dashboard</span>
<span class="text-sm">Dashboard</span>
</a>
<a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="<%= ctx %>/vet/queue">
<span class="material-symbols-outlined">group_work</span>
<span class="text-sm font-medium">Patients Queue</span>
</a>
<a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="#">
<span class="material-symbols-outlined">clinical_notes</span>
<span class="text-sm font-medium">Medical Records</span>
</a>
<a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="#">
<span class="material-symbols-outlined">lab_panel</span>
<span class="text-sm font-medium">Lab Results</span>
</a>
</nav>
<div class="p-4 border-t border-slate-200 dark:border-slate-800">
<div class="flex items-center gap-3 p-2">
<div class="size-10 rounded-full bg-slate-200 dark:bg-slate-700 overflow-hidden flex items-center justify-center text-slate-500 dark:text-slate-400 text-sm font-bold"<% if (user.getProfilePictureUrl() != null && !user.getProfilePictureUrl().isEmpty()) { %> style="background-image: url('<%= ctx %><%= user.getProfilePictureUrl() %>'); background-size: cover;"<% } %>><% if (user.getProfilePictureUrl() == null || user.getProfilePictureUrl().isEmpty()) { %><%= (user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "?" %><% } %></div>
<div class="flex-1 min-w-0">
<p class="text-sm font-bold truncate"><%= user.getFullName() %></p>
<p class="text-xs text-slate-500 truncate"><%= roleTitle %></p>
</div>
</div>
<a href="<%= ctx %>/logout" class="block mt-2 text-center text-xs text-slate-500 hover:text-primary transition-colors">Sign out</a>
</div>
</aside>
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
<button class="relative p-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors">
<span class="material-symbols-outlined">notifications</span>
<span class="absolute top-2 right-2 size-2 bg-primary rounded-full border-2 border-white dark:border-slate-900"></span>
</button>
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
<h3 class="text-3xl font-bold">12</h3>
<span class="text-green-500 text-xs font-bold flex items-center bg-green-50 dark:bg-green-900/20 px-2 py-1 rounded-full">+4% vs yesterday</span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Surgeries Today</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold">03</h3>
<span class="text-primary text-xs font-bold flex items-center bg-primary/10 px-2 py-1 rounded-full">High Priority</span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Pending Lab Results</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold">08</h3>
<span class="text-slate-400 text-xs font-bold flex items-center">In progress</span>
</div>
</div>
<div class="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
<p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Follow-ups</p>
<div class="flex items-end justify-between">
<h3 class="text-3xl font-bold">05</h3>
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
</tr>
</thead>
<tbody class="divide-y divide-slate-100 dark:divide-slate-800">
<tr class="hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
<td class="px-6 py-4 text-sm font-medium text-slate-400">P-102</td>
<td class="px-6 py-4 text-sm font-bold">Max</td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400">John Doe</td>
<td class="px-6 py-4">
<span class="px-3 py-1 bg-slate-100 dark:bg-slate-800 rounded-full text-xs font-bold">Vaccination</span>
</td>
<td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100">09:00 AM</td>
</tr>
<tr class="hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
<td class="px-6 py-4 text-sm font-medium text-slate-400">P-105</td>
<td class="px-6 py-4 text-sm font-bold">Bella</td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400">Sarah Wilson</td>
<td class="px-6 py-4">
<span class="px-3 py-1 bg-slate-100 dark:bg-slate-800 rounded-full text-xs font-bold">Check-up</span>
</td>
<td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100">10:30 AM</td>
</tr>
<tr class="hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
<td class="px-6 py-4 text-sm font-medium text-slate-400">P-108</td>
<td class="px-6 py-4 text-sm font-bold">Charlie</td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400">Mike Brown</td>
<td class="px-6 py-4">
<span class="px-3 py-1 bg-primary/10 text-primary rounded-full text-xs font-bold">Surgery</span>
</td>
<td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100">01:00 PM</td>
</tr>
<tr class="hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
<td class="px-6 py-4 text-sm font-medium text-slate-400">P-112</td>
<td class="px-6 py-4 text-sm font-bold">Luna</td>
<td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400">Emily Davis</td>
<td class="px-6 py-4">
<span class="px-3 py-1 bg-slate-100 dark:bg-slate-800 rounded-full text-xs font-bold">X-Ray</span>
</td>
<td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100">02:30 PM</td>
</tr>
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
<button class="w-full flex items-center justify-between px-4 py-3 bg-primary text-white rounded-xl font-bold hover:bg-primary/90 transition-all shadow-lg shadow-primary/20">
<span>New Examination</span>
<span class="material-symbols-outlined">add_circle</span>
</button>
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
<div class="p-4 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer">
<div>
<p class="text-sm font-bold">Bella</p>
<p class="text-xs text-slate-500">Blood Profile</p>
</div>
<div class="text-right">
<p class="text-xs font-bold text-primary">Critical</p>
<p class="text-[10px] text-slate-400 uppercase">Oct 24, 2023</p>
</div>
</div>
<div class="p-4 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer">
<div>
<p class="text-sm font-bold">Charlie</p>
<p class="text-xs text-slate-500">Post-Op Screening</p>
</div>
<div class="text-right">
<p class="text-xs font-bold text-green-500">Normal</p>
<p class="text-[10px] text-slate-400 uppercase">Oct 23, 2023</p>
</div>
</div>
<div class="p-4 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer">
<div>
<p class="text-sm font-bold">Max</p>
<p class="text-xs text-slate-500">Urinalysis</p>
</div>
<div class="text-right">
<p class="text-xs font-bold text-slate-500">Pending</p>
<p class="text-[10px] text-slate-400 uppercase">Oct 23, 2023</p>
</div>
</div>
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
