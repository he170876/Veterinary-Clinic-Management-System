<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Appointment" %>
<%@ page import="model.Pet" %>
<%@ page import="model.Customer" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.Period" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="model.Service" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) request.getAttribute("user");
    Appointment ap = (Appointment) request.getAttribute("appointment");
    if (user == null || ap == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    String roleTitle = (user.getRole() != null && user.getRole().getRoleName() != null)
        ? user.getRole().getRoleName() : "Veterinarian";
    Pet pet = ap.getPet();
    Customer cust = ap.getCustomer();
    String ownerName = (cust != null && cust.getUser() != null) ? cust.getUser().getFullName() : "—";
    String petName = (pet != null) ? pet.getName() : "—";
    String species = (pet != null && pet.getSpecies() != null) ? pet.getSpecies() : "";
    String breed = (pet != null && pet.getBreed() != null) ? pet.getBreed() : "";
    String breedAge = breed != null ? breed : "";
    if (pet != null && pet.getBirthDate() != null) {
        Period period = Period.between(pet.getBirthDate(), LocalDate.now());
        int years = period.getYears();
        String agePart = (years > 0) ? (years + " yrs") : (period.getMonths() + " mo");
        breedAge = breedAge.isEmpty() ? agePart : (breedAge + " / " + agePart);
    }
    if (breedAge.isEmpty()) breedAge = "—";
    String weightStr = (pet != null && pet.getWeight() != null) ? pet.getWeight() + " kg" : "—";
    int petId = (pet != null) ? pet.getPetId() : 0;
    String patientId = "#ANP-" + petId;
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    String lastVisit = (ap.getAppointmentTime() != null) ? ap.getAppointmentTime().format(dateFmt) : "—";
    @SuppressWarnings("unchecked")
    List<Service> clinicServices = (List<Service>) request.getAttribute("clinicServices");
    if (clinicServices == null) clinicServices = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Current Examination - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200;300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f14437",
                        "background-light": "#f8f6f6",
                        "background-dark": "#1a0f0e",
                    },
                    fontFamily: { "display": ["Manrope"] },
                    borderRadius: { "DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px" },
                },
            },
        }
    </script>
    <style>
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        #revisit-modal:target { display: flex; }
        #lab-request-modal:target { display: flex; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 min-h-screen">
<div class="flex h-screen overflow-hidden">
<aside class="w-64 bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800 flex flex-col shrink-0">
<div class="p-6 flex flex-col h-full">
<div class="flex items-center gap-3 mb-10">
<div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white">
<span class="material-symbols-outlined text-2xl">pets</span>
</div>
<div>
<h1 class="text-slate-900 dark:text-white font-bold leading-none">Anipats VCMS</h1>
<p class="text-slate-500 text-xs mt-1">Veterinarian Portal</p>
</div>
</div>
<nav class="flex-1 flex flex-col gap-1">
<a class="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-500 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="<%= ctx %>/vet/dashboard">
<span class="material-symbols-outlined">dashboard</span>
<span class="text-sm font-semibold">Dashboard</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary transition-colors" href="#">
<span class="material-symbols-outlined">description</span>
<span class="text-sm font-semibold">Medical Records</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-500 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="#">
<span class="material-symbols-outlined">biotech</span>
<span class="text-sm font-semibold">Lab Requests</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-500 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="<%= ctx %>/vet/queue">
<span class="material-symbols-outlined">calendar_today</span>
<span class="text-sm font-semibold">Appointments</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-500 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="#">
<span class="material-symbols-outlined">settings</span>
<span class="text-sm font-semibold">Settings</span>
</a>
</nav>
<div class="mt-auto pt-6">
<button class="w-full bg-primary text-white py-3 rounded-xl font-bold text-sm shadow-lg shadow-primary/20 hover:bg-primary/90 transition-all flex items-center justify-center gap-2">
<span class="material-symbols-outlined text-lg">emergency</span>
                    Emergency Alert
                </button>
