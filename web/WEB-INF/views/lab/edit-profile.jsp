<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
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
    String err = request.getParameter("error");
    String profilePicUrl = user.getProfilePictureUrl();
    boolean hasProfilePic = (profilePicUrl != null && !profilePicUrl.isEmpty());
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Lab Edit Profile - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200;300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
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
                    fontFamily: { "display": ["Manrope", "sans-serif"] },
                    borderRadius: { "DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px" },
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
    <%
        request.setAttribute("labSidebarActive", "profile");
    %>
    <%@ include file="/WEB-INF/views/lab/_lab-sidebar.jspf" %>
    <main class="flex-1 flex flex-col overflow-y-auto ml-64">
        <header class="h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-8">
            <div class="flex items-center gap-2 text-slate-500 text-sm">
                <a class="hover:text-primary" href="<%= ctx %>/lab/profile"><span class=\material-symbols-outlined text-base text-slate-400\>person</span><span>My Profile</span></a>
                <span class="material-symbols-outlined text-xs">chevron_right</span>
                <span class="text-slate-900 dark:text-slate-100 font-medium">Edit Profile</span>
            </div>
            <div class="relative">
                <button type="button"
                        id="lab-profile-toggle"
                        class="size-10 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold overflow-hidden hover:brightness-95 transition-colors">
                    <% if (hasProfilePic) { %>
                    <img class="w-full h-full object-cover" src="<%= ctx %><%= esc(profilePicUrl) %>" alt="Profile"/>
                    <% } else { %>
                    <%= (displayName != null && !displayName.isEmpty()) ? String.valueOf(displayName.charAt(0)).toUpperCase() : "?" %>
                    <% } %>
                </button>
                <div id="lab-profile-menu"
                     class="absolute right-0 mt-2 w-56 origin-top-right rounded-xl bg-white dark:bg-slate-900 shadow-lg border border-slate-200 dark:border-slate-800 z-50"
                     style="display:none;">
                    <a href="<%= ctx %>/lab/profile"
                       class="block px-4 py-3 text-sm font-bold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors rounded-t-xl flex items-center gap-2">
                        <span class="material-symbols-outlined text-base text-primary">person</span>
                        <span>My Profile</span>
                    </a>
                    <a href="<%= ctx %>/logout"
                       class="block px-4 py-3 text-sm font-bold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors rounded-b-xl flex items-center gap-2">
                        <span class="material-symbols-outlined text-base text-primary">logout</span>
                        <span>Sign out</span>
                    </a>
                </div>
            </div>
        </header>
        <div class="p-8 max-w-4xl mx-auto w-full">
            <% if (err != null && !err.isEmpty()) { %>
            <div class="mb-6 p-4 rounded-xl bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm">
                <%= java.net.URLDecoder.decode(err, "UTF-8") %>
            </div>
            <% } %>
            <div class="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
                <div class="p-6 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
                    <h1 class="text-lg font-bold text-slate-900 dark:text-slate-100">Edit Profile</h1>
                    <div class="flex items-center gap-2">
                        <div class="size-9 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-sm">
                            <%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "L" %>
                        </div>
                    </div>
                </div>
                <form method="post" action="<%= ctx %>/lab/edit-profile" enctype="multipart/form-data" class="p-6 space-y-6">
                    <div class="flex flex-col md:flex-row md:items-center gap-6 mb-4">
                        <div class="relative group">
                            <div id="profilePhotoPreview" class="w-24 h-24 rounded-full ring-4 ring-background-light dark:ring-slate-900 overflow-hidden flex items-center justify-center bg-primary/10 text-primary font-bold text-3xl shrink-0">
                                <% if (hasProfilePic) { %>
                                <img src="<%= ctx %><%= esc(profilePicUrl) %>" alt="Profile" class="w-full h-full object-cover" id="profilePhotoImg"/>
                                <% } else { %>
                                <span id="profilePhotoInitial"><%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "L" %></span>
                                <% } %>
                            </div>
                            <label class="absolute bottom-0 right-0 flex items-center justify-center size-9 rounded-full bg-primary text-white cursor-pointer shadow-lg hover:bg-primary/90 transition-colors" title="Change photo">
                                <span class="material-symbols-outlined text-lg">photo_camera</span>
                                <input type="file" name="profilePicture" id="profilePictureInput" accept="image/jpeg,image/png,image/gif,image/webp" class="hidden"/>
                            </label>
                        </div>
                        <div class="flex-1 space-y-1">
                            <h2 class="text-base font-semibold text-slate-900 dark:text-slate-100">Profile Photo</h2>
                            <p class="text-xs text-slate-500 dark:text-slate-400">JPG, PNG, GIF or WebP. Max 2 MB.</p>
                        </div>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="space-y-1">
                            <label class="text-xs font-semibold text-slate-700 dark:text-slate-200">Full Name</label>
                            <input name="fullName" type="text" required minlength="1" maxlength="30"
                                   value="<%= esc(user.getFullName() != null ? user.getFullName() : "") %>"
                                   class="w-full h-10 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 px-3 text-sm focus:ring-primary focus:border-primary"/>
                            <p class="text-[11px] text-slate-400">1-30 characters, letters and spaces only.</p>
                        </div>
                        <div class="space-y-1">
                            <label class="text-xs font-semibold text-slate-700 dark:text-slate-200">Phone Number</label>
                            <input name="phone" type="tel" pattern="0[0-9]{9}" placeholder="0123456789"
                                   value="<%= esc(user.getPhone() != null ? user.getPhone() : "") %>"
                                   class="w-full h-10 rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 px-3 text-sm focus:ring-primary focus:border-primary"/>
                            <p class="text-[11px] text-slate-400">10 digits, must start with 0.</p>
                        </div>
                        <div class="md:col-span-2 space-y-1">
                            <label class="text-xs font-semibold text-slate-700 dark:text-slate-200">Email (read-only)</label>
                            <input type="email" value="<%= esc(user.getEmail() != null ? user.getEmail() : "") %>" readonly
                                   class="w-full h-10 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-100 dark:bg-slate-800 px-3 text-sm text-slate-500 cursor-not-allowed"/>
                        </div>
                        <div class="md:col-span-2 space-y-1">
                            <label class="text-xs font-semibold text-slate-700 dark:text-slate-200">Address</label>
                            <textarea name="address" rows="3"
                                      class="w-full rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 px-3 py-2 text-sm focus:ring-primary focus:border-primary"><%= esc(user.getAddress() != null ? user.getAddress() : "") %></textarea>
                            <p class="text-[11px] text-slate-400">Optional. Max 500 characters.</p>
                        </div>
                    </div>
                    <div class="flex items-center justify-end gap-3 pt-4 border-t border-slate-100 dark:border-slate-800">
                        <a href="<%= ctx %>/lab/profile" class="px-5 py-2 rounded-lg border border-slate-200 dark:border-slate-700 text-sm font-semibold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800">
                            Cancel
                        </a>
                        <button type="submit" class="px-7 py-2 rounded-lg bg-primary text-white text-sm font-semibold hover:bg-primary/90 shadow-lg shadow-primary/20">
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>
<script>
(function() {
    var input = document.getElementById('profilePictureInput');
    var preview = document.getElementById('profilePhotoPreview');
    if (!input || !preview) return;
    function isImageFile(file) {
        if (!file) return false;
        var t = (file.type || '').toLowerCase();
        if (t.indexOf('image/') === 0) return true;
        var n = (file.name || '').toLowerCase();
        return /\.(jpe?g|png|gif|webp|bmp)$/i.test(n);
    }
    input.addEventListener('change', function() {
        var file = this.files && this.files[0];
        if (!file) return;
        if (!isImageFile(file)) {
            alert('Please choose an image file (JPG, PNG, GIF, or WebP).');
            this.value = '';
            return;
        }
        var img = preview.querySelector('#profilePhotoImg');
        var initial = preview.querySelector('#profilePhotoInitial');
        var reader = new FileReader();
        reader.onload = function(e) {
            var url = e.target.result;
            if (img) {
                img.src = url;
                img.style.display = '';
            } else {
                img = document.createElement('img');
                img.id = 'profilePhotoImg';
                img.alt = 'Profile';
                img.className = 'w-full h-full object-cover';
                img.src = url;
                if (initial) initial.remove();
                preview.appendChild(img);
            }
            if (initial && initial.parentNode) initial.style.display = 'none';
        };
        reader.readAsDataURL(file);
    });

    // Profile dropdown toggle (header)
    var labToggle = document.getElementById('lab-profile-toggle');
    var labMenu = document.getElementById('lab-profile-menu');
    if (labToggle && labMenu) {
        labToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            labMenu.style.display = (labMenu.style.display === 'none' || labMenu.style.display === '') ? 'block' : 'none';
        });
        document.addEventListener('click', function(e) {
            if (!labMenu.contains(e.target) && !labToggle.contains(e.target)) {
                labMenu.style.display = 'none';
            }
        });
    }
})();
</script>
</body>
</html>

