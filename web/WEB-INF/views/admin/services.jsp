<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Veterinary Services - Anipat</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
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
            <!-- Sidebar -->
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

                    <a class="flex items-center gap-3 px-3 py-2.5 sidebar-item-active text-primary" href="#">
                        <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">medical_services</span>
                        <span class="text-sm font-bold">Services</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/admin/images">
                        <span class="material-symbols-outlined">image</span>
                        <span class="text-sm font-semibold">Image Control</span>
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

            <!-- Main Content -->
            <main class="flex-1 flex flex-col min-w-0 bg-[#fcfaf8] dark:bg-[#0f1115]">
                <!-- Header -->
                <header class="h-16 border-b border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark flex items-center justify-between px-6 gap-8 sticky top-0 z-10">
                    <div class="flex items-center gap-4 lg:hidden">
                        <div class="size-8 rounded-full bg-primary flex items-center justify-center text-white">
                            <span class="material-symbols-outlined text-lg">pets</span>
                        </div>
                    </div>
                    <div class="flex-1">
                        <div class="relative group max-w-2xl">
                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#a17145] group-focus-within:text-primary transition-colors">search</span>
                            <input class="w-full bg-[#f4ede6] dark:bg-gray-800 border-none rounded-xl py-2 pl-11 pr-4 text-sm focus:ring-2 focus:ring-primary/20 transition-all placeholder-[#a17145]/60" placeholder="Search services..." type="text" id="searchInput" onkeyup="filterServices()"/>
                        </div>
                    </div>
                    <div class="flex items-center gap-4">
                        <button class="size-10 rounded-full border border-[#eadbcd] dark:border-gray-800 flex items-center justify-center hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-colors relative">
                            <span class="material-symbols-outlined text-xl text-[#a17145]">notifications</span>
                        </button>
                        <div class="h-8 w-px bg-[#eadbcd] dark:border-gray-800 mx-1"></div>
                        <button class="flex items-center gap-2 pl-2 pr-1 py-1 rounded-full hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-all border border-transparent hover:border-[#eadbcd] dark:hover:border-gray-700">
                            <div class="size-8 rounded-full bg-cover bg-center border border-white dark:border-gray-700 shadow-sm" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuAYUCJ5rFUlr81fchNgluov8XqF0omAMzcfRI6nmGwV8EbFQxDeqFbQ2PwK2MKwmUSKZit9vi8bIYew6GamGqmcFBwcGpAYU-bsg_UlBH_Iyq3v1Tw3iOUpKfVh7-O0zJ8tNEHwIneejfmZjDaWpXXIebkX_Wngol2e-sAKBsguK_Eoh0Ei9Um081oSK5oCR6I8GRroVTLARRcp1703Dl_8kP8qgtUq9GiIWG-D7MNPw2LA8xy1lh2GUpxleoam1XNeO1icd6fRSUI');"></div>
                            <span class="material-symbols-outlined text-[#a17145]">expand_more</span>
                        </button>
                    </div>
                </header>

                <!-- Page Content -->
                <div class="p-8 max-w-6xl mx-auto w-full flex flex-col gap-6">
                    <div class="flex flex-col @[480px]:flex-row justify-between items-start @[480px]:items-end gap-4">
                        <div class="flex flex-col gap-1">
                            <div class="flex items-center gap-2 mb-1">
                                <span class="text-[#a17145] text-sm font-medium">Management</span>
                                <span class="text-[#eadbcd] dark:text-gray-700">/</span>
                                <span class="text-[#1d140c] dark:text-white text-sm font-bold">Services</span>
                            </div>
                            <h2 class="text-2xl font-bold tracking-tight">Clinic Services</h2>
                            <p class="text-[#a17145] text-sm">Manage the list of medical services offered to patients.</p>
                        </div>
                        <button onclick="openAddServiceModal()" class="px-6 py-3 bg-primary hover:bg-[#e66f00] text-white rounded-xl font-bold shadow-lg shadow-primary/20 flex items-center gap-2 transition-all hover:scale-[1.02] active:scale-[0.98]">
                            <span class="material-symbols-outlined">add</span>
                            <span>Add Service</span>
                        </button>
                    </div>

                    <!-- Services Table -->
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
                                <tbody class="divide-y divide-gray-100 dark:divide-gray-800" id="servicesTableBody">
                                    <c:choose>
                                        <c:when test="${empty services}">
                                            <tr>
                                                <td colspan="5" class="px-6 py-8 text-center text-[#a17145]">
                                                    <div class="flex flex-col items-center gap-2">
                                                        <span class="material-symbols-outlined text-4xl opacity-50">inbox</span>
                                                        <p>No services found. Create your first service!</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="service" items="${services}">
                                                <tr class="hover:bg-[#fcfaf8] dark:hover:bg-gray-800/30 transition-colors service-row" data-service-name="${service.name}" data-service-category="${service.category}">
                                                    <td class="px-6 py-4">
                                                        <div class="font-bold text-[#1d140c] dark:text-white">${service.name}</div>
                                                        <div class="text-xs text-[#a17145]">${service.description}</div>
                                                    </td>
                                                    <td class="px-6 py-4">
                                                        <c:choose>
                                                            <c:when test="${service.category == 'Wellness'}">
                                                                <span class="px-2.5 py-1 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 text-xs font-bold rounded-full">${service.category}</span>
                                                            </c:when>
                                                            <c:when test="${service.category == 'Dental'}">
                                                                <span class="px-2.5 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 text-xs font-bold rounded-full">${service.category}</span>
                                                            </c:when>
                                                            <c:when test="${service.category == 'Diagnostics'}">
                                                                <span class="px-2.5 py-1 bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-400 text-xs font-bold rounded-full">${service.category}</span>
                                                            </c:when>
                                                            <c:when test="${service.category == 'Surgery'}">
                                                                <span class="px-2.5 py-1 bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400 text-xs font-bold rounded-full">${service.category}</span>
                                                            </c:when>
                                                            <c:when test="${service.category == 'Emergency'}">
                                                                <span class="px-2.5 py-1 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 text-xs font-bold rounded-full">${service.category}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="px-2.5 py-1 bg-gray-100 dark:bg-gray-900/30 text-gray-700 dark:text-gray-400 text-xs font-bold rounded-full">${service.category != null ? service.category : 'N/A'}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="px-6 py-4 text-sm font-medium text-[#a17145]">${service.duration > 0 ? service.duration : 'N/A'} ${service.duration > 0 ? 'min' : ''}</td>
                                                    <td class="px-6 py-4 text-sm font-bold"><fmt:formatNumber value="${service.price}" type="currency" currencySymbol="$" pattern="$#,##0.00"/></td>
                                                    <td class="px-6 py-4">
                                                        <div class="flex items-center justify-end gap-2">
                                                            <button onclick="openEditServiceModal(${service.serviceId})" class="p-2 text-[#a17145] hover:text-primary hover:bg-primary/10 rounded-lg transition-all" title="Edit">
                                                                <span class="material-symbols-outlined text-xl">edit</span>
                                                            </button>
                                                            <button onclick="deleteService(${service.serviceId})" class="p-2 text-[#a17145] hover:text-red-500 hover:bg-red-50/50 rounded-lg transition-all" title="Delete">
                                                                <span class="material-symbols-outlined text-xl">delete</span>
                                                            </button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                        <div class="bg-[#fcfaf8] dark:bg-gray-800/50 px-6 py-4 border-t border-[#eadbcd] dark:border-gray-800 flex items-center justify-between">
                            <p class="text-sm text-[#a17145]">Showing <span id="serviceCount">${empty services ? 0 : services.size()}</span> services</p>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <!-- Add Service Modal -->
        <div id="addServiceModal" class="fixed inset-0 bg-black/30 hidden items-center justify-center z-50 p-4 overflow-y-auto">
            <div class="bg-background-light dark:bg-background-dark rounded-2xl w-full max-w-2xl soft-shadow border border-[#eadbcd] dark:border-gray-800 my-8">
                <div class="px-8 py-6 border-b border-[#eadbcd] dark:border-gray-800 bg-[#fcfaf8] dark:bg-[#1a1c22]">
                    <h2 class="text-xl font-bold">Add New Service</h2>
                    <p class="text-[#a17145] text-sm mt-1">Fill in the details to create a new veterinary service.</p>
                </div>
                <form id="addServiceForm" onsubmit="submitAddService(event)" class="p-8 space-y-6">
                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Service Name</label>
                        <input class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all placeholder-[#a17145]/40" name="name" id="addName" placeholder="e.g. Annual Wellness Checkup" required type="text"/>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="flex flex-col gap-2">
                            <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Category</label>
                            <select class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all" id="addCategory" name="category" required>
                                <option value="">Select Category</option>
                                <option value="Wellness">Wellness</option>
                                <option value="Preventive">Preventive</option>
                                <option value="Dental">Dental</option>
                                <option value="Diagnostics">Diagnostics</option>
                                <option value="Surgery">Surgery</option>
                                <option value="Emergency">Emergency</option>
                                <option value="Consultation">Consultation</option>
                            </select>
                        </div>
                        <div class="flex flex-col gap-2">
                            <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Standard Duration (min)</label>
                            <div class="relative">
                                <input class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all placeholder-[#a17145]/40" id="addDuration" min="0" name="duration" placeholder="30" step="1" type="number" required/>
                                <span class="absolute right-4 top-1/2 -translate-y-1/2 text-xs font-bold text-[#a17145]">MINS</span>
                            </div>
                        </div>
                    </div>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Price ($)</label>
                        <div class="relative">
                            <span class="absolute left-4 top-1/2 -translate-y-1/2 text-sm font-bold text-[#a17145]">$</span>
                            <input class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 pl-8 pr-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all placeholder-[#a17145]/40" id="addPrice" name="price" placeholder="0.00" step="0.01" type="number" required/>
                        </div>
                    </div>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Description</label>
                        <textarea class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all placeholder-[#a17145]/40 resize-none" id="addDescription" name="description" placeholder="Detailed description of what the service includes..." rows="5"></textarea>
                    </div>

                    <div class="flex items-center justify-end gap-4 pt-4 border-t border-[#eadbcd] dark:border-gray-800">
                        <button class="px-6 py-3 border border-[#eadbcd] dark:border-gray-700 hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl text-sm font-bold text-[#a17145] transition-all" onclick="closeAddModal()" type="button">Cancel</button>
                        <button class="px-8 py-3 bg-primary hover:bg-[#e66f00] text-white rounded-xl text-sm font-bold shadow-lg shadow-primary/20 flex items-center gap-2 transition-all active:scale-95" type="submit">
                            <span class="material-symbols-outlined text-sm">save</span>
                            Save Service
                        </button>
                    </div>
                    <input type="hidden" name="action" value="create"/>
                </form>
            </div>
        </div>

        <!-- Edit Service Modal -->
        <div id="editServiceModal" class="fixed inset-0 bg-black/30 hidden items-center justify-center z-50 p-4 overflow-y-auto">
            <div class="bg-background-light dark:bg-background-dark rounded-2xl w-full max-w-2xl soft-shadow border border-[#eadbcd] dark:border-gray-800 my-8">
                <div class="px-8 py-6 border-b border-[#eadbcd] dark:border-gray-800 bg-[#fcfaf8] dark:bg-[#1a1c22]">
                    <h2 class="text-xl font-bold">Edit Service</h2>
                    <p class="text-[#a17145] text-sm mt-1">Update the service details below.</p>
                </div>
                <form id="editServiceForm" onsubmit="submitEditService(event)" class="p-8 space-y-6">
                    <input type="hidden" id="editServiceId" name="serviceId" value="0"/>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Service Name</label>
                        <input class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all placeholder-[#a17145]/40" name="name" id="editName" placeholder="e.g. Annual Wellness Checkup" required type="text"/>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="flex flex-col gap-2">
                            <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Category</label>
                            <select class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all" id="editCategory" name="category" required>
                                <option value="">Select Category</option>
                                <option value="Wellness">Wellness</option>
                                <option value="Preventive">Preventive</option>
                                <option value="Dental">Dental</option>
                                <option value="Diagnostics">Diagnostics</option>
                                <option value="Surgery">Surgery</option>
                                <option value="Emergency">Emergency</option>
                                <option value="Consultation">Consultation</option>
                            </select>
                        </div>
                        <div class="flex flex-col gap-2">
                            <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Standard Duration (min)</label>
                            <div class="relative">
                                <input class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all placeholder-[#a17145]/40" id="editDuration" min="0" name="duration" placeholder="30" step="1" type="number" required/>
                                <span class="absolute right-4 top-1/2 -translate-y-1/2 text-xs font-bold text-[#a17145]">MINS</span>
                            </div>
                        </div>
                    </div>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Price ($)</label>
                        <div class="relative">
                            <span class="absolute left-4 top-1/2 -translate-y-1/2 text-sm font-bold text-[#a17145]">$</span>
                            <input class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 pl-8 pr-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all placeholder-[#a17145]/40" id="editPrice" name="price" placeholder="0.00" step="0.01" type="number" required/>
                        </div>
                    </div>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-bold text-[#1d140c] dark:text-gray-200">Description</label>
                        <textarea class="w-full bg-[#fcfaf8] dark:bg-gray-800 border border-[#eadbcd] dark:border-gray-700 rounded-xl py-3 px-4 text-sm focus:ring-2 focus:ring-primary focus:border-primary transition-all placeholder-[#a17145]/40 resize-none" id="editDescription" name="description" placeholder="Detailed description of what the service includes..." rows="5"></textarea>
                    </div>

                    <div class="flex items-center justify-end gap-4 pt-4 border-t border-[#eadbcd] dark:border-gray-800">
                        <button class="px-6 py-3 border border-[#eadbcd] dark:border-gray-700 hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl text-sm font-bold text-[#a17145] transition-all" onclick="closeEditModal()" type="button">Cancel</button>
                        <button class="px-8 py-3 bg-primary hover:bg-[#e66f00] text-white rounded-xl text-sm font-bold shadow-lg shadow-primary/20 flex items-center gap-2 transition-all active:scale-95" type="submit">
                            <span class="material-symbols-outlined text-sm">save</span>
                            Save Changes
                        </button>
                    </div>
                    <input type="hidden" name="action" value="update"/>
                </form>
            </div>
        </div>

        <!-- Hidden data container for service data -->
        <div id="serviceDataContainer" style="display: none;">
            <c:forEach var="service" items="${services}">
                <div class="service-data"
                data-id="${service.serviceId}"
                data-name="${service.name}"
                data-category="${service.category}"
                data-duration="${service.duration}"
                data-price="${service.price}"
                data-description="${service.description}"></div>
            </c:forEach>
        </div>

        <script>
            // Modal Controls
            function openAddServiceModal() {
                document.getElementById('addServiceForm').reset();
                document.getElementById('addServiceModal').classList.remove('hidden');
                document.getElementById('addServiceModal').classList.add('flex');
            }
            
            function closeAddModal() {
                document.getElementById('addServiceModal').classList.add('hidden');
                document.getElementById('addServiceModal').classList.remove('flex');
            }
            
            function openEditServiceModal(serviceId) {
                const service = window.serviceDataMap[serviceId];
                if (!service) {
                    alert('Service not found');
                    return;
                }
                
                document.getElementById('editServiceId').value = service.id;
                document.getElementById('editName').value = service.name;
                document.getElementById('editCategory').value = service.category;
                document.getElementById('editDuration').value = service.duration;
                document.getElementById('editPrice').value = service.price;
                document.getElementById('editDescription').value = service.description;
                
                document.getElementById('editServiceModal').classList.remove('hidden');
                document.getElementById('editServiceModal').classList.add('flex');
            }
            
            function closeEditModal() {
                document.getElementById('editServiceModal').classList.add('hidden');
                document.getElementById('editServiceModal').classList.remove('flex');
            }
            
            // Form Submissions
            function submitAddService(event) {
                event.preventDefault();
                const formData = new FormData(document.getElementById('addServiceForm'));
                const params = new URLSearchParams(formData);
                
                fetch('<%= request.getContextPath() %>/owner/dashboard', {
                    method: 'POST',
                    body: params
                })
                .then(response => {
                    console.log('Response status:', response.status);
                    if (response.status === 302 || response.redirected) {
                        location.reload();
                        } else if (response.ok) {
                            location.reload();
                            } else {
                                alert('Error saving service (Status: ' + response.status + ')');
                            }
                        })
                        .catch(error => {
                            console.error('Fetch error:', error);
                            alert('Network error: ' + error.message);
                        });
                    }
                    
                    function submitEditService(event) {
                        event.preventDefault();
                        const formData = new FormData(document.getElementById('editServiceForm'));
                        const params = new URLSearchParams(formData);
                        
                        fetch('<%= request.getContextPath() %>/owner/dashboard', {
                            method: 'POST',
                            body: params
                        })
                        .then(response => {
                            console.log('Response status:', response.status);
                            if (response.status === 302 || response.redirected) {
                                location.reload();
                                } else if (response.ok) {
                                    location.reload();
                                    } else {
                                        alert('Error updating service (Status: ' + response.status + ')');
                                    }
                                })
                                .catch(error => {
                                    console.error('Fetch error:', error);
                                    alert('Network error: ' + error.message);
                                });
                            }
                            
                            // Delete Service
                            function deleteService(id) {
                                if (confirm('Are you sure you want to delete this service?')) {
                                    const params = new URLSearchParams();
                                    params.append('action', 'delete');
                                    params.append('serviceId', id);
                                    
                                    fetch('<%= request.getContextPath() %>/owner/dashboard', {
                                        method: 'POST',
                                        body: params
                                    })
                                    .then(response => {
                                        console.log('Delete response status:', response.status);
                                        if (response.status === 302 || response.redirected) {
                                            location.reload();
                                            } else if (response.ok) {
                                                location.reload();
                                                } else {
                                                    alert('Error deleting service');
                                                }
                                            })
                                            .catch(error => {
                                                console.error('Fetch error:', error);
                                                alert('Network error: ' + error.message);
                                            });
                                        }
                                    }
                                    
                                    // Search/Filter Services
                                    function filterServices() {
                                        const searchText = document.getElementById('searchInput').value.toLowerCase();
                                        const rows = document.querySelectorAll('.service-row');
                                        
                                        rows.forEach(row => {
                                            const name = row.getAttribute('data-service-name').toLowerCase();
                                            const category = row.getAttribute('data-service-category').toLowerCase();
                                            
                                            if (name.includes(searchText) || category.includes(searchText)) {
                                                row.style.display = '';
                                                } else {
                                                    row.style.display = 'none';
                                                }
                                            });
                                        }
                                        
                                        // Close modal when clicking outside
                                        document.getElementById('addServiceModal').addEventListener('click', function(e) {
                                            if (e.target === this) {
                                                closeAddModal();
                                            }
                                        });
                                        
                                        document.getElementById('editServiceModal').addEventListener('click', function(e) {
                                            if (e.target === this) {
                                                closeEditModal();
                                            }
                                        });
                                        
                                        // Initialize service data map from data attributes
                                        window.serviceDataMap = {};
                                        document.querySelectorAll('#serviceDataContainer .service-data').forEach(div => {
                                            const id = parseInt(div.dataset.id);
                                            window.serviceDataMap[id] = {
                                                id: id,
                                                name: div.dataset.name || '',
                                                category: div.dataset.category || '',
                                                duration: parseInt(div.dataset.duration) || 0,
                                                price: parseFloat(div.dataset.price) || 0,
                                                description: div.dataset.description || ''
                                            };
                                        });
                                    </script>

                                </body>
                            </html>