</div>
</div>
</aside>
<main class="flex-1 flex flex-col overflow-hidden">
<header class="h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-8 shrink-0">
<div class="flex items-center gap-4">
<h2 class="text-slate-800 dark:text-white font-bold text-lg">Current Examination</h2>
</div>
<div class="flex items-center gap-6">
<div class="relative w-64">
<span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xl">search</span>
<input class="w-full pl-10 pr-4 py-1.5 bg-slate-100 dark:bg-slate-800 border-none rounded-lg text-sm focus:ring-2 focus:ring-primary/20" placeholder="Search patient or owner..." type="text"/>
</div>
<div class="flex items-center gap-3">
<button class="size-9 rounded-lg bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-slate-600 dark:text-slate-400">
<span class="material-symbols-outlined text-xl">notifications</span>
</button>
<div class="flex items-center gap-2 pl-3 border-l border-slate-200 dark:border-slate-800">
<div class="text-right hidden sm:block">
<p class="text-xs font-bold text-slate-900 dark:text-white leading-none"><%= user.getFullName() %></p>
<p class="text-[10px] text-slate-500"><%= roleTitle %></p>
</div>
<div class="size-9 rounded-full bg-slate-200 dark:bg-slate-700 overflow-hidden flex items-center justify-center text-primary font-bold">
<% if (user.getProfilePictureUrl() != null && !user.getProfilePictureUrl().isEmpty()) { %>
<img alt="Doctor Profile" class="w-full h-full object-cover" src="<%= ctx %><%= user.getProfilePictureUrl() %>"/>
<% } else { %>
<%= (user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "?" %>
<% } %>
</div>
</div>
</div>
</div>
</header>
<div class="flex-1 overflow-y-auto p-8 space-y-6">
<div class="flex items-center justify-between">
<div>
<div class="flex items-center gap-2 text-sm text-slate-400 mb-1">
<span>Dashboard</span>
<span class="material-symbols-outlined text-sm">chevron_right</span>
<a href="<%= ctx %>/vet/queue" class="text-slate-400 hover:text-primary">Appointments</a>
<span class="material-symbols-outlined text-sm">chevron_right</span>
<span class="text-primary font-medium">Patient Examination</span>
</div>
<h3 class="text-3xl font-black text-slate-900 dark:text-white"><%= petName %> <span class="text-slate-400 font-light">(<%= species.isEmpty() ? "—" : species %>)</span></h3>
<p class="text-slate-500">Patient ID: <span class="font-mono text-slate-700 dark:text-slate-300"><%= patientId %></span> | Owner: <%= ownerName %></p>
</div>
<div class="flex items-center gap-3">
<span class="px-4 py-1.5 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300 text-xs font-black rounded-full tracking-widest flex items-center gap-2">
<span class="size-2 rounded-full bg-green-500 animate-pulse"></span>
                        OPEN
                    </span>
<button class="px-6 py-2 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200 font-bold rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 transition-all">
                        Save Progress
                    </button>
</div>
</div>
<div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 grid grid-cols-2 lg:grid-cols-4 gap-8">
<div>
<p class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Breed / Age</p>
<p class="text-slate-900 dark:text-white font-semibold"><%= breedAge %></p>
</div>
<div>
<p class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Weight</p>
<p class="text-slate-900 dark:text-white font-semibold"><%= weightStr %></p>
</div>
<div>
<p class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Last Visit</p>
<p class="text-slate-900 dark:text-white font-semibold"><%= lastVisit %></p>
</div>
<div>
<p class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Condition</p>
<span class="px-2 py-0.5 bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300 text-[10px] font-bold rounded uppercase">Follow-up Required</span>
</div>
</div>
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
<div class="lg:col-span-2 space-y-6">
<div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
<h4 class="text-lg font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
<span class="material-symbols-outlined text-primary">medical_information</span>
                            Diagnosis &amp; Observation
                        </h4>
<textarea class="w-full rounded-xl border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white focus:ring-primary focus:border-primary placeholder:text-slate-400 p-4" placeholder="Describe symptoms, physical exam findings, and preliminary diagnosis..." rows="6"></textarea>
</div>
<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
<div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
<h4 class="text-md font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
<span class="material-symbols-outlined text-primary text-xl">payments</span>
                                Services
                            </h4>
<div class="space-y-3" id="examination-services-list">
<div class="flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row" data-service-id="" data-service-name="General Consultation">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span>
<span class="text-sm font-semibold text-slate-700 dark:text-slate-200">General Consultation</span>
</div>
<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-edit" aria-label="Edit"><span class="material-symbols-outlined text-lg">edit</span></button>
<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button>
</div>
</div>
</div>
<button type="button" id="add-service-btn" class="w-full py-2 border-2 border-dashed border-slate-200 dark:border-slate-700 rounded-lg text-slate-400 text-xs font-bold hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                                    + ADD SERVICE
                                </button>
<% if (!clinicServices.isEmpty()) { %>
<div id="add-service-dropdown" class="hidden mt-2 p-2 bg-slate-50 dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 max-h-48 overflow-y-auto">
<% for (Service svc : clinicServices) { %>
<button type="button" class="add-service-option w-full text-left px-3 py-2 text-sm text-slate-700 dark:text-slate-200 hover:bg-primary/10 rounded-lg flex justify-between items-center" data-id="<%= svc.getServiceId() %>" data-name="<%= svc.getName() %>"><span><%= svc.getName() %></span><span class="text-xs text-slate-400"><%= String.format("%.2f", svc.getPrice()) %> </span></button>
<% } %>
</div>
<% } %>
</div>
</div>
<div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
<h4 class="text-md font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
<span class="material-symbols-outlined text-primary text-xl">prescriptions</span>
                                Prescription
                            </h4>
<div class="space-y-3">
<div class="flex items-center gap-2">
<input class="flex-1 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Medication name" type="text"/>
<input class="w-20 rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Dose" type="text"/>
</div>
<input class="w-full rounded-lg border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2" placeholder="Frequency (e.g. 2x daily)" type="text"/>
<button class="w-full py-2 border-2 border-dashed border-slate-200 dark:border-slate-700 rounded-lg text-slate-400 text-xs font-bold hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                                    + ADD MEDICATION
                                </button>
</div>
</div>
<div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm md:col-span-2 lg:col-span-1">
<h4 class="text-md font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
<span class="material-symbols-outlined text-primary text-xl">vaccines</span>
                                Treatment Plan
                            </h4>
<div class="space-y-3">
<textarea class="w-full rounded-lg border border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm" placeholder="Step-by-step treatment instructions..." rows="3"></textarea>
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-slate-400 text-lg">event_repeat</span>
<select class="flex-1 rounded-lg border border-slate-200 dark:border-slate-700 dark:bg-slate-800 text-sm py-2">
<option>Schedule next checkup</option>
<option>In 3 days</option>
<option>In 1 week</option>
<option>In 2 weeks</option>
</select>
</div>
</div>
</div>
</div>
</div>
</div>
<div class="space-y-6">
<div class="bg-white dark:bg-slate-900 rounded-xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
<h4 class="text-sm font-bold text-slate-400 uppercase tracking-widest mb-6">Action Panel</h4>
<div class="space-y-4 mb-8">
<p class="text-sm text-slate-600 dark:text-slate-400">Clinical investigations and follow-ups:</p>
<a href="#lab-request-modal" class="w-full bg-primary text-white py-3.5 rounded-xl font-bold text-sm flex items-center justify-center gap-2 shadow-lg shadow-primary/20 hover:bg-primary/90 transition-all text-center no-underline">
<span class="material-symbols-outlined text-xl">biotech</span>
                                Request Lab Test
                            </a>
<a class="w-full border-2 border-primary text-primary py-3 rounded-xl font-bold text-sm flex items-center justify-center gap-2 hover:bg-primary/5 transition-all text-center cursor-pointer" href="#revisit-modal">
<span class="material-symbols-outlined text-xl">event_available</span>
                                Schedule Revisit
                            </a>
</div>
<div class="space-y-3">
<hr class="border-slate-100 dark:border-slate-800 my-4"/>
<button class="w-full bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 py-4 rounded-xl font-bold text-lg hover:scale-[1.02] transition-transform shadow-lg shadow-slate-900/10">
                                Complete Examination
                            </button>
<p class="text-center text-[10px] text-slate-400 italic">Completing will finalize the medical record and generate billing charges.</p>
</div>
</div>
<div class="bg-primary/5 rounded-xl p-6 border border-primary/10">
<h4 class="text-sm font-bold text-primary mb-3 flex items-center gap-2">
<span class="material-symbols-outlined text-sm">history</span>
                            Recent Lab Work (2 weeks ago)
                        </h4>
<ul class="space-y-2 text-xs">
<li class="flex justify-between text-slate-600 dark:text-slate-400">
<span>Hematology CBC</span>
<span class="font-bold text-slate-900 dark:text-white">Normal</span>
</li>
<li class="flex justify-between text-slate-600 dark:text-slate-400">
<span>Glucose Level</span>
<span class="font-bold text-primary">High (132)</span>
</li>
<li class="flex justify-between text-slate-600 dark:text-slate-400">
<span>Urinalysis</span>
<span class="font-bold text-slate-900 dark:text-white">Clear</span>
</li>
</ul>
</div>
</div>
</div>
</div>
</main>
</div>
<div class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 items-center justify-center p-4" id="revisit-modal">
<div class="bg-white dark:bg-slate-900 w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
<div class="p-6 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center">
<h3 class="text-lg font-bold text-slate-900 dark:text-white flex items-center gap-2">
<span class="material-symbols-outlined text-primary">calendar_month</span>
                Schedule Follow-up
            </h3>
<a class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200" href="#">
<span class="material-symbols-outlined">close</span>
</a>
</div>
<div class="p-8 space-y-6">
<div>
<label class="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Preferred Date</label>
<input class="w-full rounded-xl border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white focus:ring-primary focus:border-primary p-3" type="date" name="revisitDate"/>
</div>
<div>
<label class="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Preferred Time</label>
<div class="grid grid-cols-3 gap-2">
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors">09:00 AM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-primary text-primary bg-primary/5 rounded-lg">10:30 AM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors">01:00 PM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors">02:30 PM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors">04:00 PM</button>
<button type="button" class="revisit-time py-2 text-xs font-semibold border border-slate-200 dark:border-slate-700 rounded-lg hover:border-primary hover:text-primary transition-colors">05:30 PM</button>
</div>
</div>
<div class="pt-2">
<a class="w-full bg-primary text-white py-3.5 rounded-xl font-bold text-sm flex items-center justify-center gap-2 shadow-lg shadow-primary/20 hover:bg-primary/90 transition-all text-center inline-block" href="#">
                    Confirm Appointment
                </a>
</div>
</div>
</div>
</div>

<script>
(function() {
    var addBtn = document.getElementById('add-service-btn');
    var dropdown = document.getElementById('add-service-dropdown');
    var list = document.getElementById('examination-services-list');
    if (addBtn && dropdown) {
        addBtn.addEventListener('click', function() {
            dropdown.classList.toggle('hidden');
        });
    }
    if (list && dropdown) {
        document.querySelectorAll('.add-service-option').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var id = this.getAttribute('data-id');
                var name = this.getAttribute('data-name');
                var row = document.createElement('div');
                row.className = 'flex items-center justify-between p-3 bg-slate-50 dark:bg-slate-800 rounded-lg group service-row';
                row.setAttribute('data-service-id', id);
                row.setAttribute('data-service-name', name);
                row.innerHTML = '<div class="flex items-center gap-3"><span class="material-symbols-outlined text-slate-400 text-lg">check_circle</span><span class="text-sm font-semibold text-slate-700 dark:text-slate-200">' + (name || '').replace(/</g, '&lt;') + '</span></div>' +
                    '<div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">' +
                    '<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-edit" aria-label="Edit"><span class="material-symbols-outlined text-lg">edit</span></button>' +
                    '<button type="button" class="p-1 hover:text-primary text-slate-400 transition-colors service-remove" aria-label="Remove"><span class="material-symbols-outlined text-lg">delete</span></button></div>';
                row.querySelector('.service-remove').addEventListener('click', function() { row.remove(); });
                list.appendChild(row);
                dropdown.classList.add('hidden');
            });
        });
    }
    document.querySelectorAll('#examination-services-list .service-remove').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var row = this.closest('.service-row');
            if (row) row.remove();
        });
    });
})();
</script>

