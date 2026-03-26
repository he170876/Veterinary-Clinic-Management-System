
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Management</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
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
        .status-select {
            font-weight: 700;
            border-radius: 9999px;
            padding: 6px 14px;
            font-size: 0.85rem;
            border: 2px solid;
            background-image: none;
        }
        .status-active {
            background-color: #dcfce7;
            color: #166534;
            border-color: #22c55e;
        }
        .status-inactive {
            background-color: #fef9c3;
            color: #854d0e;
            border-color: #eab308;
        }
        .status-blocked {
            background-color: #fee2e2;
            color: #991b1b;
            border-color: #ef4444;
        }
        .status-select option {
            background-color: white;
            color: #111827;
            font-weight: 600;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#1d140c] dark:text-white transition-colors duration-200">
<c:if test="${param.created == '1'}">
    <div id="createSuccessToast" class="fixed top-5 right-5 z-[9999] min-w-[280px] max-w-sm rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-green-800 soft-shadow">
        <div class="flex items-start gap-3">
            <span class="material-symbols-outlined text-green-600">check_circle</span>
            <div>
                <p class="font-bold">Create account successful</p>
                <p class="text-sm text-green-700">The new user account has been created.</p>
            </div>
        </div>
    </div>
</c:if>

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
            <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/dashboard">
                <span class="material-symbols-outlined">dashboard</span>
                <span class="text-sm font-semibold">Dashboard</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2.5 sidebar-item-active text-primary" href="user-management">
                <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">group</span>
                <span class="text-sm font-bold">User Management</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/services">
                <span class="material-symbols-outlined">medical_services</span>
                <span class="text-sm font-semibold">Services</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/content">
                <span class="material-symbols-outlined">edit_document</span>
                <span class="text-sm font-semibold">Content</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/images">
                        <span class="material-symbols-outlined">image</span>
                        <span class="text-sm font-semibold">Images</span>
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
                    <form action="user-management" method="get">
                        <input name="keyword" value="${param.keyword}" class="w-full bg-[#f4ede6] dark:bg-gray-800 border-none rounded-xl py-2 pl-11 pr-4 text-sm focus:ring-2 focus:ring-primary/20 transition-all placeholder-[#a17145]/60" placeholder="Search users..." type="text" />
                        <input type="hidden" name="filterRoleId" value="${param.filterRoleId}" />
                        <input type="hidden" name="filterStatus" value="${param.filterStatus}" />
                        <input type="hidden" name="page" value="1" />
                        <input type="hidden" name="sort" value="${sort}" />
                    </form>
                </div>
            </div>
            <div class="flex items-center gap-4">
                <button class="size-10 rounded-full border border-[#eadbcd] dark:border-gray-800 flex items-center justify-center hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-colors relative">
                    <span class="material-symbols-outlined text-xl text-[#a17145]">notifications</span>
                </button>
                <div class="h-8 w-px bg-[#eadbcd] dark:border-gray-800 mx-1"></div>
                <div class="relative">
                        <button type="button" id="admin-profile-toggle"
                                class="flex items-center gap-2 pl-2 pr-1 py-1 rounded-full hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-all border border-transparent hover:border-[#eadbcd] dark:hover:border-gray-700">
                        <%@ include file="_owner_header_avatar.jspf" %>
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
        <div class="p-8 max-w-6xl mx-auto w-full flex flex-col gap-6">
            <div class="flex flex-col @[480px]:flex-row justify-between items-start @[480px]:items-end gap-4 mb-4">
                <div class="flex flex-col gap-1">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="text-[#a17145] text-sm font-medium">Management</span>
                        <span class="text-[#eadbcd] dark:text-gray-700">/</span>
                        <span class="text-[#1d140c] dark:text-white text-sm font-bold">User Management</span>
                    </div>
                    <h2 class="text-2xl font-bold tracking-tight">System Users</h2>
                    <p class="text-[#a17145] text-sm">Search and filter system users</p>
                </div>
                <button type="button"
                        onclick="openCreateUserModal()"
                        class="px-5 py-3 bg-primary hover:bg-[#e66f00] text-white rounded-xl font-bold shadow-sm">
                    Add Account
                </button>
            </div>
            <!-- FILTER -->
            <form action="user-management" method="get"
                  class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-8">

                <input type="hidden" name="page" value="${currentPage}" />

                <input name="keyword" value="${param.keyword}"
                       placeholder="Search name or email"
                       class="rounded-xl border px-4 py-3"/>

                <select name="filterRoleId" class="rounded-xl border px-4 py-3">
                    <option value="">All roles</option>
                    <option value="1" ${param.filterRoleId=='1'?'selected':''}>Customer</option>
                    <option value="2" ${param.filterRoleId=='2'?'selected':''}>Veterinarian</option>
                    <option value="3" ${param.filterRoleId=='3'?'selected':''}>Receptionist</option>
                    <option value="4" ${param.filterRoleId=='4'?'selected':''}>Lab Staff</option>
                    <option value="5" ${param.filterRoleId=='5'?'selected':''}>Admin</option>
                    <option value="6" ${param.filterRoleId=='6'?'selected':''}>Clinic Owner</option>
                </select>

                <select name="filterStatus" class="rounded-xl border px-4 py-3">
                    <option value="">All status</option>
                    <option value="Active" ${param.filterStatus=='Active'?'selected':''}>Active</option>
                    <option value="Inactive" ${param.filterStatus=='Inactive'?'selected':''}>Inactive</option>
                    <option value="Blocked" ${param.filterStatus=='Blocked'?'selected':''}>Blocked</option>
                </select>

                <button class="bg-primary hover:bg-[#e66f00] text-white font-bold rounded-xl">Filter</button>

                <a href="user-management"
                   class="bg-gray-200 rounded-xl font-bold flex items-center justify-center">
                    Clear
                </a>
            </form>
            <!-- TABLE -->
            <div class="soft-shadow rounded-xl border border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark overflow-x-auto">
                <table class="min-w-full text-sm">
                <thead class="bg-[#fcfaf8] dark:bg-gray-800/50 border-b border-[#eadbcd] dark:border-gray-800">
                    <tr>
                        <th class="px-6 py-4">
                            <form method="get" action="user-management" class="inline-flex items-center gap-1">
                                <input type="hidden" name="keyword" value="${param.keyword}" />
                                <input type="hidden" name="filterRoleId" value="${param.filterRoleId}" />
                                <input type="hidden" name="filterStatus" value="${param.filterStatus}" />
                                <input type="hidden" name="page" value="1" />
                                <input type="hidden" name="sort" value="${sort == 'id_asc' ? 'id_desc' : 'id_asc'}" />
                                ID
                                <button type="submit" class="ml-1 font-bold text-primary hover:scale-110 transition">
                                    <c:choose>
                                        <c:when test="${sort eq 'id_asc'}">↑</c:when>
                                        <c:when test="${sort eq 'id_desc'}">↓</c:when>
                                        <c:otherwise>↕</c:otherwise>
                                    </c:choose>
                                </button>
                            </form>
                        </th>
                        <th class="px-6 py-4">Name</th>
                        <th class="px-6 py-4">Email</th>
                        <th class="px-6 py-4">Role</th>
                        <th class="px-6 py-4">Status</th>
                        <th class="px-6 py-4 text-center">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
                    <c:forEach items="${users}" var="u">
                        <tr class="hover:bg-[#fcfaf8] dark:hover:bg-gray-800/30 transition-colors">
                            <td class="px-6 py-4">${u.userId}</td>
                            <td class="px-6 py-4 font-semibold">${u.fullName}</td>
                            <td class="px-6 py-4">${u.email}</td>
                            <td class="px-6 py-4">${u.role.roleName}</td>
                            <td class="px-6 py-4">
                                <form action="${pageContext.request.contextPath}/admin/change-user-status" method="post">
                                    <input type="hidden" name="id" value="${u.userId}" />
                                    <input type="hidden" name="keyword" value="${param.keyword}" />
                                    <input type="hidden" name="filterRoleId" value="${param.filterRoleId}" />
                                    <input type="hidden" name="filterStatus" value="${param.filterStatus}" />
                                    <input type="hidden" name="page" value="${currentPage}" />
                                    <input type="hidden" name="sort" value="${sort}" />
                                    <select name="status"
                                            data-user-id="${u.userId}"
                                            data-old-status="${u.status}"
                                            onchange="openConfirmModal(this)"
                                            ${u.role.roleName == 'Customer' ? 'disabled' : ''}
                                            class="status-select
                                            ${u.role.roleName == 'Customer' ? 'opacity-60 cursor-not-allowed' : ''}
                                            ${u.status == 'Active' ? 'status-active' :
                                              u.status == 'Inactive' ? 'status-inactive' :
                                              'status-blocked'}">
                                        <option value="Active" ${u.status=='Active'?'selected':''}>Active</option>
                                        <option value="Inactive" ${u.status=='Inactive'?'selected':''}>Inactive</option>
                                        <option value="Blocked" ${u.status=='Blocked'?'selected':''}>Blocked</option>
                                    </select>
                                </form>
                            </td>
                            <td class="px-6 py-4 text-center">
                                <button type="button"
                                        onclick="openUserModal(
                                                        '${u.userId}',
                                                        '${u.fullName}',
                                                        '${u.email}',
                                                        '${u.role.roleName}',
                                                        '${u.status}',
                                                        '${u.phone}',
                                                        '${u.address}',
                                                        '${u.createdAt}',
                                                        '${u.updatedAt}'
                                                        )"
                                        class="px-4 py-2 bg-blue-500 text-white rounded-lg font-bold hover:bg-blue-600">
                                    View
                                </button>
                                <c:if test="${u.role.roleName != 'Customer'}">
                                    <button type="button"
                                            onclick="openEditUserModal(
                                                            '${u.userId}',
                                                            '${u.fullName}',
                                                            '${u.email}',
                                                            '${u.phone}',
                                                            '${u.address}',
                                                            '${u.role.roleId}',
                                                            '${u.status}'
                                                            )"
                                            class="px-4 py-2 bg-amber-500 text-white rounded-lg font-bold hover:bg-amber-600">
                                        Edit
                                    </button>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty users}">
                        <tr>
                            <td colspan="6" class="text-center py-10 text-[#a17145]">
                                <div class="flex flex-col items-center gap-2">
                                    <span class="material-symbols-outlined text-4xl opacity-50">inbox</span>
                                    <p>No users found</p>
                                </div>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <div class="bg-[#fcfaf8] dark:bg-gray-800/50 px-6 py-4 border-t border-[#eadbcd] dark:border-gray-800 flex items-center justify-between mt-2">
            <c:set var="from" value="${(currentPage - 1) * pageSize + 1}" />
            <c:set var="to" value="${currentPage * pageSize}" />
            <c:if test="${to > totalUsers}">
                <c:set var="to" value="${totalUsers}" />
            </c:if>
            <div class="text-sm text-[#a17145]">
                Showing <b>${from}</b> to <b>${to}</b> of <b>${totalUsers}</b> users
            </div>
        </div>


        <!-- PAGINATION -->
        <c:if test="${totalPages > 1}">
            <div class="flex justify-center items-center gap-2 mt-8">
                <c:if test="${currentPage > 1}">
                    <a href="user-management?page=${currentPage-1}&keyword=${param.keyword}&filterRoleId=${param.filterRoleId}&filterStatus=${param.filterStatus}&sort=${sort}"
                       class="px-4 py-2 rounded-lg bg-gray-200 font-bold hover:bg-gray-300">
                        Prev
                    </a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <a href="user-management?page=${i}&keyword=${param.keyword}&filterRoleId=${param.filterRoleId}&filterStatus=${param.filterStatus}&sort=${sort}"
                       class="px-4 py-2 rounded-lg font-bold
                       ${i == currentPage ? 'bg-primary text-white' : 'bg-gray-100 hover:bg-gray-200'}">
                        ${i}
                    </a>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a href="user-management?page=${currentPage+1}&keyword=${param.keyword}&filterRoleId=${param.filterRoleId}&filterStatus=${param.filterStatus}&sort=${sort}"
                       class="px-4 py-2 rounded-lg bg-gray-200 font-bold hover:bg-gray-300">
                        Next
                    </a>
                </c:if>
            </div>
        </c:if>
    </div>
    </main>
