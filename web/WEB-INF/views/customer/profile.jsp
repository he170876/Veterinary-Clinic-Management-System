<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%!
    String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    String displayName = (user.getFullName() != null && !user.getFullName().isEmpty()) ? user.getFullName() : user.getEmail();
    String roleTitle = (user.getRole() != null && user.getRole().getRoleName() != null) ? user.getRole().getRoleName() : "Customer";
    String memberSince = (user.getCreatedAt() != null)
            ? user.getCreatedAt().format(DateTimeFormatter.ofPattern("MMM yyyy"))
            : "—";
    String customerId = "AN-" + user.getUserId();
    String profilePicUrl = user.getProfilePictureUrl();
    boolean hasProfilePic = (profilePicUrl != null && !profilePicUrl.isEmpty());
    String profilePicCacheBust = "";
    if (hasProfilePic && user.getUpdatedAt() != null) {
        profilePicCacheBust = "?v=" + user.getUpdatedAt().atZone(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli();
    }
    boolean isGoogleUser = user.isGoogleUser();
    String pwMsg = request.getParameter("pw");
    String pwErr = request.getParameter("pwError");
    String profileUpdated = request.getParameter("updated");
    request.setAttribute("customerCurrentPage", "profile");
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>My Profile - Anipats</title>
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
                        "background-light": "#f8f7f5",
                        "background-dark": "#23190f",
                    },
                    fontFamily: { "display": ["Manrope"] },
                },
            },
        }
    </script>
    <style>
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100">
<div class="flex min-h-screen overflow-hidden">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    <main class="flex-1 flex flex-col min-w-0">
        <header class="h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-8">
            <div class="flex items-center gap-2 text-slate-500 text-sm min-w-0">
                <a class="hover:text-primary" href="<%= ctx %>/customer/dashboard">Dashboard</a>
                <span class="material-symbols-outlined text-xs shrink-0">chevron_right</span>
                <span class="text-slate-900 dark:text-slate-100 font-medium truncate">My Profile</span>
            </div>
            <%@ include file="/WEB-INF/includes/customer-header-right.jspf" %>
        </header>
        <div class="flex-1 overflow-y-auto p-8">
            <div class="max-w-4xl mx-auto space-y-6">
                <% if ("1".equals(profileUpdated)) { %>
                <div class="p-4 rounded-xl bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-800 dark:text-green-200 text-sm font-medium">
                    Profile updated successfully.
                </div>
                <% } %>
                <% if ("1".equals(pwMsg)) { %>
                <div class="p-4 rounded-xl bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-800 dark:text-green-200 text-sm font-medium">
                    Password updated successfully.
                </div>
                <% } %>
                <% if (pwErr != null && !pwErr.isEmpty()) { %>
                <div class="p-4 rounded-xl bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm font-medium">
                    <%= java.net.URLDecoder.decode(pwErr, "UTF-8") %>
                </div>
                <% } %>
                <div class="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm flex flex-col md:flex-row items-start md:items-center gap-6">
                    <div class="flex items-center gap-4">
                        <% if (hasProfilePic) { %>
                        <img src="<%= ctx %><%= esc(profilePicUrl) %><%= profilePicCacheBust %>" alt="" class="rounded-full size-20 border-4 border-white dark:border-slate-800 object-cover"/>
                        <% } else { %>
                        <div class="bg-primary/10 rounded-full size-20 border-4 border-white dark:border-slate-800 flex items-center justify-center text-primary font-bold text-3xl">
                            <%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %>
                        </div>
                        <% } %>
                        <div>
                            <h1 class="text-2xl font-bold text-slate-900 dark:text-slate-100"><%= esc(displayName) %></h1>
                            <p class="text-sm text-slate-500 dark:text-slate-400"><%= esc(roleTitle) %> · <%= esc(customerId) %> · Member since <%= esc(memberSince) %></p>
                        </div>
                    </div>
                    <div class="ml-auto flex gap-2 flex-wrap">
                        <a href="<%= ctx %>/customer/edit-profile" class="px-4 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-sm font-semibold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800">
                            Edit Profile
                        </a>
                        <% if (!isGoogleUser) { %>
                        <button type="button" id="btnChangePassword" class="px-4 py-2 rounded-lg bg-primary text-white text-sm font-semibold hover:bg-primary/90">
                            Change Password
                        </button>
                        <% } %>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
                        <h2 class="text-sm font-bold text-slate-700 dark:text-slate-200 mb-4 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">contact_page</span>
                            Contact Details
                        </h2>
                        <dl class="space-y-3 text-sm">
                            <div>
                                <dt class="text-slate-400">Email</dt>
                                <dd class="text-slate-900 dark:text-slate-100 font-medium"><%= user.getEmail() != null ? esc(user.getEmail()) : "—" %></dd>
                            </div>
                            <div>
                                <dt class="text-slate-400">Phone</dt>
                                <dd class="text-slate-900 dark:text-slate-100 font-medium"><%= (user.getPhone() != null && !user.getPhone().isEmpty()) ? esc(user.getPhone()) : "Not set" %></dd>
                            </div>
                            <div>
                                <dt class="text-slate-400">Address</dt>
                                <dd class="text-slate-900 dark:text-slate-100 font-medium"><%= (user.getAddress() != null && !user.getAddress().isEmpty()) ? esc(user.getAddress()) : "Not set" %></dd>
                            </div>
                            <div>
                                <dt class="text-slate-400">Emergency contact</dt>
                                <dd class="text-slate-900 dark:text-slate-100 font-medium"><span class="text-slate-400">Not set</span></dd>
                            </div>
                        </dl>
                    </div>
                    <div class="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-slate-200 dark:border-slate-800 shadow-sm">
                        <h2 class="text-sm font-bold text-slate-700 dark:text-slate-200 mb-4 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">pets</span>
                            Pets &amp; visits
                        </h2>
                        <p class="text-sm text-slate-500 dark:text-slate-400 mb-4">
                            Manage your pets, appointments, and medical records from the sidebar menu.
                        </p>
                        <div class="flex flex-wrap gap-2">
                            <a href="<%= ctx %>/pets" class="inline-flex items-center gap-1 px-3 py-2 rounded-lg bg-primary/10 text-primary text-xs font-bold hover:bg-primary/15">My Pets</a>
                            <a href="<%= ctx %>/customer/appointments/book" class="inline-flex items-center gap-1 px-3 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-xs font-semibold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800">Book appointment</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
