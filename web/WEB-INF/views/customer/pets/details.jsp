<%@ page import="model.Pet" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%!
    private String resolvePhotoUrl(jakarta.servlet.http.HttpServletRequest request, String rawPhotoUrl, String fallbackUrl) {
        if (rawPhotoUrl == null || rawPhotoUrl.trim().isEmpty()) {
            return fallbackUrl;
        }

        String value = rawPhotoUrl.trim().replace ("\\", "/");
        if (value.startsWith("http://") || value.startsWith("https://")) {
            return value;
        }

        if (value.matches("^[A-Za-z]:/.*")) {
            int lastSlash = value.lastIndexOf('/');
            String fileName = lastSlash >= 0 ? value.substring(lastSlash + 1) : value;
            value = "uploads/pets/" + fileName;
        }

        while (value.startsWith("/")) {
            value = value.substring(1);
        }
        return request.getContextPath() + "/" + value;
    }
%>
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Anipat - Pet Profile Overview</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700;900&amp;display=swap" rel="stylesheet"/>
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
                        "display": ["Public Sans", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"},
                },
            },
        }
    </script>
<style>
        body {
            font-family: 'Public Sans', sans-serif;
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
    String photoUrl = resolvePhotoUrl(request,
        pet != null ? pet.getPhotoUrl() : null,
        "https://via.placeholder.com/300/cccccc/666666?text=" + (species != null && !"N/A".equals(species) ? species.substring(0,1) : "P"));
    model.User currentUser = (model.User) session.getAttribute("currentUser");
    String currentRole = (currentUser != null && currentUser.getRole() != null) ? currentUser.getRole().getRoleName() : "";
    boolean isCustomerUser = "Customer".equalsIgnoreCase(currentRole);
    request.setAttribute("customerCurrentPage", "pets");
%>
<div class="flex h-screen overflow-hidden">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    <main class="flex-1 overflow-y-auto bg-background-light dark:bg-background-dark">

        <!-- Header -->
        <div class="sticky top-0 z-10 bg-white/95 dark:bg-background-dark/85 border-b border-slate-200 dark:border-slate-800 px-8 py-4 backdrop-blur-sm">
            <div class="max-w-5xl mx-auto flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div class="flex items-center gap-4">
                    <div class="size-16 rounded-2xl overflow-hidden border-2 border-primary/20 shadow-sm flex-shrink-0"
                         style='background-image: url("<%= photoUrl %>"); background-size: cover; background-position: center;'></div>
                    <div>
                        <h1 class="text-2xl font-black text-[#181410] dark:text-white tracking-tight"><%= petName %></h1>
                        <p class="text-sm text-[#8d755e] font-medium mt-0.5">
                            <%= species %><%= "N/A".equals(breed) ? "" : " &bull; " + breed %>
                        </p>
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    <a href="<%= request.getContextPath() %>/pets?action=edit&id=<%= petId %>"
                       class="inline-flex items-center gap-1.5 px-4 py-2 rounded-lg border border-[#e5e7eb] dark:border-zinc-700 bg-white dark:bg-zinc-800 text-sm font-semibold text-[#181410] dark:text-white hover:bg-zinc-50 dark:hover:bg-zinc-700 transition-colors">
                        <span class="material-symbols-outlined text-base">edit</span>
                        Edit Pet
                    </a>
                    <a href="<%= request.getContextPath() %>/customer/medical-history?petId=<%= petId %>"
                       class="inline-flex items-center gap-1.5 px-4 py-2 rounded-lg bg-primary text-white text-sm font-semibold shadow-sm hover:bg-primary/90 transition-colors">
                        <span class="material-symbols-outlined text-base">history</span>
                        Medical History
                    </a>
                    <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                    <div class="h-8 w-px bg-slate-200 dark:bg-slate-700"></div>
                    <div class="text-right hidden sm:block">
                        <p class="text-sm font-bold text-slate-900 dark:text-slate-100"><%= currentUser != null && currentUser.getFullName() != null ? currentUser.getFullName() : "Customer" %></p>
                        <p class="text-xs text-slate-500">Pet Owner</p>
                    </div>
                    <div class="bg-primary/10 rounded-full size-10 border-2 border-primary/20 flex items-center justify-center text-primary font-bold text-lg">
                        <%= currentUser != null && currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0, 1).toUpperCase() : "C" %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Content Grid -->
        <div class="max-w-5xl mx-auto px-8 py-8 grid grid-cols-1 lg:grid-cols-12 gap-6">

            <!-- Left: Photo + Details -->
            <div class="lg:col-span-4 flex flex-col gap-5">
                <div class="bg-white dark:bg-zinc-900 rounded-2xl border border-[#e5e7eb] dark:border-zinc-800 overflow-hidden shadow-sm">
                    <div class="aspect-square w-full bg-center bg-cover bg-no-repeat"
                         style='background-image: url("<%= photoUrl %>");'></div>
                </div>
                <div class="bg-white dark:bg-zinc-900 rounded-2xl border border-[#e5e7eb] dark:border-zinc-800 shadow-sm p-5">
                    <h3 class="text-xs font-bold uppercase tracking-widest text-[#8d755e] mb-4">Pet Details</h3>
                    <div class="space-y-0">
                        <div class="flex items-center justify-between py-3 border-b border-[#f5f2f0] dark:border-zinc-800">
                            <div class="flex items-center gap-2 text-[#8d755e]">
                                <span class="material-symbols-outlined text-lg">pets</span>
                                <span class="text-xs font-semibold">Species</span>
                            </div>
                            <span class="text-sm font-bold text-[#181410] dark:text-white"><%= species %></span>
                        </div>
                        <div class="flex items-center justify-between py-3 border-b border-[#f5f2f0] dark:border-zinc-800">
                            <div class="flex items-center gap-2 text-[#8d755e]">
                                <span class="material-symbols-outlined text-lg">category</span>
                                <span class="text-xs font-semibold">Breed</span>
                            </div>
                            <span class="text-sm font-bold text-[#181410] dark:text-white"><%= "N/A".equals(breed) ? "&mdash;" : breed %></span>
                        </div>
                        <div class="flex items-center justify-between py-3 border-b border-[#f5f2f0] dark:border-zinc-800">
                            <div class="flex items-center gap-2 text-[#8d755e]">
                                <span class="material-symbols-outlined text-lg">male</span>
                                <span class="text-xs font-semibold">Gender</span>
                            </div>
                            <span class="text-sm font-bold text-[#181410] dark:text-white"><%= gender %></span>
                        </div>
                        <div class="flex items-center justify-between py-3 border-b border-[#f5f2f0] dark:border-zinc-800">
                            <div class="flex items-center gap-2 text-[#8d755e]">
                                <span class="material-symbols-outlined text-lg">cake</span>
                                <span class="text-xs font-semibold">Age</span>
                            </div>
                            <span class="text-sm font-bold text-[#181410] dark:text-white"><%= ageDisplay %></span>
                        </div>
                        <div class="flex items-center justify-between py-3">
                            <div class="flex items-center gap-2 text-[#8d755e]">
                                <span class="material-symbols-outlined text-lg">monitor_weight</span>
                                <span class="text-xs font-semibold">Weight</span>
                            </div>
                            <span class="text-sm font-bold text-[#181410] dark:text-white"><%= weight %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right: Actions & Info -->
            <div class="lg:col-span-8 flex flex-col gap-5">

                <!-- Medical History Banner -->
                <div class="bg-gradient-to-r from-primary/10 to-orange-50 dark:from-primary/10 dark:to-zinc-900 rounded-2xl border border-primary/20 p-5 flex items-center justify-between gap-4">
                    <div class="flex items-center gap-4">
                        <div class="size-12 rounded-xl bg-primary/15 flex items-center justify-center text-primary flex-shrink-0">
                            <span class="material-symbols-outlined text-2xl">medical_services</span>
                        </div>
                        <div>
                            <p class="font-bold text-[#181410] dark:text-white">Medical Records</p>
                            <p class="text-xs text-[#8d755e] mt-0.5">View full examination history, diagnoses and treatments for <%= petName %>.</p>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/customer/medical-history?petId=<%= petId %>"
                       class="flex-shrink-0 inline-flex items-center gap-1.5 px-4 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:bg-primary/90 transition-colors shadow-sm">
                        View History
                        <span class="material-symbols-outlined text-base">arrow_forward</span>
                    </a>
                </div>

                <!-- Quick Actions -->
                <div class="bg-white dark:bg-zinc-900 rounded-2xl border border-[#e5e7eb] dark:border-zinc-800 shadow-sm p-5">
                    <h3 class="text-xs font-bold uppercase tracking-widest text-[#8d755e] mb-4">Quick Actions</h3>
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                        <a href="<%= request.getContextPath() %>/customer/appointments/book"
                           class="flex flex-col items-center gap-2.5 p-4 rounded-xl border border-[#e5e7eb] dark:border-zinc-700 hover:border-primary/40 hover:bg-primary/5 transition-all group text-center">
                            <div class="size-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary group-hover:bg-primary/20 transition-colors">
                                <span class="material-symbols-outlined">event_available</span>
                            </div>
                            <span class="text-xs font-bold text-[#181410] dark:text-white">Book Appointment</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/customer/appointments"
                           class="flex flex-col items-center gap-2.5 p-4 rounded-xl border border-[#e5e7eb] dark:border-zinc-700 hover:border-primary/40 hover:bg-primary/5 transition-all group text-center">
                            <div class="size-10 rounded-xl bg-blue-50 dark:bg-blue-900/20 flex items-center justify-center text-blue-600 group-hover:bg-blue-100 transition-colors">
                                <span class="material-symbols-outlined">calendar_month</span>
                            </div>
                            <span class="text-xs font-bold text-[#181410] dark:text-white">My Appointments</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/pets?action=edit&id=<%= petId %>"
                           class="flex flex-col items-center gap-2.5 p-4 rounded-xl border border-[#e5e7eb] dark:border-zinc-700 hover:border-primary/40 hover:bg-primary/5 transition-all group text-center">
                            <div class="size-10 rounded-xl bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center text-[#8d755e] group-hover:bg-zinc-200 transition-colors">
                                <span class="material-symbols-outlined">edit_square</span>
                            </div>
                            <span class="text-xs font-bold text-[#181410] dark:text-white">Edit Profile</span>
                        </a>
                    </div>
                </div>

                <!-- Overview Stats -->
                <div class="bg-white dark:bg-zinc-900 rounded-2xl border border-[#e5e7eb] dark:border-zinc-800 shadow-sm p-5">
                    <h3 class="text-xs font-bold uppercase tracking-widest text-[#8d755e] mb-4">Overview</h3>
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                        <div class="flex flex-col items-center gap-1.5 p-3 bg-background-light dark:bg-zinc-800 rounded-xl text-center">
                            <span class="material-symbols-outlined text-2xl text-primary">pets</span>
                            <p class="text-[10px] text-[#8d755e] font-medium uppercase tracking-wide">Species</p>
                            <p class="text-sm font-bold text-[#181410] dark:text-white"><%= species %></p>
                        </div>
                        <div class="flex flex-col items-center gap-1.5 p-3 bg-background-light dark:bg-zinc-800 rounded-xl text-center">
                            <span class="material-symbols-outlined text-2xl text-primary">male</span>
                            <p class="text-[10px] text-[#8d755e] font-medium uppercase tracking-wide">Gender</p>
                            <p class="text-sm font-bold text-[#181410] dark:text-white"><%= gender %></p>
                        </div>
                        <div class="flex flex-col items-center gap-1.5 p-3 bg-background-light dark:bg-zinc-800 rounded-xl text-center">
                            <span class="material-symbols-outlined text-2xl text-primary">cake</span>
                            <p class="text-[10px] text-[#8d755e] font-medium uppercase tracking-wide">Age</p>
                            <p class="text-sm font-bold text-[#181410] dark:text-white"><%= ageDisplay %></p>
                        </div>
                        <div class="flex flex-col items-center gap-1.5 p-3 bg-background-light dark:bg-zinc-800 rounded-xl text-center">
                            <span class="material-symbols-outlined text-2xl text-primary">monitor_weight</span>
                            <p class="text-[10px] text-[#8d755e] font-medium uppercase tracking-wide">Weight</p>
                            <p class="text-sm font-bold text-[#181410] dark:text-white"><%= weight %></p>
                        </div>
                    </div>
                    <% if (!"N/A".equals(birthDate)) { %>
                    <div class="mt-4 pt-4 border-t border-[#f5f2f0] dark:border-zinc-800 flex items-center gap-2 text-sm text-[#8d755e]">
                        <span class="material-symbols-outlined text-base">event</span>
                        Date of birth: <span class="font-semibold text-[#181410] dark:text-white ml-1"><%= birthDate %></span>
                    </div>
                    <% } %>
                </div>

            </div>
        </div>

    </main>
</div>
</body></html>
