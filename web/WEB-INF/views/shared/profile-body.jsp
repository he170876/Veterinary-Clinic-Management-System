<%
    Object userObj = request.getAttribute("user");
    model.User user = (userObj instanceof model.User) ? (model.User) userObj : null;
    if (user == null && session != null) {
        Object sessionUserObj = session.getAttribute("currentUser");
        if (sessionUserObj instanceof model.User) {
            user = (model.User) sessionUserObj;
        }
    }
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String ctx = request.getContextPath();
    String roleName = (user.getRole() != null && user.getRole().getRoleName() != null) ? user.getRole().getRoleName().trim() : "";
    String normalizedRole = roleName.toLowerCase().replace(" ", "").replace("_", "").replace("-", "");

    String roleSegment = "customer";
    if ("veterinarian".equals(normalizedRole) || "vet".equals(normalizedRole) || "veterinary".equals(normalizedRole)) {
        roleSegment = "vet";
    } else if ("receptionist".equals(normalizedRole) || "frontdesk".equals(normalizedRole)) {
        roleSegment = "Receptionist";
    } else if ("labstaff".equals(normalizedRole) || "lab".equals(normalizedRole) || "laboratory".equals(normalizedRole) || "labtechnician".equals(normalizedRole)) {
        roleSegment = "lab";
    } else if ("admin".equals(normalizedRole) || "clinicowner".equals(normalizedRole) || "owner".equals(normalizedRole) || "administrator".equals(normalizedRole)) {
        roleSegment = "admin";
    }

    String basePath = "/" + roleSegment;
    boolean isCustomerRole = "customer".equalsIgnoreCase(roleSegment);
    boolean isVetRole = "vet".equalsIgnoreCase(roleSegment);
    boolean isLabRole = "lab".equalsIgnoreCase(roleSegment);
    boolean isReceptionistRole = "Receptionist".equals(roleSegment);
    boolean isAdminRole = "admin".equalsIgnoreCase(roleSegment);

    String dashboardUrl = ctx + "/customer/dashboard";
    if ("vet".equalsIgnoreCase(roleSegment)) {
        dashboardUrl = ctx + "/vet/dashboard";
    } else if ("Receptionist".equals(roleSegment)) {
        dashboardUrl = ctx + "/Receptionist/Dashboard";
    } else if ("lab".equalsIgnoreCase(roleSegment)) {
        dashboardUrl = ctx + "/lab/labqueue";
    } else if ("admin".equalsIgnoreCase(roleSegment)) {
        dashboardUrl = ctx + "/owner/dashboard";
    }

    String displayName = (user.getFullName() != null && !user.getFullName().isEmpty()) ? user.getFullName() : user.getEmail();
    String memberSince = (user.getCreatedAt() != null)
            ? user.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("MMM yyyy"))
            : "-";
    String accountId = "AN-" + user.getUserId();

    String profilePicUrl = user.getProfilePictureUrl();
    boolean hasProfilePic = (profilePicUrl != null && !profilePicUrl.isEmpty());
    boolean isGoogleUser = user.isGoogleUser();

    String pwMsg = request.getParameter("pw");
    String pwErr = request.getParameter("pwError");
    String decodedPwErr = null;
    if (pwErr != null && !pwErr.isEmpty()) {
        try {
            decodedPwErr = java.net.URLDecoder.decode(pwErr, "UTF-8");
        } catch (Exception e) {
            decodedPwErr = pwErr;
        }
    }
    String profileUpdated = request.getParameter("updated");

    request.setAttribute("customerCurrentPage", "profile");
    request.setAttribute("customerHeaderTitle", "My Profile");
    request.setAttribute("customerHeaderSubtitle", "Manage your account details and security settings.");
    request.setAttribute("customerHeaderDisplayName", displayName);
    request.setAttribute("customerHeaderRoleText", (roleName == null || roleName.isEmpty()) ? "User" : roleName);
    request.setAttribute("customerHeaderShowAvatar", "true");
    request.setAttribute("profileBasePath", basePath);
    request.setAttribute("customerHeaderActionUrl", dashboardUrl);
    request.setAttribute("customerHeaderActionLabel", "Back to Dashboard");
    request.setAttribute("customerHeaderActionIcon", "arrow_back");
    if (hasProfilePic) {
        request.setAttribute("customerHeaderAvatarUrl", ctx + profilePicUrl);
    }
    request.setAttribute("customerHeaderAvatarInitial", displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?");

    String editProfileUrl = ctx + basePath + "/edit-profile";
    String changePasswordUrl = ctx + basePath + "/change-password";
%>
<body class="bg-background-light dark:bg-background-dark font-display">
<div class="flex min-h-screen">
    <% if (isCustomerRole) { %>
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    <% } else if (isVetRole) { %>
    <%@ include file="/WEB-INF/views/vet/_sidebar.jspf" %>
    <% } else if (isLabRole) {
        request.setAttribute("labSidebarActive", "queue");
    %>
    <%@ include file="/WEB-INF/views/lab/_lab-sidebar.jspf" %>
    <% } else if (isReceptionistRole) { %>
    <aside class="w-64 border-r border-slate-200 bg-white flex flex-col h-screen sticky top-0">
        <div class="p-6 flex items-center gap-3">
            <div class="w-10 h-10 bg-primary rounded-xl flex items-center justify-center">
                <span class="material-symbols-outlined text-white">pets</span>
            </div>
            <span class="text-2xl font-bold tracking-tight">Anipat</span>
        </div>
        <nav class="flex-1 px-4 mt-4 space-y-1">
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="<%= ctx %>/Receptionist/Dashboard">
                <span class="material-symbols-outlined">dashboard</span>
                <span class="font-medium">Dashboard</span>
            </a>
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="<%= ctx %>/Receptionist/ViewListAppointment">
                <span class="material-symbols-outlined">calendar_today</span>
                <span class="font-medium">Schedule</span>
            </a>
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="<%= ctx %>/Receptionist/ManageAppointmentRequests">
                <span class="material-symbols-outlined">pending_actions</span>
                <span class="font-medium">Request Center</span>
            </a>
            <a class="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary text-white shadow-lg shadow-primary/20" href="<%= ctx %>/Receptionist/profile">
                <span class="material-symbols-outlined">person</span>
                <span class="font-medium">My Profile</span>
            </a>
        </nav>
    </aside>
    <% } else if (isAdminRole) { %>
    <aside class="w-72 bg-white border-r border-[#e9d9ce] flex flex-col h-full">
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
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] rounded-xl transition-all" href="<%= ctx %>/owner/dashboard">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm font-semibold">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] rounded-xl transition-all" href="<%= ctx %>/owner/user-management">
                        <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">group</span>
                        <span class="text-sm font-semibold">User Management</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] rounded-xl transition-all" href="<%= ctx %>/owner/services">
                        <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">medical_services</span>
                        <span class="text-sm font-semibold">Services</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] rounded-xl transition-all" href="<%= ctx %>/owner/images">
                        <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">image</span>
                        <span class="text-sm font-semibold">Images</span>
                    </a>
                    <a class="flex items-center gap-3 px-4 py-3 rounded-full bg-primary text-white transition-all" href="<%= ctx %>/admin/profile">
                        <span class="material-symbols-outlined">person</span>
                        <span class="text-sm font-bold">My Profile</span>
                    </a>
                </nav>
            </div>
        </div>
    </aside>
    <% } %>

    <main class="flex-1 flex flex-col min-w-0">
        <% if (isCustomerRole) { %>
        <jsp:include page="/WEB-INF/includes/customer-header.jsp"/>
        <% } else { %>
        <header class="h-16 border-b border-slate-200 bg-white flex items-center justify-between px-8 sticky top-0 z-10">
            <div>
                <h2 class="text-lg font-bold text-slate-800">My Profile</h2>
                <p class="text-xs text-slate-500"><%= roleName == null || roleName.isEmpty() ? "User" : roleName %></p>
            </div>
            <div class="flex items-center gap-4">
                <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                <div class="relative">
                    <button type="button" id="role-profile-toggle" class="w-10 h-10 rounded-full overflow-hidden focus:outline-none bg-primary/10 text-primary flex items-center justify-center">
                        <% if (hasProfilePic) { %>
                        <img alt="Profile" class="w-full h-full object-cover" src="<%= ctx %><%= profilePicUrl %>"/>
                        <% } else { %>
                        <span class="font-semibold"><%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %></span>
                        <% } %>
                    </button>
                    <div id="role-profile-menu" class="absolute right-0 mt-2 w-48 origin-top-right rounded-xl bg-white shadow-lg border border-slate-200 z-50" style="display:none;">
                        <a href="<%= ctx %><%= basePath %>/profile" class="block px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 rounded-t-xl">My Profile</a>
                        <a href="<%= ctx %>/logout" class="block px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 rounded-b-xl">Sign out</a>
                    </div>
                </div>
            </div>
        </header>
        <% } %>
        <div class="p-8 max-w-6xl mx-auto w-full">
            <% if ("1".equals(profileUpdated)) { %>
            <div class="mb-6 p-4 rounded-xl bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-800 dark:text-green-200 text-sm font-medium">
                Profile updated successfully.
            </div>
            <% } %>
            <% if ("1".equals(pwMsg)) { %>
            <div class="mb-6 p-4 rounded-xl bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-800 dark:text-green-200 text-sm font-medium">
                Password updated successfully.
            </div>
            <% } %>
            <% if (decodedPwErr != null && !decodedPwErr.isEmpty()) { %>
            <div class="mb-6 p-4 rounded-xl bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm font-medium">
                <%= decodedPwErr.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") %>
            </div>
            <% } %>

            <div class="flex items-center gap-2 mb-6 text-sm">
                <a class="text-[#896461] hover:text-primary transition-colors" href="<%= dashboardUrl %>">Dashboard</a>
                <span class="text-[#896461]">/</span>
                <span class="text-[#181111] dark:text-white font-semibold">My Profile</span>
            </div>

            <div class="bg-white dark:bg-white/5 rounded-2xl p-6 shadow-sm border border-[#f4f0f0] dark:border-white/10 mb-8">
                <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                    <div class="flex items-center gap-6">
                        <% if (hasProfilePic) { %>
                        <img src="<%= ctx %><%= profilePicUrl %>" alt="<%= displayName %>" class="rounded-full size-24 border-4 border-white dark:border-background-dark shadow-md object-cover"/>
                        <% } else { %>
                        <div class="bg-primary/10 rounded-full size-24 border-4 border-white dark:border-background-dark shadow-md flex items-center justify-center text-primary font-bold text-4xl">
                            <%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %>
                        </div>
                        <% } %>
                        <div class="flex flex-col">
                            <h3 class="text-[#181111] dark:text-white text-2xl font-bold"><%= displayName %></h3>
                            <p class="text-[#896461] text-sm font-medium"><%= roleName == null || roleName.isEmpty() ? "User" : roleName %> | ID: <%= accountId %> | Member since <%= memberSince %></p>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="<%= editProfileUrl %>" class="flex items-center gap-2 px-5 py-2.5 bg-background-light dark:bg-white/10 text-[#181111] dark:text-white text-sm font-bold rounded-xl border border-transparent hover:border-primary/20 transition-all">
                            <span class="material-symbols-outlined text-sm">edit</span>
                            Edit Profile
                        </a>
                        <% if (!isGoogleUser) { %>
                        <button type="button" id="btnChangePassword" class="flex items-center gap-2 px-5 py-2.5 bg-background-light dark:bg-white/10 text-[#181111] dark:text-white text-sm font-bold rounded-xl border border-transparent hover:border-primary/20 transition-all">
                            <span class="material-symbols-outlined text-sm">lock_reset</span>
                            Change Password
                        </button>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div class="bg-white dark:bg-white/5 rounded-2xl p-6 shadow-sm border border-[#f4f0f0] dark:border-white/10">
                    <h4 class="text-[#181111] dark:text-white text-lg font-bold mb-5 flex items-center gap-2">
                        <span class="material-symbols-outlined text-primary">contact_page</span>
                        Contact Details
                    </h4>
                    <div class="space-y-4">
                        <div class="flex flex-col">
                            <span class="text-[#896461] text-xs font-medium uppercase tracking-tight">Email Address</span>
                            <span class="text-[#181111] dark:text-white font-medium"><%= user.getEmail() != null ? user.getEmail() : "-" %></span>
                        </div>
                        <div class="flex flex-col">
                            <span class="text-[#896461] text-xs font-medium uppercase tracking-tight">Phone Number</span>
                            <span class="text-[#181111] dark:text-white font-medium"><%= (user.getPhone() != null && !user.getPhone().isEmpty()) ? user.getPhone() : "Not set" %></span>
                        </div>
                        <div class="flex flex-col">
                            <span class="text-[#896461] text-xs font-medium uppercase tracking-tight">Address</span>
                            <span class="text-[#181111] dark:text-white font-medium"><%= (user.getAddress() != null && !user.getAddress().isEmpty()) ? user.getAddress() : "Not set" %></span>
                        </div>
                    </div>
                </div>

                <div class="bg-white dark:bg-white/5 rounded-2xl p-6 shadow-sm border border-[#f4f0f0] dark:border-white/10">
                    <h4 class="text-[#181111] dark:text-white text-lg font-bold mb-5 flex items-center gap-2">
                        <span class="material-symbols-outlined text-primary">verified_user</span>
                        Account Security
                    </h4>
                    <div class="space-y-4 text-sm text-[#896461]">
                        <p>Keep your profile information up-to-date to receive clinic notifications and reminders.</p>
                        <p>Use a strong password with a mix of uppercase letters, numbers, and symbols.</p>
                        <p>Last updated: <span class="text-[#181111] dark:text-white font-semibold"><%= memberSince %></span></p>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<% if (!isGoogleUser) { %>
<div id="modalChangePassword" class="fixed inset-0 z-[100] hidden items-center justify-center p-4 bg-[#181111]/60 backdrop-blur-sm">
    <div class="w-full max-w-[480px] bg-white dark:bg-white/10 rounded-2xl shadow-2xl border border-white/20 overflow-hidden">
        <div class="relative pt-8 pb-4 px-8 text-center">
            <button type="button" class="absolute top-6 right-6 text-[#896461] hover:text-primary transition-colors" id="btnCloseModal" aria-label="Close">
                <span class="material-symbols-outlined">close</span>
            </button>
            <div class="inline-flex items-center justify-center size-14 bg-primary/10 text-primary rounded-full mb-4">
                <span class="material-symbols-outlined text-3xl">lock_reset</span>
            </div>
            <h1 class="text-[#181111] dark:text-white text-2xl font-bold leading-tight font-display">Change Password</h1>
            <p class="text-[#896461] text-sm font-normal leading-normal mt-2 px-4">Ensure your account stays secure by choosing a strong password you have not used before.</p>
        </div>
        <form method="post" action="<%= changePasswordUrl %>" class="p-8 pt-4 space-y-5">
            <div class="flex flex-col gap-2">
                <label class="text-[#181111] dark:text-white text-sm font-semibold leading-normal">Current Password</label>
                <div class="relative flex w-full items-stretch rounded-xl border border-[#e6e0db] dark:border-white/20 bg-white dark:bg-white/5 focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/20 overflow-hidden h-12 transition-all">
                    <input name="currentPassword" class="flex w-full min-w-0 flex-1 border-none bg-transparent text-[#181111] dark:text-white placeholder:text-[#b0a194] px-4 text-sm font-normal leading-normal focus:ring-0" placeholder="Enter current password" type="password" required/>
                </div>
            </div>
            <div class="flex flex-col gap-2">
                <label class="text-[#181111] dark:text-white text-sm font-semibold leading-normal">New Password</label>
                <div class="relative flex w-full items-stretch rounded-xl border border-[#e6e0db] dark:border-white/20 bg-white dark:bg-white/5 focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/20 overflow-hidden h-12 transition-all">
                    <input name="newPassword" class="flex w-full min-w-0 flex-1 border-none bg-transparent text-[#181111] dark:text-white placeholder:text-[#b0a194] px-4 text-sm font-normal leading-normal focus:ring-0" placeholder="6-128 chars, 1 uppercase, 1 number" type="password" required minlength="6" maxlength="128"/>
                </div>
            </div>
            <div class="flex flex-col gap-2">
                <label class="text-[#181111] dark:text-white text-sm font-semibold leading-normal">Confirm New Password</label>
                <div class="relative flex w-full items-stretch rounded-xl border border-[#e6e0db] dark:border-white/20 bg-white dark:bg-white/5 focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/20 overflow-hidden h-12 transition-all">
                    <input name="confirmPassword" class="flex w-full min-w-0 flex-1 border-none bg-transparent text-[#181111] dark:text-white placeholder:text-[#b0a194] px-4 text-sm font-normal leading-normal focus:ring-0" placeholder="Confirm your new password" type="password" required minlength="6" maxlength="128"/>
                </div>
            </div>
            <div class="flex flex-col gap-3 pt-4">
                <button class="w-full bg-primary text-white font-bold py-3 px-6 rounded-xl hover:brightness-105 active:scale-[0.98] transition-all focus:outline-none focus:ring-4 focus:ring-primary/40 shadow-lg shadow-primary/20" type="submit">Save New Password</button>
                <button class="w-full text-[#896461] font-semibold py-2 px-6 rounded-xl hover:text-[#181111] dark:hover:text-white transition-colors focus:outline-none" type="button" id="btnCancelModal">Cancel</button>
            </div>
        </form>
    </div>
</div>
<% } %>

<script>
(function() {
    var modal = document.getElementById('modalChangePassword');
    var btnOpen = document.getElementById('btnChangePassword');
    var btnClose = document.getElementById('btnCloseModal');
    var btnCancel = document.getElementById('btnCancelModal');
    if (!modal || !btnOpen) return;

    btnOpen.addEventListener('click', function() {
        modal.classList.remove('hidden');
        modal.classList.add('flex');
    });

    function closeModal() {
        modal.classList.add('hidden');
        modal.classList.remove('flex');
    }

    if (btnClose) btnClose.addEventListener('click', closeModal);
    if (btnCancel) btnCancel.addEventListener('click', closeModal);
    modal.addEventListener('click', function(e) {
        if (e.target === modal) closeModal();
    });
})();
</script>
<script>
(function() {
    var toggle = document.getElementById('role-profile-toggle');
    var menu = document.getElementById('role-profile-menu');
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