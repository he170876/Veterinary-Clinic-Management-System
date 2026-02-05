<%@ page import="model.Pet" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Anipat - Pet Profile Overview</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;700;800&amp;display=swap" rel="stylesheet"/>
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
        body {
            font-family: 'Manrope', sans-serif;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-white min-h-screen">
<%
    Pet pet = (Pet) request.getAttribute("pet");
    String petName = pet != null && pet.getName() != null ? pet.getName() : "Pet";
    String species = pet != null && pet.getSpecies() != null ? pet.getSpecies() : "N/A";
    String breed = pet != null && pet.getBreed() != null ? pet.getBreed() : "N/A";
    String gender = pet != null && pet.getGender() != null ? pet.getGender() : "N/A";
    String birthDate = pet != null && pet.getBirthDate() != null ? pet.getBirthDate().toString() : "N/A";
    
    // Calculate age - if under 1 year, show in months
    String ageDisplay = "N/A";
    if (pet != null && pet.getBirthDate() != null) {
        LocalDate birthDateObj = pet.getBirthDate();
        LocalDate today = LocalDate.now();
        long years = ChronoUnit.YEARS.between(birthDateObj, today);
        
        if (years == 0) {
            // Under 1 year - show in months, but not 0 months
            long months = ChronoUnit.MONTHS.between(birthDateObj, today);
            if (months == 0) {
                ageDisplay = "Less than 1 month old";
            } else {
                ageDisplay = months + " months";
            }
        } else {
            // 1 year or older - show in years
            ageDisplay = years + " years";
        }
    }
    
    String weight = pet != null && pet.getWeight() != null ? String.format("%.1f kg", pet.getWeight()) : "N/A";
    int petId = pet != null ? pet.getPetId() : 0;
    String photoUrl = pet != null && pet.getPhotoUrl() != null && !pet.getPhotoUrl().isEmpty()
        ? request.getContextPath() + "/" + pet.getPhotoUrl()
        : "https://via.placeholder.com/300/cccccc/666666?text=" + (species != null && !"N/A".equals(species) ? species.substring(0,1) : "P");
%>
<div class="flex h-screen overflow-hidden">
<!-- Sidebar -->
<aside class="w-64 bg-white dark:bg-zinc-900 border-r border-[#e5e7eb] dark:border-zinc-800 flex flex-col justify-between p-4 shrink-0">
<div class="flex flex-col gap-8">
<div class="flex items-center gap-3 px-2">
<div class="size-10 bg-primary rounded-lg flex items-center justify-center text-white">
<span class="material-symbols-outlined">pets</span>
</div>
<div>
<h1 class="text-lg font-bold leading-none">Anipat</h1>
<p class="text-[#8d755e] text-xs font-medium">Pet Management</p>
</div>
</div>
<nav class="flex flex-col gap-1">
<a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#8d755e] hover:bg-background-light dark:hover:bg-zinc-800 transition-colors" href="#">
<span class="material-symbols-outlined">dashboard</span>
<span class="text-sm font-medium">Dashboard</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary transition-colors" href="#">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">potted_plant</span>
<span class="text-sm font-bold">My Pets</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#8d755e] hover:bg-background-light dark:hover:bg-zinc-800 transition-colors" href="#">
<span class="material-symbols-outlined">description</span>
<span class="text-sm font-medium">Medical Records</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#8d755e] hover:bg-background-light dark:hover:bg-zinc-800 transition-colors" href="#">
<span class="material-symbols-outlined">notifications</span>
<span class="text-sm font-medium">Reminders</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#8d755e] hover:bg-background-light dark:hover:bg-zinc-800 transition-colors" href="#">
<span class="material-symbols-outlined">settings</span>
<span class="text-sm font-medium">Settings</span>
</a>
</nav>
</div>
<div class="flex flex-col gap-4">
<!-- Quick Stats -->
<div class="p-3 bg-background-light dark:bg-zinc-800 rounded-xl space-y-3">
<p class="text-xs font-bold text-[#8d755e] uppercase tracking-wider">Quick Stats</p>
<div class="flex justify-between items-center">
<span class="text-sm">Total Visits</span>
<span class="text-sm font-bold text-primary">12</span>
</div>
<div class="flex justify-between items-center">
<span class="text-sm">Vaccinations</span>
<span class="text-sm font-bold text-primary">8</span>
</div>
</div>
<a class="w-full bg-primary text-white font-bold py-2.5 rounded-lg text-sm flex items-center justify-center gap-2" href="<%= request.getContextPath() %>/pets?action=create">
<span class="material-symbols-outlined text-sm">add</span>
                    Add New Pet
                </a>
</div>
</aside>
<!-- Main Content -->
<main class="flex-1 overflow-y-auto">
<!-- Header Section -->
<div class="bg-white dark:bg-zinc-900 border-b border-[#e5e7eb] dark:border-zinc-800 p-6">
<div class="max-w-6xl mx-auto flex flex-col md:flex-row md:items-center justify-between gap-4">
<div class="flex items-center gap-5">
<div class="size-20 bg-primary/20 rounded-2xl overflow-hidden border-2 border-primary/10">
<div class="w-full h-full bg-center bg-cover bg-no-repeat" data-alt="Pet profile photo" style='background-image: url("<%= photoUrl %>");'></div>
</div>
<div>
<h2 class="text-3xl font-extrabold tracking-tight"><%= petName %></h2>
<p class="text-[#8d755e] font-medium"><%= species %><%= "N/A".equals(breed) ? "" : " &bull; " + breed %></p>
</div>
</div>
<div class="flex items-center gap-3">
<a class="px-5 py-2.5 bg-background-light dark:bg-zinc-800 border border-[#e5e7eb] dark:border-zinc-700 rounded-lg text-sm font-bold hover:bg-zinc-100 transition-colors" href="<%= request.getContextPath() %>/pets?action=edit&id=<%= petId %>">
                            Edit Pet
                        </a>
<a class="px-5 py-2.5 bg-primary text-white rounded-lg text-sm font-bold shadow-lg shadow-primary/20 hover:brightness-110 transition-all" href="<%= request.getContextPath() %>/pets">
                            View Medical History
                        </a>
</div>
</div>
</div>
<!-- Dashboard Grid -->
<div class="p-6 max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-6">
<!-- Left Column: Profile Card -->
<div class="lg:col-span-4 flex flex-col gap-6">
<div class="bg-white dark:bg-zinc-900 rounded-xl border border-[#e5e7eb] dark:border-zinc-800 overflow-hidden shadow-sm">
<div class="aspect-square w-full bg-center bg-cover bg-no-repeat" data-alt="Pet full profile photo" style='background-image: url("<%= photoUrl %>");'></div>
<div class="p-6 space-y-4">
<h3 class="text-lg font-bold border-b border-[#f5f2f0] dark:border-zinc-800 pb-2">Profile Details</h3>
<div class="grid grid-cols-1 gap-4">
<div class="flex items-center gap-3">
<div class="size-10 rounded-lg bg-background-light dark:bg-zinc-800 flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-xl">male</span>
</div>
<div>
<p class="text-[10px] uppercase font-bold text-[#8d755e] tracking-wider">Gender</p>
<p class="text-sm font-bold"><%= gender %></p>
</div>
</div>
<div class="flex items-center gap-3">
<div class="size-10 rounded-lg bg-background-light dark:bg-zinc-800 flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-xl">weight</span>
</div>
<div>
<p class="text-[10px] uppercase font-bold text-[#8d755e] tracking-wider">Weight</p>
<p class="text-sm font-bold"><%= weight %></p>
</div>
</div>
<div class="flex items-center gap-3">
<div class="size-10 rounded-lg bg-background-light dark:bg-zinc-800 flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-xl">palette</span>
</div>
<div>
<p class="text-[10px] uppercase font-bold text-[#8d755e] tracking-wider">Color</p>
<p class="text-sm font-bold">Golden Blonde</p>
</div>
</div>
<div class="flex items-center gap-3">
<div class="size-10 rounded-lg bg-background-light dark:bg-zinc-800 flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-xl">cake</span>
</div>
<div>
<p class="text-[10px] uppercase font-bold text-[#8d755e] tracking-wider">Tuổi</p>
<p class="text-sm font-bold"><%= ageDisplay %></p>
</div>
</div>
</div>
</div>
</div>
</div>
<!-- Right Column: Health Overview -->
<div class="lg:col-span-8 space-y-6">
<!-- Status & Last Visit Section -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
<!-- Last Visit Card -->
<div class="bg-white dark:bg-zinc-900 p-5 rounded-xl border border-[#e5e7eb] dark:border-zinc-800 shadow-sm flex flex-col justify-between">
<div class="flex justify-between items-start mb-4">
<div>
<h4 class="text-[#8d755e] text-xs font-bold uppercase tracking-widest mb-1">Last Visit</h4>
<p class="text-xl font-bold">Oct 15, 2023</p>
</div>
<div class="size-10 bg-primary/10 rounded-lg flex items-center justify-center text-primary">
<span class="material-symbols-outlined">stethoscope</span>
</div>
</div>
<div class="flex items-center gap-3 bg-background-light dark:bg-zinc-800 p-3 rounded-lg">
<div class="size-8 rounded-full bg-center bg-cover" data-alt="Profile photo of Dr. Emily Smith" style='background-image: url("https://lh3.googleusercontent.com/aida-public/AB6AXuCQPGjCReywMp7lXIvHGp3DMGSBEgleWhqLmaR5zOCja83w9FrmRqSlzMtz46LrWcCGAnh5cCzA8fsmH46YXn57NckNZiuKOhPdTtmTlvhJRfqaLUutOTAsOIFS6fqyF6s1JZfiwVtAENecnZ-oVHMRxWx4os8HlXJzIT_J1DZuMtVE5nmU1MXsiPKotCdG9Tftatqyfbpcdax46q9n2MD6F8Iq6L3LqlKLRfy-UmpAe6VABrIUVPEelP7ZwM6D8IPt97l1fYYbeQ");'></div>
<div class="flex-1">
<p class="text-xs font-bold leading-tight">Dr. Emily Smith</p>
<p class="text-[10px] text-[#8d755e]">Anipat Vet Clinic</p>
</div>
<button class="text-primary hover:text-primary/80">
<span class="material-symbols-outlined text-lg">open_in_new</span>
</button>
</div>
</div>
<!-- Current Health Status Card -->
<div class="bg-white dark:bg-zinc-900 p-5 rounded-xl border border-[#e5e7eb] dark:border-zinc-800 shadow-sm flex flex-col justify-between">
<div>
<h4 class="text-[#8d755e] text-xs font-bold uppercase tracking-widest mb-1">Health Status</h4>
<div class="mt-2 flex items-center gap-2">
<span class="relative flex h-3 w-3">
<span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
<span class="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
</span>
<p class="text-xl font-bold">Up to Date</p>
</div>
</div>
<div class="mt-4">
<p class="text-sm text-[#8d755e] leading-relaxed">Max is currently in excellent health. Next screening scheduled in 6 months.</p>
</div>
<div class="mt-4 pt-4 border-t border-[#f5f2f0] dark:border-zinc-800">
<div class="flex items-center justify-between">
<span class="text-xs font-medium text-[#8d755e]">Immunity Score</span>
<span class="text-xs font-bold text-green-600">92%</span>
</div>
<div class="w-full bg-zinc-100 dark:bg-zinc-800 rounded-full h-1.5 mt-2 overflow-hidden">
<div class="bg-green-500 h-1.5 rounded-full" style="width: 92%"></div>
</div>
</div>
</div>
</div>
<!-- Upcoming Care Section -->
<div class="bg-white dark:bg-zinc-900 rounded-xl border border-[#e5e7eb] dark:border-zinc-800 shadow-sm overflow-hidden">
<div class="px-6 py-4 border-b border-[#f5f2f0] dark:border-zinc-800 flex justify-between items-center">
<h3 class="font-bold text-lg">Upcoming Care</h3>
<button class="text-primary text-sm font-bold">View Calendar</button>
</div>
<div class="divide-y divide-[#f5f2f0] dark:divide-zinc-800">
<!-- Care Item 1 -->
<div class="p-4 flex items-center justify-between hover:bg-background-light dark:hover:bg-zinc-800/50 transition-colors">
<div class="flex items-center gap-4">
<div class="size-12 rounded-xl bg-[#fff2e6] dark:bg-primary/20 flex flex-col items-center justify-center text-primary border border-primary/10">
<span class="text-[10px] font-bold uppercase leading-none">Nov</span>
<span class="text-lg font-extrabold leading-none">12</span>
</div>
<div>
<p class="font-bold text-sm">Rabies Booster</p>
<p class="text-xs text-[#8d755e]">Annual vaccination schedule</p>
</div>
</div>
<div class="flex items-center gap-2 px-3 py-1 bg-zinc-100 dark:bg-zinc-800 rounded-full">
<span class="material-symbols-outlined text-[14px]">event</span>
<span class="text-[10px] font-bold">Due in 18 days</span>
</div>
</div>
<!-- Care Item 2 -->
<div class="p-4 flex items-center justify-between hover:bg-background-light dark:hover:bg-zinc-800/50 transition-colors">
<div class="flex items-center gap-4">
<div class="size-12 rounded-xl bg-zinc-100 dark:bg-zinc-800 flex flex-col items-center justify-center text-[#8d755e] border border-zinc-200 dark:border-zinc-700">
<span class="text-[10px] font-bold uppercase leading-none">Dec</span>
<span class="text-lg font-extrabold leading-none">05</span>
</div>
<div>
<p class="font-bold text-sm">Dental Cleaning</p>
<p class="text-xs text-[#8d755e]">Routine plaque removal</p>
</div>
</div>
<div class="flex items-center gap-2 px-3 py-1 bg-zinc-100 dark:bg-zinc-800 rounded-full">
<span class="material-symbols-outlined text-[14px]">event</span>
<span class="text-[10px] font-bold">In 1 month</span>
</div>
</div>
<!-- Care Item 3 -->
<div class="p-4 flex items-center justify-between hover:bg-background-light dark:hover:bg-zinc-800/50 transition-colors">
<div class="flex items-center gap-4">
<div class="size-12 rounded-xl bg-zinc-100 dark:bg-zinc-800 flex flex-col items-center justify-center text-[#8d755e] border border-zinc-200 dark:border-zinc-700">
<span class="text-[10px] font-bold uppercase leading-none">Jan</span>
<span class="text-lg font-extrabold leading-none">15</span>
</div>
<div>
<p class="font-bold text-sm">Heartworm Prevention</p>
<p class="text-xs text-[#8d755e]">Oral medication refill</p>
</div>
</div>
<div class="flex items-center gap-2 px-3 py-1 bg-zinc-100 dark:bg-zinc-800 rounded-full">
<span class="material-symbols-outlined text-[14px]">event</span>
<span class="text-[10px] font-bold">Scheduled</span>
</div>
</div>
</div>
<div class="p-4 bg-background-light/50 dark:bg-zinc-800/20 text-center">
<button class="w-full py-2 border-2 border-dashed border-zinc-200 dark:border-zinc-700 rounded-lg text-xs font-bold text-[#8d755e] hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors">
                                + Add Reminder
                            </button>
</div>
</div>
</div>
</div>
</main>
</div>
</body></html>