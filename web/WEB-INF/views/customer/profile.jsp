<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    String displayName = (user.getFullName() != null && !user.getFullName().isEmpty()) ? user.getFullName() : user.getEmail();
    String roleName = (user.getRole() != null && user.getRole().getRoleName() != null) ? user.getRole().getRoleName() : "User";
    String memberSince = (user.getCreatedAt() != null)
            ? user.getCreatedAt().format(DateTimeFormatter.ofPattern("MMM yyyy"))
            : "—";
    String customerId = "AN-" + user.getUserId();
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
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Customer Profile Dashboard - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#ff7b00",
                        "background-light": "#f8f6f6",
                        "background-dark": "#221110",
                    },
                    fontFamily: { "display": ["Manrope"] },
                    borderRadius: {"DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px"},
                },
            },
        }
    </script>
    <style>
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display">
<div class="flex min-h-screen">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    <!-- Main Content -->
    <main class="flex-1 flex flex-col min-w-0">
        <!-- Header -->
        <header class="flex items-center justify-between border-b border-[#f4f0f0] dark:border-white/10 bg-white dark:bg-background-dark px-8 py-4 sticky top-0 z-10">
            <div class="flex items-center gap-8 flex-1">
                <div class="flex items-center gap-2 text-[#181111] dark:text-white">
                    <h2 class="text-lg font-bold tracking-tight">VCMS Portal</h2>
                </div>
                <label class="flex flex-col min-w-40 h-10 max-w-md flex-1">
                    <div class="flex w-full items-stretch rounded-xl bg-background-light dark:bg-white/5 h-full border border-transparent focus-within:border-primary/30 transition-all">
                        <div class="text-[#896461] flex items-center justify-center pl-4">
                            <span class="material-symbols-outlined">search</span>
                        </div>
                        <input class="w-full bg-transparent border-none focus:ring-0 text-[#181111] dark:text-white placeholder:text-[#896461] text-sm" placeholder="Search records, pets, or bills" value=""/>
                    </div>
                </label>
            </div>
            <div class="flex items-center gap-6 ml-4">
                <div class="hidden md:flex items-center gap-6">
                    <a class="text-[#181111] dark:text-white text-sm font-medium hover:text-primary transition-colors" href="<%= ctx %>/index.jsp">Home</a>
                    <a class="text-[#181111] dark:text-white text-sm font-medium hover:text-primary transition-colors" href="#">Support</a>
                </div>
                <div class="flex gap-2 items-center">
                    <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                    <button type="button" class="size-10 flex items-center justify-center rounded-xl bg-background-light dark:bg-white/5 text-[#181111] dark:text-white hover:bg-background-light/80">
                        <span class="material-symbols-outlined">settings</span>
                    </button>
                </div>
                <% if (hasProfilePic) { %>
                <img src="<%= ctx %><%= profilePicUrl %>" alt="<%= displayName %>" class="rounded-full size-10 border-2 border-primary/20 object-cover" title="<%= displayName %>"/>
                <% } else { %>
                <div class="bg-primary/10 rounded-full size-10 border-2 border-primary/20 flex items-center justify-center text-primary font-bold text-lg" title="<%= displayName %>">
                    <%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %>
                </div>
                <% } %>
            </div>
        </header>
        <div class="p-8 max-w-7xl mx-auto w-full">
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
            <!-- Breadcrumbs -->
            <div class="flex items-center gap-2 mb-6">
                <a class="text-[#896461] text-sm font-medium hover:text-primary transition-colors" href="<%= ctx %>/customer/dashboard">Dashboard</a>
                <span class="text-[#896461] text-sm">/</span>
                <span class="text-[#181111] dark:text-white text-sm font-semibold">My Profile</span>
            </div>
            <!-- Profile Overview -->
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
                            <p class="text-[#896461] text-sm font-medium">Customer ID: <%= customerId %> • Member since <%= memberSince %></p>
                            <div class="flex items-center gap-4 mt-2">
                                <span class="px-3 py-1 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300 text-xs font-bold rounded-full uppercase tracking-wider">Active Member</span>
                            </div>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="<%= ctx %>/customer/edit-profile" class="flex items-center gap-2 px-5 py-2.5 bg-background-light dark:bg-white/10 text-[#181111] dark:text-white text-sm font-bold rounded-xl border border-transparent hover:border-primary/20 transition-all">
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
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Contact Details -->
                <div class="lg:col-span-1 space-y-6">
                    <div class="bg-white dark:bg-white/5 rounded-2xl p-6 shadow-sm border border-[#f4f0f0] dark:border-white/10">
                        <h4 class="text-[#181111] dark:text-white text-lg font-bold mb-5 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">contact_page</span>
                            Contact Details
                        </h4>
                        <div class="space-y-4">
                            <div class="flex flex-col">
                                <span class="text-[#896461] text-xs font-medium uppercase tracking-tight">Email Address</span>
                                <span class="text-[#181111] dark:text-white font-medium"><%= user.getEmail() != null ? user.getEmail() : "—" %></span>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[#896461] text-xs font-medium uppercase tracking-tight">Phone Number</span>
                                <span class="text-[#181111] dark:text-white font-medium"><%= (user.getPhone() != null && !user.getPhone().isEmpty()) ? user.getPhone() : "Not set" %></span>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[#896461] text-xs font-medium uppercase tracking-tight">Residential Address</span>
                                <span class="text-[#181111] dark:text-white font-medium"><%= (user.getAddress() != null && !user.getAddress().isEmpty()) ? user.getAddress() : "Not set" %></span>
                            </div>
                            <div class="pt-4 border-t border-[#f4f0f0] dark:border-white/10">
                                <div class="flex flex-col">
                                    <span class="text-primary text-xs font-bold uppercase tracking-tight">Emergency Contact</span>
                                    <span class="text-[#181111] dark:text-white font-medium">Not set</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- My Pets Section -->
                <div class="lg:col-span-2 space-y-6">
                    <div class="flex items-center justify-between">
                        <h4 class="text-[#181111] dark:text-white text-xl font-bold flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">pets</span>
                            My Pets
                        </h4>
                        <button type="button" class="flex items-center gap-2 px-4 py-2 bg-primary text-white text-sm font-bold rounded-xl hover:bg-primary/90 shadow-md shadow-primary/20 transition-all">
                            <span class="material-symbols-outlined text-sm">add</span>
                            Add Pet
                        </button>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <!-- Pet Card 1 (placeholder - wire to real pets when backend ready) -->
                        <div class="bg-white dark:bg-white/5 rounded-2xl p-5 shadow-sm border border-[#f4f0f0] dark:border-white/10 hover:border-primary/30 transition-all group">
                            <div class="flex gap-4">
                                <div class="bg-primary/10 rounded-xl size-20 shrink-0 flex items-center justify-center text-primary">
                                    <span class="material-symbols-outlined text-4xl">pets</span>
                                </div>
                                <div class="flex flex-col justify-between py-1 flex-1">
                                    <div>
                                        <div class="flex justify-between items-start">
                                            <h5 class="text-[#181111] dark:text-white font-bold text-lg">No pets yet</h5>
                                            <span class="px-2 py-0.5 bg-background-light dark:bg-white/10 text-[#896461] dark:text-white/70 text-[10px] font-bold rounded uppercase">—</span>
                                        </div>
                                        <p class="text-[#896461] text-sm">Register a pet to see records here.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="mt-4 flex gap-2">
                                <a href="<%= ctx %>/index.jsp" class="flex-1 text-center text-xs font-bold py-2 bg-background-light dark:bg-white/10 text-[#181111] dark:text-white rounded-lg hover:bg-primary hover:text-white transition-colors no-underline">Book Visit</a>
                            </div>
                        </div>
                        <!-- Add Pet Placeholder -->
                        <div class="border-2 border-dashed border-[#f4f0f0] dark:border-white/10 rounded-2xl p-5 flex flex-col items-center justify-center gap-2 group cursor-pointer hover:border-primary/30 hover:bg-primary/5 transition-all h-[156px]">
                            <div class="size-10 rounded-full bg-background-light dark:bg-white/5 flex items-center justify-center text-[#896461] group-hover:bg-primary group-hover:text-white transition-all">
                                <span class="material-symbols-outlined">add</span>
                            </div>
                            <span class="text-sm font-bold text-[#896461] dark:text-white/70">Register New Pet</span>
                        </div>
                    </div>
                    <!-- Recent Activity Section -->
                    <div class="bg-white dark:bg-white/5 rounded-2xl p-6 shadow-sm border border-[#f4f0f0] dark:border-white/10">
                        <h4 class="text-[#181111] dark:text-white text-lg font-bold mb-5 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">history</span>
                            Recent Activity
                        </h4>
                        <div class="space-y-4">
                            <p class="text-sm text-[#896461]">No recent activity. Book an appointment to get started.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<% if (!isGoogleUser) { %>
<!-- Change Password Modal -->
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
            <p class="text-[#896461] text-sm font-normal leading-normal mt-2 px-4">Ensure your account stays secure by choosing a strong password you haven't used before.</p>
        </div>
        <form method="post" action="<%= ctx %>/customer/change-password" class="p-8 pt-4 space-y-5">
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
                <p class="text-[11px] text-[#896461] leading-tight">Must include 6+ characters. For stronger security use numbers and symbols.</p>
            </div>
            <div class="flex flex-col gap-2">
                <label class="text-[#181111] dark:text-white text-sm font-semibold leading-normal">Confirm New Password</label>
                <div class="relative flex w-full items-stretch rounded-xl border border-[#e6e0db] dark:border-white/20 bg-white dark:bg-white/5 focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/20 overflow-hidden h-12 transition-all">
                    <input name="confirmPassword" class="flex w-full min-w-0 flex-1 border-none bg-transparent text-[#181111] dark:text-white placeholder:text-[#b0a194] px-4 text-sm font-normal leading-normal focus:ring-0" placeholder="Confirm your new password" type="password" required minlength="6" maxlength="128"/>
                </div>
            </div>
            <div class="flex flex-col gap-3 pt-4">
                <button class="w-full bg-primary text-white font-bold py-3 px-6 rounded-xl hover:brightness-105 active:scale-[0.98] transition-all focus:outline-none focus:ring-4 focus:ring-primary/40 shadow-lg shadow-primary/20" type="submit">
                    Save New Password
                </button>
                <button class="w-full text-[#896461] font-semibold py-2 px-6 rounded-xl hover:text-[#181111] dark:hover:text-white transition-colors focus:outline-none" type="button" id="btnCancelModal">
                    Cancel
                </button>
            </div>
        </form>
        <div class="bg-background-light dark:bg-white/5 px-8 py-5 text-center border-t border-[#e6e0db] dark:border-white/10">
            <p class="text-xs text-[#896461]">Forgot your current password? <a class="text-primary font-bold hover:underline" href="<%= ctx %>/login">Sign in</a> to request a reset (contact support).</p>
        </div>
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
    if (modal) modal.addEventListener('click', function(e) {
        if (e.target === modal) closeModal();
    });
})();
</script>
</body>
</html>
