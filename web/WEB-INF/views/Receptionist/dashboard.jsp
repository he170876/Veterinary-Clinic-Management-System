<%-- 
    Document   : Dashboard
    Created on : Feb 26, 2026
    Author     : admin
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipat - Receptionist Dashboard</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,typography,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <style type="text/tailwindcss">
        :root { --primary-color: #ff7b00; }
        body { font-family: 'Inter', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #e5e7eb; border-radius: 10px; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
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
                },
            },
        };
    </script>
    </head>
<body class="bg-background-light text-slate-900 min-h-screen flex">
    <!-- Left Sidebar -->
    <aside class="w-64 border-r border-slate-200 bg-white flex flex-col h-screen sticky top-0">
        <div class="p-6 flex items-center gap-3">
            <div class="w-10 h-10 bg-primary rounded-xl flex items-center justify-center">
                <span class="material-symbols-outlined text-white">pets</span>
            </div>
            <span class="text-2xl font-bold tracking-tight">Anipat</span>
        </div>
        
        <nav class="flex-1 px-4 mt-4 space-y-1">
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary text-white shadow-lg shadow-primary/20" href="#">
                <span class="material-symbols-outlined">dashboard</span>
                <span class="font-medium">Dashboard</span>
            </a>
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="${pageContext.request.contextPath}/Receptionist/ViewListAppointment">
                <span class="material-symbols-outlined">calendar_today</span>
                <span class="font-medium">Schedule</span>
            </a>
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="#">
                <span class="material-symbols-outlined">folder</span>
                <span class="font-medium">Records</span>
            </a>
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="#">
                <span class="material-symbols-outlined">settings</span>
                <span class="font-medium">Settings</span>
            </a>
        </nav>

        <!-- Clinic Status Widget -->
        <div class="p-4 m-4 bg-orange-50 rounded-xl border border-orange-100">
            <p class="text-xs font-bold text-primary uppercase tracking-wider">Clinic Status</p>
            <div class="flex items-center gap-2 mt-2">
                <span class="w-2 h-2 bg-green-500 rounded-full"></span>
                <span class="text-sm font-semibold text-slate-700">Open & Operating</span>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col min-h-screen">
        <!-- Top Bar -->
        <header class="h-16 border-b border-slate-200 bg-white flex items-center justify-between px-8 sticky top-0 z-10">
            <div class="relative w-96">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xl">search</span>
                <input class="w-full pl-10 pr-4 py-2 bg-slate-100 border-none rounded-full text-sm focus:ring-2 focus:ring-primary/20 placeholder-slate-500" placeholder="Search patients, owners or records..." type="text"/>
            </div>
            <div class="flex items-center gap-4">
                <button class="w-10 h-10 flex items-center justify-center rounded-full bg-slate-100 text-slate-600 relative">
                    <span class="material-symbols-outlined">notifications</span>
                    <span class="absolute top-2 right-2 w-2 h-2 bg-primary rounded-full border-2 border-white"></span>
                </button>
                <div class="flex items-center gap-3 pl-4 border-l border-slate-200">
                    <div class="text-right">
                        <p class="text-sm font-semibold">${not empty currentUser ? currentUser.fullName : 'User'}</p>
                        <p class="text-xs text-slate-500"><c:out value="${not empty sessionScope.currentUser.role ? sessionScope.currentUser.role.roleName : 'User'}"/></p>
                    </div>
                    <img alt="Profile" class="w-10 h-10 rounded-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDbM3tqKcwxIsoi5slYj6Kdkox1ysp7KyLPDUH241MYJyDiLgGIKJ9QfoxuwyxV7s__5dZyVili1E1pp7xhQFoF-V8TeZNJinkVaQLjApB2--PT016uBomLlR7k5ltY6L9ulS8rA6R9XrEDYfPiKRJAXNwpDWjOg_9KCYs2yO3_5n8QJ1kKKmQloVoxUx4kSNIbI7UBGluY2j-V8Oysu6VNuosQ1slgZWJMFmS4Rk4Ivn1Jv10A3YoUxgz9L5k5j8p-uVqiMJH_3EY"/>
                </div>
            </div>
        </header>

        <!-- Dashboard Content -->
        <div class="p-8 flex-1 overflow-y-auto custom-scrollbar">
            <!-- Header -->
            <div class="flex items-center justify-between mb-8">
                <div>
                    <h1 class="text-2xl font-bold text-slate-800">Dashboard</h1>
                    <p class="text-slate-500 text-sm mt-1">Welcome back! Here's what's happening at Anipat today.</p>
                </div>
                <div class="flex gap-3">
                    <button class="bg-primary text-white px-5 py-2.5 rounded-xl font-semibold flex items-center gap-2 hover:opacity-90 transition-opacity">
                        <span class="material-symbols-outlined text-lg">add</span>
                        <span>New Appointment</span>
                    </button>
                    <button class="bg-red-500 text-white px-5 py-2.5 rounded-xl font-semibold flex items-center gap-2 hover:opacity-90 transition-opacity">
                        <span class="material-symbols-outlined text-lg">emergency</span>
                        <span>Emergency</span>
                    </button>
                </div>
            </div>

            <!-- Stats Cards -->
            <div class="grid grid-cols-3 gap-6 mb-8">
                <!-- Total Appointments -->
                <div class="bg-white rounded-2xl p-6 border-l-4 border-orange-400 shadow-sm">
                    <div class="flex items-start justify-between">
                        <div>
                            <p class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Total Appointments</p>
                            <p class="text-4xl font-bold text-slate-800 mt-2">${totalAppointments}</p>
                            <p class="text-sm text-green-600 mt-2 font-medium">+12% from yesterday</p>
                        </div>
                        <div class="w-12 h-12 bg-orange-100 rounded-xl flex items-center justify-center">
                            <span class="material-symbols-outlined text-orange-500 text-2xl">calendar_month</span>
                        </div>
                    </div>
                </div>

                <!-- Normal Appointments -->
                <div class="bg-white rounded-2xl p-6 border-l-4 border-primary shadow-sm">
                    <div class="flex items-start justify-between">
                        <div>
                            <p class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Normal Appointments</p>
                            <p class="text-4xl font-bold text-slate-800 mt-2">${normalAppointments}</p>
                            <p class="text-sm text-slate-500 mt-2">
                                <c:choose>
                                    <c:when test="${totalAppointments > 0}">
                                        <fmt:formatNumber value="${(normalAppointments * 100) / totalAppointments}" pattern="#"/>% of total volume
                                    </c:when>
                                    <c:otherwise>0% of total volume</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div class="w-12 h-12 bg-orange-100 rounded-xl flex items-center justify-center">
                            <span class="material-symbols-outlined text-primary text-2xl">add_circle</span>
                        </div>
                    </div>
                </div>

                <!-- Emergency Cases -->
                <div class="bg-white rounded-2xl p-6 border-l-4 border-red-500 shadow-sm">
                    <div class="flex items-start justify-between">
                        <div>
                            <p class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Emergency Cases</p>
                            <p class="text-4xl font-bold text-slate-800 mt-2">${emergencyCases}</p>
                            <p class="text-sm text-slate-500 mt-2">Active: ${emergencyActive} | Resolved: ${emergencyResolved}</p>
                        </div>
                        <div class="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center">
                            <span class="material-symbols-outlined text-red-500 text-2xl">warning</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Appointments Table -->
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-6 border-b border-slate-100 flex items-center justify-between">
                    <h2 class="text-lg font-bold text-slate-800">Recent Appointments & Live Status</h2>
                    <a href="${pageContext.request.contextPath}/Receptionist/ViewListAppointment" class="text-primary text-sm font-semibold hover:underline">View All Schedule</a>
                </div>
                
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-slate-50 border-b border-slate-100">
                            <tr>
                                <th class="text-left text-xs font-bold text-slate-400 uppercase tracking-wider px-6 py-4">Pet Info</th>
                                <th class="text-left text-xs font-bold text-slate-400 uppercase tracking-wider px-6 py-4">Owner</th>
                                <th class="text-left text-xs font-bold text-slate-400 uppercase tracking-wider px-6 py-4">Time</th>
                                <th class="text-left text-xs font-bold text-slate-400 uppercase tracking-wider px-6 py-4">Service</th>
                                <th class="text-left text-xs font-bold text-slate-400 uppercase tracking-wider px-6 py-4">Doctor</th>
                                <th class="text-left text-xs font-bold text-slate-400 uppercase tracking-wider px-6 py-4">Status</th>
                                <th class="text-right text-xs font-bold text-slate-400 uppercase tracking-wider px-6 py-4">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <c:choose>
                                <c:when test="${empty recentAppointments}">
                                    <tr>
                                        <td colspan="7" class="px-6 py-12 text-center text-slate-400">
                                            <span class="material-symbols-outlined text-6xl text-slate-300">event_busy</span>
                                            <p class="mt-4">No appointments today</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="apt" items="${recentAppointments}">
                                        <c:set var="status" value="${apt.status}"/>
                                        <c:set var="isCompleted" value="${status == 'Completed' || status == 'Done'}"/>
                                        <c:set var="isPending" value="${status == 'Pending' || status == 'Scheduled'}"/>
                                        <c:set var="isConfirmed" value="${status == 'Confirmed'}"/>
                                        <c:set var="isInExam" value="${status == 'In-Examination' || status == 'In Progress'}"/>
                                        <c:set var="isCheckedIn" value="${status == 'Checked-in'}"/>
                                        <c:set var="isCanceled" value="${status == 'Canceled' || status == 'Cancelled'}"/>
                                        <tr class="hover:bg-slate-50 transition-colors">
                                            <td class="px-6 py-4">
                                                <div class="flex items-center gap-3">
                                                    <c:choose>
                                                        <c:when test="${not empty apt.pet.photoURL}">
                                                            <img alt="Pet" class="w-10 h-10 rounded-lg object-cover" src="${apt.pet.photoURL}"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="w-10 h-10 rounded-lg bg-slate-200 flex items-center justify-center">
                                                                <span class="material-symbols-outlined text-slate-400">pets</span>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div>
                                                        <p class="font-semibold text-slate-800">${apt.pet.name}</p>
                                                        <p class="text-xs text-slate-500">${apt.pet.breed}</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4">
                                                <p class="text-sm text-slate-700">${apt.customer.user.fullName}</p>
                                            </td>
                                            <td class="px-6 py-4">
                                                <div class="flex items-center gap-2">
                                                    <span class="material-symbols-outlined text-primary text-base">schedule</span>
                                                    <span class="text-sm text-slate-600">${apt.formattedTime}</span>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4">
                                                <span class="px-3 py-1 bg-slate-100 text-slate-600 text-xs font-medium rounded-full">
                                                    ${not empty apt.service ? apt.service : 'N/A'}
                                                </span>
                                            </td>
                                            <td class="px-6 py-4">
                                                <p class="text-sm text-slate-600">${not empty apt.veterinarianName ? apt.veterinarianName : 'Not assigned'}</p>
                                            </td>
                                            <td class="px-6 py-4">
                                                <c:choose>
                                                    <c:when test="${isInExam}">
                                                        <span class="px-3 py-1 bg-green-100 text-green-600 text-xs font-bold rounded-full">In Treatment</span>
                                                    </c:when>
                                                    <c:when test="${isCheckedIn}">
                                                        <span class="px-3 py-1 bg-blue-100 text-blue-600 text-xs font-bold rounded-full">Checked-in</span>
                                                    </c:when>
                                                    <c:when test="${isPending}">
                                                        <span class="px-3 py-1 bg-yellow-100 text-yellow-600 text-xs font-bold rounded-full">Pending</span>
                                                    </c:when>
                                                    <c:when test="${isConfirmed}">
                                                        <span class="px-3 py-1 bg-emerald-100 text-emerald-600 text-xs font-bold rounded-full">Confirmed</span>
                                                    </c:when>
                                                    <c:when test="${isCompleted}">
                                                        <span class="px-3 py-1 bg-slate-100 text-slate-500 text-xs font-bold rounded-full">Completed</span>
                                                    </c:when>
                                                    <c:when test="${isCanceled}">
                                                        <span class="px-3 py-1 bg-red-100 text-red-600 text-xs font-bold rounded-full">Canceled</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="px-3 py-1 bg-slate-100 text-slate-600 text-xs font-bold rounded-full">${status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="px-6 py-4 text-right">
                                                <button onclick="openDetail(${apt.appointmentId})" class="px-3 py-1.5 bg-primary/10 text-primary text-xs font-semibold rounded-lg hover:bg-primary hover:text-white transition-all">
                                                    Details
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <!-- Detail Panel (hidden by default) -->
    <div class="hidden fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-end" id="detailView">
        <div class="bg-white w-full max-w-xl h-full shadow-2xl flex flex-col relative">
            <div class="flex items-center justify-between p-6 border-b border-slate-200">
                <h2 class="text-xl font-bold text-slate-800">Appointment Details</h2>
                <button class="p-2 rounded-full hover:bg-slate-100 text-slate-400" onclick="closeDetail()">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            
            <div id="detailLoading" class="flex-1 flex items-center justify-center">
                <div class="text-center">
                    <span class="material-symbols-outlined text-4xl text-slate-300 animate-spin">progress_activity</span>
                    <p class="mt-2 text-sm text-slate-400">Loading...</p>
                </div>
            </div>
            
            <div id="detailContent" class="hidden flex-1 overflow-y-auto custom-scrollbar p-6 space-y-6">
                <section>
                    <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Pet Profile</h3>
                    <div class="flex items-start gap-5">
                        <img id="d-pet-photo" alt="Pet" class="w-24 h-24 rounded-2xl object-cover ring-4 ring-primary/5" src=""/>
                        <div id="d-pet-no-photo" class="hidden w-24 h-24 rounded-2xl bg-slate-200 flex items-center justify-center ring-4 ring-primary/5">
                            <span class="material-symbols-outlined text-slate-400 text-4xl">pets</span>
                        </div>
                        <div class="space-y-3 flex-1">
                            <div class="flex items-center justify-between">
                                <h4 id="d-pet-name" class="text-2xl font-bold text-slate-800"></h4>
                                <span id="d-status-badge" class="px-3 py-1 bg-primary/10 text-primary text-xs font-bold rounded-full"></span>
                            </div>
                            <div class="grid grid-cols-2 gap-y-2 text-sm">
                                <div><p class="text-slate-400">Species/Breed</p><p id="d-species-breed" class="font-medium"></p></div>
                                <div><p class="text-slate-400">Age</p><p id="d-age" class="font-medium"></p></div>
                                <div><p class="text-slate-400">Gender</p><p id="d-gender" class="font-medium"></p></div>
                                <div><p class="text-slate-400">Weight</p><p id="d-weight" class="font-medium"></p></div>
                            </div>
                        </div>
                    </div>
                </section>
                
                <section class="bg-slate-50 p-5 rounded-2xl border border-slate-100">
                    <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Owner Information</h3>
                    <div class="grid grid-cols-2 gap-4 text-sm">
                        <div class="flex gap-3">
                            <span class="material-symbols-outlined text-primary/60">person</span>
                            <div><p class="text-slate-400 text-xs">Name</p><p id="d-owner-name" class="font-semibold"></p></div>
                        </div>
                        <div class="flex gap-3">
                            <span class="material-symbols-outlined text-primary/60">phone</span>
                            <div><p class="text-slate-400 text-xs">Phone</p><p id="d-owner-phone" class="font-semibold"></p></div>
                        </div>
                        <div class="flex gap-3">
                            <span class="material-symbols-outlined text-primary/60">mail</span>
                            <div><p class="text-slate-400 text-xs">Email</p><p id="d-owner-email" class="font-semibold"></p></div>
                        </div>
                        <div class="flex gap-3">
                            <span class="material-symbols-outlined text-primary/60">location_on</span>
                            <div><p class="text-slate-400 text-xs">Address</p><p id="d-owner-address" class="font-semibold"></p></div>
                        </div>
                    </div>
                </section>
                
                <section>
                    <h3 class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Appointment Data</h3>
                    <div class="space-y-4">
                        <div class="grid grid-cols-2 gap-4">
                            <div class="space-y-1">
                                <label class="text-xs font-medium text-slate-500">Date</label>
                                <div class="flex items-center gap-2 px-3 py-2 bg-white border border-slate-200 rounded-xl text-sm">
                                    <span class="material-symbols-outlined text-sm text-primary">calendar_today</span>
                                    <span id="d-date"></span>
                                </div>
                            </div>
                            <div class="space-y-1">
                                <label class="text-xs font-medium text-slate-500">Time</label>
                                <div class="flex items-center gap-2 px-3 py-2 bg-white border border-slate-200 rounded-xl text-sm">
                                    <span class="material-symbols-outlined text-sm text-primary">schedule</span>
                                    <span id="d-time"></span>
                                </div>
                            </div>
                        </div>
                        <div class="space-y-1">
                            <label class="text-xs font-medium text-slate-500">Service</label>
                            <div class="flex items-center gap-2 px-3 py-2 bg-white border border-slate-200 rounded-xl text-sm">
                                <span class="material-symbols-outlined text-sm text-primary">medical_services</span>
                                <span id="d-service"></span>
                            </div>
                        </div>
                        <div class="space-y-1">
                            <label class="text-xs font-medium text-slate-500">Assigned Doctor</label>
                            <div class="flex items-center gap-2">
                                <span class="material-symbols-outlined text-sm text-primary opacity-60">stethoscope</span>
                                <select id="d-doctor-select" data-appointment-id="" data-original-vet="" 
                                    class="flex-1 px-3 py-2 bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-primary/20"
                                    onchange="showDoctorChangeConfirm(this)">
                                    <option value="0">Chưa có</option>
                                    <!-- Veterinarians loaded from server -->
                                    <c:forEach var="vet" items="${veterinarians}">
                                        <option value="${vet.userId}"><c:out value="${vet.fullName}"/></option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
            
            <div id="detailFooter" class="hidden p-6 border-t border-slate-200 bg-slate-50 flex items-center justify-end gap-2">
                <button id="d-btn-confirm" class="hidden px-4 py-2 bg-primary text-white text-sm font-semibold rounded-xl">Confirm</button>
                <button id="d-btn-reject" class="hidden px-4 py-2 border border-slate-200 text-slate-600 text-sm font-semibold rounded-xl">Reject</button>
                <button id="d-btn-checkin" class="hidden px-4 py-2 bg-blue-500 text-white text-sm font-semibold rounded-xl">Check-in</button>
                <button id="d-btn-cancel" class="hidden px-4 py-2 border border-red-200 text-red-500 text-sm font-semibold rounded-xl">Cancel</button>
                <button id="d-btn-invoice" class="hidden px-4 py-2 border border-green-200 text-green-600 text-sm font-semibold rounded-xl">View Invoice</button>
            </div>
        </div>
    </div>

    <script>
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
                    alert('Error loading details');
                    panel.classList.add('hidden');
                });
        }

        function populateDetail(d) {
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
            
            // Populate doctor select
            const doctorSelect = document.getElementById('d-doctor-select');
            doctorSelect.setAttribute('data-appointment-id', d.appointmentId);
            doctorSelect.setAttribute('data-original-vet', d.veterinarianId || 0);
            doctorSelect.value = d.veterinarianId && d.veterinarianId > 0 ? d.veterinarianId : "0";
        }

        function closeDetail() {
            document.getElementById('detailView').classList.add('hidden');
        }
        
        let currentDoctorAppointmentId = null;
        let currentDoctorSelect = null;
        let originalDoctorId = null;
        
        function showDoctorChangeConfirm(selectElement) { const newVetId = parseInt(selectElement.value);
            originalDoctorId = parseInt(selectElement.getAttribute('data-original-vet')) || 0;
            
            // If same value, do nothing
            if (newVetId === originalDoctorId) return;
            
            currentDoctorAppointmentId = selectElement.getAttribute('data-appointment-id');
            currentDoctorSelect = selectElement;
            
            // Show confirmation popup
            document.getElementById('confirmPopup').classList.add('active');
        }
        
        function closeDoctorPopup() {
            // Reset select to original value
            if (currentDoctorSelect && originalDoctorId !== null) {
                currentDoctorSelect.value = originalDoctorId > 0 ? originalDoctorId : "0";
            }
            document.getElementById('confirmPopup').classList.remove('active');
            currentDoctorAppointmentId = null;
            currentDoctorSelect = null;
            originalDoctorId = null;
        }
        
        function confirmDoctorChange() {
            if (!currentDoctorAppointmentId || !currentDoctorSelect) return;
            
            const newVetId = parseInt(currentDoctorSelect.value);
            
            fetch('UpdateAppointmentDoctor', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'appointmentId=' + currentDoctorAppointmentId + '&veterinarianId=' + newVetId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update the original vet id
                    currentDoctorSelect.setAttribute('data-original-vet', newVetId);
                    
                    // Show success toast
                    showToast(data.message);
                    
                    // Close popup
                    document.getElementById('confirmPopup').classList.remove('active');
                } else {
                    alert('Lỗi: ' + data.message);
                    // Reset select
                    if (originalDoctorId !== null) {
                        currentDoctorSelect.value = originalDoctorId > 0 ? originalDoctorId : "0";
                    }
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Có lỗi xảy ra khi đổi bác sỹ');
                // Reset select
                if (originalDoctorId !== null) {
                    currentDoctorSelect.value = originalDoctorId > 0 ? originalDoctorId : "0";
                }
            })
            .finally(() => {
                currentDoctorAppointmentId = null;
                currentDoctorSelect = null;
                originalDoctorId = null;
            });
        }
        
        function showToast(message) {
            const toast = document.getElementById('successToast');
            const toastMessage = document.getElementById('toastMessage');
            toastMessage.textContent = message;
            toast.classList.add('active');
            
            setTimeout(() => {
                toast.classList.remove('active');
            }, 3000);
        }
    </script>

    <!-- Confirmation Popup -->
    <div id="confirmPopup" class="hidden fixed inset-0 bg-black/50 backdrop-blur-sm z-[1000] flex items-center justify-center">
        <div class="bg-white rounded-2xl p-6 max-w-sm w-full mx-4 shadow-2xl">
            <div class="flex items-center gap-4 mb-4">
                <div class="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center">
                    <span class="material-symbols-outlined text-orange-600 text-2xl">warning</span>
                </div>
                <h3 class="text-lg font-bold text-slate-800">Xác nhận đổi bác sỹ</h3>
            </div>
            <p class="text-slate-600 mb-6">Bạn có chắc chắn muốn đổi bác sỹ? Hãy chắc chắn rằng đã thông báo cho khách hàng biết.</p>
            <div class="flex gap-3 justify-end">
                <button onclick="closeDoctorPopup()" class="px-4 py-2 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 font-medium transition-all">Hủy</button>
                <button onclick="confirmDoctorChange()" class="px-4 py-2 rounded-lg bg-primary text-white hover:opacity-90 font-medium transition-all">Xác nhận</button>
            </div>
        </div>
    </div>

    <!-- Success Toast -->
    <div id="successToast" class="hidden fixed top-6 right-6 bg-green-500 text-white px-6 py-3 rounded-xl shadow-lg flex items-center gap-2 z-[2000] animate-slide-in">
        <span class="material-symbols-outlined">check_circle</span>
        <span id="toastMessage">Thành công!</span>
    </div>

    <style>
        @keyframes slide-in {
            from { transform: translateX(400px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        .animate-slide-in { animation: slide-in 0.3s ease-out; }
    </style>
    </body>
</html>




