<html class="light" lang="en"><head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Veterinary Services List - Anipat</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#ff7b00",
                        "background-light": "#ffffff",
                        "background-dark": "#16181d",
                    },
                    fontFamily: {
                        "display": ["Manrope"]
                    },
                    borderRadius: {"DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px"},
                },
            },
        }
    </script>
    <style type="text/tailwindcss">
        body { font-family: 'Manrope', sans-serif; }
        .soft-shadow { box-shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.08); }
        .sidebar-item-active { background-color: #f4ede6; border-radius: 0.75rem; }
        .dark .sidebar-item-active { background-color: #1a1c22; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#1d140c] dark:text-white transition-colors duration-200">
    <div class="flex min-h-screen">
        <aside class="w-64 border-r border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark hidden lg:flex flex-col p-6 sticky top-0 h-screen">
            <div class="flex items-center gap-3 mb-8">
                <div class="size-10 rounded-full bg-primary flex items-center justify-center text-white">
                    <span class="material-symbols-outlined">pets</span>
                </div>
                <div class="flex flex-col">
                    <h1 class="text-lg font-bold leading-tight">Anipat</h1>
                    <p class="text-[#a17145] text-xs font-medium">Veterinary Clinic</p>
                </div>
            </div>
            <nav class="flex flex-col gap-2 flex-1">
                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                    <span class="material-symbols-outlined">dashboard</span>
                    <span class="text-sm font-semibold">Dashboard</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                    <span class="material-symbols-outlined">calendar_today</span>
                    <span class="text-sm font-semibold">Schedule</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                    <span class="material-symbols-outlined">pets</span>
                    <span class="text-sm font-semibold">Patients</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 sidebar-item-active text-primary" href="#">
                    <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">medical_services</span>
                    <span class="text-sm font-bold">Services</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                    <span class="material-symbols-outlined">group</span>
                    <span class="text-sm font-semibold">Staff</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                    <span class="material-symbols-outlined">description</span>
                    <span class="text-sm font-semibold">Reports</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                    <span class="material-symbols-outlined">settings</span>
                    <span class="text-sm font-semibold">Settings</span>
                </a>
            </nav>
        </aside>
        <main class="flex-1 flex flex-col min-w-0 bg-[#fcfaf8] dark:bg-[#0f1115]">
            <header class="h-16 border-b border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark flex items-center justify-between px-6 gap-8 sticky top-0 z-10">
                <div class="flex items-center gap-4 lg:hidden">
                    <div class="size-8 rounded-full bg-primary flex items-center justify-center text-white">
                        <span class="material-symbols-outlined text-lg">pets</span>
                    </div>
                </div>
                <div class="flex-1">
                    <div class="relative group max-w-2xl">
                        <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#a17145] group-focus-within:text-primary transition-colors">search</span>
                        <input class="w-full bg-[#f4ede6] dark:bg-gray-800 border-none rounded-xl py-2 pl-11 pr-4 text-sm focus:ring-2 focus:ring-primary/20 transition-all placeholder-[#a17145]/60" placeholder="Search services, categories, or prices..." type="text"/>
                    </div>
                </div>
                <div class="flex items-center gap-4">
                    <button class="size-10 rounded-full border border-[#eadbcd] dark:border-gray-800 flex items-center justify-center hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-colors relative">
                        <span class="material-symbols-outlined text-xl text-[#a17145]">notifications</span>
                        <span class="absolute top-2.5 right-2.5 size-2 bg-primary rounded-full border-2 border-white dark:border-gray-900"></span>
                    </button>
                    <div class="h-8 w-px bg-[#eadbcd] dark:border-gray-800 mx-1"></div>
                    <button class="flex items-center gap-2 pl-2 pr-1 py-1 rounded-full hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-all border border-transparent hover:border-[#eadbcd] dark:hover:border-gray-700">
                        <div class="size-8 rounded-full bg-cover bg-center border border-white dark:border-gray-700 shadow-sm" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuAYUCJ5rFUlr81fchNgluov8XqF0omAMzcfRI6nmGwV8EbFQxDeqFbQ2PwK2MKwmUSKZit9vi8bIYew6GamGqmcFBwcGpAYU-bsg_UlBH_Iyq3v1Tw3iOUpKfVh7-O0zJ8tNEHwIneejfmZjDaWpXXIebkX_Wngol2e-sAKBsguK_Eoh0Ei9Um081oSK5oCR6I8GRroVTLARRcp1703Dl_8kP8qgtUq9GiIWG-D7MNPw2LA8xy1lh2GUpxleoam1XNeO1icd6fRSUI');"></div>
                        <span class="material-symbols-outlined text-[#a17145]">expand_more</span>
                    </button>
                </div>
            </header>
            <div class="p-8 max-w-6xl mx-auto w-full flex flex-col gap-6">
                <div class="flex flex-col @[480px]:flex-row justify-between items-start @[480px]:items-end gap-4">
                    <div class="flex flex-col gap-1">
                        <div class="flex items-center gap-2 mb-1">
                            <a class="text-[#a17145] text-sm font-medium hover:text-primary transition-colors" href="#">Management</a>
                            <span class="text-[#eadbcd] dark:text-gray-700">/</span>
                            <span class="text-[#1d140c] dark:text-white text-sm font-bold">Services</span>
                        </div>
                        <h2 class="text-2xl font-bold tracking-tight">Clinic Services</h2>
                        <p class="text-[#a17145] text-sm">Manage the list of medical services offered to patients.</p>
                    </div>
                    <button class="px-6 py-3 bg-primary hover:bg-[#e66f00] text-white rounded-xl font-bold shadow-lg shadow-primary/20 flex items-center gap-2 transition-all hover:scale-[1.02] active:scale-[0.98]">
                        <span class="material-symbols-outlined">add</span>
                        <span>Add Service</span>
                    </button>
                </div>
                <div class="soft-shadow rounded-xl border border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-[#fcfaf8] dark:bg-gray-800/50 border-b border-[#eadbcd] dark:border-gray-800">
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#a17145]">Service Name</th>
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#a17145]">Category</th>
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#a17145]">Duration</th>
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#a17145]">Price</th>
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#a17145] text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
                                <tr class="hover:bg-[#fcfaf8] dark:hover:bg-gray-800/30 transition-colors">
                                    <td class="px-6 py-4">
                                        <div class="font-bold text-[#1d140c] dark:text-white">Rabies Vaccination</div>
                                        <div class="text-xs text-[#a17145]">Standard immunization for all pets</div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-2.5 py-1 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 text-xs font-bold rounded-full">Prevention</span>
                                    </td>
                                    <td class="px-6 py-4 text-sm font-medium text-[#a17145]">15 min</td>
                                    <td class="px-6 py-4 text-sm font-bold">$25.00</td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center justify-end gap-2">
                                            <button class="p-2 text-[#a17145] hover:text-primary hover:bg-primary/10 rounded-lg transition-all" title="Edit">
                                                <span class="material-symbols-outlined text-xl">edit</span>
                                            </button>
                                            <button class="p-2 text-[#a17145] hover:text-red-500 hover:bg-red-50/50 rounded-lg transition-all" title="Delete">
                                                <span class="material-symbols-outlined text-xl">delete</span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <tr class="hover:bg-[#fcfaf8] dark:hover:bg-gray-800/30 transition-colors">
                                    <td class="px-6 py-4">
                                        <div class="font-bold text-[#1d140c] dark:text-white">Dental Cleaning</div>
                                        <div class="text-xs text-[#a17145]">Ultrasound scaling and polishing</div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-2.5 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 text-xs font-bold rounded-full">Hygiene</span>
                                    </td>
                                    <td class="px-6 py-4 text-sm font-medium text-[#a17145]">45 min</td>
                                    <td class="px-6 py-4 text-sm font-bold">$120.00</td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center justify-end gap-2">
                                            <button class="p-2 text-[#a17145] hover:text-primary hover:bg-primary/10 rounded-lg transition-all">
                                                <span class="material-symbols-outlined text-xl">edit</span>
                                            </button>
                                            <button class="p-2 text-[#a17145] hover:text-red-500 hover:bg-red-50/50 rounded-lg transition-all">
                                                <span class="material-symbols-outlined text-xl">delete</span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <tr class="hover:bg-[#fcfaf8] dark:hover:bg-gray-800/30 transition-colors">
                                    <td class="px-6 py-4">
                                        <div class="font-bold text-[#1d140c] dark:text-white">General Consultation</div>
                                        <div class="text-xs text-[#a17145]">Comprehensive health check-up</div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-2.5 py-1 bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-400 text-xs font-bold rounded-full">Clinical</span>
                                    </td>
                                    <td class="px-6 py-4 text-sm font-medium text-[#a17145]">30 min</td>
                                    <td class="px-6 py-4 text-sm font-bold">$45.00</td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center justify-end gap-2">
                                            <button class="p-2 text-[#a17145] hover:text-primary hover:bg-primary/10 rounded-lg transition-all">
                                                <span class="material-symbols-outlined text-xl">edit</span>
                                            </button>
                                            <button class="p-2 text-[#a17145] hover:text-red-500 hover:bg-red-50/50 rounded-lg transition-all">
                                                <span class="material-symbols-outlined text-xl">delete</span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <tr class="hover:bg-[#fcfaf8] dark:hover:bg-gray-800/30 transition-colors">
                                    <td class="px-6 py-4">
                                        <div class="font-bold text-[#1d140c] dark:text-white">Spay/Neuter Surgery</div>
                                        <div class="text-xs text-[#a17145]">Elective reproductive surgery</div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-2.5 py-1 bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400 text-xs font-bold rounded-full">Surgery</span>
                                    </td>
                                    <td class="px-6 py-4 text-sm font-medium text-[#a17145]">120 min</td>
                                    <td class="px-6 py-4 text-sm font-bold">$250.00</td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center justify-end gap-2">
                                            <button class="p-2 text-[#a17145] hover:text-primary hover:bg-primary/10 rounded-lg transition-all">
                                                <span class="material-symbols-outlined text-xl">edit</span>
                                            </button>
                                            <button class="p-2 text-[#a17145] hover:text-red-500 hover:bg-red-50/50 rounded-lg transition-all">
                                                <span class="material-symbols-outlined text-xl">delete</span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <tr class="hover:bg-[#fcfaf8] dark:hover:bg-gray-800/30 transition-colors">
                                    <td class="px-6 py-4">
                                        <div class="font-bold text-[#1d140c] dark:text-white">Emergency Visit</div>
                                        <div class="text-xs text-[#a17145]">Immediate triage and stabilization</div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-2.5 py-1 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 text-xs font-bold rounded-full">Urgent Care</span>
                                    </td>
                                    <td class="px-6 py-4 text-sm font-medium text-[#a17145]">60 min</td>
                                    <td class="px-6 py-4 text-sm font-bold">$150.00</td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center justify-end gap-2">
                                            <button class="p-2 text-[#a17145] hover:text-primary hover:bg-primary/10 rounded-lg transition-all">
                                                <span class="material-symbols-outlined text-xl">edit</span>
                                            </button>
                                            <button class="p-2 text-[#a17145] hover:text-red-500 hover:bg-red-50/50 rounded-lg transition-all">
                                                <span class="material-symbols-outlined text-xl">delete</span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="bg-[#fcfaf8] dark:bg-gray-800/50 px-6 py-4 border-t border-[#eadbcd] dark:border-gray-800 flex items-center justify-between">
                        <p class="text-sm text-[#a17145]">Showing 1 to 5 of 24 services</p>
                        <div class="flex gap-2">
                            <button class="px-3 py-1 border border-[#eadbcd] dark:border-gray-700 rounded-lg text-sm font-medium hover:bg-white dark:hover:bg-gray-800 transition-colors disabled:opacity-50" disabled="">Previous</button>
                            <button class="px-3 py-1 border border-[#eadbcd] dark:border-gray-700 rounded-lg text-sm font-medium hover:bg-white dark:hover:bg-gray-800 transition-colors">Next</button>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

</body></html>