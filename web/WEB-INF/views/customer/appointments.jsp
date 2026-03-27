<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="model.Appointment" %>
<%
    request.setAttribute("customerCurrentPage", "appointments");
    String ctx = request.getContextPath();
    model.User user = (model.User) request.getAttribute("user");
    if (user == null && session != null) {
        user = (model.User) session.getAttribute("currentUser");
    }
    Set<Integer> pendingRescheduleIds = (Set<Integer>) request.getAttribute("pendingRescheduleIds");
    if (pendingRescheduleIds == null) {
        pendingRescheduleIds = new java.util.HashSet<>();
    }
    request.setAttribute("customerHeaderTitle", "My Appointments");
    request.setAttribute("customerHeaderSubtitle", "Track and manage your scheduled consultations for your furry friends.");
    request.setAttribute("customerHeaderDisplayName", user != null ? user.getFullName() : "Customer");
    request.setAttribute("customerHeaderRoleText", "Pet Owner");
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>My Appointments - Anipat</title>
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
                    borderRadius: {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                },
            },
        }

        function openRescheduleModal(button) {
            const modal = document.getElementById('rescheduleModal');
            document.getElementById('appointmentId').value = button.dataset.id;
            document.getElementById('tabValue').value = button.dataset.tab || 'upcoming';
            document.getElementById('detailText').textContent = button.dataset.detail || 'Appointment';
            document.getElementById('currentTimeText').textContent = button.dataset.current || '';
            modal.classList.remove('hidden');
        }

        function closeRescheduleModal() {
            const modal = document.getElementById('rescheduleModal');
            modal.classList.add('hidden');
            document.getElementById('rescheduleForm').reset();
        }

        document.addEventListener('DOMContentLoaded', function () {
            const dateInput = document.querySelector('input[name="requestedDate"]');
            if (dateInput) {
                const now = new Date();
                const yyyy = now.getFullYear();
                const mm = String(now.getMonth() + 1).padStart(2, '0');
                const dd = String(now.getDate()).padStart(2, '0');
                dateInput.min = yyyy + '-' + mm + '-' + dd;
            }
        });
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
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 min-h-screen">
<div class="flex h-screen overflow-hidden">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    <main class="flex-1 flex flex-col overflow-hidden bg-background-light dark:bg-background-dark">
        <jsp:include page="/WEB-INF/includes/customer-header.jsp"/>

        <div class="flex-1 overflow-y-auto p-8">
            <div class="max-w-6xl mx-auto flex flex-col gap-8">
                <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
                    <div class="flex flex-col gap-1">
                        <h2 class="text-2xl font-black text-slate-900 dark:text-slate-100 tracking-tight">Appointments List</h2>
                        <p class="text-slate-500 dark:text-slate-400">Use filters below to find upcoming, past, or cancelled visits.</p>
                    </div>
                    <a href="<%= ctx %>/customer/appointments/book" class="inline-flex items-center justify-center gap-2 px-4 py-2 rounded-lg bg-primary text-white text-sm font-bold hover:bg-primary/90 shadow-sm">
                        <span class="material-symbols-outlined text-base">event_available</span>
                        Book Appointment
                    </a>
                </div>

                <c:if test="${param.booked == '1'}">
                    <div class="rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-700 px-4 py-3 text-sm font-medium">
                        Appointment booked successfully. The clinic will review and confirm it soon.
                    </div>
                </c:if>
                <c:if test="${param.requested == '1'}">
                    <div class="rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-700 px-4 py-3 text-sm font-medium">
                        Reschedule request has been sent. Please wait for receptionist approval.
                    </div>
                </c:if>
                <c:if test="${not empty param.error}">
                    <div class="rounded-xl border border-rose-200 bg-rose-50 text-rose-700 px-4 py-3 text-sm font-medium">
                        <c:choose>
                            <c:when test="${param.error == 'conflict_slot'}">
                                You already have another appointment in this slot. Please choose a different date or time slot.
                            </c:when>
                            <c:when test="${param.error == 'same_slot'}">
                                New schedule must be different from your current appointment slot.
                            </c:when>
                            <c:when test="${param.error == 'slot_passed'}">
                                Selected time slot has passed. Please choose another slot.
                            </c:when>
                            <c:when test="${param.error == 'invalid_datetime'}">
                                Invalid date/time selection. Please check and try again.
                            </c:when>
                            <c:otherwise>
                                Could not submit your request. Please check data and try again.
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <div class="flex flex-col gap-3 border-b border-slate-200 dark:border-slate-800 pb-2">
                    <form method="get" action="<%= ctx %>/customer/appointments" class="flex items-end gap-3">
                        <input type="hidden" name="tab" value="${tab}"/>
                        <div class="flex flex-col gap-1 min-w-[220px]">
                            <label class="text-xs font-semibold text-slate-500">Search by name</label>
                            <input type="text" name="q" value="${q}" placeholder="Pet, doctor, service..." class="rounded-lg border-slate-200 text-sm"/>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label class="text-xs font-semibold text-slate-500">From date</label>
                            <input type="date" name="fromDate" value="${fromDate}" class="rounded-lg border-slate-200 text-sm"/>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label class="text-xs font-semibold text-slate-500">To date</label>
                            <input type="date" name="toDate" value="${toDate}" class="rounded-lg border-slate-200 text-sm"/>
                        </div>
                        <button type="submit" class="px-4 py-2 rounded-lg bg-primary text-white text-sm font-bold hover:bg-primary/90">Apply</button>
                        <a href="<%= ctx %>/customer/appointments?tab=${tab}" class="px-4 py-2 rounded-lg border border-slate-200 text-sm font-bold text-slate-600 hover:bg-slate-50">Clear</a>
                    </form>
                    <div class="flex gap-4">
                        <a href="<%= ctx %>/customer/appointments?tab=upcoming&q=${q}&fromDate=${fromDate}&toDate=${toDate}&page=1" class="px-4 py-2 border-b-2 text-sm font-semibold ${tab == 'upcoming' ? 'border-primary text-primary' : 'border-transparent text-slate-500 hover:text-slate-700'}">Upcoming (${upcomingCount})</a>
                        <a href="<%= ctx %>/customer/appointments?tab=past&q=${q}&fromDate=${fromDate}&toDate=${toDate}&page=1" class="px-4 py-2 border-b-2 text-sm font-semibold ${tab == 'past' ? 'border-primary text-primary' : 'border-transparent text-slate-500 hover:text-slate-700'}">Past Visits (${pastCount})</a>
                        <a href="<%= ctx %>/customer/appointments?tab=cancelled&q=${q}&fromDate=${fromDate}&toDate=${toDate}&page=1" class="px-4 py-2 border-b-2 text-sm font-semibold ${tab == 'cancelled' ? 'border-primary text-primary' : 'border-transparent text-slate-500 hover:text-slate-700'}">Cancelled (${cancelledCount})</a>
                    </div>
                </div>

                <div class="bg-white dark:bg-slate-900/40 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
                    <div class="overflow-x-auto @container">
                        <table class="w-full text-left border-collapse">
                            <thead>
                            <tr class="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Pet Name</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Date &amp; Slot</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Veterinarian</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 text-center">Status</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 text-right">Request</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 text-right">Action</th>
                            </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-200 dark:divide-slate-800">
                            <c:choose>
                                <c:when test="${empty appointments}">
                                    <tr>
                                        <td colspan="6" class="px-6 py-10 text-center text-slate-500">No appointments found.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="appointment" items="${appointments}">
                                        <%
                                            Appointment appointment = (Appointment) pageContext.getAttribute("appointment");
                                            String status = appointment.getStatus() != null ? appointment.getStatus() : "N/A";
                                            String lowerStatus = status.toLowerCase(Locale.ENGLISH);
                                            boolean isCancelled = lowerStatus.contains("cancel");
                                            boolean isCompleted = lowerStatus.contains("completed") || lowerStatus.contains("done");
                                            boolean requestableStatus = lowerStatus.contains("pending")
                                                    || lowerStatus.contains("scheduled")
                                                    || lowerStatus.contains("confirm");
                                            LocalDate appointmentDate = appointment.getAppointmentDate();
                                            if (appointmentDate == null && appointment.getAppointmentTime() != null) {
                                                appointmentDate = appointment.getAppointmentTime().toLocalDate();
                                            }
                                            boolean isPast = appointmentDate != null && appointmentDate.isBefore(LocalDate.now());
                                            boolean hasPendingRequest = pendingRescheduleIds.contains(appointment.getAppointmentId());
                                            boolean canRequest = !isCancelled && !isCompleted && !isPast && requestableStatus && !hasPendingRequest;
                                            String timeSlotText = appointment.getDisplayTimePeriodEnglish();
                                            String detail = (appointment.getPet() != null ? appointment.getPet().getName() : "Pet")
                                                    + " with "
                                                    + (appointment.getVeterinarianName() != null && !appointment.getVeterinarianName().isEmpty() ? " " + appointment.getVeterinarianName() : "Unassigned doctor");
                                            String current = appointment.getFormattedDate() + " - " + timeSlotText;
                                            pageContext.setAttribute("canRequest", canRequest);
                                            pageContext.setAttribute("hasPendingRequest", hasPendingRequest);
                                            pageContext.setAttribute("detail", detail);
                                            pageContext.setAttribute("timeSlotText", timeSlotText);
                                            pageContext.setAttribute("currentTimeText", current);
                                        %>
                                        <tr class="hover:bg-slate-50 dark:hover:bg-slate-800/30 transition-colors">
                                            <td class="px-6 py-5">
                                                <div class="flex items-center gap-3">
                                                    <div class="w-8 h-8 rounded-lg bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center text-primary">
                                                        <span class="material-symbols-outlined text-lg">pets</span>
                                                    </div>
                                                    <span class="font-semibold text-slate-900 dark:text-slate-100">${appointment.pet.name}</span>
                                                </div>
                                            </td>
                                            <td class="px-6 py-5">
                                                <div class="flex flex-col">
                                                    <span class="text-slate-900 dark:text-slate-100 font-medium">${appointment.formattedDate}</span>
                                                    <span class="text-xs text-slate-500">${timeSlotText}</span>
                                                </div>
                                            </td>
                                            <td class="px-6 py-5">
                                                <div class="flex items-center gap-2">
                                                    <span class="material-symbols-outlined text-slate-400 text-sm">medical_services</span>
                                                    <span class="text-slate-600 dark:text-slate-300">
                                                        <c:choose>
                                                            <c:when test="${not empty appointment.veterinarianName}">${appointment.veterinarianName}</c:when>
                                                            <c:otherwise>Unassigned</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </td>
                                            <td class="px-6 py-5 text-center">
                                                <c:set var="s" value="${appointment.status}"/>
                                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold
                                                    ${s == 'Confirmed' ? 'bg-green-100 text-green-700' :
                                                      s == 'Pending' || s == 'Scheduled' ? 'bg-amber-100 text-amber-700' :
                                                      s == 'Completed' || s == 'Done' ? 'bg-slate-100 text-slate-600' :
                                                      s == 'Cancelled' || s == 'Canceled' ? 'bg-rose-100 text-rose-700' :
                                                      'bg-slate-100 text-slate-600'}">
                                                    ${appointment.status}
                                                </span>
                                            </td>
                                            <td class="px-6 py-5 text-right">
                                                <div class="flex flex-col items-end gap-1">
                                                    <c:choose>
                                                        <c:when test="${canRequest}">
                                                            <button
                                                                    type="button"
                                                                    class="text-primary hover:text-primary/80 font-bold text-sm underline-offset-4 hover:underline"
                                                                    data-id="${appointment.appointmentId}"
                                                                    data-detail="${detail}"
                                                                    data-current="${currentTimeText}"
                                                                    data-tab="${tab}"
                                                                    onclick="openRescheduleModal(this)">
                                                                Request Reschedule
                                                            </button>
                                                        </c:when>
                                                        <c:when test="${hasPendingRequest}">
                                                            <span class="text-amber-600 font-bold text-sm">Waiting approval</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-slate-400 font-bold text-sm">Not available</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                            <td class="px-6 py-5 text-right">
                                                <a href="<%= ctx %>/customer/appointments/detail?id=${appointment.appointmentId}" class="text-slate-600 hover:text-slate-900 dark:text-slate-300 dark:hover:text-slate-100 font-bold text-sm underline-offset-4 hover:underline">
                                                    View Detail
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="flex items-center justify-between">
                    <p class="text-sm text-slate-500">
                        Showing ${empty appointments ? 0 : appointments.size()} of ${totalFiltered} appointments
                    </p>
                    <div class="flex items-center gap-2">
                        <c:choose>
                            <c:when test="${currentPage > 1}">
                                <a href="<%= ctx %>/customer/appointments?tab=${tab}&q=${q}&fromDate=${fromDate}&toDate=${toDate}&page=${currentPage - 1}" class="px-3 py-1.5 rounded-lg border border-slate-200 text-sm font-semibold text-slate-600 hover:bg-slate-50">Prev</a>
                            </c:when>
                            <c:otherwise>
                                <span class="px-3 py-1.5 rounded-lg border border-slate-200 text-sm font-semibold text-slate-300 cursor-not-allowed">Prev</span>
                            </c:otherwise>
                        </c:choose>

                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <span class="px-3 py-1.5 rounded-lg bg-primary text-white text-sm font-bold">${i}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="<%= ctx %>/customer/appointments?tab=${tab}&q=${q}&fromDate=${fromDate}&toDate=${toDate}&page=${i}" class="px-3 py-1.5 rounded-lg border border-slate-200 text-sm font-semibold text-slate-600 hover:bg-slate-50">${i}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:choose>
                            <c:when test="${currentPage < totalPages}">
                                <a href="<%= ctx %>/customer/appointments?tab=${tab}&q=${q}&fromDate=${fromDate}&toDate=${toDate}&page=${currentPage + 1}" class="px-3 py-1.5 rounded-lg border border-slate-200 text-sm font-semibold text-slate-600 hover:bg-slate-50">Next</a>
                            </c:when>
                            <c:otherwise>
                                <span class="px-3 py-1.5 rounded-lg border border-slate-200 text-sm font-semibold text-slate-300 cursor-not-allowed">Next</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="bg-primary/5 dark:bg-primary/10 border border-primary/20 rounded-xl p-6">
                    <div class="flex gap-4">
                        <div class="text-primary">
                            <span class="material-symbols-outlined text-3xl">info</span>
                        </div>
                        <div class="flex flex-col gap-2">
                            <h4 class="font-bold text-slate-900 dark:text-slate-100">About Rescheduling</h4>
                            <p class="text-sm text-slate-600 dark:text-slate-400 leading-relaxed">
                                Clicking 'Request Reschedule' will notify our staff of your request. A clinic coordinator will review and confirm a new time slot.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<div id="rescheduleModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 hidden">
    <div class="bg-white dark:bg-background-dark w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 dark:border-slate-800">
        <div class="p-6 flex flex-col gap-6">
            <div class="flex justify-between items-start">
                <h3 class="text-xl font-bold">Request Reschedule</h3>
                <button type="button" class="text-slate-400 hover:text-slate-600" onclick="closeRescheduleModal()">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>

            <form id="rescheduleForm" method="post" action="<%= ctx %>/customer/appointments/request-reschedule" class="flex flex-col gap-4">
                <input type="hidden" name="appointmentId" id="appointmentId"/>
                <input type="hidden" name="tab" id="tabValue"/>

                <div class="p-3 bg-slate-50 dark:bg-slate-800/50 rounded-lg flex flex-col gap-1">
                    <p class="text-xs text-slate-500 uppercase font-bold tracking-wider">Appointment Detail</p>
                    <p id="detailText" class="text-sm font-semibold"></p>
                    <p id="currentTimeText" class="text-xs text-slate-500"></p>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-semibold">Preferred New Date</label>
                        <input class="w-full rounded-xl border-slate-200 dark:border-slate-800 dark:bg-slate-900 focus:border-primary focus:ring-primary" type="date" name="requestedDate" required/>
                    </div>
                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-semibold">Preferred Time Slot</label>
                        <select class="w-full rounded-xl border-slate-200 dark:border-slate-800 dark:bg-slate-900 focus:border-primary focus:ring-primary" name="requestedTimeSlot" required>
                            <option value="morning">in the Morning</option>
                            <option value="afternoon">in the Afternoon</option>
                        </select>
                    </div>
                </div>

                <div class="flex flex-col gap-2">
                    <label class="text-sm font-semibold">Reason for Change</label>
                    <textarea class="w-full rounded-xl border-slate-200 dark:border-slate-800 dark:bg-slate-900 focus:border-primary focus:ring-primary" placeholder="Optional notes..." rows="3" name="reason"></textarea>
                </div>

                <div class="flex items-center gap-2 p-3 bg-amber-50 dark:bg-amber-900/20 rounded-lg text-amber-700 dark:text-amber-400 text-xs italic">
                    <span class="material-symbols-outlined text-sm">lock</span>
                    <span>Veterinarian assignment is locked for this appointment.</span>
                </div>

                <div class="flex gap-3">
                    <button type="button" onclick="closeRescheduleModal()" class="flex-1 py-3 px-4 border border-slate-200 dark:border-slate-800 rounded-xl font-bold hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">Cancel</button>
                    <button type="submit" class="flex-1 py-3 px-4 bg-primary text-white rounded-xl font-bold hover:bg-primary/90 transition-all">Submit Request</button>
                </div>
            </form>
        </div>
    </div>
</div>

</body>
</html>
