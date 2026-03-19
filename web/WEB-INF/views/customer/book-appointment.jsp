<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="model.Pet" %>
<%@ page import="model.Service" %>
<%@ page import="model.User" %>
<%
    request.setAttribute("customerCurrentPage", "appointments");
    String ctx = request.getContextPath();
    User user = (User) request.getAttribute("user");
    if (user == null && session != null) {
        user = (User) session.getAttribute("currentUser");
    }
    if (user == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }
    
    @SuppressWarnings("unchecked")
    List<Pet> customerPets = (List<Pet>) request.getAttribute("customerPets");
    if (customerPets == null) customerPets = java.util.Collections.emptyList();
    
    @SuppressWarnings("unchecked")
    List<Service> services = (List<Service>) request.getAttribute("services");
    if (services == null) services = java.util.Collections.emptyList();
    
    @SuppressWarnings("unchecked")
    List<User> veterinarians = (List<User>) request.getAttribute("veterinarians");
    if (veterinarians == null) veterinarians = java.util.Collections.emptyList();
    
    String formError = (String) request.getAttribute("formError");
    String selectedPetId = request.getAttribute("selectedPetId") != null ? String.valueOf(request.getAttribute("selectedPetId")) : "";
    String selectedServiceIdsCsv = request.getAttribute("selectedServiceId") != null ? String.valueOf(request.getAttribute("selectedServiceId")) : "";
    Set<String> selectedServiceIdSet = new HashSet<>();
    if (selectedServiceIdsCsv != null && !selectedServiceIdsCsv.trim().isEmpty()) {
        String[] parts = selectedServiceIdsCsv.split(",");
        for (String p : parts) {
            if (p != null && !p.trim().isEmpty()) {
                selectedServiceIdSet.add(p.trim());
            }
        }
    }
    String selectedAppointmentDate = request.getAttribute("selectedAppointmentDate") != null ? String.valueOf(request.getAttribute("selectedAppointmentDate")) : "";
    String selectedTimeSlot = request.getAttribute("selectedTimeSlot") != null ? String.valueOf(request.getAttribute("selectedTimeSlot")) : "morning";
    String notesValue = request.getAttribute("notesValue") != null ? String.valueOf(request.getAttribute("notesValue")) : "";
    String notesEsc = notesValue.replace("&", "&amp;")
    .replace("<", "&lt;")
    .replace(">", "&gt;")
    .replace("\"", "&quot;");
    boolean canSubmit = !customerPets.isEmpty() && !services.isEmpty();
