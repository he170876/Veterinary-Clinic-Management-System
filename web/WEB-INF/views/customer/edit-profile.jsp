<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%!
    String esc(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '&') sb.append("&amp;");
            else if (c == '<') sb.append("&lt;");
            else if (c == '>') sb.append("&gt;");
            else if (c == '"') sb.append("&quot;");
            else sb.append(c);
        }
        return sb.toString();
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
    String requiredParam = request.getParameter("required");
    boolean requiredPhone = "phone".equals(requiredParam);
    request.setAttribute("customerCurrentPage", "edit-profile");
    String profilePicUrl = user.getProfilePictureUrl();
    boolean hasProfilePic = (profilePicUrl != null && !profilePicUrl.isEmpty());
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats Edit Profile</title>
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
                        "background-light": "#f8f6f6",
                        "background-dark": "#221110",
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
<body class="bg-background-light dark:bg-background-dark text-[#181111] dark:text-white font-display">
<div class="flex min-h-screen overflow-hidden">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    <!-- Main Content -->
    <main class="flex-1 flex flex-col overflow-y-auto">
        <header class="sticky top-0 z-10 flex items-center justify-between bg-white dark:bg-[#1a0d0c] border-b border-[#e6dcdb] dark:border-[#3d2a29] px-8 py-4">
            <div class="flex items-center gap-6">
                <h2 class="text-[#181111] dark:text-white text-xl font-extrabold tracking-tight">Profile Settings</h2>
                <nav class="hidden md:flex items-center gap-6">
                    <a class="text-primary border-b-2 border-primary pb-1 text-sm font-bold" href="<%= ctx %>/customer/edit-profile">General</a>
                    <a class="text-[#896461] hover:text-[#181111] dark:hover:text-white text-sm font-semibold transition-colors" href="<%= ctx %>/customer/profile">Security</a>
                </nav>
            </div>
            <div class="flex items-center gap-4">
                <div class="h-10 w-10 rounded-full flex items-center justify-center bg-primary/10 text-primary font-bold text-sm">
                    <%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %>
                </div>
            </div>
        </header>
        <div class="p-8 max-w-5xl mx-auto w-full">
            <!-- Breadcrumbs -->
            <div class="flex items-center gap-2 mb-6">
                <a class="text-[#896461] text-sm font-medium hover:text-primary transition-colors" href="<%= ctx %>/customer/dashboard">Dashboard</a>
                <span class="material-symbols-outlined text-[#896461] text-base leading-none">chevron_right</span>
                <a class="text-[#896461] text-sm font-medium hover:text-primary transition-colors" href="<%= ctx %>/customer/profile">Settings</a>
                <span class="material-symbols-outlined text-[#896461] text-base leading-none">chevron_right</span>
                <span class="text-[#181111] dark:text-white text-sm font-bold">Edit Profile</span>
            </div>
            <% if (requiredPhone) { %>
            <div class="mb-6 p-4 rounded-xl bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 text-amber-800 dark:text-amber-200 text-sm font-semibold flex items-center gap-2">
                <span class="material-symbols-outlined">warning</span>
                You must add your phone number to continue. Phone is required for all accounts.
            </div>
            <% } %>
            <% if (err != null && !err.isEmpty()) { %>
            <div class="mb-6 p-4 rounded-xl bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm">
                <%= java.net.URLDecoder.decode(err, "UTF-8") %>
            </div>
            <% } %>
            <!-- Form Card -->
            <div class="bg-white dark:bg-[#1a0d0c] rounded-2xl border border-[#e6dcdb] dark:border-[#3d2a29] overflow-hidden shadow-sm">
                <div class="p-8">
                    <form method="post" action="<%= ctx %>/customer/edit-profile" enctype="multipart/form-data" class="space-y-6">
                    <div class="flex flex-col md:flex-row md:items-center gap-6 mb-10 pb-10 border-b border-[#f4f0f0] dark:border-[#2d1a19]">
                        <div class="relative group">
                            <div id="profilePhotoPreview" class="w-32 h-32 rounded-full ring-4 ring-background-light dark:ring-[#2d1a19] overflow-hidden flex items-center justify-center bg-primary/10 text-primary font-bold text-4xl shrink-0">
                                <% if (hasProfilePic) { %>
                                <img src="<%= ctx %><%= esc(profilePicUrl) %>" alt="Profile" class="w-full h-full object-cover" id="profilePhotoImg"/>
                                <% } else { %>
                                <span id="profilePhotoInitial"><%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %></span>
                                <% } %>
                            </div>
                            <label class="absolute bottom-0 right-0 flex items-center justify-center size-10 rounded-full bg-primary text-white cursor-pointer shadow-lg hover:bg-primary/90 transition-colors" title="Change photo">
                                <span class="material-symbols-outlined text-xl">photo_camera</span>
                                <input type="file" name="profilePicture" id="profilePictureInput" accept="image/jpeg,image/png,image/gif" class="hidden"/>
                            </label>
                        </div>
                        <div class="flex-1 space-y-2">
                            <h3 class="text-xl font-bold text-[#181111] dark:text-white">Profile Photo</h3>
                            <p class="text-[#896461] text-sm">JPG, PNG or GIF. Max 2 MB.</p>
                            <% if (hasProfilePic) { %>
                            <label class="inline-flex items-center gap-2 text-sm text-[#896461] hover:text-red-600 cursor-pointer mt-2">
                                <input type="checkbox" name="removePhoto" value="1" class="rounded border-[#e6dcdb] text-primary focus:ring-primary"/>
                                <span>Remove current photo</span>
                            </label>
                            <% } %>
                        </div>
                    </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="flex flex-col gap-2">
                                <label class="text-[#181111] dark:text-white text-sm font-bold">Full Name <span class="text-red-500">*</span></label>
                                <div class="relative">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#896461] text-xl">person</span>
                                    <input name="fullName" class="w-full h-12 pl-10 pr-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white" type="text" value="<%= esc(user.getFullName() != null ? user.getFullName() : "") %>" minlength="1" maxlength="30" pattern="[a-zA-Z\u00C0-\u024F\u1E00-\u1EFF\s]{1,30}" title="1-30 characters, letters and spaces only (any language)." required/>
                                </div>
                                <p class="text-xs text-[#896461]">1-30 characters, letters and spaces only (any language). No leading/trailing spaces.</p>
                            </div>
                            <div class="flex flex-col gap-2">
                                <label class="text-[#181111] dark:text-white text-sm font-bold">Phone Number <%= requiredPhone ? "<span class=\"text-red-500\">*</span>" : "" %></label>
                                <div class="relative">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#896461] text-xl">call</span>
                                    <input name="phone" class="w-full h-12 pl-10 pr-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white" type="tel" value="<%= esc(user.getPhone() != null ? user.getPhone() : "") %>" pattern="0[0-9]{9}" title="10 digits starting with 0 (e.g. 0123456789)." placeholder="0123456789" <%= requiredPhone ? "required" : "" %>/>
                                </div>
                                <p class="text-xs text-[#896461]">10 digits, must start with 0. No spaces.<%= requiredPhone ? " Required to continue." : "" %></p>
                            </div>
                            <div class="flex flex-col gap-2 md:col-span-2">
                                <label class="text-[#181111] dark:text-white text-sm font-bold">Email Address</label>
                                <div class="relative">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#896461] text-xl">mail</span>
                                    <input class="w-full h-12 pl-10 pr-4 bg-[#f8f6f6] dark:bg-[#2d1a19] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl text-[#896461] cursor-not-allowed" type="email" value="<%= esc(user.getEmail() != null ? user.getEmail() : "") %>" readonly/>
                                </div>
                                <p class="text-[#896461] text-xs">Email cannot be changed. Contact support if needed.</p>
                            </div>
                            <div class="flex flex-col gap-2 md:col-span-2">
                                <label class="text-[#181111] dark:text-white text-sm font-bold">Address</label>
                                <textarea name="address" class="w-full p-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white resize-none" placeholder="Street, city, postal code..." rows="3" maxlength="500"><%= esc(user.getAddress() != null ? user.getAddress() : "") %></textarea>
                                <p class="text-xs text-[#896461]">Optional. Max 500 characters.</p>
                            </div>
                        </div>
                        <div class="flex items-center justify-end gap-3 pt-4 border-t border-[#f4f0f0] dark:border-[#2d1a19]">
                            <a href="<%= ctx %>/customer/profile" class="px-6 h-11 border border-[#e6dcdb] dark:border-[#3d2a29] text-[#181111] dark:text-white font-bold rounded-xl hover:bg-white dark:hover:bg-[#2d1a19] transition-all inline-flex items-center justify-center">Cancel</a>
                            <button type="submit" class="px-8 h-11 bg-primary text-white font-bold rounded-xl hover:bg-primary/90 shadow-lg shadow-primary/20 transition-all">Save Changes</button>
                        </div>
                    </form>
                </div>
            </div>
            <div class="mt-8 flex items-start gap-4 p-5 rounded-2xl bg-primary/5 border border-primary/10">
                <span class="material-symbols-outlined text-primary mt-1">info</span>
                <div>
                    <h4 class="text-[#181111] dark:text-white font-bold text-sm">Need Help?</h4>
                    <p class="text-[#896461] text-xs leading-relaxed mt-1">To change your password, go to My Profile and use Change Password.</p>
                </div>
            </div>
        </div>
    </main>
</div>
<script>
(function() {
    var input = document.getElementById('profilePictureInput');
    var preview = document.getElementById('profilePhotoPreview');
    if (!input || !preview) return;
    input.addEventListener('change', function() {
        var file = this.files && this.files[0];
        if (!file || !file.type.match(/^image\/(jpeg|png|gif)$/)) return;
        var img = preview.querySelector('#profilePhotoImg');
        var initial = preview.querySelector('#profilePhotoInitial');
        var reader = new FileReader();
        reader.onload = function(e) {
            if (img) {
                img.src = e.target.result;
            } else {
                img = document.createElement('img');
                img.id = 'profilePhotoImg';
                img.alt = 'Profile';
                img.className = 'w-full h-full object-cover';
                img.src = e.target.result;
                if (initial) initial.remove();
                preview.appendChild(img);
            }
            if (initial) initial.style.display = 'none';
        };
        reader.readAsDataURL(file);
    });
})();
</script>
</body>
</html>
