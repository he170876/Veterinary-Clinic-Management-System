<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>User Management</title>

        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&display=swap" rel="stylesheet"/>

        <style>
            body {
                font-family: 'Manrope', sans-serif;
            }

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

            /* dropdown options không bị dính màu */
            .status-select option {
                background-color: white;
                color: #111827;
                font-weight: 600;
            }
        </style>
    </head>

    <body class="bg-[#fdf8f1] text-[#181111]">

        <!-- NAVBAR -->
        <header class="bg-white shadow">
            <div class="max-w-[1200px] mx-auto px-6 py-4 flex justify-between items-center">
                <h1 class="text-2xl font-black">Anipats</h1>
                <nav class="space-x-6 font-semibold">
                    <a href="index.jsp">Home</a>
                    <a href="user-management" class="text-orange-500">User Management</a>
                    <a href="logout">Logout</a>
                </nav>
            </div>
        </header>

        <!-- TITLE -->
        <section class="py-8 bg-[#fff7ed]">
            <div class="max-w-[1200px] mx-auto px-6 flex justify-between items-center">
                <div>
                    <h2 class="text-4xl font-black">User Management</h2>
                    <p class="mt-2 text-[#896163]">Search and filter system users</p>
                </div>
                <button type="button"
                        onclick="openCreateUserModal()"
                        class="px-6 py-3 bg-orange-500 text-white font-bold rounded-xl hover:bg-orange-600">
                    + Add User
                </button>
            </div>
        </section>

        <main class="py-10">
            <div class="max-w-[1200px] mx-auto px-6">

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
                        <option value="Active" ${param.status=='Active'?'selected':''}>Active</option>
                        <option value="Inactive" ${param.status=='Inactive'?'selected':''}>Inactive</option>
                        <option value="Blocked" ${param.status=='Blocked'?'selected':''}>Blocked</option>
                    </select>

                    <button class="bg-orange-500 text-white font-bold rounded-xl">Filter</button>

                    <a href="user-management"
                       class="bg-gray-200 rounded-xl font-bold flex items-center justify-center">
                        Clear
                    </a>
                </form>

                <!-- TABLE -->
                <div class="bg-white rounded-2xl shadow overflow-x-auto">
                    <table class="min-w-full text-sm">
                        <thead class="bg-gray-100">
                            <tr>
                                <th class="px-6 py-4">
                                    <form method="get" action="user-management" class="inline-flex items-center gap-1">

                                        <!-- giữ filter -->
                                        <input type="hidden" name="keyword" value="${param.keyword}" />
                                        <input type="hidden" name="filterRoleId" value="${param.filterRoleId}" />
                                        <input type="hidden" name="filterStatus" value="${param.filterStatus}" />
                                        <input type="hidden" name="page" value="1" />

                                        <!-- sort -->
                                        <input type="hidden" name="sort"
                                               value="${sort == 'id_asc' ? 'id_desc' : 'id_asc'}" />

                                        ID
                                        <button type="submit"
                                                class="ml-1 font-bold text-orange-600 hover:scale-110 transition">

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

                        <tbody class="divide-y">
                            <c:forEach items="${users}" var="u">
                                <tr>
                                    <td class="px-6 py-4">${u.userId}</td>
                                    <td class="px-6 py-4 font-semibold">${u.fullName}</td>
                                    <td class="px-6 py-4">${u.email}</td>
                                    <td class="px-6 py-4">${u.role.roleName}</td>

                                    <!-- STATUS DROPDOWN -->
                                    <td class="px-6 py-4">
                                        <form action="change-user-status" method="post">

                                            <input type="hidden" name="id" value="${u.userId}" />

                                            <!-- giữ filter -->
                                            <input type="hidden" name="keyword" value="${param.keyword}" />
                                            <input type="hidden" name="filterRoleId" value="${param.filterRoleId}" />
                                            <input type="hidden" name="filterStatus" value="${param.filterStatus}" />

                                            <!-- giữ phân trang + sort -->
                                            <input type="hidden" name="page" value="${currentPage}" />
                                            <input type="hidden" name="sort" value="${sort}" />

                                            <!-- status của user -->
                                            <select name="status"
                                                    data-user-id="${u.userId}"
                                                    data-old-status="${u.status}"
                                                    onchange="openConfirmModal(this)"
                                                    class="status-select
                                                    ${u.status == 'Active' ? 'status-active' :
                                                      u.status == 'Inactive' ? 'status-inactive' :
                                                      'status-blocked'}">

                                                <option value="Active" ${u.status=='Active'?'selected':''}>Active</option>
                                                <option value="Inactive" ${u.status=='Inactive'?'selected':''}>Inactive</option>
                                                <option value="Blocked" ${u.status=='Blocked'?'selected':''}>Blocked</option>
                                            </select>
                                        </form>

                                    </td>

                                    <!-- ACTION -->
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

                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty users}">
                                <tr>
                                    <td colspan="6" class="text-center py-10 text-gray-500">
                                        No users found
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="flex justify-between items-center mt-4 text-sm text-gray-600">

                    <c:set var="from" value="${(currentPage - 1) * pageSize + 1}" />
                    <c:set var="to" value="${currentPage * pageSize}" />

                    <c:if test="${to > totalUsers}">
                        <c:set var="to" value="${totalUsers}" />
                    </c:if>

                    <div>
                        Showing
                        <b>${from}</b>
                        to
                        <b>${to}</b>
                        of
                        <b>${totalUsers}</b>
                        users
                    </div>

                </div>

                <!-- PAGINATION -->
                <c:if test="${totalPages > 1}">
                    <div class="flex justify-center items-center gap-2 mt-8">

                        <!-- PREV -->
                        <c:if test="${currentPage > 1}">
                            <a href="user-management?page=${currentPage-1}&keyword=${param.keyword}&filterRoleId=${param.filterRoleId}&filterStatus=${param.filterStatus}&sort=${sort}"
                               class="px-4 py-2 rounded-lg bg-gray-200 font-bold hover:bg-gray-300">
                                Prev
                            </a>
                        </c:if>

                        <!-- PAGE NUMBERS -->
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="user-management?page=${i}&keyword=${param.keyword}&filterRoleId=${param.filterRoleId}&filterStatus=${param.filterStatus}&sort=${sort}"
                               class="px-4 py-2 rounded-lg font-bold
                               ${i == currentPage ? 'bg-orange-500 text-white' : 'bg-gray-100 hover:bg-gray-200'}">
                                ${i}
                            </a>
                        </c:forEach>

                        <!-- NEXT -->
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

        <footer class="bg-[#181111] text-white py-10 mt-20 text-center opacity-70">
            © 2025 Anipats
        </footer>

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

                <form action="edit-user" method="post" class="space-y-4">

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
                                onclick="return confirm('Save changes for this user?')"
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

        <!-- CREATE USER MODAL -->
        <div id="createUserModal"
             class="fixed inset-0 bg-black/50 hidden items-center justify-center z-50">

            <div class="bg-white w-full max-w-xl rounded-2xl shadow-lg p-6 relative">

                <h3 class="text-2xl font-black mb-4">Create User</h3>

                <form action="create-user" method="post" class="space-y-4">

                    <!-- giữ filter + pagination -->
                    <input type="hidden" name="keyword" value="${param.keyword}" />
                    <input type="hidden" name="filterRoleId" value="${param.filterRoleId}" />
                    <input type="hidden" name="filterStatus" value="${param.filterStatus}" />
                    <input type="hidden" name="page" value="${currentPage}" />
                    <input type="hidden" name="sort" value="${sort}" />

                    <div>
                        <label class="font-semibold">Full Name</label>
                        <input name="fullName"
                               value="${fullName}"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.fullName != null ? 'border-red-500' : ''}" required=""/>

                        <c:if test="${errors.fullName != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.fullName}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Email</label>
                        <input name="email"
                               value="${email}"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.email != null ? 'border-red-500' : ''}" required=""/>

                        <c:if test="${errors.email != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.email}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Password</label>
                        <input type="password" name="password"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.password != null ? 'border-red-500' : ''}" required=""/>

                        <c:if test="${errors.password != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.password}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="block mb-1 font-medium">Re-enter Password</label>
                        <input type="password"
                               name="confirmPassword"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.confirmPassword != null ? 'border-red-500' : ''}"
                               required>

                        <c:if test="${errors.confirmPassword != null}">
                            <p class="text-red-500 text-sm mt-1">
                                ${errors.confirmPassword}
                            </p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Phone</label>
                        <input name="phone"
                               value="${phone}"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.phone != null ? 'border-red-500' : ''}"/>

                        <c:if test="${errors.phone != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.phone}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Address</label>
                        <input name="address"
                               value="${address}"
                               class="w-full rounded-lg border px-4 py-2
                               ${errors.address != null ? 'border-red-500' : ''}"/>

                        <c:if test="${errors.address != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.address}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="font-semibold">Role</label>
                        <select name="roleId"
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
                        <select name="status"
                                class="w-full rounded-lg border px-4 py-2">
                            <option value="Active" ${status == 'Active' ? 'selected' : ''}>Active</option>
                            <option value="Inactive" ${status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                            <option value="Blocked" ${status == 'Blocked' ? 'selected' : ''}>Blocked</option>
                        </select>

                        <c:if test="${errors.status != null}">
                            <p class="text-red-500 text-sm mt-1">${errors.status}</p>
                        </c:if>
                    </div>

                    <div class="flex justify-end gap-3 pt-4">
                        <button type="button"
                                onclick="closeCreateUserModal()"
                                class="px-5 py-2 bg-gray-200 rounded-lg font-bold">
                            Cancel
                        </button>

                        <button type="submit"
                                onclick="return confirm('Create this user?')"
                                class="px-5 py-2 bg-orange-500 text-white rounded-lg font-bold">
                            Create
                        </button>
                    </div>

                </form>
            </div>
        </div>

        <script>
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

    </body>
</html>
