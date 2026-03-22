<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    String displayName = (user.getFullName() != null && !user.getFullName().isEmpty()) ? user.getFullName() : user.getEmail();
    String profilePicUrl = user.getProfilePictureUrl();
    boolean hasProfilePic = profilePicUrl != null && !profilePicUrl.isEmpty();
    String err = request.getParameter("error");
    boolean requiredPhone = "phone".equals(request.getParameter("required"));
%>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Receptionist - Edit Profile - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <style>
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100">
<div class="min-h-screen">
    <header class="h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-8">
        <div class="flex items-center gap-2 text-slate-500 text-sm">
            <span class="material-symbols-outlined text-xs">chevron_right</span>
            <span class="text-slate-900 dark:text-slate-100 font-medium">Edit Profile</span>
        </div>
        <div class="flex items-center gap-4">
            <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
            <div class="relative">
                <button type="button"
                        id="receptionist-profile-toggle"
                        class="w-10 h-10 rounded-full overflow-hidden focus:outline-none">
                    <% if (hasProfilePic) { %>
                    <img alt="Profile" class="w-full h-full object-cover" src="<%= ctx %><%= profilePicUrl %>"/>
                    <% } else { %>
                    <span class="material-symbols-outlined text-primary bg-primary/10 w-full h-full flex items-center justify-center">
                        person
                    </span>
                    <% } %>
                </button>
                <div id="receptionist-profile-menu"
                     class="absolute right-0 mt-2 w-44 origin-top-right rounded-xl bg-white shadow-lg border border-slate-200 z-50"
                     style="display:none;">
                    <a href="<%= ctx %>/Receptionist/profile"
                       class="block px-4 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50 transition-colors rounded-xl flex items-center gap-2">
                        <span class="material-symbols-outlined text-base text-primary">person</span>
                        <span>My Profile</span>
                    </a>
                    <a href="<%= ctx %>/logout"
                       class="block px-4 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50 transition-colors rounded-b-xl flex items-center gap-2">
                        <span class="material-symbols-outlined text-base text-primary">logout</span>
                        <span>Sign out</span>
                    </a>
                </div>
            </div>
        </div>
    </header>

    <main class="max-w-3xl mx-auto p-8">
        <div class="flex items-center gap-2 mb-6">
            <a class="text-slate-500 hover:text-primary transition-colors text-sm font-semibold" href="<%= ctx %>/Receptionist/profile">My Profile</a>
            <span class="material-symbols-outlined text-slate-400 text-base leading-none">chevron_right</span>
            <span class="text-primary text-sm font-bold">Edit Profile</span>
        </div>

        <% if (err != null && !err.isEmpty()) { %>
        <div class="mb-6 p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 text-sm font-medium">
            <%= java.net.URLDecoder.decode(err, "UTF-8") %>
        </div>
        <% } %>

        <form method="post"
              action="<%= ctx %>/Receptionist/edit-profile"
              enctype="multipart/form-data"
              class="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm p-6">
            <div class="flex flex-col md:flex-row md:items-center md:gap-6 gap-4 mb-6">
                <div class="relative w-28 h-28 rounded-full overflow-hidden border-4 border-white dark:border-slate-800 shadow-sm bg-primary/10 flex items-center justify-center">
                    <% if (hasProfilePic) { %>
                    <img id="profilePhotoPreview"
                         src="<%= ctx %><%= profilePicUrl %>"
                         alt="Profile"
                         class="w-full h-full object-cover"/>
                    <% } else { %>
                    <span id="profilePhotoInitial" class="material-symbols-outlined text-primary text-5xl">person</span>
                    <% } %>
                </div>
                <div class="flex-1">
                    <div class="mb-4">
                        <label class="text-sm font-bold text-slate-700 dark:text-slate-200 mb-2 block">Profile Picture</label>
                        <input type="file" name="profilePicture" accept="image/jpeg,image/png,image/gif" class="block w-full text-sm text-slate-700 dark:text-slate-200"/>
                    </div>
                    <% if (hasProfilePic) { %>
                    <label class="flex items-center gap-2 text-sm font-semibold text-slate-600 dark:text-slate-300">
                        <input type="checkbox" name="removePhoto" value="1" class="rounded border-slate-300"/>
                        Remove current photo
                    </label>
                    <% } %>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div class="flex flex-col gap-2">
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200">Full Name <span class="text-red-500">*</span></label>
                    <input name="fullName"
                           class="w-full h-10 px-3 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 text-sm focus:ring-primary focus:border-primary"
                           value="<%= user.getFullName() != null ? user.getFullName() : "" %>"
                           required/>
                </div>
                <div class="flex flex-col gap-2">
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200">
                        Phone <%= requiredPhone ? "<span class=\"text-red-500\">*</span>" : "" %>
                    </label>
                    <input name="phone"
                           class="w-full h-10 px-3 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 text-sm focus:ring-primary focus:border-primary"
                           value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                           <%= requiredPhone ? "required" : "" %>/>
                </div>
                <div class="flex flex-col gap-2 md:col-span-2">
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200">Address</label>
                    <textarea name="address"
                              rows="3"
                              class="w-full px-3 py-2 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 text-sm focus:ring-primary focus:border-primary"><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                </div>
            </div>

            <div class="flex items-center justify-end gap-3 pt-4 border-t border-slate-200 dark:border-slate-800">
                <a href="<%= ctx %>/Receptionist/profile"
                   class="px-5 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-sm font-semibold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors inline-flex items-center justify-center">
                    Cancel
                </a>
                <button type="submit"
                        class="px-6 py-2 rounded-lg bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors inline-flex items-center justify-center">
                    Save Changes
                </button>
            </div>
        </form>
    </main>
</div>

<script>
    (function() {
        var toggle = document.getElementById('receptionist-profile-toggle');
        var menu = document.getElementById('receptionist-profile-menu');
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
</html>

