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
                        "primary": "#f14337",
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
<div class="flex h-screen overflow-hidden">
    <!-- Sidebar -->
    <aside class="w-64 bg-white dark:bg-[#1a0d0c] border-r border-[#e6dcdb] dark:border-[#3d2a29] flex flex-col justify-between p-4 shrink-0">
        <div class="flex flex-col gap-8">
            <a href="<%= ctx %>/index.jsp" class="flex items-center gap-3 px-2">
                <div class="bg-primary rounded-xl p-2 flex items-center justify-center">
                    <span class="material-symbols-outlined text-white text-2xl">pets</span>
                </div>
                <div class="flex flex-col">
                    <h1 class="text-[#181111] dark:text-white text-lg font-bold leading-tight">Anipats</h1>
                    <p class="text-[#896461] text-xs font-medium">Veterinary Center</p>
                </div>
            </a>
            <nav class="flex flex-col gap-2">
                <a class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-background-light dark:hover:bg-[#2d1a19] transition-colors text-[#181111] dark:text-white" href="<%= ctx %>/customer/dashboard">
                    <span class="material-symbols-outlined">dashboard</span>
                    <span class="text-sm font-semibold">Dashboard</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-background-light dark:hover:bg-[#2d1a19] transition-colors text-[#181111] dark:text-white" href="#">
                    <span class="material-symbols-outlined">group</span>
                    <span class="text-sm font-semibold">Patients</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-background-light dark:hover:bg-[#2d1a19] transition-colors text-[#181111] dark:text-white" href="#">
                    <span class="material-symbols-outlined">calendar_today</span>
                    <span class="text-sm font-semibold">Appointments</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-background-light dark:hover:bg-[#2d1a19] transition-colors text-[#181111] dark:text-white" href="#">
                    <span class="material-symbols-outlined">description</span>
                    <span class="text-sm font-semibold">Medical Records</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2.5 rounded-xl bg-primary/10 text-primary" href="<%= ctx %>/customer/edit-profile">
                    <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">settings</span>
                    <span class="text-sm font-semibold">Settings</span>
                </a>
            </nav>
        </div>
        <a href="<%= ctx %>/logout" class="flex items-center justify-center gap-2 w-full h-11 bg-primary hover:bg-primary/90 text-white rounded-xl font-bold transition-all">
            <span class="material-symbols-outlined">logout</span>
            <span>Logout</span>
        </a>
    </aside>
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
            <% if (err != null && !err.isEmpty()) { %>
            <div class="mb-6 p-4 rounded-xl bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm">
                <%= java.net.URLDecoder.decode(err, "UTF-8") %>
            </div>
            <% } %>
            <!-- Form Card -->
            <div class="bg-white dark:bg-[#1a0d0c] rounded-2xl border border-[#e6dcdb] dark:border-[#3d2a29] overflow-hidden shadow-sm">
                <div class="p-8">
                    <div class="flex flex-col md:flex-row md:items-center gap-6 mb-10 pb-10 border-b border-[#f4f0f0] dark:border-[#2d1a19]">
                        <div class="relative group">
                            <div class="w-32 h-32 rounded-full ring-4 ring-background-light dark:ring-[#2d1a19] flex items-center justify-center bg-primary/10 text-primary font-bold text-4xl">
                                <%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %>
                            </div>
                        </div>
                        <div class="flex-1">
                            <h3 class="text-xl font-bold text-[#181111] dark:text-white">Profile Photo</h3>
                            <p class="text-[#896461] text-sm mb-4">Avatar is based on your name. Photo upload coming soon.</p>
                        </div>
                    </div>
                    <form method="post" action="<%= ctx %>/customer/edit-profile" class="space-y-6">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="flex flex-col gap-2">
                                <label class="text-[#181111] dark:text-white text-sm font-bold">Full Name</label>
                                <div class="relative">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#896461] text-xl">person</span>
                                    <input name="fullName" class="w-full h-12 pl-10 pr-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white" type="text" value="<%= esc(user.getFullName() != null ? user.getFullName() : "") %>"/>
                                </div>
                            </div>
                            <div class="flex flex-col gap-2">
                                <label class="text-[#181111] dark:text-white text-sm font-bold">Phone Number</label>
                                <div class="relative">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#896461] text-xl">call</span>
                                    <input name="phone" class="w-full h-12 pl-10 pr-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white" type="tel" value="<%= esc(user.getPhone() != null ? user.getPhone() : "") %>"/>
                                </div>
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
                                <textarea name="address" class="w-full p-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white resize-none" placeholder="Street, city, postal code..." rows="3"><%= esc(user.getAddress() != null ? user.getAddress() : "") %></textarea>
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
                    <p class="text-[#896461] text-xs leading-relaxed mt-1">To change your password, go to Settings (Security) and use Change Password.</p>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
