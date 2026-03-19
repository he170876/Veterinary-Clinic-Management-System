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
                        <a class="sidebar-item active-nav flex items-center gap-3 px-4 py-3 rounded-full transition-all" href="#">
                            <span class="material-symbols-outlined">dashboard</span>
                            <span class="text-sm font-bold">Dashboard</span>
                        </a>

                        <a class="flex items-center gap-3 px-3 py-2.5  text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/user-management">
                            <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">group</span>
                            <span class="text-sm font-semibold">User Management</span>
                        </a>
                        <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/services">
                            <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">medical_services</span>
                            <span class="text-sm font-semibold">Services</span>
                        </a>
                        <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/images">
                            <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">image</span>
                            <span class="text-sm font-semibold">Images</span>
                        </a>

                    </nav>
                </div>
            </div>
        </aside>
        <main class="flex-1 flex flex-col overflow-y-auto">
            <header class="sticky top-0 z-10 bg-white/80 dark:bg-background-dark/80 backdrop-blur-md border-b border-[#f4ece6] px-8 py-4 flex items-center justify-between">
                <div class="flex items-center gap-6 flex-1">
                    <h2 class="text-[#1c130d] dark:text-white text-xl font-bold whitespace-nowrap">Admin Overview</h2>
                    <div class="relative w-full max-w-md">
                        <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-[#9e6b47]">search</span>
                        <input class="w-full bg-[#f4ece6] border-none rounded-full pl-12 pr-4 py-2.5 text-sm focus:ring-2 focus:ring-primary/50 placeholder:text-[#9e6b47]" placeholder="Search pets, owners or records..." type="text"/>
                    </div>
                </div>
                <div class="flex items-center gap-4">
                    <button class="p-2.5 rounded-full bg-[#f4ece6] text-[#1c130d] hover:bg-primary/10 transition-colors relative">
                        <span class="material-symbols-outlined">notifications</span>
                        <span class="absolute top-2 right-2.5 w-2 h-2 bg-primary rounded-full border-2 border-white"></span>
                    </button>
                    <div class="h-10 w-[1px] bg-[#f4ece6] mx-2"></div>
                    <div class="flex items-center gap-3 pl-2">
                        <div class="text-right hidden sm:block">
                            <p class="text-sm font-bold text-[#1c130d] dark:text-white leading-tight">Dr. Sarah Wilson</p>
                            <p class="text-xs text-[#9e6b47] font-medium">Head Veterinarian</p>
                        </div>
                        <img alt="Female veterinarian portrait professional profile" class="w-10 h-10 rounded-full object-cover border-2 border-primary/20" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCOpdc5OGkLav0tITWiOwMmjQcKk7mN_AVfXdkqFwaq8z2YA_kTnDh9i8q2wZqMntaisMabV0YHzOJLO7WmgWwMsUakIxHdUkugDvAcV2yOsrpsKBPm2Q_2HmvXGB0kFQLa_DfW5DypAP0mFdkFxAsd2MW3ukerIwOd3X-6mdbmAOWJR2lNSHTAt3MdjhwbKNMkqXGUnRz1Ek6dJ_GzSKGevijiTqqNX6KdHqEcfqnh7A9lgVzP4O4KZLuKIqrCQrt-rEQeEBygAU8"/>
                    </div>
                </div>
            </header>
            <div class="p-8 space-y-8">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <!-- Tổng số người dùng -->
                    <div class="bg-white dark:bg-[#2d1e14] p-6 rounded-xl border border-[#e9d9ce] shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start mb-2">
                            <div class="p-2 bg-blue-50 text-blue-600 rounded-lg">
                                <span class="material-symbols-outlined">group</span>
                            </div>
                        </div>
                        <p class="text-[#9e6b47] text-sm font-semibold uppercase tracking-wider">Total Users</p>
                        <h3 class="text-3xl font-extrabold text-[#1c130d] dark:text-white">${totalUsers}</h3>
                        <p class="text-xs text-[#9e6b47] mt-2 italic">Pet owners registered</p>
                    </div>
                    <!-- Tổng số cuộc hẹn -->
                    <div class="bg-white dark:bg-[#2d1e14] p-6 rounded-xl border border-[#e9d9ce] shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start mb-2">
                            <div class="p-2 bg-orange-50 text-primary rounded-lg">
                                <span class="material-symbols-outlined">event_available</span>
                            </div>
                        </div>
                        <p class="text-[#9e6b47] text-sm font-semibold uppercase tracking-wider">Total Appointments</p>
                        <h3 class="text-3xl font-extrabold text-[#1c130d] dark:text-white">${totalAppointments}</h3>
                        <p class="text-xs text-[#9e6b47] mt-2 italic">Scheduled this month</p>
                    </div>
                    <!-- Tổng số bệnh nhân -->
                    <div class="bg-white dark:bg-[#2d1e14] p-6 rounded-xl border border-[#e9d9ce] shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start mb-2">
                            <div class="p-2 bg-purple-50 text-purple-600 rounded-lg">
                                <span class="material-symbols-outlined">pets</span>
                            </div>
                        </div>
                        <p class="text-[#9e6b47] text-sm font-semibold uppercase tracking-wider">Total Patients</p>
                        <h3 class="text-3xl font-extrabold text-[#1c130d] dark:text-white">${totalPatients}</h3>
                        <p class="text-xs text-[#9e6b47] mt-2 italic">Unique animals treated</p>
                    </div>
                    <!-- Đăng ký mới 7 ngày -->
                    <div class="bg-white dark:bg-[#2d1e14] p-6 rounded-xl border border-[#e9d9ce] shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start mb-2">
                            <div class="p-2 bg-teal-50 text-teal-600 rounded-lg">
                                <span class="material-symbols-outlined">app_registration</span>
                            </div>
                        </div>
                        <p class="text-[#9e6b47] text-sm font-semibold uppercase tracking-wider">New Registrations</p>
                        <h3 class="text-3xl font-extrabold text-[#1c130d] dark:text-white">${newRegistrations7Days}</h3>
                        <p class="text-xs text-[#9e6b47] mt-2 italic">In the last 7 days</p>
                    </div>
                </div>
                <div class="bg-white dark:bg-[#2d1e14] rounded-xl border border-[#e9d9ce] shadow-sm overflow-hidden">
                    <div class="p-6 border-b border-[#f4ece6] flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                        <div>
                            <h2 class="text-xl font-bold text-[#1c130d] dark:text-white">Appointment Overview</h2>
                            <p class="text-sm text-[#9e6b47]">Monitor and manage upcoming pet visits</p>
                        </div>
                        <div class="inline-flex p-1 bg-[#f4ece6] rounded-full">
                            <button class="px-6 py-2 rounded-full text-sm font-bold bg-white text-primary shadow-sm transition-all">Today</button>
                            <button class="px-6 py-2 rounded-full text-sm font-bold text-[#9e6b47] hover:text-[#1c130d] transition-all">This Week</button>
                            <button class="px-6 py-2 rounded-full text-sm font-bold text-[#9e6b47] hover:text-[#1c130d] transition-all">This Month</button>
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
                                    <th class="px-6 py-4 text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-[#f4ece6]">
                                <tr class="hover:bg-[#fcfaf8] transition-colors">
                                    <td class="px-6 py-5">
                                        <div class="flex items-center gap-3">
                                            <img alt="Cute pug puppy face close up" class="w-10 h-10 rounded-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDjkg3fGQ-dWnKHDgyyeI0IVEefIp9CsBWddSV9wfdJbJ5jsGCLrOZfkorBSi7RoTejmvTcllof1OnNmf75qm_WJ2pNz5kulrNnrXdJEI_mgc9HH1sXlrgQrpzs9LZ35J8FMZO4Qxa1L1kvEIVL5dFrgINONATcsd1mQcgGRBRxj5IWZjjkHa8o30mZHKOFslYieZ-42gxiC5QlO1tJiCr94NHQ2x9OqNKgChUyIrv1oRVdPeAxoIL8JRMlRAgh91eX6XTAQB61Sv8"/>
                                            <div>
                                                <p class="text-sm font-bold text-[#1c130d] dark:text-white">Max</p>
                                                <p class="text-xs text-[#9e6b47]">Pug • 2yr</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-5 text-sm font-medium">Robert Fox</td>
                                    <td class="px-6 py-5">
                                        <div class="flex flex-col">
                                            <span class="text-sm font-bold text-[#1c130d] dark:text-white">Oct 24, 2023</span>
                                            <span class="text-xs text-[#9e6b47]">10:30 AM</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-5">
                                        <span class="text-xs font-bold px-3 py-1 bg-blue-50 text-blue-600 rounded-full">Vaccination</span>
                                    </td>
                                    <td class="px-6 py-5">
                                        <div class="flex items-center gap-1.5 text-green-600 font-bold text-xs">
                                            <span class="w-2 h-2 rounded-full bg-green-600"></span>
                                            Confirmed
                                        </div>
                                    </td>
                                    <td class="px-6 py-5 text-right">
                                        <button class="text-[#9e6b47] hover:text-primary transition-colors">
                                            <span class="material-symbols-outlined">more_vert</span>
                                        </button>
                                    </td>
                                </tr>
                                <tr class="hover:bg-[#fcfaf8] transition-colors">
                                    <td class="px-6 py-5">
                                        <div class="flex items-center gap-3">
                                            <img alt="Fluffy ginger cat looking curious" class="w-10 h-10 rounded-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDFFiEzKRjt32hdbAFDBaZZD-q-xWlprCWoAgaAzJLXLaWrEhLEEwcZbJXQMTEpbQoPlQRYJDQbLZdK8WA6qRTelQ5gxNR-2jxq_LCFiwIKp0pH-te_wUF0Ji5XEEruxMV3HDuoQVi4jOyg7pnu4KfDde5kWxdk0dU1Xg1qLNNHPUboxMyugxkL2uSi0zZe1PybU0alaYVQuLqcOzsX8QFaHgfBBuJl98hw0gHV_NxrgTGMiCU9ci9gD7Xp4WwMmOxEMhbBpRsKQwM"/>
                                            <div>
                                                <p class="text-sm font-bold text-[#1c130d] dark:text-white">Luna</p>
                                                <p class="text-xs text-[#9e6b47]">Tabby Cat • 4yr</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-5 text-sm font-medium">Jane Cooper</td>
                                    <td class="px-6 py-5">
                                        <div class="flex flex-col">
                                            <span class="text-sm font-bold text-[#1c130d] dark:text-white">Oct 24, 2023</span>
                                            <span class="text-xs text-[#9e6b47]">11:15 AM</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-5">
                                        <span class="text-xs font-bold px-3 py-1 bg-purple-50 text-purple-600 rounded-full">Routine Checkup</span>
                                    </td>
                                    <td class="px-6 py-5">
                                        <div class="flex items-center gap-1.5 text-primary font-bold text-xs">
                                            <span class="w-2 h-2 rounded-full bg-primary"></span>
                                            Pending
                                        </div>
                                    </td>
                                    <td class="px-6 py-5 text-right">
                                        <button class="text-[#9e6b47] hover:text-primary transition-colors">
                                            <span class="material-symbols-outlined">more_vert</span>
                                        </button>
                                    </td>
                                </tr>
                                <tr class="hover:bg-[#fcfaf8] transition-colors">
                                    <td class="px-6 py-5">
                                        <div class="flex items-center gap-3">
                                            <img alt="Golden Retriever puppy smiling" class="w-10 h-10 rounded-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDIw4_y83nK2Egtr2i_CEEKhVo5U62a9jhJu40xm_Yj3MqiXf_edBRAPpEUr72mnpMv6bVvm5DDThwqvtJvaHP9iOY9RF0Ou3NWPQll_iae3BKp5tWmCvljB52GID2RFBCzkCqyOmX0y3Z4hyB0f_W6NsynxZI5jJ0OtunLZ9dBh6k8o2Uuvwd48U3qU7avQGJO0zNaCGVSIFesS8U1lwRIh6s-5ADCLHfjoAKwFGs4vFsRaeNrckYZvUUDrlUL9RYCprUCfOeIUjg"/>
                                            <div>
                                                <p class="text-sm font-bold text-[#1c130d] dark:text-white">Bella</p>
                                                <p class="text-xs text-[#9e6b47]">Retriever • 1yr</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-5 text-sm font-medium">Guy Hawkins</td>
                                    <td class="px-6 py-5">
                                        <div class="flex flex-col">
                                            <span class="text-sm font-bold text-[#1c130d] dark:text-white">Oct 24, 2023</span>
                                            <span class="text-xs text-[#9e6b47]">02:30 PM</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-5">
                                        <span class="text-xs font-bold px-3 py-1 bg-red-50 text-red-600 rounded-full">Dental Surgery</span>
                                    </td>
                                    <td class="px-6 py-5">
                                        <div class="flex items-center gap-1.5 text-green-600 font-bold text-xs">
                                            <span class="w-2 h-2 rounded-full bg-green-600"></span>
                                            Confirmed
                                        </div>
                                    </td>
                                    <td class="px-6 py-5 text-right">
                                        <button class="text-[#9e6b47] hover:text-primary transition-colors">
                                            <span class="material-symbols-outlined">more_vert</span>
                                        </button>
                                    </td>
                                </tr>
                                <tr class="hover:bg-[#fcfaf8] transition-colors">
                                    <td class="px-6 py-5">
                                        <div class="flex items-center gap-3">
                                            <img alt="Small fluffy white dog" class="w-10 h-10 rounded-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDpNQYLQnpCArPUbJYy30lK_cNXKLsNiAaDpcX-NFi8lDkwnd5YYbYpRAFCD1JIBi1k-m7DhSiGx9KoXOhvI_5bHSVqE2YwkbphptGECv-0XFWHYLHUNOpHMDjJMLbXtAnK1xcvoCRSyOtR4UT6Ca7P6hQLNZYmHQdiRROEsn_qAwUr7suugxWwwe0BCv4oPgq_gFHfTyexZ7Mda9nbeBlyf0J4XHdt_Taq7Xo4UvmBd7CZiNQDR1EOFCFWOzagCR-zgj6OF1idhUU"/>
                                            <div>
                                                <p class="text-sm font-bold text-[#1c130d] dark:text-white">Charlie</p>
                                                <p class="text-xs text-[#9e6b47]">Bichon Frise • 5yr</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-5 text-sm font-medium">Eleanor Pena</td>
                                    <td class="px-6 py-5">
                                        <div class="flex flex-col">
                                            <span class="text-sm font-bold text-[#1c130d] dark:text-white">Oct 24, 2023</span>
                                            <span class="text-xs text-[#9e6b47]">04:00 PM</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-5">
                                        <span class="text-xs font-bold px-3 py-1 bg-orange-50 text-primary rounded-full">Grooming</span>
                                    </td>
                                    <td class="px-6 py-5">
                                        <div class="flex items-center gap-1.5 text-gray-500 font-bold text-xs">
                                            <span class="w-2 h-2 rounded-full bg-gray-400"></span>
                                            Rescheduled
                                        </div>
                                    </td>
                                    <td class="px-6 py-5 text-right">
                                        <button class="text-[#9e6b47] hover:text-primary transition-colors">
                                            <span class="material-symbols-outlined">more_vert</span>
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="p-4 bg-[#fcfaf8] dark:bg-[#3d2c1f] flex items-center justify-between">
                        <p class="text-xs text-[#9e6b47] font-medium">Showing 4 of 24 appointments</p>
                        <div class="flex gap-2">
                            <button class="p-1 rounded bg-white border border-[#e9d9ce] text-[#1c130d] disabled:opacity-50">
                                <span class="material-symbols-outlined text-sm leading-none">chevron_left</span>
                            </button>
                            <button class="p-1 rounded bg-white border border-[#e9d9ce] text-[#1c130d]">
                                <span class="material-symbols-outlined text-sm leading-none">chevron_right</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

</body></html>