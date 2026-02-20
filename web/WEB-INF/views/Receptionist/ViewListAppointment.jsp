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
                grid-template-columns: 200px 150px 100px 150px 140px 1fr;
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
                        // Update the original vet id
                        currentSelectElement.setAttribute('data-original-vet', newVetId);
                        
                        // Show success toast
                        showToast(data.message);
                        
                        // Close popup
                        document.getElementById('confirmPopup').classList.remove('active');
                    } else {
                        alert('Lỗi: ' + data.message);
                        // Reset select
                        if (originalVetId) {
                            currentSelectElement.value = originalVetId;
                        }
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi đổi bác sỹ');
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
                
                // Auto hide after 3 seconds
                setTimeout(() => {
                    toast.classList.remove('active');
                }, 3000);
            }
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
                <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="#">
                    <span class="material-symbols-outlined">dashboard</span>
                    <span class="font-medium">Dashboard</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary text-white shadow-lg shadow-primary/20" href="#">
                    <span class="material-symbols-outlined">calendar_today</span>
                    <span class="font-medium">Schedule</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="#">
                    <span class="material-symbols-outlined">group</span>
                    <span class="font-medium">Patients</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="#">
                    <span class="material-symbols-outlined">folder</span>
                    <span class="font-medium">Records</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors" href="#">
                    <span class="material-symbols-outlined">settings</span>
                    <span class="font-medium">Settings</span>
                </a>
            </nav>
            <div class="p-4 border-t border-slate-200 dark:border-slate-800">
                <button class="w-full flex items-center justify-center gap-2 px-4 py-2 rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all text-slate-600 dark:text-slate-300" onclick="toggleDarkMode()">
                    <span class="material-symbols-outlined text-sm">dark_mode</span>
                    <span class="text-sm font-medium">Switch Mode</span>
                </button>
            </div>
        </aside>
        <main class="flex-1 flex flex-col min-h-screen">
            <header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-between px-8 sticky top-0 z-10">
                <div class="relative w-96">
                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xl">search</span>
                    <input class="w-full pl-10 pr-4 py-2 bg-slate-100 dark:bg-slate-800 border-none rounded-full text-sm focus:ring-2 focus:ring-primary/20 placeholder-slate-500 dark:placeholder-slate-400" placeholder="Search patients, owners or records..." type="text"/>
                </div>
                <div class="flex items-center gap-4">
                    <button class="w-10 h-10 flex items-center justify-center rounded-full bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 relative">
                        <span class="material-symbols-outlined">notifications</span>
                        <span class="absolute top-2 right-2 w-2 h-2 bg-primary rounded-full border-2 border-white dark:border-slate-900"></span>
                    </button>
                    <div class="flex items-center gap-3 pl-4 border-l border-slate-200 dark:border-slate-800">
                        <div class="text-right">
                            <p class="text-sm font-semibold text-slate-800 dark:text-white">Mr. ManhLD</p>
                            <p class="text-xs text-slate-500 dark:text-slate-400">Reception</p>
                        </div>
                        <img alt="Doctor Portrait" class="w-10 h-10 rounded-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDbM3tqKcwxIsoi5slYj6Kdkox1ysp7KyLPDUH241MYJyDiLgGIKJ9QfoxuwyxV7s__5dZyVili1E1pp7xhQFoF-V8TeZNJinkVaQLjApB2--PT016uBomLlR7k5ltY6L9ulS8rA6R9XrEDYfPiKRJAXNwpDWjOg_9KCYs2yO3_5n8QJ1kKKmQloVoxUx4kSNIbI7UBGluY2j-V8Oysu6VNuosQ1slgZWJMFmS4Rk4Ivn1Jv10A3YoUxgz9L5k5j8p-uVqiMJH_3EY"/>
                    </div>
                </div>
            </header>
            <div class="p-8 flex-1 overflow-y-auto custom-scrollbar">
                <div class="flex flex-col gap-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <h1 class="text-2xl font-bold text-slate-800 dark:text-white">Appointments</h1>
                            <p class="text-slate-500 dark:text-slate-400 text-sm">Manage and monitor today's scheduled visits</p>
                        </div>
                        <div class="flex gap-3">
                            <div class="flex items-center bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl px-3 py-2">
                                <span class="material-symbols-outlined text-slate-400 mr-2 text-xl">calendar_month</span>
                                <span class="text-sm font-medium text-slate-700 dark:text-slate-300">November 12, 2023</span>
                            </div>
                            <button class="bg-primary text-white px-5 py-2.5 rounded-xl font-semibold flex items-center gap-2 hover:opacity-90 transition-opacity">
                                <span class="material-symbols-outlined text-lg">add</span>
                                <span>New Appointment</span>
                            </button>
                        </div>
                    </div>
                    <div class="flex items-center justify-between border-b border-slate-200 dark:border-slate-800">
                        <div class="flex gap-8">
                            <a href="?status=All" class="pb-4 text-sm font-semibold ${statusFilter == 'All' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">All (${totalCount})</a>
                            <a href="?status=Pending" class="pb-4 text-sm font-medium ${statusFilter == 'Pending' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Pending (${pendingCount})</a>
                            <a href="?status=Checked-in" class="pb-4 text-sm font-medium ${statusFilter == 'Checked-in' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Checked-in (${checkedInCount})</a>
                            <a href="?status=In-Examination" class="pb-4 text-sm font-medium ${statusFilter == 'In-Examination' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">In Examination (${inExaminationCount})</a>
                            <a href="?status=Completed" class="pb-4 text-sm font-medium ${statusFilter == 'Completed' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Done (${doneCount})</a>
                            <a href="?status=Canceled" class="pb-4 text-sm font-medium ${statusFilter == 'Canceled' ? 'text-primary border-b-2 border-primary' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200'}">Canceled (${canceledCount})</a>
                        </div>
                        <div class="flex items-center gap-3 pb-2">
                            <button class="p-2 text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg">
                                <span class="material-symbols-outlined">tune</span>
                            </button>
                        </div>
                    </div>
                    <div class="px-4 appointment-grid text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">
                        <div>Pet Info</div>
                        <div>Owner</div>
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
                                    <p class="mt-4 text-slate-500 dark:text-slate-400">Không có appointment nào</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                        <c:forEach var="appointment" items="${list}">
                            <c:set var="status" value="${appointment.status}"/>
                            <c:set var="isCompleted" value="${status == 'Completed' || status == 'Done'}"/>
                            <c:set var="isPending" value="${status == 'Pending' || status == 'Scheduled'}"/>
                            <c:set var="isInExamination" value="${status == 'In-Examination' || status == 'In Progress'}"/>
                            <c:set var="isCheckedIn" value="${status == 'Checked-in' || status == 'Confirmed'}"/>
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
                                                <span class="inline-block px-1.5 py-0.5 bg-orange-100 dark:bg-orange-900/30 text-orange-600 dark:text-orange-400 text-[9px] font-bold rounded uppercase tracking-wider">In Examination</span>
                                            </c:when>
                                            <c:when test="${isCheckedIn}">
                                                <span class="inline-block px-1.5 py-0.5 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 text-[9px] font-bold rounded uppercase tracking-wider">Checked-in</span>
                                            </c:when>
                                            <c:when test="${isPending}">
                                                <span class="inline-block px-1.5 py-0.5 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-600 dark:text-yellow-400 text-[9px] font-bold rounded uppercase tracking-wider">Pending</span>
                                            </c:when>
                                            <c:when test="${isCompleted}">
                                                <span class="inline-block px-1.5 py-0.5 bg-green-100 dark:bg-green-900/20 text-green-600 dark:text-green-500/70 text-[9px] font-bold rounded uppercase tracking-wider">Done</span>
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
                                <div class="flex items-center gap-2 text-xs ${isCompleted ? 'text-slate-400 dark:text-slate-500' : 'text-slate-600 dark:text-slate-400'}">
                                    <span class="material-symbols-outlined text-base opacity-60">person</span>
                                    <span class="truncate">${not empty appointment.customer.user.fullName ? appointment.customer.user.fullName : 'Chưa có'}</span>
                                </div>
                                <div class="flex items-center gap-2 text-xs ${isCompleted ? 'text-slate-400 dark:text-slate-500' : 'text-slate-600 dark:text-slate-400'}">
                                    <span class="material-symbols-outlined text-base opacity-60 text-primary">schedule</span>
                                    <span>${appointment.formattedTime}</span>
                                </div>
                                <div class="flex items-center gap-2 text-xs ${isCompleted ? 'text-slate-400 dark:text-slate-500' : 'text-slate-600 dark:text-slate-400'}">
                                    <span class="material-symbols-outlined text-base opacity-60 text-primary">medical_services</span>
                                    <span class="truncate">${not empty appointment.service ? appointment.service : 'Chưa có'}</span>
                                </div>
                                <div>
                                    <select 
                                        class="w-full px-2 py-1 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-xs text-slate-600 dark:text-slate-300 focus:ring-2 focus:ring-primary/20 focus:border-primary"
                                        data-original-vet="${appointment.veterinarianId}"
                                        onchange="showConfirmPopup(${appointment.appointmentId}, this, this.value)">
                                        <option value="0" ${empty appointment.veterinarianName ? 'selected' : ''}>Chưa có</option>
                                        <c:forEach var="vet" items="${veterinarians}">
                                            <option value="${vet.userId}" ${vet.userId == appointment.veterinarianId ? 'selected' : ''}>
                                                ${vet.fullName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="flex items-center justify-end gap-2 pr-2">
                                    <c:if test="${isPending}">
                                        <button class="bg-primary text-white px-3 py-1.5 rounded-lg text-xs font-semibold hover:opacity-90 transition-all">Confirm</button>
                                        <button class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">Reject</button>
                                    </c:if>
                                    <button class="bg-primary/10 text-primary px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-primary hover:text-white transition-all">Details</button>
                                </div>
                            </div>
                        </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="flex items-center justify-between mt-4">
                        <p class="text-sm text-slate-500 dark:text-slate-400">Showing <span class="font-semibold text-slate-800 dark:text-white"><c:out value="${not empty list ? list.size() : 0}"/></span> of <span class="font-semibold text-slate-800 dark:text-white"><c:out value="${not empty list ? list.size() : 0}"/></span> appointments</p>
                        <div class="flex gap-2">
                            <button class="p-2 rounded-lg border border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-400 disabled:opacity-50" disabled="">
                                <span class="material-symbols-outlined">chevron_left</span>
                            </button>
                            <button class="w-10 h-10 flex items-center justify-center rounded-lg bg-primary text-white font-semibold">1</button>
                            <button class="w-10 h-10 flex items-center justify-center rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-400">2</button>
                            <button class="w-10 h-10 flex items-center justify-center rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-400">3</button>
                            <button class="p-2 rounded-lg border border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-400">
                                <span class="material-symbols-outlined">chevron_right</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        <div class="hidden fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-end" id="detailView">
            <div class="bg-white dark:bg-slate-900 w-full max-w-xl h-full shadow-2xl flex flex-col p-8">
                <div class="flex items-center justify-between mb-8">
                    <h2 class="text-xl font-bold text-slate-800 dark:text-white">Appointment Details</h2>
                    <button class="p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400" onclick="document.getElementById('detailView').classList.add('hidden')">
                        <span class="material-symbols-outlined">close</span>
                    </button>
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
                    <h3 class="text-lg font-bold text-slate-800 dark:text-white">Xác nhận đổi bác sỹ</h3>
                </div>
                <p class="text-slate-600 dark:text-slate-400 mb-6">
                    Bạn có chắc chắn muốn đổi bác sỹ? Hãy chắc chắn rằng đã thông báo cho khách hàng biết.
                </p>
                <div class="flex gap-3 justify-end">
                    <button 
                        onclick="closePopup()"
                        class="px-4 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all font-medium">
                        Hủy
                    </button>
                    <button 
                        onclick="confirmDoctorChange()"
                        class="px-4 py-2 rounded-lg bg-primary text-white hover:opacity-90 transition-all font-medium">
                        Xác nhận
                    </button>
                </div>
            </div>
        </div>

        <!-- Success Toast -->
        <div id="successToast" class="toast">
            <span class="material-symbols-outlined">check_circle</span>
            <span id="toastMessage">Đổi bác sỹ thành công!</span>
        </div>

    </body></html>
