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
            <!-- Dashboard -->
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="${pageContext.request.contextPath}/Receptionist/Dashboard">
                <span class="material-symbols-outlined">dashboard</span>
                <span class="font-medium">Dashboard</span>
            </a>
            <!-- Schedule -->
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="${pageContext.request.contextPath}/Receptionist/ViewListAppointment">
                <span class="material-symbols-outlined">calendar_today</span>
                <span class="font-medium">Schedule</span>
            </a>
            <!-- Request Center -->
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary text-white shadow-lg shadow-primary/20" href="${pageContext.request.contextPath}/Receptionist/ManageAppointmentRequests">
                <span class="material-symbols-outlined">pending_actions</span>
                <span class="font-medium">Request Center</span>
            </a>
        </nav>
    </aside>

    <main class="flex-1 flex flex-col min-h-screen">
        <header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-between px-8 sticky top-0 z-10">
            <div>
                <h1 class="text-xl font-bold text-slate-800 dark:text-white">Appointment Requests</h1>
            </div>
            <div class="flex items-center gap-4">
                <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                <div class="flex items-center gap-3 pl-4 border-l border-slate-200 dark:border-slate-800">
                    <div class="text-right">
                        <p class="text-sm font-semibold text-slate-800 dark:text-white">
                            <c:out value="${not empty sessionScope.currentUser ? sessionScope.currentUser.fullName : 'User'}"/>
                        </p>
                        <p class="text-xs text-slate-500 dark:text-slate-400">
                            <c:out value="${not empty sessionScope.currentUser.role ? sessionScope.currentUser.role.roleName : 'User'}"/>
                        </p>
                    </div>
                        <div class="relative">
                            <button type="button"
                                    id="receptionist-profile-toggle"
                                    class="w-10 h-10 rounded-full overflow-hidden focus:outline-none">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.currentUser.profilePictureUrl}">
                                        <img alt="Profile"
                                             class="w-full h-full object-cover"
                                             src="${pageContext.request.contextPath}${sessionScope.currentUser.profilePictureUrl}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="material-symbols-outlined text-primary bg-primary/10 w-full h-full flex items-center justify-center">
                                            person
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </button>
                            <div id="receptionist-profile-menu"
                                 class="absolute right-0 mt-2 w-44 origin-top-right rounded-xl bg-white shadow-lg border border-slate-200 z-50"
                                 style="display:none;">
                                <a href="${pageContext.request.contextPath}/Receptionist/profile"
                                   class="block px-4 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50 transition-colors rounded-t-xl flex items-center gap-2">
                                    <span class="material-symbols-outlined text-base text-primary">person</span>
                                    <span>My Profile</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/logout"
                                   class="block px-4 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50 transition-colors rounded-b-xl flex items-center gap-2">
                                    <span class="material-symbols-outlined text-base text-primary">logout</span>
                                    <span>Sign out</span>
                                </a>
                            </div>
                        </div>
                </div>
            </div>
        </header>

        <div class="p-8 flex-1 overflow-y-auto custom-scrollbar">
            <div class="mb-6 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl p-4">
                <form method="get" class="grid grid-cols-1 md:grid-cols-5 gap-3 items-end">
                   
                    <div class="flex flex-col gap-1 md:col-span-2">
                        <label class="text-xs font-semibold text-slate-500">Search</label>
                        <input
                                type="text"
                                name="keyword"
                                value="${keyword}"
                                placeholder="Appointment ID, pet, customer, doctor..."
                                class="text-sm rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-700 dark:text-slate-300 focus:outline-none focus:ring-2 focus:ring-primary/20"/>
                    </div>
                    <div class="flex flex-col gap-1">
                        <label class="text-xs font-semibold text-slate-500">From Date</label>
                        <input
                                type="date"
                                name="fromDate"
                                value="${fromDate}"
                                class="text-sm rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-700 dark:text-slate-300 focus:outline-none focus:ring-2 focus:ring-primary/20"/>
                    </div>
                    <div class="flex flex-col gap-1">
                        <label class="text-xs font-semibold text-slate-500">To Date</label>
                        <input
                                type="date"
                                name="toDate"
                                value="${toDate}"
                                class="text-sm rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-700 dark:text-slate-300 focus:outline-none focus:ring-2 focus:ring-primary/20"/>
                    </div>
                    <div class="md:col-span-5 flex items-center justify-between gap-3 mt-1">
                        <div class="flex items-center gap-2 text-xs font-semibold">
                            <span class="px-2 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300">Total: ${totalRequestCount}</span>
                            <span class="px-2 py-1 rounded-full bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300">Reschedule: ${rescheduleCount}</span>
                        </div>
                        <div class="flex items-center gap-2">
                            <a href="${pageContext.request.contextPath}/Receptionist/ManageAppointmentRequests" class="px-3 py-1.5 rounded-lg border border-slate-200 dark:border-slate-700 text-xs font-semibold text-slate-600 dark:text-slate-300">Reset</a>
                            <button type="submit" class="px-3 py-1.5 rounded-lg bg-primary text-white text-xs font-semibold hover:opacity-90 transition-all">Apply</button>
                        </div>
                    </div>
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
                            <c:set var="details" value="${appointmentDetails[appointment.appointmentId]}"/>
                            <div id="request-${appointment.appointmentId}" class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl p-4">
                                <div class="flex items-start justify-between gap-4 mb-3">
                                    <div class="min-w-0">
                                        <p class="text-sm font-semibold text-slate-800 dark:text-white truncate">
                                            #${appointment.appointmentId} - ${appointment.pet.name} - ${appointment.customer.user.fullName}
                                        </p>
                                        <p class="text-xs text-slate-500 dark:text-slate-400">
                                            ${appointment.formattedDate} ${appointment.formattedTime} | ${not empty appointment.service ? appointment.service : 'N/A'}
                                        </p>
                                        <p class="text-xs mt-1 text-amber-600 dark:text-amber-300 font-semibold">
                                            ${appointment.status}
                                        </p>
                                    </div>
                                </div>
                                
                                <!-- Request Details -->
                                <div class="bg-slate-50 dark:bg-slate-800/50 rounded-lg p-3 mb-3 text-xs">
                                    <c:if test="${isRescheduleRequested}">
                                        <div class="space-y-2">
                                            <div>
                                                <span class="font-semibold text-slate-600 dark:text-slate-300">Current Time:</span>
                                                <span class="text-slate-700 dark:text-slate-200">${not empty details['oldTime'] ? details['oldTime'] : appointment.formattedDate}</span>
                                            </div>
                                            <div>
                                                <span class="font-semibold text-slate-600 dark:text-slate-300">Requested Slot:</span>
                                                <span class="text-slate-700 dark:text-slate-200">
                                                    <c:choose>
                                                        <c:when test="${details['requestedSlot'] == 'morning'}">Morning</c:when>
                                                        <c:when test="${details['requestedSlot'] == 'afternoon'}">Afternoon</c:when>
                                                        <c:otherwise>${not empty details['requestedTime'] ? details['requestedTime'] : 'N/A'}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <div>
                                                <span class="font-semibold text-slate-600 dark:text-slate-300">Reason:</span>
                                                <p class="text-slate-700 dark:text-slate-200 mt-1 max-h-24 overflow-y-auto">${not empty details['reason'] ? details['reason'] : 'No reason provided'}</p>
                                            </div>
                                        </div>
                                    </c:if>
                                </div>
                                
                                <!-- Action Buttons -->
                                <div class="flex items-center gap-2">
                                    <c:if test="${isRescheduleRequested}">
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="processAppointmentRequest(this.dataset.appointmentId, 'reschedule', 'approve')" class="bg-primary text-white px-3 py-1.5 rounded-lg text-xs font-semibold">Approve</button>
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="processAppointmentRequest(this.dataset.appointmentId, 'reschedule', 'reject')" class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-rose-200 dark:border-rose-700 text-rose-600 dark:text-rose-400">Reject</button>
                                    </c:if>
                                    <a href="/Veterinary_Clinic_Management_System/Receptionist/ViewListAppointment" class="bg-primary/10 text-primary px-3 py-1.5 rounded-lg text-xs font-semibold ml-auto">Open Schedule</a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
    <script>
        (function() {
            var toggle = document.getElementById('receptionist-profile-toggle');
            var menu = document.getElementById('receptionist-profile-menu');
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