<!-- Lab Request Modal -->
<div class="hidden fixed inset-0 bg-slate-900/70 backdrop-blur-sm z-50 items-center justify-center p-4" id="lab-request-modal">
<div class="relative z-20 w-full max-w-xl bg-white dark:bg-slate-900 rounded-xl shadow-2xl overflow-hidden flex flex-col">
<div class="flex items-center justify-between px-8 py-5 border-b border-slate-100 dark:border-slate-800">
<div>
<h2 class="text-slate-900 dark:text-slate-100 text-xl font-bold tracking-tight">New Lab Request</h2>
<p class="text-slate-500 text-xs mt-0.5">Fill in the clinical details for the examination</p>
</div>
<a href="#" class="text-slate-400 hover:text-primary transition-colors p-1" aria-label="Close">
<span class="material-symbols-outlined">close</span>
</a>
</div>
<div class="px-8 py-6 space-y-6">
<div class="bg-slate-50 dark:bg-slate-800/50 rounded-lg p-4 border border-slate-100 dark:border-slate-800">
<div class="grid grid-cols-3 gap-4">
<div>
<p class="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-0.5">Patient</p>
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-primary text-sm">pets</span>
<p class="text-slate-900 dark:text-slate-100 font-semibold text-sm"><%= petName %></p>
</div>
</div>
<div>
<p class="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-0.5">Breed</p>
<p class="text-slate-900 dark:text-slate-100 font-semibold text-sm"><%= breed.isEmpty() ? "—" : breed %></p>
</div>
<div>
<p class="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-0.5">Owner</p>
<p class="text-slate-900 dark:text-slate-100 font-semibold text-sm"><%= ownerName %></p>
</div>
</div>
</div>
<form class="space-y-5" id="lab-request-form" action="#" method="post">
<div class="space-y-1.5">
<label class="text-slate-700 dark:text-slate-300 text-xs font-bold uppercase tracking-wide flex items-center gap-1.5">
<span class="material-symbols-outlined text-primary text-base">biotech</span>
                    Lab Test Type
                </label>