<% if (!isGoogleUser) { %>
<div id="modalChangePassword" class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
    <div class="w-full max-w-md bg-white dark:bg-slate-900 rounded-2xl shadow-2xl border border-slate-200 dark:border-slate-700 overflow-hidden">
        <div class="px-6 pt-6 pb-4 flex items-center justify-between">
            <div>
                <h2 class="text-lg font-bold text-slate-900 dark:text-slate-100">Change Password</h2>
                <p class="text-xs text-slate-500 dark:text-slate-400 mt-1">Choose a strong password you haven't used before.</p>
            </div>
            <button type="button" id="btnCloseModal" class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <form method="post" action="<%= ctx %>/customer/change-password" class="px-6 pb-6 space-y-4">
            <div class="space-y-1">
                <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">Current Password</label>
                <input name="currentPassword" type="password" required
                       class="w-full h-10 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 px-3 text-sm focus:ring-primary focus:border-primary"/>
            </div>
            <div class="space-y-1">
                <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">New Password</label>
                <input name="newPassword" type="password" required
                       class="w-full h-10 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 px-3 text-sm focus:ring-primary focus:border-primary"/>
                <p class="text-[11px] text-slate-400 mt-1">6-128 chars, at least 1 uppercase and 1 number.</p>
            </div>
            <div class="space-y-1">
                <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">Confirm Password</label>
                <input name="confirmPassword" type="password" required
                       class="w-full h-10 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 px-3 text-sm focus:ring-primary focus:border-primary"/>
            </div>
            <div class="pt-2 flex justify-end gap-2">
                <button type="button" id="btnCancelModal" class="px-4 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-sm font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800">
                    Cancel
                </button>
                <button type="submit" class="px-5 py-2 rounded-lg bg-primary text-white text-sm font-semibold hover:bg-primary/90">
                    Update Password
                </button>
            </div>
        </form>
    </div>
</div>
<script>
(function() {
    var openBtn = document.getElementById('btnChangePassword');
    var closeBtn = document.getElementById('btnCloseModal');
    var cancelBtn = document.getElementById('btnCancelModal');
    var modal = document.getElementById('modalChangePassword');
    if (!openBtn || !modal) return;
    function hide() { modal.classList.add('hidden'); modal.classList.remove('flex'); }
    openBtn.addEventListener('click', function() {
        modal.classList.remove('hidden');
        modal.classList.add('flex');
    });
    if (closeBtn) closeBtn.addEventListener('click', hide);
    if (cancelBtn) cancelBtn.addEventListener('click', function(e) { e.preventDefault(); hide(); });
})();
</script>
<% } %>
</body>
</html>
