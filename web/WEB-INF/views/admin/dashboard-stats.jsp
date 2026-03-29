<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html class="light" lang="en"><head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipat Admin Analytics Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f97a1f",
                        "background-light": "#f8f7f5",
                        "background-dark": "#23170f",
                    },
                    fontFamily: {
                        "display": ["Manrope", "sans-serif"]
                    },
                    borderRadius: {
                        "DEFAULT": "1rem",
                        "lg": "2rem",
                        "xl": "3rem",
                        "full": "9999px"
                    },
                },
            },
        }
    </script>
    <style>
        body {
            font-family: 'Manrope', sans-serif;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .active-nav {
            background-color: #f97a1f;
            color: white;
        }
        .sidebar-item:hover:not(.active-nav) {
            background-color: rgba(249, 122, 31, 0.1);
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#1c130d] font-display">
    <div class="flex h-screen overflow-hidden">
        <aside class="w-72 bg-white dark:bg-[#2d1e14] border-r border-[#e9d9ce] flex flex-col h-full">
            <div class="p-6 flex flex-col h-full">
                <div class="space-y-8">
                    <div class="flex items-center gap-3 mb-8">
                        <div class="size-10 rounded-full bg-primary flex items-center justify-center text-white">
                            <span class="material-symbols-outlined">pets</span>
                        </div>
                        <div class="flex flex-col">
                            <h1 class="text-lg font-bold leading-tight">Anipat</h1>
                            <p class="text-[#a17145] text-xs font-medium">Veterinary Clinic</p>
                        </div>
                    </div>
                    <nav class="flex flex-col gap-2">
                        <a class="flex items-center gap-3 px-3 py-2.5 sidebar-item-active text-primary" href="#">
                            <span class="material-symbols-outlined">dashboard</span>
                            <span class="text-sm font-bold">Dashboard</span>
                        </a>

                        <a class="flex items-center gap-3 px-3 py-2.5  text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/user-management">
                            <span class="material-symbols-outlined" >group</span>
                            <span class="text-sm font-semibold">User Management</span>
                        </a>
                        <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/services">
                            <span class="material-symbols-outlined" >medical_services</span>
                            <span class="text-sm font-semibold">Services</span>
                        </a>
                        <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/content">
                            <span class="material-symbols-outlined" >edit_document</span>
                            <span class="text-sm font-semibold">Content</span>
                        </a>
                        <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/images">
                            <span class="material-symbols-outlined">image</span>
                            <span class="text-sm font-semibold">Images</span>
                        </a>

                    </nav>
                </div>
            </div>
        </aside>
        <main class="flex-1 flex flex-col overflow-y-auto">
            <header class="sticky top-0 z-10 bg-white/80 dark:bg-background-dark/80 backdrop-blur-md border-b border-[#f4ece6] px-8 py-4 flex items-center justify-between">
                <div class="flex items-center gap-6 flex-1">
                    <h2 class="text-[#1c130d] dark:text-white text-xl font-bold whitespace-nowrap">Owner Overview</h2>
                    <div class="relative w-full max-w-md">
                        <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-[#9e6b47]">search</span>
                        <input class="w-full bg-[#f4ece6] border-none rounded-full pl-12 pr-4 py-2.5 text-sm focus:ring-2 focus:ring-primary/50 placeholder:text-[#9e6b47]" placeholder="Search pets, owners or records..." type="text"/>
                    </div>
                </div>
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/logout"
                       class="px-4 py-2 rounded-xl bg-dark-accent text-white text-sm font-bold hover:opacity-90 transition-all flex items-center gap-2">
                        <span class="material-symbols-outlined text-[18px]">logout</span>
                        <span>Logout</span>
                    </a>
                    <button class="size-10 rounded-full border border-[#eadbcd] dark:border-gray-800 flex items-center justify-center hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-colors relative">
                        <span class="material-symbols-outlined text-xl text-[#a17145]">notifications</span>
                    </button>
                    <div class="h-8 w-px bg-[#eadbcd] dark:border-gray-800 mx-1"></div>
                    <div class="relative">
                        <button type="button" id="admin-profile-toggle"
                                class="flex items-center gap-2 pl-2 pr-1 py-1 rounded-full hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-all border border-transparent hover:border-[#eadbcd] dark:hover:border-gray-700">
                        <span class="size-8 rounded-full bg-cover bg-center border border-white dark:border-gray-700 shadow-sm" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuAYUCJ5rFUlr81fchNgluov8XqF0omAMzcfRI6nmGwV8EbFQxDeqFbQ2PwK2MKwmUSKZit9vi8bIYew6GamGqmcFBwcGpAYU-bsg_UlBH_Iyq3v1Tw3iOUpKfVh7-O0zJ8tNEHwIneejfmZjDaWpXXIebkX_Wngol2e-sAKBsguK_Eoh0Ei9Um081oSK5oCR6I8GRroVTLARRcp1703Dl_8kP8qgtUq9GiIWG-D7MNPw2LA8xy1lh2GUpxleoam1XNeO1icd6fRSUI');"></span>
                        <span class="material-symbols-outlined text-[#a17145]">expand_more</span>
                        </button>
                        <div id="admin-profile-menu"
                             class="absolute right-0 mt-2 w-56 origin-top-right rounded-xl bg-white shadow-lg border border-slate-200 z-50"
                             style="display:none;">
                            <a href="${pageContext.request.contextPath}/owner/profile"
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
            </header>
            <div class="p-8 space-y-8">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <div class="bg-white dark:bg-[#2d1e14] p-6 rounded-xl border border-[#e9d9ce] shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start mb-2">
                            <div class="p-2 bg-blue-50 text-blue-600 rounded-lg">
                                <span class="material-symbols-outlined">group</span>
                            </div>
                        </div>
                        <p class="text-[#9e6b47] text-sm font-semibold uppercase tracking-wider">Total Users</p>
                        <h3 class="text-3xl font-extrabold text-[#1c130d] dark:text-white">${totalUsers}</h3>
                    </div>
                    <div class="bg-white dark:bg-[#2d1e14] p-6 rounded-xl border border-[#e9d9ce] shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start mb-2">
                            <div class="p-2 bg-orange-50 text-primary rounded-lg">
                                <span class="material-symbols-outlined">event_available</span>
                            </div>
                        </div>
                        <p class="text-[#9e6b47] text-sm font-semibold uppercase tracking-wider">Total Appointments</p>
                        <h3 class="text-3xl font-extrabold text-[#1c130d] dark:text-white">${totalAppointments}</h3>
                    </div>
                    <div class="bg-white dark:bg-[#2d1e14] p-6 rounded-xl border border-[#e9d9ce] shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start mb-2">
                            <div class="p-2 bg-purple-50 text-purple-600 rounded-lg">
                                <span class="material-symbols-outlined">pets</span>
                            </div>
                        </div>
                        <p class="text-[#9e6b47] text-sm font-semibold uppercase tracking-wider">Total Patients</p>
                        <h3 class="text-3xl font-extrabold text-[#1c130d] dark:text-white">${totalPatients}</h3>
                    </div>
                    <div class="bg-white dark:bg-[#2d1e14] p-6 rounded-xl border border-[#e9d9ce] shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start mb-2">
                            <div class="p-2 bg-teal-50 text-teal-600 rounded-lg">
                                <span class="material-symbols-outlined">app_registration</span>
                            </div>
                        </div>
                        <p class="text-[#9e6b47] text-sm font-semibold uppercase tracking-wider">New Registrations</p>
                        <h3 class="text-3xl font-extrabold text-[#1c130d] dark:text-white">${newRegistrations7Days}</h3>
                    </div>
                </div>
                <div class="bg-white dark:bg-[#2d1e14] rounded-xl border border-[#e9d9ce] shadow-sm overflow-hidden">
                    <div class="p-6 border-b border-[#f4ece6] flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                        <div>
                            <h2 class="text-xl font-bold text-[#1c130d] dark:text-white">Appointment Overview</h2>
                            <p class="text-sm text-[#9e6b47]">Monitor and manage upcoming pet visits</p>
                        </div>
                        <div class="inline-flex p-1 bg-[#f4ece6] rounded-full">
                            <a href="${pageContext.request.contextPath}/owner/dashboard?appScope=today&appPage=1"
                            class="px-6 py-2 rounded-full text-sm font-bold transition-all ${appScope eq 'today' ? 'bg-white text-primary shadow-sm' : 'text-[#9e6b47] hover:text-[#1c130d]'}">
                            Today
                        </a>
                        <a href="${pageContext.request.contextPath}/owner/dashboard?appScope=week&appPage=1"
                        class="px-6 py-2 rounded-full text-sm font-bold transition-all ${appScope eq 'week' ? 'bg-white text-primary shadow-sm' : 'text-[#9e6b47] hover:text-[#1c130d]'}">
                        This Week
                    </a>
                    <a href="${pageContext.request.contextPath}/owner/dashboard?appScope=month&appPage=1"
                    class="px-6 py-2 rounded-full text-sm font-bold transition-all ${appScope eq 'month' ? 'bg-white text-primary shadow-sm' : 'text-[#9e6b47] hover:text-[#1c130d]'}">
                    This Month
                </a>
            </div>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-left">
                <thead class="bg-[#fcfaf8] dark:bg-[#3d2c1f] text-[#9e6b47] text-xs font-bold uppercase tracking-widest border-b border-[#f4ece6]">
                    <tr>
                        <th class="px-6 py-4">Pet Name</th>
                        <th class="px-6 py-4">Owner</th>
                        <th class="px-6 py-4">Date &amp; Time</th>
                        <th class="px-6 py-4">Service Type</th>
                        <th class="px-6 py-4">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-[#f4ece6]">
                    <c:forEach var="appointment" items="${appointments}">
                        <tr class="hover:bg-[#fcfaf8] transition-colors">
                            <td class="px-6 py-5">
                                <div class="flex items-center gap-3">
                                    <c:url var="petPhotoSrc" value="${not empty appointment.pet.photoUrl ? appointment.pet.photoUrl : '/anipat-master/img/default-pet.png'}"/>
                                    <img alt="Pet photo" class="w-10 h-10 rounded-full object-cover" src="${petPhotoSrc}"/>
                                    <div>
                                        <p class="text-sm font-bold text-[#1c130d] dark:text-white">${appointment.pet.name}</p>
                                        <p class="text-xs text-[#9e6b47]">${appointment.pet.breed} •
                                            <c:choose>
                                                <c:when test="${appointment.pet.birthDate != null}">
                                                    <c:set var="age" value="${pageContext.request.time.year - appointment.pet.birthDate.year}"/>
                                                    ${age}yr
                                                </c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-5 text-sm font-medium">${appointment.customer.name}</td>
                                <td class="px-6 py-5">
                                    <div class="flex flex-col">
                                        <span class="text-sm font-bold text-[#1c130d] dark:text-white">${appointment.formattedDate}</span>
                                        <span class="text-xs text-[#9e6b47]">${appointment.formattedTime}</span>
                                    </div>
                                </td>
                                <td class="px-6 py-5">
                                    <span class="text-xs font-bold px-3 py-1 bg-blue-50 text-blue-600 rounded-full inline-block max-w-[220px] truncate align-middle" title="${appointment.service}">${appointment.service}</span>
                                </td>
                                <td class="px-6 py-5">
                                    <c:choose>
                                        <c:when test="${appointment.status eq 'Confirmed'}">
                                            <div class="flex items-center gap-1.5 text-green-600 font-bold text-xs">
                                                <span class="w-2 h-2 rounded-full bg-green-600"></span>
                                                Confirmed
                                            </div>
                                        </c:when>
                                        <c:when test="${appointment.status eq 'Pending'}">
                                            <div class="flex items-center gap-1.5 text-primary font-bold text-xs">
                                                <span class="w-2 h-2 rounded-full bg-primary"></span>
                                                Pending
                                            </div>
                                        </c:when>
                                        <c:when test="${appointment.status eq 'Rescheduled'}">
                                            <div class="flex items-center gap-1.5 text-gray-500 font-bold text-xs">
                                                <span class="w-2 h-2 rounded-full bg-gray-400"></span>
                                                Rescheduled
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="flex items-center gap-1.5 text-[#9e6b47] font-bold text-xs">
                                                <span class="w-2 h-2 rounded-full bg-[#9e6b47]"></span>
                                                ${appointment.status}
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <div class="p-4 bg-[#fcfaf8] dark:bg-[#3d2c1f] flex items-center justify-between">
                <p class="text-xs text-[#9e6b47] font-medium">
                    Showing
                    <c:out value="${appointments.size()}"/> of <c:out value="${appTotal}"/> appointments
                    </p>
                    <div class="flex gap-2">
                        <form method="get" action="${pageContext.request.contextPath}/owner/dashboard" style="display:inline;">
                            <input type="hidden" name="appScope" value="${appScope}"/>
                            <input type="hidden" name="appPage" value="${appPage - 1}"/>
                            <button class="p-1 rounded bg-white border border-[#e9d9ce] text-[#1c130d]" ${appPage == 1 ? 'disabled' : ''}>
                                <span class="material-symbols-outlined text-sm leading-none">chevron_left</span>
                            </button>
                        </form>
                        <span class="px-2 text-xs">Page <c:out value="${appPage}"/> of <c:out value="${appTotalPages}"/></span>
                        <form method="get" action="${pageContext.request.contextPath}/owner/dashboard" style="display:inline;">
                            <input type="hidden" name="appScope" value="${appScope}"/>
                            <input type="hidden" name="appPage" value="${appPage + 1}"/>
                            <button class="p-1 rounded bg-white border border-[#e9d9ce] text-[#1c130d]" ${appPage == appTotalPages ? 'disabled' : ''}>
                                <span class="material-symbols-outlined text-sm leading-none">chevron_right</span>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

        <script>
            (function () {
                var toggle = document.getElementById('admin-profile-toggle');
                var menu = document.getElementById('admin-profile-menu');
                if (!toggle || !menu) return;
                toggle.addEventListener('click', function (e) {
                    e.stopPropagation();
                    menu.style.display = (menu.style.display === 'none' || menu.style.display === '') ? 'block' : 'none';
                });
                document.addEventListener('click', function (e) {
                    if (!menu.contains(e.target) && !toggle.contains(e.target)) {
                        menu.style.display = 'none';
                    }
                });
            })();
        </script>
        </body></html>