</div>

        <!-- CREATE USER MODAL -->
        <div id="createUserModal"
             class="fixed inset-0 bg-black/50 hidden items-center justify-center z-50">

            <div class="bg-white w-full max-w-xl rounded-2xl shadow-lg p-6 relative max-h-[90vh] overflow-y-auto">

                <h3 class="text-2xl font-black mb-4">Add Account</h3>

                <form id="createUserForm" action="${pageContext.request.contextPath}/owner/create-user" method="post" class="space-y-4">

                    <input type="hidden" name="keyword" value="${param.keyword}" />
                    <input type="hidden" name="filterRoleId" value="${param.filterRoleId}" />
                    <input type="hidden" name="filterStatus" value="${param.filterStatus}" />
                    <input type="hidden" name="page" value="${currentPage}" />
                    <input type="hidden" name="sort" value="${sort}" />

                    <div>
                        <label class="font-semibold">Full Name</label>
                        <input name="fullName"
                               value="${fullName}"
                               class="w-full rounded-lg border px-4 py-2 ${openCreateModal and errors.fullName != null ? 'border-red-500' : ''}"/>
                        <c:if test="${openCreateModal and errors.fullName != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.fullName}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Account (Email login)</label>
                        <input name="email"
                               value="${email}"
                               class="w-full rounded-lg border px-4 py-2 ${openCreateModal and errors.email != null ? 'border-red-500' : ''}"/>
                        <c:if test="${openCreateModal and errors.email != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.email}</p>
                        </c:if>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="font-semibold">Password</label>
                            <input type="password"
                                   name="password"
                                   class="w-full rounded-lg border px-4 py-2 ${openCreateModal and errors.password != null ? 'border-red-500' : ''}"/>
                            <c:if test="${openCreateModal and errors.password != null}">
                                <p class="text-red-500 text-sm mt-1">${errors.password}</p>
                            </c:if>
                        </div>
                        <div>
                            <label class="font-semibold">Confirm Password</label>
                            <input type="password"
                                   name="confirmPassword"
                                   class="w-full rounded-lg border px-4 py-2 ${openCreateModal and errors.confirmPassword != null ? 'border-red-500' : ''}"/>
                            <c:if test="${openCreateModal and errors.confirmPassword != null}">
                                <p class="text-red-500 text-sm mt-1">${errors.confirmPassword}</p>
                            </c:if>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="font-semibold">Role</label>
                            <select name="roleId"
                                    class="w-full rounded-lg border px-4 py-2 ${openCreateModal and errors.roleId != null ? 'border-red-500' : ''}">
                                <option value="">Select role</option>
                                <option value="1" ${roleId == 1 ? 'selected' : ''}>Customer</option>
                                <option value="2" ${roleId == 2 ? 'selected' : ''}>Veterinarian</option>
                                <option value="3" ${roleId == 3 ? 'selected' : ''}>Receptionist</option>
                                <option value="4" ${roleId == 4 ? 'selected' : ''}>Lab Staff</option>
                                <option value="5" ${roleId == 5 ? 'selected' : ''}>Admin</option>
                                <option value="6" ${roleId == 6 ? 'selected' : ''}>Clinic Owner</option>
                            </select>
                            <c:if test="${openCreateModal and errors.roleId != null}">
                                <p class="text-red-500 text-sm mt-1">${errors.roleId}</p>
                            </c:if>
                        </div>
                        <div>
                            <label class="font-semibold">Status</label>
                            <select name="status"
                                    class="w-full rounded-lg border px-4 py-2 ${openCreateModal and errors.status != null ? 'border-red-500' : ''}">
                                <option value="Active" ${status == 'Active' ? 'selected' : ''}>Active</option>
                                <option value="Inactive" ${status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                <option value="Blocked" ${status == 'Blocked' ? 'selected' : ''}>Blocked</option>
                            </select>
                            <c:if test="${openCreateModal and errors.status != null}">
                                <p class="text-red-500 text-sm mt-1">${errors.status}</p>
                            </c:if>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="font-semibold">Phone (optional)</label>
                            <input name="phone"
                                   value="${phone}"
                                   class="w-full rounded-lg border px-4 py-2 ${openCreateModal and errors.phone != null ? 'border-red-500' : ''}"/>
                            <c:if test="${openCreateModal and errors.phone != null}">
                                <p class="text-red-500 text-sm mt-1">${errors.phone}</p>
                            </c:if>
                        </div>
                        <div>
                            <label class="font-semibold">Address (optional)</label>
                            <input name="address"
                                   value="${address}"
                                   class="w-full rounded-lg border px-4 py-2 ${openCreateModal and errors.address != null ? 'border-red-500' : ''}"/>
                            <c:if test="${openCreateModal and errors.address != null}">
                                <p class="text-red-500 text-sm mt-1">${errors.address}</p>
                            </c:if>
                        </div>
                    </div>

                    <div class="flex justify-end gap-3 pt-4">
                        <button type="button"
                                onclick="closeCreateUserModal()"
                                class="px-5 py-2 bg-gray-200 rounded-lg font-bold">
                            Cancel
                        </button>

                        <button type="submit"
                                class="px-5 py-2 bg-primary text-white rounded-lg font-bold hover:bg-[#e66f00]">
                            Create Account
                        </button>
                    </div>

                </form>
            </div>
        </div>

        <script>
            (function () {
                var toast = document.getElementById('createSuccessToast');
                if (!toast) {
                    return;
                }
                setTimeout(function () {
                    toast.style.opacity = '0';
                    toast.style.transition = 'opacity 0.3s ease';
                    setTimeout(function () {
                        if (toast && toast.parentNode) {
                            toast.parentNode.removeChild(toast);
                        }
                    }, 300);
                }, 2500);
            })();

            function openCreateUserModal() {
                const modal = document.getElementById('createUserModal');
                modal.classList.remove('hidden');
                modal.classList.add('flex');
            }

            function closeCreateUserModal() {
                const modal = document.getElementById('createUserModal');
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            }
        </script>

        <c:if test="${openCreateModal}">
            <script>
                openCreateUserModal();
            </script>
        </c:if>

        <!-- UPDATE USER STATUS -->
        <script>
            function updateStatusStyle(select) {
                select.classList.remove('status-active', 'status-inactive', 'status-blocked');
                if (select.value === 'Active')
                    select.classList.add('status-active');
                else if (select.value === 'Inactive')
                    select.classList.add('status-inactive');
                else
                    select.classList.add('status-blocked');
            }
        </script>

        <div id="confirmModal"
             class="fixed inset-0 bg-black/50 hidden items-center justify-center z-50">

            <div class="bg-white rounded-2xl p-6 w-full max-w-md shadow-lg">

                <h3 class="text-xl font-black mb-4">Confirm status change</h3>

                <p class="mb-2">
                    Change status for user ID:
                    <b><span id="c-user-id" class="text-orange-600"></span></b>
                </p>

                <p class="mb-4">
                    From <b><span id="c-old"></span></b>
                    → <b><span id="c-new"></span></b>
                </p>

                <div class="flex justify-end gap-3">
                    <button onclick="cancelChange()"
                            class="px-4 py-2 bg-gray-200 rounded-lg font-bold">
                        Cancel
                    </button>
                    <button onclick="confirmChange()"
                            class="px-4 py-2 bg-orange-500 text-white rounded-lg font-bold">
                        Confirm
                    </button>
                </div>
            </div>
        </div>

        <script>
            let pendingSelect = null;

            function openConfirmModal(select) {
                const oldStatus = select.dataset.oldStatus;
                const newStatus = select.value;

                if (oldStatus === newStatus)
                    return;

                pendingSelect = select;

                document.getElementById('c-user-id').innerText = select.dataset.userId;
                document.getElementById('c-old').innerText = oldStatus;
                document.getElementById('c-new').innerText = newStatus;

                document.getElementById('confirmModal').classList.remove('hidden');
                document.getElementById('confirmModal').classList.add('flex');
            }

            function cancelChange() {
                if (pendingSelect) {
                    pendingSelect.value = pendingSelect.dataset.oldStatus;
                }
                closeConfirmModal();
            }

            function confirmChange() {
                updateStatusStyle(pendingSelect);
                pendingSelect.form.submit();
            }

            function closeConfirmModal() {
                document.getElementById('confirmModal').classList.add('hidden');
                document.getElementById('confirmModal').classList.remove('flex');
            }
        </script>

        <!-- USER VIEW MODAL -->
        <div id="userModal"
             class="fixed inset-0 bg-black/50 hidden items-center justify-center z-50">

            <div class="bg-white w-full max-w-xl rounded-2xl shadow-lg p-6 relative">

                <h3 class="text-2xl font-black mb-4">User Details</h3>

                <div class="grid grid-cols-2 gap-4 text-sm">

                    <div><strong>ID:</strong> <span id="m-id"></span></div>
                    <div>
                        <strong>Status:</strong>
                        <span id="m-status"
                              class="inline-block px-3 py-1 rounded-full text-xs font-bold">
                        </span>
                    </div>

                    <div class="col-span-2"><strong>Full Name:</strong> <span id="m-name"></span></div>
                    <div class="col-span-2"><strong>Email:</strong> <span id="m-email"></span></div>

                    <div><strong>Role:</strong> <span id="m-role"></span></div>
                    <div><strong>Phone:</strong> <span id="m-phone"></span></div>

                    <div class="col-span-2"><strong>Address:</strong> <span id="m-address"></span></div>

                    <div><strong>Created At:</strong> <span id="m-created"></span></div>
                    <div><strong>Updated At:</strong> <span id="m-updated"></span></div>
                </div>

                <div class="mt-6 text-right">
                    <button onclick="closeUserModal()"
                            class="px-5 py-2 bg-gray-200 rounded-lg font-bold hover:bg-gray-300">
                        Close
                    </button>
                </div>

            </div>
        </div>

        <script>
            function openUserModal(id, name, email, role, status, phone, address, created, updated) {

                document.getElementById('m-id').innerText = id;
                document.getElementById('m-name').innerText = name;
                document.getElementById('m-email').innerText = email;
                document.getElementById('m-role').innerText = role;
                document.getElementById('m-phone').innerText = phone || 'N/A';
                document.getElementById('m-address').innerText = address || 'N/A';
                document.getElementById('m-created').innerText = created;
                document.getElementById('m-updated').innerText = updated;

                const statusEl = document.getElementById('m-status');
                statusEl.innerText = status;

                // reset màu
                statusEl.classList.remove('status-active', 'status-inactive', 'status-blocked');

                // set màu đúng status
                if (status === 'Active') {
                    statusEl.classList.add('status-active');
                } else if (status === 'Inactive') {
                    statusEl.classList.add('status-inactive');
                } else {
                    statusEl.classList.add('status-blocked');
                }

                document.getElementById('userModal').classList.remove('hidden');
                document.getElementById('userModal').classList.add('flex');
            }

            function closeUserModal() {
                document.getElementById('userModal').classList.add('hidden');
                document.getElementById('userModal').classList.remove('flex');
            }
        </script> 

        <!-- EDIT USER MODAL -->
        <div id="editUserModal"
             class="fixed inset-0 bg-black/50 hidden items-center justify-center z-50">

            <div class="bg-white w-full max-w-xl rounded-2xl shadow-lg p-6 relative">

                <h3 class="text-2xl font-black mb-4">Edit User</h3>

                <form id="editUserForm" action="${pageContext.request.contextPath}/owner/change-user-role" method="post" class="space-y-4">

                    <input type="hidden" name="id" id="e-id"/>

                    <!-- giữ filter + pagination -->
                    <input type="hidden" name="keyword" value="${param.keyword}" />
                    <input type="hidden" name="filterRoleId" value="${param.filterRoleId}" />
                    <input type="hidden" name="filterStatus" value="${param.filterStatus}" />
                    <input type="hidden" name="page" value="${currentPage}" />
                    <input type="hidden" name="sort" value="${sort}" />

                    <div>
                        <label class="font-semibold">Full Name</label>
                        <input id="e-name" name="fullName"
                               value="${fullName}"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.fullName != null ? 'border-red-500' : ''}"/>

                        <c:if test="${errors.fullName != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.fullName}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Email</label>
                        <input id="e-email" name="email"
                               value="${email}"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.email != null ? 'border-red-500' : ''}"/>

                        <c:if test="${errors.email != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.email}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Phone</label>
                        <input id="e-phone" name="phone"
                               value="${phone}"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.phone != null ? 'border-red-500' : ''}"/>

                        <c:if test="${errors.phone != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.phone}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Address</label>
                        <input id="e-address" name="address"
                               value="${address}"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.address != null ? 'border-red-500' : ''}"/>

                        <c:if test="${errors.address != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.address}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Role</label>
                        <select id="e-role" name="roleId"
                                class="w-full rounded-lg border px-4 py-2
                                ${errors.roleId != null ? 'border-red-500' : ''}">

                            <option value="1" ${roleId == 1 ? 'selected' : ''}>Customer</option>
                            <option value="2" ${roleId == 2 ? 'selected' : ''}>Veterinarian</option>
                            <option value="3" ${roleId == 3 ? 'selected' : ''}>Receptionist</option>
                            <option value="4" ${roleId == 4 ? 'selected' : ''}>Lab Staff</option>
                            <option value="5" ${roleId == 5 ? 'selected' : ''}>Admin</option>
                            <option value="6" ${roleId == 6 ? 'selected' : ''}>Clinic Owner</option>
                        </select>

                        <c:if test="${errors.roleId != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.roleId}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Status</label>
                        <select id="e-status" name="status"
                                class="w-full rounded-lg border px-4 py-2">
                            <option value="Active">Active</option>
                            <option value="Inactive">Inactive</option>
                            <option value="Blocked">Blocked</option>
                        </select>

                        <c:if test="${errors.status != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.status}</p>
                        </c:if>
                    </div>

                    <div class="flex justify-end gap-3 pt-4">
                        <button type="button"
                                onclick="closeEditUserModal()"
                                class="px-5 py-2 bg-gray-200 rounded-lg font-bold">
                            Cancel
                        </button>

                        <button type="submit"
                                onclick="return handleEditUserSubmit(event)"
                                class="px-5 py-2 bg-orange-500 text-white rounded-lg font-bold">
                            Save
                        </button>
                    </div>

                </form>
            </div>
        </div>

        <script>
            function openEditUserModal(id, name, email, phone, address, roleId, status) {

                document.getElementById('e-id').value = id;
                document.getElementById('e-name').value = name;
                document.getElementById('e-email').value = email;
                document.getElementById('e-phone').value = phone || '';
                document.getElementById('e-address').value = address || '';
                document.getElementById('e-role').value = roleId;
                document.getElementById('e-status').value = status;

                const modal = document.getElementById('editUserModal');
                modal.classList.remove('hidden');
                modal.classList.add('flex');
            }

            function closeEditUserModal() {
                const modal = document.getElementById('editUserModal');
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            }
        </script>

        <c:if test="${openEditModal}">
            <script>
                const modal = document.getElementById('editUserModal');
                modal.classList.remove('hidden');
                modal.classList.add('flex');
            </script>
        </c:if>

       

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

    </body>
</html>
