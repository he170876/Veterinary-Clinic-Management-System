<%@ page import="java.util.List,java.time.LocalDate,java.time.Period,model.Pet,model.Customer,model.User" %>
<!DOCTYPE html>
<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Anipat Enhanced Pet Management Dashboard</title>
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
        .sidebar-active {
            @apply bg-[#ff7b0015] text-primary border-l-4 border-primary;
        }
        .summary-card-icon {
            @apply size-12 rounded-xl flex items-center justify-center;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-[#f8f7f5]">
<%
    List<Pet> pets = (List<Pet>) request.getAttribute("pets");
%>
<%
    if (pets == null) {
        response.sendRedirect(request.getContextPath() + "/pets");
        return;
    }
%>
<div class="flex h-screen overflow-hidden">
<aside class="w-64 flex flex-col bg-white dark:bg-[#2d2116] border-r border-[#f5f2f0] dark:border-[#3d2f23]">
<div class="p-6 flex items-center gap-3">
<div class="size-10 bg-primary rounded-lg flex items-center justify-center text-white">
<span class="material-symbols-outlined text-2xl">pets</span>
</div>
<div>
<h1 class="text-xl font-bold text-primary leading-tight">Anipat</h1>
<p class="text-xs text-[#8d755e] dark:text-[#a68e7a]">Pet Management</p>
</div>
</div>
<nav class="flex-1 mt-4 px-3 space-y-1">
<a class="flex items-center gap-3 px-4 py-3 rounded-lg sidebar-active transition-colors" href="#">
<span class="material-symbols-outlined">dashboard</span>
<span class="text-sm font-bold">Dashboard</span>
</a>
<a class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-600 dark:text-gray-300 hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors" href="#">
<span class="material-symbols-outlined">pets</span>
<span class="text-sm font-semibold">My Pets</span>
</a>
<a class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-600 dark:text-gray-300 hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors" href="#">
<span class="material-symbols-outlined">medical_information</span>
<span class="text-sm font-semibold">Medical Records</span>
</a>
<a class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-600 dark:text-gray-300 hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors" href="#">
<span class="material-symbols-outlined">calendar_month</span>
<span class="text-sm font-semibold">Appointments</span>
</a>
<a class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-600 dark:text-gray-300 hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors" href="#">
<span class="material-symbols-outlined">settings</span>
<span class="text-sm font-semibold">Settings</span>
</a>
</nav>
<div class="p-4 mt-auto border-t border-[#f5f2f0] dark:border-[#3d2f23]">
<a class="flex items-center gap-3 px-4 py-3 rounded-lg text-red-500 hover:bg-red-50 dark:hover:bg-red-900/10 transition-colors" href="#">
<span class="material-symbols-outlined">logout</span>
<span class="text-sm font-semibold">Logout</span>
</a>
</div>
</aside>
<main class="flex-1 flex flex-col overflow-y-auto">
<header class="flex items-center justify-between bg-white dark:bg-[#2d2116] border-b border-[#f5f2f0] dark:border-[#3d2f23] px-8 py-4 sticky top-0 z-10">
<div class="flex items-center gap-4 flex-1">
<h2 class="text-xl font-bold tracking-tight">Dashboard Overview</h2>
<div class="relative w-64 ml-4">
<form action="<%= request.getContextPath() %>/pets" method="get">
<input type="hidden" name="action" value="search"/>
<span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#8d755e] text-xl pointer-events-none">search</span>
<%
    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) searchQuery = "";
%>
<input class="w-full pl-10 pr-4 py-2 bg-[#f5f2f0] dark:bg-[#3d2f23] border-none rounded-lg focus:ring-2 focus:ring-primary/50 text-sm" 
       placeholder="Search pets..." 
       type="text" 
       name="q"
       value="<%= searchQuery %>"/>
</form>
</div>
</div>
<div class="flex items-center gap-6">
<button class="relative p-2 text-[#8d755e] hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] rounded-full transition-colors">
<span class="material-symbols-outlined">notifications</span>
<span class="absolute top-2 right-2 size-2 bg-primary rounded-full border-2 border-white dark:border-[#2d2116]"></span>
</button>
<div class="flex items-center gap-3 pl-4 border-l border-[#f5f2f0] dark:border-[#3d2f23]">
<div class="text-right">
<%
    Customer customer = (Customer) request.getAttribute("customer");
    String customerName = customer != null ? customer.getName() : "Pet Parent";
    String customerAvatar = customer != null && customer.getProfilePicture() != null ? 
        customer.getProfilePicture() : 
        "https://lh3.googleusercontent.com/aida-public/AB6AXuAYzvVNZrdN5NNbem2goJWK2gz9HMXOTc-WbF8vF_7opdIEsRYhKo_JL1TBXuWxTOXp5NyQ9O1xvcZLApjZg0odnljfG1-cg41-R5ZtvIZjbAAa8x-XwpfXcfZDBZ8v04bsqrDYVeXt_HlNY7yWZxwP02gP_laKZAWgmGl9qt3E7TfetvgWteNVfrj5HkNO7xqPys34XZV7VnQ7DbF1uT892-Iw87DF_YtR9jJ8bPpu_mhbECp2i4UMQYidzLPHverlgvCFo7pp-g";
%>
<p class="text-sm font-bold"><%= customerName %></p>
<p class="text-xs text-[#8d755e]">Pet Parent</p>
</div>
<div class="size-10 bg-center bg-no-repeat bg-cover rounded-full border border-primary/20" style='background-image: url("<%= customerAvatar %>");'></div>
</div>
</div>
</header>
<div class="p-8 max-w-7xl mx-auto w-full">
<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
<div class="bg-white dark:bg-[#2d2116] p-6 rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] flex items-center gap-5">
<div class="summary-card-icon bg-orange-100 text-primary">
<span class="material-symbols-outlined text-3xl">pets</span>
</div>
<div>
<p class="text-sm font-medium text-[#8d755e] dark:text-[#a68e7a]">Total Pets</p>
<p class="text-2xl font-extrabold"><%= pets != null ? pets.size() : 0 %></p>
</div>
</div>
<div class="bg-white dark:bg-[#2d2116] p-6 rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] flex items-center gap-5">
<div class="summary-card-icon bg-blue-100 text-blue-600">
<span class="material-symbols-outlined text-3xl">event</span>
</div>
<div>
<p class="text-sm font-medium text-[#8d755e] dark:text-[#a68e7a]">Upcoming Appointments</p>
<p class="text-2xl font-extrabold">02</p>
</div>
</div>
<div class="bg-white dark:bg-[#2d2116] p-6 rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] flex items-center gap-5">
<div class="summary-card-icon bg-green-100 text-green-600">
<span class="material-symbols-outlined text-3xl">medical_services</span>
</div>
<div>
<p class="text-sm font-medium text-[#8d755e] dark:text-[#a68e7a]">Total Visits</p>
<p class="text-2xl font-extrabold">24</p>
</div>
</div>
</div>
<%
    // Get customer_id from parameter or session
    String custIdParam = request.getParameter("customer_id");
    String customerIdUrl = custIdParam != null && !custIdParam.isEmpty() ? "&customer_id=" + custIdParam : "";
%>
<div class="flex flex-wrap items-center justify-between gap-4 mb-6">
<div>
<h3 class="text-2xl font-extrabold tracking-tight">Pet List</h3>
<p class="text-[#8d755e] dark:text-[#a68e7a] text-sm">Manage your pets and their health records below.</p>
</div>
<a class="flex items-center gap-2 px-6 py-2.5 bg-primary text-white font-bold rounded-lg hover:bg-orange-600 transition-colors shadow-lg shadow-primary/20" href="<%= request.getContextPath() %>/pets?action=create<%= customerIdUrl %>">
<span class="material-symbols-outlined text-xl">add</span>
<span>Add Pet</span>
</a>
</div>
<div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] overflow-hidden">
<div class="overflow-x-auto">
<table class="w-full text-left border-collapse">
<thead>
<tr class="bg-[#fcfbf9] dark:bg-[#34281d] border-b border-[#f5f2f0] dark:border-[#3d2f23]">
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Pet Info</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Species &amp; Breed</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Age</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Health Status</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Last Visit</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a] text-right">Actions</th>
</tr>
</thead>
<tbody class="divide-y divide-[#f5f2f0] dark:divide-[#3d2f23]">
<%
    if (pets == null || pets.isEmpty()) {
%>
<tr>
    <td class="px-6 py-6 text-sm text-[#8d755e]" colspan="6">No pets found.</td>
</tr>
<%
    } else {
        for (Pet pet : pets) {
            String petName = pet.getName() != null ? pet.getName() : "(No name)";
            String species = pet.getSpecies() != null ? pet.getSpecies() : "N/A";
            String breed = pet.getBreed() != null ? pet.getBreed() : "N/A";
            String photoUrl = pet.getPhotoUrl() != null && !pet.getPhotoUrl().isEmpty() 
                ? request.getContextPath() + "/" + pet.getPhotoUrl() 
                : "https://via.placeholder.com/150/cccccc/666666?text=" + (species != null ? species.substring(0,1) : "P");
            String ageText = "N/A";
            if (pet.getBirthDate() != null) {
                Period age = Period.between(pet.getBirthDate(), LocalDate.now());
                ageText = age.getYears() + " years";
            }
%>
<tr class="hover:bg-[#fcfbf9] dark:hover:bg-[#34281d] transition-colors">
    <td class="px-6 py-4">
        <div class="flex items-center gap-4">
            <div class="size-12 rounded-lg bg-cover bg-center border border-[#f5f2f0] dark:border-[#3d2f23]" style='background-image: url("<%= photoUrl %>");'></div>
            <div>
                <p class="font-bold"><%= petName %></p>
                <p class="text-xs text-[#8d755e]">ID: <%= pet.getPetId() %></p>
            </div>
        </div>
    </td>
    <td class="px-6 py-4 text-sm">
        <p class="font-medium"><%= species %></p>
        <p class="text-xs text-[#8d755e]"><%= breed %></p>
    </td>
    <td class="px-6 py-4 text-sm font-medium"><%= ageText %></td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-green-100 text-green-700">Active</span>
    </td>
    <td class="px-6 py-4 text-sm">N/A</td>
    <td class="px-6 py-4">
        <div class="flex items-center justify-end gap-2">
            <a class="p-2 text-primary hover:bg-primary/10 rounded-lg" title="View Details" href="<%= request.getContextPath() %>/pets?action=details&id=<%= pet.getPetId() %><%= customerIdUrl %>">
                <span class="material-symbols-outlined text-xl">visibility</span>
            </a>
            <a class="p-2 text-[#8d755e] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg" title="Edit" href="<%= request.getContextPath() %>/pets?action=edit&id=<%= pet.getPetId() %><%= customerIdUrl %>">
                <span class="material-symbols-outlined text-xl">edit</span>
            </a>
            <a class="p-2 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/10 rounded-lg" title="Delete" href="<%= request.getContextPath() %>/pets?action=delete&id=<%= pet.getPetId() %><%= customerIdUrl %>" onclick="return confirm('Are you sure you want to delete <%= petName %>? This action cannot be undone.');">
                <span class="material-symbols-outlined text-xl">delete</span>
            </a>
        </div>
    </td>
</tr>
<%
        }
    }
%>
</tbody>
</table>
</div>
<div class="px-6 py-4 bg-[#fcfbf9] dark:bg-[#34281d] border-t border-[#f5f2f0] dark:border-[#3d2f23] flex items-center justify-between">
<p class="text-sm text-[#8d755e]">Showing <%= pets != null ? pets.size() : 0 %> of <%= pets != null ? pets.size() : 0 %> pets</p>
<div class="flex gap-2">
<button class="px-3 py-1 border border-[#f5f2f0] rounded text-sm disabled:opacity-50" disabled="">Previous</button>
<button class="px-3 py-1 border border-[#f5f2f0] rounded text-sm bg-white font-bold">1</button>
<button class="px-3 py-1 border border-[#f5f2f0] rounded text-sm bg-white">Next</button>
</div>
</div>
</div>
</div>
</main>
</div>

</body></html>