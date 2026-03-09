<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipat - Request Center</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,typography,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <style type="text/tailwindcss">
        :root { --primary-color: #ff7b00; }
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        .custom-scrollbar::-webkit-scrollbar { width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #e5e7eb; border-radius: 10px; }
    </style>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        primary: "#ff7b00",
                        "background-light": "#f9fafb",
                        "background-dark": "#111827"
                    }
                }
            }
        };

        function processAppointmentRequest(appointmentId, requestType, decision, veterinarianId) {
            if (requestType === 'doctor-change' && decision === 'approve') {
                if (!veterinarianId || parseInt(veterinarianId, 10) <= 0) {
                    alert('Please select a new doctor before approval.');
                    return;
                }
            }

            let body = 'appointmentId=' + encodeURIComponent(appointmentId)
                    + '&requestType=' + encodeURIComponent(requestType)
                    + '&decision=' + encodeURIComponent(decision);
            if (veterinarianId) {
                body += '&veterinarianId=' + encodeURIComponent(veterinarianId);
            }

            fetch('HandleAppointmentRequest', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: body
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert(data.message || 'Request processed successfully');
                    window.location.reload();
                } else {
                    alert('Error: ' + (data.message || 'Unable to process request'));
                }
            })
            .catch(error => {
                console.error(error);
                alert('An error occurred while processing request');
            });
        }

        document.addEventListener('DOMContentLoaded', function () {
            const selectedId = '${selectedAppointmentId}';
            if (!selectedId) return;
            const row = document.getElementById('request-' + selectedId);
            if (!row) return;
            row.classList.add('ring-2', 'ring-primary', 'ring-offset-2');
            row.scrollIntoView({ behavior: 'smooth', block: 'center' });
        });
    </script>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 min-h-screen flex">
    <aside class="w-64 border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex flex-col h-screen sticky top-0">
        <div class="p-6 flex items-center gap-3">
            <div class="w-10 h-10 bg-primary rounded-xl flex items-center justify-center">
                <span class="material-symbols-outlined text-white">pets</span>
            </div>
            <span class="text-2xl font-bold tracking-tight text-slate-800 dark:text-white">Anipat</span>
        </div>
        <nav class="flex-1 px-4 mt-4 space-y-1">
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="/Veterinary_Clinic_Management_System/Receptionist/Dashboard">
                <span class="material-symbols-outlined">dashboard</span>
                <span class="font-medium">Dashboard</span>
            </a>
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="/Veterinary_Clinic_Management_System/Receptionist/ViewListAppointment">
                <span class="material-symbols-outlined">calendar_today</span>
                <span class="font-medium">Schedule</span>
            </a>
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary text-white shadow-lg shadow-primary/20" href="/Veterinary_Clinic_Management_System/Receptionist/ManageAppointmentRequests">
                <span class="material-symbols-outlined">pending_actions</span>
                <span class="font-medium">Request Center</span>
            </a>
        </nav>
    </aside>

    <main class="flex-1 flex flex-col min-h-screen">
        <header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-between px-8 sticky top-0 z-10">
            <div>
                <h1 class="text-xl font-bold text-slate-800 dark:text-white">Appointment Requests</h1>
                <p class="text-xs text-slate-500 dark:text-slate-400">Approve/Reject reschedule and doctor-change requests</p>
            </div>
            <div class="flex items-center gap-4">
                <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                <a href="/Veterinary_Clinic_Management_System/Receptionist/ViewListAppointment" class="px-3 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-sm font-medium text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800">Back to Appointments</a>
            </div>
        </header>

        <div class="p-8 flex-1 overflow-y-auto custom-scrollbar">
            <div class="flex items-center justify-between mb-6">
                <div class="flex gap-6 border-b border-slate-200 dark:border-slate-800">
                    <a href="?requestType=All&amp;fromDate=${fromDate}&amp;toDate=${toDate}&amp;keyword=${keyword}&amp;customerName=${customerName}" class="pb-3 text-sm font-semibold ${requestType == 'All' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400'}">All (${totalRequestCount})</a>
                    <a href="?requestType=Reschedule&amp;fromDate=${fromDate}&amp;toDate=${toDate}&amp;keyword=${keyword}&amp;customerName=${customerName}" class="pb-3 text-sm font-semibold ${requestType == 'Reschedule' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400'}">Reschedule (${rescheduleCount})</a>
                    <a href="?requestType=DoctorChange&amp;fromDate=${fromDate}&amp;toDate=${toDate}&amp;keyword=${keyword}&amp;customerName=${customerName}" class="pb-3 text-sm font-semibold ${requestType == 'DoctorChange' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400'}">Doctor Change (${doctorChangeCount})</a>
                </div>

                <form method="get" class="flex items-center bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl px-3 py-2 gap-2">
                    <input type="hidden" name="requestType" value="${requestType}"/>
                    <input type="text" name="keyword" value="${keyword}" placeholder="Search by appointment ID, pet, owner..." class="text-xs px-2 py-1 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 w-60"/>
                    <input type="text" name="customerName" value="${customerName}" placeholder="Filter customer name..." class="text-xs px-2 py-1 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 w-52"/>
                    <input type="date" name="fromDate" value="${fromDate}" class="text-xs px-2 py-1 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800"/>
                    <span class="text-xs text-slate-400">to</span>
                    <input type="date" name="toDate" value="${toDate}" class="text-xs px-2 py-1 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800"/>
                    <button type="submit" class="px-3 py-1.5 rounded-lg bg-primary text-white text-xs font-semibold">Apply</button>
                </form>
            </div>

            <p class="text-sm text-slate-500 dark:text-slate-400 mb-4">${displayDateRange}</p>

            <div class="space-y-3">
                <c:choose>
                    <c:when test="${empty requestList}">
                        <div class="text-center py-16 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl">
                            <span class="material-symbols-outlined text-6xl text-slate-300 dark:text-slate-700">event_busy</span>
                            <p class="mt-4 text-slate-500 dark:text-slate-400">No request found in selected date range</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="appointment" items="${requestList}">
                            <c:set var="isRescheduleRequested" value="${appointment.status == 'Reschedule-Requested'}"/>
                            <c:set var="isDoctorChangeRequested" value="${appointment.status == 'Doctor-Change-Requested'}"/>
                            <div id="request-${appointment.appointmentId}" class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl p-4 flex items-center justify-between gap-4">
                                <div class="min-w-0">
                                    <p class="text-sm font-semibold text-slate-800 dark:text-white truncate">
                                        #${appointment.appointmentId} - ${appointment.pet.name} - ${appointment.customer.user.fullName}
                                    </p>
                                    <p class="text-xs text-slate-500 dark:text-slate-400">
                                        ${appointment.formattedDate} ${appointment.formattedTime} | ${not empty appointment.service ? appointment.service : 'N/A'}
                                    </p>
                                    <p class="text-xs mt-1 ${isRescheduleRequested ? 'text-amber-600 dark:text-amber-300' : 'text-violet-600 dark:text-violet-300'} font-semibold">
                                        ${appointment.status}
                                    </p>
                                </div>
                                <div class="flex items-center gap-2 shrink-0">
                                    <c:if test="${isRescheduleRequested}">
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="processAppointmentRequest(this.dataset.appointmentId, 'reschedule', 'approve')" class="bg-primary text-white px-3 py-1.5 rounded-lg text-xs font-semibold">Approve</button>
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="processAppointmentRequest(this.dataset.appointmentId, 'reschedule', 'reject')" class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-rose-200 dark:border-rose-700 text-rose-600 dark:text-rose-400">Reject</button>
                                    </c:if>
                                    <c:if test="${isDoctorChangeRequested}">
                                        <select id="vet-select-${appointment.appointmentId}" class="px-2 py-1 rounded-lg text-xs border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800">
                                            <option value="0">Select doctor</option>
                                            <c:forEach var="vet" items="${veterinarians}">
                                                <option value="${vet.userId}">${vet.fullName}</option>
                                            </c:forEach>
                                        </select>
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="processAppointmentRequest(this.dataset.appointmentId, 'doctor-change', 'approve', document.getElementById('vet-select-${appointment.appointmentId}').value)" class="bg-primary text-white px-3 py-1.5 rounded-lg text-xs font-semibold">Approve</button>
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="processAppointmentRequest(this.dataset.appointmentId, 'doctor-change', 'reject')" class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-rose-200 dark:border-rose-700 text-rose-600 dark:text-rose-400">Reject</button>
                                    </c:if>
                                    <a href="/Veterinary_Clinic_Management_System/Receptionist/ViewListAppointment" class="bg-primary/10 text-primary px-3 py-1.5 rounded-lg text-xs font-semibold">Open Schedule</a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