<div class="relative">
<select class="w-full h-11 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-4 text-slate-900 dark:text-slate-100 focus:ring-2 focus:ring-primary focus:border-transparent appearance-none cursor-pointer text-sm" name="labTestType" required>
<option disabled selected value="">Select examination type...</option>
<option value="cbc">Complete Blood Count (CBC)</option>
<option value="urinalysis">Urinalysis (Full Panel)</option>
<option value="xray">Digital X-Ray - Thoracic</option>
<option value="biopsy">Tissue Biopsy</option>
<option value="fecal">Fecal Examination</option>
</select>
<span class="material-symbols-outlined absolute right-3 top-2.5 text-slate-400 pointer-events-none">expand_more</span>
</div>
</div>
<div class="space-y-1.5">
<label class="text-slate-700 dark:text-slate-300 text-xs font-bold uppercase tracking-wide flex items-center gap-1.5">
<span class="material-symbols-outlined text-primary text-base">priority_high</span>
                    Priority Level
                </label>
<div class="flex h-10 bg-slate-100 dark:bg-slate-800 rounded-lg p-1 gap-1">
<label class="flex-1 flex items-center justify-center cursor-pointer rounded-md transition-all has-[:checked]:bg-white dark:has-[:checked]:bg-slate-700 has-[:checked]:shadow-sm has-[:checked]:text-slate-900 text-slate-500 font-semibold text-xs">
<input checked class="hidden" name="priority" type="radio" value="normal"/>
<span>Normal</span>
</label>
<label class="flex-1 flex items-center justify-center cursor-pointer rounded-md transition-all has-[:checked]:bg-primary has-[:checked]:text-white text-slate-500 font-semibold text-xs">
<input class="hidden" name="priority" type="radio" value="urgent"/>
<span>Urgent</span>
</label>
</div>
</div>
<div class="space-y-1.5">
<label class="text-slate-700 dark:text-slate-300 text-xs font-bold uppercase tracking-wide flex items-center gap-1.5">
<span class="material-symbols-outlined text-primary text-base">description</span>
                    Clinical Notes
                </label>
<textarea class="w-full min-h-[120px] bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg p-3 text-slate-900 dark:text-slate-100 text-sm focus:ring-2 focus:ring-primary focus:border-transparent placeholder:text-slate-400 resize-none" name="clinicalNotes" placeholder="Provide clinical observations or reason for request..."></textarea>
</div>
</form>
</div>
<div class="px-8 py-5 border-t border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/50 flex items-center justify-end gap-3">
<a href="#" class="px-5 py-2 rounded-lg text-slate-600 dark:text-slate-400 font-bold text-sm hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors">
            Cancel
        </a>
<button type="submit" form="lab-request-form" class="px-7 py-2.5 rounded-lg bg-primary text-white font-bold text-sm shadow-md shadow-primary/20 hover:brightness-110 active:scale-[0.98] transition-all flex items-center gap-2">
<span>Submit Request</span>
<span class="material-symbols-outlined text-base">send</span>
</button>
</div>
</div>
</div>
</div>

</body>
</html>