%>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Book Appointment - Anipat</title>
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
            
            document.addEventListener('DOMContentLoaded', function () {
                var dateInput = document.getElementById('appointmentDate');
                if (dateInput) {
                    var now = new Date();
                    var yyyy = now.getFullYear();
                    var mm = String(now.getMonth() + 1).padStart(2, '0');
                    var dd = String(now.getDate()).padStart(2, '0');
                    dateInput.min = yyyy + '-' + mm + '-' + dd;
                }

                var bookingForm = document.getElementById('bookingForm');
                var serviceSearch = document.getElementById('serviceSearch');
                var serviceOptions = Array.prototype.slice.call(document.querySelectorAll('.service-option'));
                var serviceCheckboxes = Array.prototype.slice.call(document.querySelectorAll('.service-checkbox'));
                var serviceSelectionError = document.getElementById('serviceSelectionError');
                var serviceSearchEmpty = document.getElementById('serviceSearchEmpty');
                var selectedCount = document.getElementById('serviceSelectedCount');
                var selectedDuration = document.getElementById('serviceSelectedDuration');

                function updateServiceSummary() {
                    var count = 0;
                    var totalDuration = 0;

                    for (var i = 0; i < serviceCheckboxes.length; i++) {
                        var checkbox = serviceCheckboxes[i];
                        if (!checkbox.checked) {
                            continue;
                        }
                        count++;

                        var duration = parseInt(checkbox.getAttribute('data-service-duration') || '0', 10);
                        if (!isNaN(duration) && duration > 0) {
                            totalDuration += duration;
                        }
                    }

                    if (selectedCount) {
                        selectedCount.textContent = count + (count === 1 ? ' service selected' : ' services selected');
                    }
                    if (selectedDuration) {
                        selectedDuration.textContent = totalDuration > 0 ? (totalDuration + ' min') : 'N/A';
                    }

                    if (count > 0 && serviceSelectionError) {
                        serviceSelectionError.classList.add('hidden');
                    }
                }

                function filterServices() {
                    var keyword = serviceSearch ? serviceSearch.value.trim().toLowerCase() : '';
                    var visibleCount = 0;

                    for (var i = 0; i < serviceOptions.length; i++) {
                        var option = serviceOptions[i];
                        var haystack = option.textContent.toLowerCase();
                        var matched = keyword.length === 0 || haystack.indexOf(keyword) !== -1;

                        option.classList.toggle('hidden', !matched);
                        if (matched) {
                            visibleCount++;
                        }
                    }

                    if (serviceSearchEmpty) {
                        serviceSearchEmpty.classList.toggle('hidden', visibleCount > 0);
                    }
                }

                for (var i = 0; i < serviceCheckboxes.length; i++) {
                    serviceCheckboxes[i].addEventListener('change', updateServiceSummary);
                }

                if (serviceSearch) {
                    serviceSearch.addEventListener('input', filterServices);
                }

                if (bookingForm) {
                    bookingForm.addEventListener('submit', function (event) {
                        var hasChecked = false;
                        for (var i = 0; i < serviceCheckboxes.length; i++) {
                            if (serviceCheckboxes[i].checked) {
                                hasChecked = true;
                                break;
                            }
                        }

                        if (!hasChecked && serviceCheckboxes.length > 0) {
                            event.preventDefault();
                            if (serviceSelectionError) {
                                serviceSelectionError.classList.remove('hidden');
                            }
                            if (serviceSearch) {
                                serviceSearch.focus();
                            }
                        }
                    });
                }

                updateServiceSummary();
                filterServices();
            });
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
                    <div>
                        <h2 class="text-lg font-black tracking-tight">Book Appointment</h2>
                        <p class="text-xs text-slate-500">Schedule a check-up for one of your pets.</p>
                    </div>
                    <div class="flex items-center gap-4">
                        <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                        <div class="text-right hidden sm:block">
                            <p class="text-sm font-bold text-slate-900 dark:text-slate-100"><%= user.getFullName() != null ? user.getFullName() : "Customer" %></p>
                            <p class="text-xs text-slate-500">Pet Owner</p>
                        </div>
                    </div>
                </header>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-5xl mx-auto grid grid-cols-1 xl:grid-cols-[minmax(0,1fr)_320px] gap-6">
                        <section class="bg-white dark:bg-slate-900/40 rounded-xl border border-slate-200 dark:border-slate-800 p-6 shadow-sm">
                            <div class="mb-6">
                                <h3 class="text-2xl font-black tracking-tight">New Appointment Request</h3>
                                <p class="text-sm text-slate-500 mt-1">Choose your pet, select a service, pick your preferred date, and choose morning or afternoon time slot. A veterinarian will be assigned when you check in.</p>
                            </div>

                            <% if (formError != null && !formError.isEmpty()) { %>
                            <div class="mb-6 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm font-medium text-rose-700">
                                <%= formError %>
                            </div>
                            <% } %>

                            <% if (customerPets.isEmpty()) { %>
                            <div class="rounded-xl border border-amber-200 bg-amber-50 px-5 py-4 text-sm text-amber-800 mb-6">
                                You need at least one registered pet before booking an appointment.
                                <a href="<%= ctx %>/pets?action=create" class="ml-2 font-bold underline hover:no-underline">Add a pet now</a>
                            </div>
                            <% } else if (services.isEmpty()) { %>
                            <div class="rounded-xl border border-amber-200 bg-amber-50 px-5 py-4 text-sm text-amber-800 mb-6">
                                No services are available for booking right now. Please contact the clinic staff.
                            </div>
                            <% } %>

                            <form id="bookingForm" method="post" action="<%= ctx %>/customer/appointments/book" class="space-y-6">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div class="flex flex-col gap-2">
                                        <label for="petId" class="text-sm font-bold text-slate-700 dark:text-slate-200">Pet</label>
                                        <select id="petId" name="petId" class="rounded-xl border-slate-200 text-sm" required <%= customerPets.isEmpty() ? "disabled" : "" %>>
                                            <option value="">Select your pet</option>
                                            <% for (Pet pet : customerPets) {
                                                String optionValue = String.valueOf(pet.getPetId());
                                                String petLabel = pet.getName() != null ? pet.getName() : "Unnamed pet";
                                                if (pet.getSpecies() != null && !pet.getSpecies().isEmpty()) {
                                                    petLabel += " - " + pet.getSpecies();
                                                }
                                                if (pet.getBreed() != null && !pet.getBreed().isEmpty()) {
                                                    petLabel += " (" + pet.getBreed() + ")";
                                                }
                                            %>
                                            <option value="<%= optionValue %>" <%= optionValue.equals(selectedPetId) ? "selected" : "" %>><%= petLabel %></option>
                                            <% } %>
                                        </select>
                                    </div>

                                    <div class="flex flex-col gap-3 md:col-span-2">
                                        <label for="serviceSearch" class="text-sm font-bold text-slate-700 dark:text-slate-200">Services</label>
                                        <div class="relative">
                                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-base">search</span>
                                            <input id="serviceSearch" type="text" placeholder="Search services by name, category, or description" class="w-full rounded-xl border-slate-200 pl-10 text-sm" <%= services.isEmpty() ? "disabled" : "" %>/>
                                        </div>

                                        <div id="serviceSelectionError" class="hidden rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-xs font-semibold text-rose-700">
                                            Please choose at least one service.
                                        </div>

                                        <div class="rounded-xl border border-slate-200 p-2 max-h-72 overflow-y-auto space-y-2 bg-slate-50/40 dark:bg-slate-900/30">
                                            <% for (Service service : services) {
                                                String optionValue = String.valueOf(service.getServiceId());
                                                String serviceName = service.getName() != null ? service.getName() : "Service";
                                                String serviceCategory = service.getCategory() != null && !service.getCategory().trim().isEmpty()
                                                        ? service.getCategory().trim() : "General";
                                                String serviceDescription = service.getDescription() != null ? service.getDescription().trim() : "";
                                            %>
                                            <label class="service-option block cursor-pointer">
                                                <input
                                                    type="checkbox"
                                                    class="peer sr-only service-checkbox"
                                                    name="serviceIds"
                                                    value="<%= optionValue %>"
                                                    data-service-duration="<%= service.getDuration() %>"
                                                    <%= selectedServiceIdSet.contains(optionValue) ? "checked" : "" %>
                                                    <%= services.isEmpty() ? "disabled" : "" %>
                                                />
                                                <div class="rounded-xl border-2 border-slate-200 bg-white dark:bg-slate-900/50 p-4 transition-all peer-checked:border-primary peer-checked:bg-primary/5 hover:border-primary/40">
                                                    <div class="flex items-start justify-between gap-3">
                                                        <div class="min-w-0">
                                                            <p class="service-name text-sm font-bold text-slate-800 dark:text-slate-100"><%= serviceName %></p>
                                                            <p class="text-xs text-slate-500 mt-1"><%= serviceCategory %> <% if (service.getDuration() > 0) { %>- <%= service.getDuration() %> min<% } %></p>
                                                            <% if (!serviceDescription.isEmpty()) { %>
                                                            <p class="text-xs text-slate-500 mt-2"><%= serviceDescription %></p>
                                                            <% } %>
                                                        </div>
                                                        <div class="text-right shrink-0">
                                                            <span class="inline-flex rounded-full bg-slate-100 text-slate-500 text-[10px] font-bold px-2 py-0.5 peer-checked:bg-primary peer-checked:text-white">Select</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </label>
                                            <% } %>
                                            <p id="serviceSearchEmpty" class="hidden px-3 py-6 text-center text-xs text-slate-500">No services match your search.</p>
                                        </div>

                                        <div class="rounded-xl border border-slate-200 bg-white dark:bg-slate-900/40 px-4 py-3 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                                            <p id="serviceSelectedCount" class="text-sm font-bold text-slate-700 dark:text-slate-200">0 services selected</p>
                                            <div class="flex items-center gap-4 text-xs font-semibold text-slate-600 dark:text-slate-300">
                                                <span>Total duration: <strong id="serviceSelectedDuration" class="text-slate-900 dark:text-slate-100">N/A</strong></span>
                                            </div>
                                        </div>

                                        <p class="text-xs text-slate-500">Click one or more service cards to build your visit request.</p>
                                    </div>

                                    <div class="flex flex-col gap-2">
                                        <label for="appointmentDate" class="text-sm font-bold text-slate-700 dark:text-slate-200">Preferred Date</label>
                                        <input id="appointmentDate" name="appointmentDate" type="date" value="<%= selectedAppointmentDate %>" class="rounded-xl border-slate-200 text-sm" required <%= canSubmit ? "" : "disabled" %>/>
                                    </div>

                                    <div class="flex flex-col gap-2">
                                        <label class="text-sm font-bold text-slate-700 dark:text-slate-200">Appointment Time Slot</label>
                                        <div class="flex gap-3">
                                            <label class="flex items-center gap-2 p-3 rounded-lg border-2 cursor-pointer transition-colors" id="morning-label" style="border-color: <%= "morning".equals(selectedTimeSlot) ? "#ff7b00" : "#e2e8f0" %>; background-color: <%= "morning".equals(selectedTimeSlot) ? "rgba(255, 123, 0, 0.05)" : "transparent" %>;">
                                                <input type="radio" name="timeSlot" value="morning" class="w-4 h-4" <%= "morning".equals(selectedTimeSlot) ? "checked" : "" %> onchange="document.getElementById('morning-label').style.borderColor='#ff7b00'; document.getElementById('morning-label').style.backgroundColor='rgba(255, 123, 0, 0.05)'; document.getElementById('afternoon-label').style.borderColor='#e2e8f0'; document.getElementById('afternoon-label').style.backgroundColor='transparent';"/>
                                                <span class="text-sm font-semibold">Morning </span>
                                            </label>
                                            <label class="flex items-center gap-2 p-3 rounded-lg border-2 cursor-pointer transition-colors" id="afternoon-label" style="border-color: <%= "afternoon".equals(selectedTimeSlot) ? "#ff7b00" : "#e2e8f0" %>; background-color: <%= "afternoon".equals(selectedTimeSlot) ? "rgba(255, 123, 0, 0.05)" : "transparent" %>;">
                                                <input type="radio" name="timeSlot" value="afternoon" class="w-4 h-4" <%= "afternoon".equals(selectedTimeSlot) ? "checked" : "" %> onchange="document.getElementById('afternoon-label').style.borderColor='#ff7b00'; document.getElementById('afternoon-label').style.backgroundColor='rgba(255, 123, 0, 0.05)'; document.getElementById('morning-label').style.borderColor='#e2e8f0'; document.getElementById('morning-label').style.backgroundColor='transparent';"/>
                                                <span class="text-sm font-semibold">Afternoon </span>
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <div class="flex flex-col gap-2">
                                    <label for="notes" class="text-sm font-bold text-slate-700 dark:text-slate-200">Notes for the clinic</label>
                                    <textarea id="notes" name="notes" rows="5" maxlength="1000" class="rounded-xl border-slate-200 text-sm resize-y" placeholder="Symptoms, concerns, or anything the vet should know before the visit." <%= canSubmit ? "" : "disabled" %>><%= notesEsc %></textarea>
                                    <p class="text-xs text-slate-500">Optional. Maximum 1000 characters.</p>
                                </div>

                                <div class="flex flex-col-reverse sm:flex-row justify-end gap-3 pt-2">
                                    <a href="<%= ctx %>/customer/appointments" class="inline-flex items-center justify-center px-5 py-3 rounded-xl border border-slate-200 text-sm font-bold text-slate-600 hover:bg-slate-50 transition-colors">
                                        Cancel
                                    </a>
                                    <button type="submit" class="inline-flex items-center justify-center gap-2 px-5 py-3 rounded-xl bg-primary text-white text-sm font-bold hover:bg-primary/90 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed" <%= canSubmit ? "" : "disabled" %>>
                                        <span class="material-symbols-outlined text-base">event_available</span>
                                        Submit Booking Request
                                    </button>
                                </div>
                            </form>
                        </section>

                        <aside class="space-y-6">
                            <section class="bg-white dark:bg-slate-900/40 rounded-xl border border-slate-200 dark:border-slate-800 p-6 shadow-sm">
                                <h4 class="text-lg font-bold mb-3">Before You Submit</h4>
                                <ul class="space-y-3 text-sm text-slate-600 dark:text-slate-300">
                                    <li class="flex gap-2"><span class="material-symbols-outlined text-primary text-base">check_circle</span><span>Choose one of your registered pets.</span></li>
                                    <li class="flex gap-2"><span class="material-symbols-outlined text-primary text-base">check_circle</span><span>Select one or more services that match the visit reason.</span></li>
                                    <li class="flex gap-2"><span class="material-symbols-outlined text-primary text-base">check_circle</span><span>Choose your preferred appointment time: morning or afternoon.</span></li>
                                    <li class="flex gap-2"><span class="material-symbols-outlined text-primary text-base">check_circle</span><span>Your appointment will be created with Pending status until the clinic reviews it.</span></li>
                                </ul>
                            </section>

                            <section class="bg-primary/5 dark:bg-primary/10 border border-primary/20 rounded-xl p-5">
                                <h4 class="font-bold mb-2">Need to add or update pet info?</h4>
                                <p class="text-sm text-slate-600 dark:text-slate-300">Keep your pet details current so the clinic has the right information for the visit.</p>
                                <div class="mt-4 flex flex-col gap-2">
                                    <a href="<%= ctx %>/pets" class="inline-flex items-center justify-center px-4 py-2 rounded-lg bg-white text-primary text-sm font-bold border border-primary/20 hover:bg-primary/5">Manage Pets</a>
                                    <a href="<%= ctx %>/pets?action=create" class="inline-flex items-center justify-center px-4 py-2 rounded-lg bg-primary text-white text-sm font-bold hover:bg-primary/90">Add New Pet</a>
                                </div>
                            </section>
                        </aside>
                    </div>
                </div>
            </main>
        </div>
    </body>
</html>