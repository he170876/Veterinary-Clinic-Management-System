<%-- 
    Document   : ViewListAppointment
    Created on : Feb 3, 2026, 12:56:24 AM
    Author     : admin
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html class="light" lang="en"><head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Anipat - Veterinary Appointment Management</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,typography,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&amp;display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
        <style type="text/tailwindcss">
            :root {
                --primary-color: #ff7b00;
            }
            body {
                font-family: 'Inter', sans-serif;
            }
            .custom-scrollbar::-webkit-scrollbar {
                width: 6px;
            }
            .custom-scrollbar::-webkit-scrollbar-track {
                background: transparent;
            }
            .custom-scrollbar::-webkit-scrollbar-thumb {
                background: #e5e7eb;
                border-radius: 10px;
            }
            .dark .custom-scrollbar::-webkit-scrollbar-thumb {
                background: #374151;
            }
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
            .appointment-grid {
                display: grid;
                grid-template-columns: 200px 150px 140px 100px 150px 140px 1fr;
                align-items: center;
                gap: 1rem;
            }
            
            /* Popup styles */
            .popup-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                z-index: 1000;
                align-items: center;
                justify-content: center;
            }
            
            .popup-overlay.active {
                display: flex;
            }
            
            .popup-content {
                background: white;
                padding: 2rem;
                border-radius: 12px;
                max-width: 400px;
                width: 90%;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            }
            
            .dark .popup-content {
                background: #1e293b;
            }
            
            /* Toast notification */
            .toast {
                position: fixed;
                top: 20px;
                right: 20px;
                background: #10b981;
                color: white;
                padding: 1rem 1.5rem;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                z-index: 2000;
                display: none;
                align-items: center;
                gap: 0.5rem;
                animation: slideIn 0.3s ease-out;
            }
            
            .toast.active {
                display: flex;
            }
            
            @keyframes slideIn {
                from {
                    transform: translateX(400px);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }
        </style>
        <script>
            tailwind.config = {
                darkMode: "class",
                theme: {
                    extend: {
                        colors: {
                            primary: "#ff7b00",
                            "background-light": "#f9fafb",
                            "background-dark": "#111827",
                        },
                        fontFamily: {
                            display: ["Inter", "sans-serif"],
                        },
                        borderRadius: {
                            DEFAULT: "12px",
                        },
                    },
                },
            };
            function toggleDarkMode() {
                document.documentElement.classList.toggle('dark');
            }
            
            let currentAppointmentId = null;
            let currentSelectElement = null;
            let originalVetId = null;
            let currentDetailAppointmentId = null;
            
            function showConfirmPopup(appointmentId, selectElement, newVetId) {
                currentAppointmentId = appointmentId;
                currentSelectElement = selectElement;
                originalVetId = selectElement.getAttribute('data-original-vet');
                
                // Show popup
                document.getElementById('confirmPopup').classList.add('active');
            }
            
            function closePopup() {
                // Reset select to original value
                if (currentSelectElement && originalVetId) {
                    currentSelectElement.value = originalVetId;
                }
                document.getElementById('confirmPopup').classList.remove('active');
                currentAppointmentId = null;
                currentSelectElement = null;
                originalVetId = null;
            }
            
            function confirmDoctorChange() {
                if (!currentAppointmentId || !currentSelectElement) return;
                
                const newVetId = currentSelectElement.value;
                
                // Send AJAX request
                fetch('UpdateAppointmentDoctor', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'appointmentId=' + currentAppointmentId + '&veterinarianId=' + newVetId
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Update the original vet id in popup
                        currentSelectElement.setAttribute('data-original-vet', newVetId);
                        
                        // Update doctor dropdown in the main list
                        const mainListSelect = document.querySelector('select[data-appointment-id="' + currentAppointmentId + '"]');
                        if (mainListSelect) {
                            mainListSelect.value = newVetId;
                            mainListSelect.setAttribute('data-original-vet', newVetId);
                        }
                        
                        // Show success toast
                        showToast(data.message);
                        
                        // Close popup
                        document.getElementById('confirmPopup').classList.remove('active');
                    } else {
                        alert('Error: ' + data.message);
                        // Reset select
                        if (originalVetId) {
                            currentSelectElement.value = originalVetId;
                        }
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while changing the doctor');
                    // Reset select
                    if (originalVetId) {
                        currentSelectElement.value = originalVetId;
                    }
                })
                .finally(() => {
                    currentAppointmentId = null;
                    currentSelectElement = null;
                    originalVetId = null;
                });
            }
            
            function showToast(message) {
                const toast = document.getElementById('successToast');
                const toastMessage = document.getElementById('toastMessage');
                toastMessage.textContent = message;
                toast.classList.add('active');
                setTimeout(() => { toast.classList.remove('active'); }, 3000);
            }
            window.showToast = showToast;

            function processAppointmentRequest(appointmentId, requestType, decision) {
                fetch('HandleAppointmentRequest', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'appointmentId=' + encodeURIComponent(appointmentId)
                            + '&requestType=' + encodeURIComponent(requestType)
                            + '&decision=' + encodeURIComponent(decision)
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showToast(data.message || 'Request processed successfully');
                        setTimeout(() => {
                            window.location.reload();
                        }, 450);
                    } else {
                        alert('Error: ' + (data.message || 'Unable to process the request'));
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while processing the request');
                });
            }

            function openDetail(appointmentId) {
                const panel = document.getElementById('detailView');
                const loading = document.getElementById('detailLoading');
                const content = document.getElementById('detailContent');
                const footer = document.getElementById('detailFooter');
                panel.classList.remove('hidden');
                loading.classList.remove('hidden');
                content.classList.add('hidden');
                footer.classList.add('hidden');
                fetch('GetAppointmentDetail?appointmentId=' + appointmentId)
                    .then(r => r.json())
                    .then(data => {
                        if (!data.success) {
                            alert('Error: ' + data.message);
                            panel.classList.add('hidden');
                            return;
                        }
                        populateDetail(data);
                        loading.classList.add('hidden');
                        content.classList.remove('hidden');
                        footer.classList.remove('hidden');
                    })
                    .catch(err => {
                        console.error(err);
                        alert('An error occurred while loading appointment details');
                        panel.classList.add('hidden');
                    });
            }

            function populateDetail(d) {
                currentDetailAppointmentId = d.appointmentId;
                
                const pet = d.pet || {};
                const owner = d.owner || {};
                const photoEl = document.getElementById('d-pet-photo');
                const noPhotoEl = document.getElementById('d-pet-no-photo');
                if (pet.photoUrl) {
                    photoEl.src = pet.photoUrl;
                    photoEl.classList.remove('hidden');
                    noPhotoEl.classList.add('hidden');
                } else {
                    photoEl.classList.add('hidden');
                    noPhotoEl.classList.remove('hidden');
                }
                document.getElementById('d-pet-name').textContent = pet.name || '';
                document.getElementById('d-status-badge').textContent = d.status || '';
                const sb = document.getElementById('d-status-badge');
                sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-primary/10 text-primary';
                const s = (d.status || '').toLowerCase();
                if (s === 'pending' || s === 'scheduled') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-yellow-100 text-yellow-600';
                else if (s === 'confirmed') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-emerald-100 text-emerald-600';
                else if (s === 'checked-in') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-blue-100 text-blue-600';
                else if (s === 'in-examination') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-orange-100 text-orange-600';
                else if (s === 'completed' || s === 'done') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-green-100 text-green-600';
                else if (s === 'canceled' || s === 'cancelled') sb.className = 'px-3 py-1 text-xs font-bold rounded-full bg-red-100 text-red-600';
                const sp = pet.species || '', br = pet.breed || '';
                document.getElementById('d-species-breed').textContent = sp && br ? sp + ' / ' + br : (sp || br || 'N/A');
                document.getElementById('d-age').textContent = pet.age || 'N/A';
                document.getElementById('d-gender').textContent = pet.gender || 'N/A';
                document.getElementById('d-weight').textContent = pet.weight || 'N/A';
                document.getElementById('d-owner-name').textContent = owner.name || 'N/A';
                document.getElementById('d-owner-phone').textContent = owner.phone || 'N/A';
                document.getElementById('d-owner-email').textContent = owner.email || 'N/A';
                document.getElementById('d-owner-address').textContent = owner.address || 'N/A';
                document.getElementById('d-date').textContent = d.date || 'N/A';
                document.getElementById('d-time').textContent = d.time || 'N/A';
                document.getElementById('d-service').textContent = d.service || 'N/A';
                document.getElementById('d-doctor-name').textContent = d.veterinarianName || 'N/A';

                // Populate doctor select in detail panel
                const doctorSelect = document.getElementById('d-doctor-select');
                if (doctorSelect) {
                    doctorSelect.setAttribute('data-appointment-id', d.appointmentId);
                    doctorSelect.setAttribute('data-original-vet', d.veterinarianId || 0);
                    doctorSelect.value = d.veterinarianId && d.veterinarianId > 0 ? d.veterinarianId : "0";
                }

                // Show/hide footer buttons based on status
                const allBtns = ['d-btn-confirm','d-btn-reject','d-btn-checkin','d-btn-reschedule','d-btn-cancel','d-btn-markpaid','d-btn-invoice'];
                allBtns.forEach(id => document.getElementById(id).classList.add('hidden'));

                const isPending   = s === 'pending' || s === 'scheduled';
                const isConfirmed = s === 'confirmed';
                const isCheckedIn = s === 'checked-in' || s === 'Checked-in' || s === 'checked in';
                const isWaiting   = s === 'waiting-for-payment' || s === 'waiting for payment';
                const isDone      = s === 'completed' || s === 'done';

                if (isPending) {
                    document.getElementById('d-btn-confirm').classList.remove('hidden');
                    document.getElementById('d-btn-reject').classList.remove('hidden');
                }
                if (isConfirmed) {
                    document.getElementById('d-btn-checkin').classList.remove('hidden');
                    document.getElementById('d-btn-reschedule').classList.remove('hidden');
                    document.getElementById('d-btn-cancel').classList.remove('hidden');
                }
                if (isCheckedIn) {
                    document.getElementById('d-btn-cancel').classList.remove('hidden');
                }
                if (isWaiting) {
                    document.getElementById('d-btn-markpaid').classList.remove('hidden');
                }
                if (isDone) {
                    document.getElementById('d-btn-invoice').classList.remove('hidden');
                }

                // Show footer only if there are visible buttons
                const hasButtons = isPending || isConfirmed || isCheckedIn || isWaiting || isDone;
                document.getElementById('detailFooter').classList.toggle('hidden', !hasButtons);
            }

            function closeDetail() {
                document.getElementById('detailView').classList.add('hidden');
            }
            
            // Function to handle doctor change from detail panel dropdown
            function showDoctorChangeConfirm(selectElement) {
                const newVetId = parseInt(selectElement.value);
                const originalVetId = parseInt(selectElement.getAttribute('data-original-vet')) || 0;
                
                if (newVetId === originalVetId) return;
                
                currentAppointmentId = selectElement.getAttribute('data-appointment-id');
                currentSelectElement = selectElement;
                
                document.getElementById('confirmPopup').classList.add('active');
            }

            // Appointment action functions
            function updateStatus(appointmentId, newStatus, button) {
                if (button) {
                    button.disabled = true;
                    button.textContent = '...';
                }
                
                fetch('UpdateAppointmentStatus', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'appointmentId=' + appointmentId + '&status=' + newStatus
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showToast(data.message);
                        setTimeout(() => { location.reload(); }, 1500);
                    } else {
                        alert('Error: ' + data.message);
                        if (button) button.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while updating status');
                    if (button) button.disabled = false;
                });
            }

            function confirmAppointment(appointmentId, button) {
                updateStatus(appointmentId, 'Confirmed', button);
            }

            let currentRejectAppointmentId = null;
            let currentRejectButton = null;

            function rejectAppointment(appointmentId, button) {
                currentRejectAppointmentId = appointmentId;
                currentRejectButton = button;
                document.getElementById('rejectPopup').classList.add('active');
            }

            function closeRejectPopup() {
                document.getElementById('rejectPopup').classList.remove('active');
                currentRejectAppointmentId = null;
                currentRejectButton = null;
            }

            function confirmReject() {
                if (!currentRejectAppointmentId) return;
                const appointmentId = currentRejectAppointmentId;
                const button = currentRejectButton;
                closeRejectPopup();
                updateStatus(appointmentId, 'Rejected', button);
            }

            function checkInAppointment(appointmentId, button) {
                updateStatus(appointmentId, 'Checked-in', button);
            }

            function rescheduleAppointment(appointmentId) {
                const newDate = prompt('Enter new date (yyyy-MM-dd):');
                if (!newDate) return;
                const newTime = prompt('Enter new time (HH:mm):');
                if (!newTime) return;
                
                fetch('RescheduleAppointment', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'appointmentId=' + appointmentId + '&newDate=' + newDate + '&newTime=' + newTime
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showToast(data.message);
                        setTimeout(() => { location.reload(); }, 1500);
                    } else {
                        alert('Error: ' + data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while rescheduling the appointment');
                });
            }

            let currentCancelAppointmentId = null;
            let currentCancelButton = null;

            function cancelAppointment(appointmentId, button) {
                currentCancelAppointmentId = appointmentId;
                currentCancelButton = button;
                document.getElementById('cancelPopup').classList.add('active');
            }

            function closeCancelPopup() {
                document.getElementById('cancelPopup').classList.remove('active');
                currentCancelAppointmentId = null;
                currentCancelButton = null;
            }

            function confirmCancel() {
                if (!currentCancelAppointmentId) return;
                const appointmentId = currentCancelAppointmentId;
                const button = currentCancelButton;
                closeCancelPopup();
                updateStatus(appointmentId, 'Canceled', button);
            }

            function markAsPaid(appointmentId, button) {
                if (button) {
                    button.disabled = true;
                    button.textContent = '...';
                }

                fetch('MarkInvoicePaid', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    },
                    body: 'appointmentId=' + encodeURIComponent(appointmentId)
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showToast(data.message || 'Payment confirmed');
                        setTimeout(() => { location.reload(); }, 1500);
                    } else {
                        alert('Error: ' + (data.message || 'Unable to confirm payment'));
                        if (button) button.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while confirming payment');
                    if (button) button.disabled = false;
                });
            }

            function viewInvoice(appointmentId) {
                window.open('ViewInvoice?appointmentId=' + appointmentId, '_blank');
            }
            
            // Live search by Pet, Owner, Phone (client-side)
            document.addEventListener('DOMContentLoaded', function () {
                const searchInput = document.getElementById('appointmentSearchInput');
                if (!searchInput) return;
                searchInput.addEventListener('input', function () {
                    const term = this.value.trim().toLowerCase();
                    const rows = document.querySelectorAll('.appointment-row');
                    rows.forEach(function (row) {
                        const pet = (row.getAttribute('data-pet-name') || '').toLowerCase();
                        const owner = (row.getAttribute('data-owner-name') || '').toLowerCase();
                        const phone = (row.getAttribute('data-phone') || '').toLowerCase();
                        const match = !term || pet.includes(term) || owner.includes(term) || phone.includes(term);
                        row.closest('.appointment-grid-item, .bg-white, .dark\\:bg-slate-900')?.classList?.toggle('hidden', !match);
                        if (!row.closest('.appointment-grid-item, .bg-white, .dark\\:bg-slate-900')) {
                            row.parentElement.classList.toggle('hidden', !match);
                        }
                    });
                });
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
                <a class="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary text-white shadow-lg shadow-primary/20" href="${pageContext.request.contextPath}/Receptionist/ViewListAppointment">
                    <span class="material-symbols-outlined">calendar_today</span>
                    <span class="font-medium">Schedule</span>
                </a>
                <!-- Request Center -->
                <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="${pageContext.request.contextPath}/Receptionist/ManageAppointmentRequests">
                    <span class="material-symbols-outlined">pending_actions</span>
                    <span class="font-medium">Request Center</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="${pageContext.request.contextPath}/Receptionist/profile">
                    <span class="material-symbols-outlined">person</span>
                    <span class="font-medium">My Profile</span>
                </a>
            </nav>

        </aside>
        <main class="flex-1 flex flex-col min-h-screen">
            <header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-between px-8 sticky top-0 z-10">
                <div class="flex-1"></div>
                <div class="flex items-center gap-4">
                    <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                    <div class="flex items-center gap-3 pl-4 border-l border-slate-200 dark:border-slate-800">
                        <div class="text-right">
                            <p class="text-sm font-semibold text-slate-800 dark:text-white"><c:out value="${not empty sessionScope.currentUser ? sessionScope.currentUser.fullName : 'User'}"/></p>
                            <p class="text-xs text-slate-500 dark:text-slate-400"><c:out value="${not empty sessionScope.currentUser.role ? sessionScope.currentUser.role.roleName : 'User'}"/></p>
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
                <div class="flex flex-col gap-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <h1 class="text-2xl font-bold text-slate-800 dark:text-white">Appointments</h1>
                            <p class="text-slate-500 dark:text-slate-400 text-sm">Manage and monitor today's scheduled visits</p>
                            <div class="mt-4">
                                <div class="relative w-96 max-w-full">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xl">search</span>
                                    <input 
                                        class="w-full pl-10 pr-4 py-2 bg-slate-100 dark:bg-slate-800 border-none rounded-full text-sm focus:ring-2 focus:ring-primary/20 placeholder-slate-500 text-slate-800 dark:text-slate-100" 
                                        type="text" 
                                        id="appointmentSearchInput"
                                        placeholder="Search patients, owners or records..."/>
                                </div>
                            </div>
                        </div>
                        <div class="flex gap-3">
                            <form method="get" class="flex items-center bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl px-3 py-2 gap-3">
                                <input type="hidden" name="status" value="${statusFilter}"/>
                                <span class="material-symbols-outlined text-slate-400 text-xl">calendar_month</span>
                                <div class="flex items-center gap-2 ml-3">
                                    <input 
                                        type="date" 
                                        name="fromDate" 
                                        value="${fromDate}" 
                                        class="text-xs px-2 py-1 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 focus:outline-none focus:ring-2 focus:ring-primary/20"/>
                                    <span class="text-xs text-slate-400 dark:text-slate-500">to</span>
                                    <input 
                                        type="date" 
                                        name="toDate" 
                                        value="${toDate}" 
                                        class="text-xs px-2 py-1 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 focus:outline-none focus:ring-2 focus:ring-primary/20"/>
                                </div>
                                <button 
                                    type="submit"
                                    class="ml-2 px-3 py-1.5 rounded-lg bg-primary text-white text-xs font-semibold hover:opacity-90 transition-all">
                                    Apply
                                </button>
                            </form>
                            <button type="button" onclick="openBookAppointmentModal()" class="bg-primary text-white px-5 py-2.5 rounded-xl font-semibold flex items-center gap-2 hover:opacity-90 transition-opacity">
                                <span class="material-symbols-outlined text-lg">add</span>
                                <span>New Appointment</span>
                            </button>
                            <button type="button" onclick="openEmergencyAppointmentModal()" class="bg-red-500 text-white px-5 py-2.5 rounded-xl font-semibold flex items-center gap-2 hover:opacity-90 transition-opacity">
                                <span class="material-symbols-outlined text-lg">emergency</span>
                                <span>Emergency</span>
                            </button>
                                        
                        </div>
                    </div>
                    <div class="flex items-center justify-between border-b border-slate-200 dark:border-slate-800">
                        <div class="flex gap-8">
                            <a href="?status=All&amp;fromDate=${fromDate}&amp;toDate=${toDate}" class="pb-4 text-sm font-semibold ${statusFilter == 'All' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">All (${totalCount})</a>
                            <a href="?status=Pending&amp;fromDate=${fromDate}&amp;toDate=${toDate}" class="pb-4 text-sm font-medium ${statusFilter == 'Pending' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Pending (${pendingCount})</a>
                            <a href="?status=Confirmed&amp;fromDate=${fromDate}&amp;toDate=${toDate}" class="pb-4 text-sm font-medium ${statusFilter == 'Confirmed' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Confirmed (${confirmedCount})</a>
                            <a href="?status=Checked-in&amp;fromDate=${fromDate}&amp;toDate=${toDate}" class="pb-4 text-sm font-medium ${statusFilter == 'Checked-in' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Checked-in (${checkedInCount})</a>
                            <a href="?status=In-Examination&amp;fromDate=${fromDate}&amp;toDate=${toDate}" class="pb-4 text-sm font-medium ${statusFilter == 'In-Examination' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">In-Examination (${inExaminationCount})</a>
                            <a href="?status=Waiting-for-Payment&amp;fromDate=${fromDate}&amp;toDate=${toDate}" class="pb-4 text-sm font-medium ${statusFilter == 'Waiting-for-Payment' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Waiting for Payment (${waitingForPaymentCount})</a>
                            <a href="?status=Done&amp;fromDate=${fromDate}&amp;toDate=${toDate}" class="pb-4 text-sm font-medium ${statusFilter == 'Done' || statusFilter == 'Completed' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Done (${doneCount})</a>
                            <a href="?status=Canceled&amp;fromDate=${fromDate}&amp;toDate=${toDate}" class="pb-4 text-sm font-medium ${statusFilter == 'Canceled' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Canceled (${canceledCount})</a>
                        </div>
                        <div class="flex items-center gap-3 pb-2"></div>
                    </div>
                    <div class="px-4 appointment-grid text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">
                        <div>Pet Info</div>
                        <div>Owner</div>
                        <div>Phone Number</div>
                        <div>Time</div>
                        <div>Service</div>
                        <div>Doctor</div>
                        <div class="text-right pr-4">Actions</div>
                    </div>
                    <div class="grid grid-cols-1 gap-3">
                        <c:choose>
                            <c:when test="${empty list}">
                                <div class="text-center py-12">
                                    <span class="material-symbols-outlined text-6xl text-slate-300 dark:text-slate-700">event_busy</span>
                                    <p class="mt-4 text-slate-500 dark:text-slate-400">No appointments found</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                        <c:forEach var="appointment" items="${list}">
                            <c:set var="status" value="${appointment.status}"/>
                            <c:set var="isCompleted" value="${status == 'Completed' || status == 'Done'}"/>
                            <c:set var="isPending" value="${status == 'Pending' || status == 'Scheduled'}"/>
                            <c:set var="isConfirmed" value="${status == 'Confirmed'}"/>
                            <c:set var="isRescheduleRequested" value="${status == 'Reschedule-Requested'}"/>
                            <c:set var="isDoctorChangeRequested" value="${status == 'Doctor-Change-Requested'}"/>
                            <c:set var="isInExamination" value="${status == 'In-Examination' || status == 'In Progress'}"/>
                            <c:set var="isCheckedIn" value="${status == 'Checked-in'}"/>
                            <c:set var="isWaitingForPayment" value="${status == 'Waiting-for-Payment' || status == 'Waiting for Payment'}"/>
                            <c:set var="isCanceled" value="${status == 'Canceled' || status == 'Cancelled'}"/>
                            
                            <c:choose>
                                <c:when test="${isCompleted}">
                                    <div class="group bg-white/60 dark:bg-slate-900/40 border border-slate-200 dark:border-slate-800 rounded-2xl p-3 appointment-grid opacity-80">
                                </c:when>
                                <c:otherwise>
                                    <div class="group bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl p-3 appointment-grid hover:shadow-md transition-shadow">
                                </c:otherwise>
                            </c:choose>
                            
                                <div class="flex items-center gap-2">
                                    <div class="relative flex-shrink-0">
                                        <c:choose>
                                            <c:when test="${not empty appointment.pet.photoURL}">
                                                <img alt="Pet Profile" class="w-10 h-10 rounded-lg object-cover ring-2 ring-primary/10 ${isCompleted ? 'grayscale' : ''}" src="${appointment.pet.photoURL}"/>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="w-10 h-10 rounded-lg bg-slate-200 dark:bg-slate-700 flex items-center justify-center ${isCompleted ? 'grayscale' : ''}">
                                                    <span class="material-symbols-outlined text-slate-400 text-base">pets</span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${isCheckedIn || isInExamination}">
                                            <span class="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-green-500 border-2 border-white dark:border-slate-900 rounded-full"></span>
                                        </c:if>
                                    </div>
                                    <div class="min-w-0">
                                        <h3 class="font-bold text-sm ${isCompleted ? 'text-slate-400 dark:text-slate-500' : 'text-slate-800 dark:text-white'} truncate">${appointment.pet.name}</h3>
                                        <c:choose>
                                            <c:when test="${isInExamination}">
                                                <span class="inline-block px-1.5 py-0.5 bg-orange-100 dark:bg-orange-900/30 text-orange-600 dark:text-orange-400 text-[9px] font-bold rounded uppercase tracking-wider">In-Examination</span>
                                            </c:when>
                                            <c:when test="${isCheckedIn}">
                                                <span class="inline-block px-1.5 py-0.5 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 text-[9px] font-bold rounded uppercase tracking-wider">Checked-in</span>
                                            </c:when>
                                            <c:when test="${isPending}">
                                                <span class="inline-block px-1.5 py-0.5 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-600 dark:text-yellow-400 text-[9px] font-bold rounded uppercase tracking-wider">Pending</span>
                                            </c:when>
                                            <c:when test="${isConfirmed}">
                                                <span class="inline-block px-1.5 py-0.5 bg-emerald-100 dark:bg-emerald-900/30 text-emerald-600 dark:text-emerald-400 text-[9px] font-bold rounded uppercase tracking-wider">Confirmed</span>
                                            </c:when>
                                            <c:when test="${isRescheduleRequested}">
                                                <span class="inline-block px-1.5 py-0.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300 text-[9px] font-bold rounded uppercase tracking-wider">Reschedule Requested</span>
                                            </c:when>
                                            <c:when test="${isDoctorChangeRequested}">
                                                <span class="inline-block px-1.5 py-0.5 bg-violet-100 dark:bg-violet-900/30 text-violet-700 dark:text-violet-300 text-[9px] font-bold rounded uppercase tracking-wider">Doctor Change Requested</span>
                                            </c:when>
                                            <c:when test="${isCompleted}">
                                                <span class="inline-block px-1.5 py-0.5 bg-green-100 dark:bg-green-900/20 text-green-600 dark:text-green-500/70 text-[9px] font-bold rounded uppercase tracking-wider">Done</span>
                                            </c:when>
                                            <c:when test="${isWaitingForPayment}">
                                                <span class="inline-block px-1.5 py-0.5 bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 text-[9px] font-bold rounded uppercase tracking-wider">Waiting for Payment</span>
                                            </c:when>
                                            <c:when test="${isCanceled}">
                                                <span class="inline-block px-1.5 py-0.5 bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 text-[9px] font-bold rounded uppercase tracking-wider">Canceled</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-block px-1.5 py-0.5 bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 text-[9px] font-bold rounded uppercase tracking-wider">${status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="flex items-center gap-2 text-xs owner-cell ${isCompleted ? 'text-slate-400 dark:text-slate-500' : 'text-slate-600 dark:text-slate-400'} appointment-row"
                                     data-pet-name="${appointment.pet.name}"
                                     data-owner-name="${appointment.customer.user.fullName}"
                                     data-phone="${appointment.customer.user.phone}">
                                    <span class="material-symbols-outlined text-base opacity-60">person</span>
                                    <span class="truncate">${not empty appointment.customer.user.fullName ? appointment.customer.user.fullName : 'N/A'}</span>
                                </div>
                                <div class="flex items-center text-xs phone-cell ${isCompleted ? 'text-slate-400 dark:text-slate-500' : 'text-slate-600 dark:text-slate-400'}">
                                    <span class="material-symbols-outlined text-base opacity-60">call</span>
                                    <span class="truncate">
                                        ${not empty appointment.customer.user.phone ? appointment.customer.user.phone : 'N/A'}
                                    </span>
                                </div>
                                <div class="flex flex-col text-xs ${isCompleted ? 'text-slate-400 dark:text-slate-500' : 'text-slate-600 dark:text-slate-400'}">
                                    <span class="font-semibold">${appointment.formattedDateWithSlot}</span>
                                </div>
                                <div class="flex items-center gap-2 text-xs ${isCompleted ? 'text-slate-400 dark:text-slate-500' : 'text-slate-600 dark:text-slate-400'}">
                                    <span class="material-symbols-outlined text-base opacity-60 text-primary">medical_services</span>
                                    <span class="truncate">${not empty appointment.service ? appointment.service : 'N/A'}</span>
                                </div>
                                <div>
                                    <c:choose>
                                        <c:when test="${isInExamination || isWaitingForPayment || isCompleted}">
                                            <p class="text-xs text-slate-600 dark:text-slate-400">
                                                ${not empty appointment.veterinarianName ? appointment.veterinarianName : 'N/A'}
                                            </p>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="text-xs text-slate-600 dark:text-slate-400">N/A</p>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="flex items-center justify-end gap-2 pr-2">
                                    <%-- Pending: Confirm + Reject --%>
                                    <c:if test="${isPending}">
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="confirmAppointment(this.dataset.appointmentId, this)" class="bg-primary text-white px-3 py-1.5 rounded-lg text-xs font-semibold hover:opacity-90 transition-all">Confirm</button>
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="rejectAppointment(this.dataset.appointmentId, this)" class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">Reject</button>
                                    </c:if>
                                    <%-- Confirmed: Check-in + Re-Schedule + Cancel --%>
                                    <c:if test="${isConfirmed}">
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="checkInAppointment(this.dataset.appointmentId, this)" class="bg-blue-500 text-white px-3 py-1.5 rounded-lg text-xs font-semibold hover:opacity-90 transition-all">Check-in</button>
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="rescheduleAppointment(this.dataset.appointmentId)" class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-indigo-200 dark:border-indigo-700 text-indigo-600 dark:text-indigo-400 hover:bg-indigo-50 dark:hover:bg-indigo-900/20 transition-all">Re-Schedule</button>
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="cancelAppointment(this.dataset.appointmentId, this)" class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-red-200 dark:border-red-700 text-red-500 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-all">Cancel</button>
                                    </c:if>
                                    <%-- Checked-in: Cancel only --%>
                                    <c:if test="${isCheckedIn}">
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="cancelAppointment(this.dataset.appointmentId, this)" class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-red-200 dark:border-red-700 text-red-500 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-all">Cancel</button>
                                    </c:if>
                                    <%-- Waiting for Payment: Mark as Paid --%>
                                    <c:if test="${isWaitingForPayment}">
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="markAsPaid(this.dataset.appointmentId, this)" class="bg-purple-500 text-white px-3 py-1.5 rounded-lg text-xs font-semibold hover:opacity-90 transition-all">Mark as Paid</button>
                                    </c:if>
                                    <%-- Done: View Invoice --%>
                                    <c:if test="${isCompleted}">
                                        <button data-appointment-id="${appointment.appointmentId}" onclick="viewInvoice(this.dataset.appointmentId)" class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-green-200 dark:border-green-700 text-green-600 dark:text-green-400 hover:bg-green-50 dark:hover:bg-green-900/20 transition-all">View Invoice</button>
                                    </c:if>
                                    <%-- In-Examination and Canceled: no action buttons --%>
                                    <button data-appointment-id="${appointment.appointmentId}" onclick="openDetail(this.dataset.appointmentId)" class="bg-primary/10 text-primary px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-primary hover:text-white transition-all">Details</button>
                                </div>
                            </div>
                        </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="flex items-center justify-between mt-4">
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Showing 
                            <span class="font-semibold text-slate-800 dark:text-white">
                                <c:out value="${not empty list ? list.size() : 0}"/>
                            </span> 
                            of 
                            <span class="font-semibold text-slate-800 dark:text-white">
                                <c:out value="${totalFiltered}"/>
                            </span> 
                            appointments
                        </p>
                        <div class="flex gap-2">
                            <!-- Previous page -->
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                                <a href="?status=${statusFilter}&amp;fromDate=${fromDate}&amp;toDate=${toDate}&amp;page=${currentPage - 1}"
                                       class="p-2 rounded-lg border border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-400">
                                        <span class="material-symbols-outlined">chevron_left</span>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button class="p-2 rounded-lg border border-slate-200 dark:border-slate-800 text-slate-400 opacity-50 cursor-not-allowed" disabled>
                                        <span class="material-symbols-outlined">chevron_left</span>
                                    </button>
                                </c:otherwise>
                            </c:choose>

                            <!-- Page numbers -->
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <c:choose>
                                    <c:when test="${i == currentPage}">
                                        <button class="w-10 h-10 flex items-center justify-center rounded-lg bg-primary text-white font-semibold">
                                            ${i}
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                                     <a href="?status=${statusFilter}&amp;fromDate=${fromDate}&amp;toDate=${toDate}&amp;page=${i}"
                                           class="w-10 h-10 flex items-center justify-center rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-400">
                                            ${i}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <!-- Next page -->
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                                <a href="?status=${statusFilter}&amp;fromDate=${fromDate}&amp;toDate=${toDate}&amp;page=${currentPage + 1}"
                                       class="p-2 rounded-lg border border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-400">
                                        <span class="material-symbols-outlined">chevron_right</span>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button class="p-2 rounded-lg border border-slate-200 dark:border-slate-800 text-slate-400 opacity-50 cursor-not-allowed" disabled>
                                        <span class="material-symbols-outlined">chevron_right</span>
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        <div class="hidden fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-end" id="detailView">
            <div class="bg-white dark:bg-slate-900 w-full max-w-xl h-full shadow-2xl flex flex-col relative">
                <div class="flex items-center justify-between p-6 border-b border-slate-200 dark:border-slate-800">
                    <h2 class="text-xl font-bold text-slate-800 dark:text-white">Appointment Details</h2>
                    <button class="p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400" onclick="closeDetail()">
                        <span class="material-symbols-outlined">close</span>
                    </button>
                </div>
                <!-- Loading state -->
                <div id="detailLoading" class="flex-1 flex items-center justify-center">
                    <div class="text-center">
                        <span class="material-symbols-outlined text-4xl text-slate-300 animate-spin">progress_activity</span>
                        <p class="mt-2 text-sm text-slate-400">Loading...</p>
                    </div>
                </div>
                <!-- Detail content -->
                <div id="detailContent" class="hidden flex-1 overflow-y-auto custom-scrollbar p-6 space-y-6">
                    <section>
                        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Pet Profile</h3>
                        <div class="flex items-start gap-5">
                            <img id="d-pet-photo" alt="Pet" class="w-24 h-24 rounded-2xl object-cover ring-4 ring-primary/5" src=""/>
                            <div id="d-pet-no-photo" class="hidden w-24 h-24 rounded-2xl bg-slate-200 dark:bg-slate-700 flex items-center justify-center ring-4 ring-primary/5">
                                <span class="material-symbols-outlined text-slate-400 text-4xl">pets</span>
                            </div>
                            <div class="space-y-3 flex-1">
                                <div class="flex items-center justify-between">
                                    <h4 id="d-pet-name" class="text-2xl font-bold text-slate-800 dark:text-white"></h4>
                                    <span id="d-status-badge" class="px-3 py-1 bg-primary/10 text-primary text-xs font-bold rounded-full"></span>
                                </div>
                                <div class="grid grid-cols-2 gap-y-2 text-sm">
                                    <div>
                                        <p class="text-slate-400">Species/Breed</p>
                                        <p id="d-species-breed" class="font-medium text-slate-700 dark:text-slate-300"></p>
                                    </div>
                                    <div>
                                        <p class="text-slate-400">Age</p>
                                        <p id="d-age" class="font-medium text-slate-700 dark:text-slate-300"></p>
                                    </div>
                                    <div>
                                        <p class="text-slate-400">Gender</p>
                                        <p id="d-gender" class="font-medium text-slate-700 dark:text-slate-300"></p>
                                    </div>
                                    <div>
                                        <p class="text-slate-400">Weight</p>
                                        <p id="d-weight" class="font-medium text-slate-700 dark:text-slate-300"></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>
                    <section class="bg-slate-50 dark:bg-slate-800/50 p-5 rounded-2xl border border-slate-100 dark:border-slate-800">
                        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Owner Information</h3>
                        <div class="grid grid-cols-2 gap-6 text-sm">
                            <div class="flex gap-3">
                                <span class="material-symbols-outlined text-primary/60">person</span>
                                <div>
                                    <p class="text-slate-400 text-xs">Name</p>
                                    <p id="d-owner-name" class="font-semibold text-slate-700 dark:text-slate-300"></p>
                                </div>
                            </div>
                            <div class="flex gap-3">
                                <span class="material-symbols-outlined text-primary/60">phone</span>
                                <div>
                                    <p class="text-slate-400 text-xs">Phone</p>
                                    <p id="d-owner-phone" class="font-semibold text-slate-700 dark:text-slate-300"></p>
                                </div>
                            </div>
                            <div class="flex gap-3">
                                <span class="material-symbols-outlined text-primary/60">mail</span>
                                <div>
                                    <p class="text-slate-400 text-xs">Email</p>
                                    <p id="d-owner-email" class="font-semibold text-slate-700 dark:text-slate-300"></p>
                                </div>
                            </div>
                            <div class="flex gap-3">
                                <span class="material-symbols-outlined text-primary/60">location_on</span>
                                <div>
                                    <p class="text-slate-400 text-xs">Address</p>
                                    <p id="d-owner-address" class="font-semibold text-slate-700 dark:text-slate-300"></p>
                                </div>
                            </div>
                        </div>
                    </section>
                    <section>
                        <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Appointment Data</h3>
                        <div class="space-y-4">
                            <div class="grid grid-cols-2 gap-4">
                                <div class="space-y-1">
                                    <label class="text-xs font-medium text-slate-500">Date</label>
                                    <div class="flex items-center gap-2 px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm">
                                        <span class="material-symbols-outlined text-sm text-primary">calendar_today</span>
                                        <span id="d-date"></span>
                                    </div>
                                </div>
                                <div class="space-y-1">
                                    <label class="text-xs font-medium text-slate-500">Time</label>
                                    <div class="flex items-center gap-2 px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm">
                                        <span class="material-symbols-outlined text-sm text-primary">schedule</span>
                                        <span id="d-time"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="space-y-1">
                                <label class="text-xs font-medium text-slate-500">Service</label>
                                <div class="flex items-center gap-2 px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm">
                                    <span class="material-symbols-outlined text-sm text-primary">medical_services</span>
                                    <span id="d-service"></span>
                                </div>
                            </div>
                            <div class="space-y-1">
                                <label class="text-xs font-medium text-slate-500">Assigned Doctor</label>
                                <div class="flex items-center gap-2 px-3 py-2 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm">
                                    <span class="material-symbols-outlined text-sm text-primary opacity-60">stethoscope</span>
                                    <span id="d-doctor-name">N/A</span>
                                </div>
                            </div>
                        </div>
                    </section>
                </div>
                <div id="detailFooter" class="hidden p-6 border-t border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900 flex items-center justify-end gap-2 flex-wrap">
                    <!-- Pending -->
                    <button id="d-btn-confirm"     class="hidden px-4 py-2 bg-primary text-white text-sm font-semibold rounded-xl shadow shadow-primary/20 hover:opacity-90 transition-all" onclick="confirmAppointment(currentDetailAppointmentId, this)">Confirm</button>
                    <button id="d-btn-reject"      class="hidden px-4 py-2 border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 text-sm font-semibold rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 transition-all" onclick="rejectAppointment(currentDetailAppointmentId, this)">Reject</button>
                    <!-- Confirmed -->
                    <button id="d-btn-checkin"     class="hidden px-4 py-2 bg-blue-500 text-white text-sm font-semibold rounded-xl hover:opacity-90 transition-all" onclick="checkInAppointment(currentDetailAppointmentId, this)">Check-in</button>
                    <button id="d-btn-reschedule"  class="hidden px-4 py-2 border border-indigo-200 dark:border-indigo-700 text-indigo-600 dark:text-indigo-400 text-sm font-semibold rounded-xl hover:bg-indigo-50 dark:hover:bg-indigo-900/20 transition-all" onclick="rescheduleAppointment(currentDetailAppointmentId)">Re-Schedule</button>
                    <button id="d-btn-cancel"      class="hidden px-4 py-2 border border-red-200 dark:border-red-700 text-red-500 dark:text-red-400 text-sm font-semibold rounded-xl hover:bg-red-50 dark:hover:bg-red-900/20 transition-all" onclick="cancelAppointment(currentDetailAppointmentId, this)">Cancel</button>
                    <!-- Waiting for Payment -->
                    <button id="d-btn-markpaid"    class="hidden px-4 py-2 bg-purple-500 text-white text-sm font-semibold rounded-xl hover:opacity-90 transition-all" onclick="markAsPaid(currentDetailAppointmentId, this)">Mark as Paid</button>
                    <!-- Done -->
                    <button id="d-btn-invoice"     class="hidden px-4 py-2 border border-green-200 dark:border-green-700 text-green-600 dark:text-green-400 text-sm font-semibold rounded-xl hover:bg-green-50 dark:hover:bg-green-900/20 transition-all" onclick="viewInvoice(currentDetailAppointmentId)">View Invoice</button>
                </div>
            </div>
        </div>

        <!-- Confirmation Popup -->
        <div id="confirmPopup" class="popup-overlay">
            <div class="popup-content">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-12 h-12 bg-orange-100 dark:bg-orange-900/30 rounded-full flex items-center justify-center">
                        <span class="material-symbols-outlined text-orange-600 dark:text-orange-400 text-2xl">warning</span>
                    </div>
                    <h3 class="text-lg font-bold text-slate-800 dark:text-white">Confirm doctor change?</h3>
                </div>
                <p class="text-slate-600 dark:text-slate-400 mb-6">
                    Please make sure the customer has been informed.
                </p>
                <div class="flex gap-3 justify-end">
                    <button 
                        onclick="closePopup()"
                        class="px-4 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all font-medium">
                        Cancel
                    </button>
                    <button 
                        onclick="confirmDoctorChange()"
                        class="px-4 py-2 rounded-lg bg-primary text-white hover:opacity-90 transition-all font-medium">
                        Confirm
                    </button>
                </div>
            </div>
        </div>

        <!-- Success Toast -->
        <div id="successToast" class="toast">
            <span class="material-symbols-outlined">check_circle</span>
            <span id="toastMessage">Doctor changed successfully!</span>
        </div>

        <!-- Cancel Confirmation Popup -->
        <div id="cancelPopup" class="popup-overlay">
            <div class="popup-content">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-12 h-12 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center">
                        <span class="material-symbols-outlined text-red-600 dark:text-red-400 text-2xl">warning</span>
                    </div>
                    <h3 class="text-lg font-bold text-slate-800 dark:text-white">Xác nhận hủy lịch hẹn</h3>
                </div>
                <p class="text-slate-600 dark:text-slate-400 mb-6">
                    Bạn có chắc chắn muốn hủy lịch hẹn này?
                </p>
                <div class="flex gap-3 justify-end">
                    <button 
                        onclick="closeCancelPopup()"
                        class="px-4 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all font-medium">
                        Hủy
                    </button>
                    <button 
                        onclick="confirmCancel()"
                        class="px-4 py-2 rounded-lg bg-red-500 text-white hover:opacity-90 transition-all font-medium">
                        Xác nhận hủy
                    </button>
                </div>
            </div>
        </div>

        <!-- Reject Confirmation Popup -->
        <div id="rejectPopup" class="popup-overlay">
            <div class="popup-content">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-12 h-12 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center">
                        <span class="material-symbols-outlined text-red-600 dark:text-red-400 text-2xl">warning</span>
                    </div>
                    <h3 class="text-lg font-bold text-slate-800 dark:text-white">Xác nhận từ chối lịch hẹn</h3>
                </div>
                <p class="text-slate-600 dark:text-slate-400 mb-6">
                    Bạn có chắc chắn muốn từ chối lịch hẹn này?
                </p>
                <div class="flex gap-3 justify-end">
                    <button 
                        onclick="closeRejectPopup()"
                        class="px-4 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all font-medium">
                        Hủy
                    </button>
                    <button 
                        onclick="confirmReject()"
                        class="px-4 py-2 rounded-lg bg-red-500 text-white hover:opacity-90 transition-all font-medium">
                        Xác nhận từ chối
                    </button>
                </div>
            </div>
        </div>
    <jsp:include page="book-appointment-modal.jsp"/>
    <jsp:include page="emergency-appointment-modal.jsp"/>
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
    </body></html>
