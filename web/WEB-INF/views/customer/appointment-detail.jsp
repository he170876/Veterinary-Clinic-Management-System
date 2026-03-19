<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.Period" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashSet" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Appointment" %>
<%@ page import="model.Pet" %>
<%@ page import="model.User" %>
<%
    request.setAttribute("customerCurrentPage", "appointments");

    String ctx = request.getContextPath();
    User user = (User) request.getAttribute("user");
    if (user == null && session != null) {
        user = (User) session.getAttribute("currentUser");
    }

    Appointment appointment = (Appointment) request.getAttribute("appointment");

    if (user == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    if (appointment == null) {
        response.sendRedirect(ctx + "/customer/appointments");
        return;
    }

    Pet pet = appointment.getPet();

    String status = appointment.getStatus() != null ? appointment.getStatus() : "Unknown";
    String lowerStatus = status.toLowerCase();
    String statusClass;
    if (lowerStatus.contains("cancel")) {
        statusClass = "bg-rose-100 text-rose-700";
    } else if (lowerStatus.contains("complete") || lowerStatus.contains("done")) {
        statusClass = "bg-slate-100 text-slate-600";
    } else if (lowerStatus.contains("confirm")) {
        statusClass = "bg-emerald-100 text-emerald-700";
    } else {
        statusClass = "bg-amber-100 text-amber-700";
    }

    String appointmentDateTime = "N/A";
    LocalDateTime appointmentTime = appointment.getAppointmentTime();
    if (appointmentTime != null) {
        appointmentDateTime = appointmentTime.format(DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' hh:mm a"));
    }

    String petName = pet != null && pet.getName() != null ? pet.getName() : "N/A";
    String petSpecies = pet != null && pet.getSpecies() != null ? pet.getSpecies() : "N/A";
    String petBreed = pet != null && pet.getBreed() != null ? pet.getBreed() : "N/A";
    String petGender = pet != null && pet.getGender() != null ? pet.getGender() : "N/A";
    String petWeight = (pet != null && pet.getWeight() != null) ? String.format("%.1f kg", pet.getWeight()) : "N/A";
    List<String> selectedServices = new ArrayList<>();
    if (appointment.getService() != null && !appointment.getService().trim().isEmpty()) {
        LinkedHashSet<String> uniqueServices = new LinkedHashSet<>();
        for (String token : appointment.getService().split(",")) {
            if (token != null) {
                String normalized = token.trim();
                if (!normalized.isEmpty()) {
                    uniqueServices.add(normalized);
                }
            }
        }
        selectedServices.addAll(uniqueServices);
    }
    String serviceSummary = selectedServices.isEmpty()
            ? "No service selected"
            : selectedServices.size() + (selectedServices.size() == 1 ? " service selected" : " services selected");
    String vetName = appointment.getVeterinarianName() != null && !appointment.getVeterinarianName().trim().isEmpty()
            ? "Dr. " + appointment.getVeterinarianName() : "Unassigned";

    String petAge = "N/A";
    if (pet != null && pet.getBirthDate() != null) {
        Period age = Period.between(pet.getBirthDate(), LocalDate.now());
        if (age.getYears() > 0) {
            petAge = age.getYears() + " year" + (age.getYears() > 1 ? "s" : "");
            if (age.getMonths() > 0) {
                petAge += " " + age.getMonths() + " month" + (age.getMonths() > 1 ? "s" : "");
            }
        } else {
            petAge = age.getMonths() + " month" + (age.getMonths() > 1 ? "s" : "");
        }
    }

    String notes = appointment.getNotes() != null && !appointment.getNotes().trim().isEmpty()
            ? appointment.getNotes() : "No additional notes.";

    User owner = appointment.getCustomer() != null ? appointment.getCustomer().getUser() : null;
    String ownerName = owner != null && owner.getFullName() != null ? owner.getFullName() : "N/A";
    String ownerEmail = owner != null && owner.getEmail() != null ? owner.getEmail() : "N/A";
    String ownerPhone = owner != null && owner.getPhone() != null ? owner.getPhone() : "N/A";
    String ownerAddress = owner != null && owner.getAddress() != null && !owner.getAddress().trim().isEmpty() ? owner.getAddress() : "N/A";
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Appointment Detail - Anipat</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700;900&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#ff7b00",
                        "background-light": "#f8f6f6",
                        "background-dark": "#221610",
                    },
                    fontFamily: {
                        "display": ["Public Sans", "sans-serif"]
                    },
                },
            },
        }
    </script>
    <style>
        body { font-family: 'Public Sans', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 min-h-screen">
<div class="flex h-screen overflow-hidden">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>

    <main class="flex-1 flex flex-col overflow-hidden bg-background-light dark:bg-background-dark">
        <header class="h-16 flex items-center justify-between px-8 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-background-dark/50 backdrop-blur-sm">
            <div class="flex items-center gap-4">
                <a href="<%= ctx %>/customer/appointments" class="inline-flex items-center justify-center w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors">
                    <span class="material-symbols-outlined">arrow_back</span>
                </a>
                <div>
                    <h2 class="text-lg font-black tracking-tight">Appointment Detail</h2>
                    <p class="text-xs text-slate-500">Appointment #<%= appointment.getAppointmentId() %></p>
                </div>
            </div>
            <div class="text-right hidden sm:block">
                <p class="text-sm font-bold text-slate-900 dark:text-slate-100"><%= user.getFullName() != null ? user.getFullName() : "Customer" %></p>
                <p class="text-xs text-slate-500">Pet Owner</p>
            </div>
        </header>

        <div class="flex-1 overflow-y-auto p-8">
            <div class="max-w-5xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div class="lg:col-span-2 space-y-6">
                    <section class="bg-white dark:bg-slate-900/40 rounded-xl border border-slate-200 dark:border-slate-800 p-6 shadow-sm">
                        <div class="flex items-start justify-between gap-3">
                            <div>
                                <h3 class="text-lg font-bold">Visit Information</h3>
                                <p class="text-sm text-slate-500 mt-1"><%= appointmentDateTime %></p>
                            </div>
                            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-bold <%= statusClass %>"><%= status %></span>
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-6">
                            <div class="rounded-lg border border-slate-200 dark:border-slate-800 p-4">
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Services</p>
                                <div class="mt-2 flex flex-wrap gap-2">
                                    <% if (selectedServices.isEmpty()) { %>
                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-slate-100 text-slate-600 text-xs font-semibold">N/A</span>
                                    <% } else {
                                        for (String selectedService : selectedServices) { %>
                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-primary/10 text-primary border border-primary/20 text-xs font-semibold"><%= selectedService %></span>
                                    <% }
                                    } %>
                                </div>
                                <p class="mt-2 text-xs text-slate-500"><%= serviceSummary %></p>
                            </div>
                            <div class="rounded-lg border border-slate-200 dark:border-slate-800 p-4">
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Veterinarian</p>
                                <p class="mt-1 font-semibold"><%= vetName %></p>
                            </div>
                        </div>
                    </section>

                    <section class="bg-white dark:bg-slate-900/40 rounded-xl border border-slate-200 dark:border-slate-800 p-6 shadow-sm">
                        <h3 class="text-lg font-bold mb-4">Pet Information</h3>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div class="rounded-lg bg-slate-50 dark:bg-slate-800/60 p-4">
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Pet Name</p>
                                <p class="mt-1 font-semibold"><%= petName %></p>
                            </div>
                            <div class="rounded-lg bg-slate-50 dark:bg-slate-800/60 p-4">
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Species</p>
                                <p class="mt-1 font-semibold"><%= petSpecies %></p>
                            </div>
                            <div class="rounded-lg bg-slate-50 dark:bg-slate-800/60 p-4">
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Breed</p>
                                <p class="mt-1 font-semibold"><%= petBreed %></p>
                            </div>
                            <div class="rounded-lg bg-slate-50 dark:bg-slate-800/60 p-4">
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Gender</p>
                                <p class="mt-1 font-semibold"><%= petGender %></p>
                            </div>
                     
                            <div class="rounded-lg bg-slate-50 dark:bg-slate-800/60 p-4">
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Weight</p>
                                <p class="mt-1 font-semibold"><%= petWeight %></p>
                            </div>
                        </div>
                    </section>

                    <section class="bg-white dark:bg-slate-900/40 rounded-xl border border-slate-200 dark:border-slate-800 p-6 shadow-sm">
                        <h3 class="text-lg font-bold mb-3">Notes</h3>
                        <p class="text-sm leading-relaxed text-slate-600 dark:text-slate-300 whitespace-pre-line"><%= notes %></p>
                    </section>
                </div>

                <aside class="space-y-6">
                    <section class="bg-white dark:bg-slate-900/40 rounded-xl border border-slate-200 dark:border-slate-800 p-6 shadow-sm">
                        <h3 class="text-lg font-bold mb-4">Owner Contact</h3>
                        <div class="space-y-3 text-sm">
                            <div>
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Name</p>
                                <p class="mt-1 font-medium"><%= ownerName %></p>
                            </div>
                            <div>
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Email</p>
                                <p class="mt-1 font-medium break-all"><%= ownerEmail %></p>
                            </div>
                            <div>
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Phone</p>
                                <p class="mt-1 font-medium"><%= ownerPhone %></p>
                            </div>
                            <div>
                                <p class="text-xs uppercase tracking-wider text-slate-500 font-bold">Address</p>
                                <p class="mt-1 font-medium"><%= ownerAddress %></p>
                            </div>
                        </div>
                    </section>

                    <section class="bg-primary/5 dark:bg-primary/10 border border-primary/20 rounded-xl p-5">
                        <h4 class="font-bold mb-2">Need to make changes?</h4>
                        <p class="text-sm text-slate-600 dark:text-slate-300">Go back to appointment list to request reschedule or doctor change.</p>
                        <a href="<%= ctx %>/customer/appointments?tab=upcoming" class="inline-flex mt-4 w-full items-center justify-center px-4 py-2 rounded-lg bg-primary text-white text-sm font-bold hover:bg-primary/90">Manage Appointment</a>
                    </section>
                </aside>
            </div>
        </div>
    </main>
</div>
</body>
</html>