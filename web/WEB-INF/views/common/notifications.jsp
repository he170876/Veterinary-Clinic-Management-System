<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Notification" %>
<%
    model.User user = (model.User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    @SuppressWarnings("unchecked")
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    if (notifications == null) notifications = java.util.Collections.emptyList();
    java.time.format.DateTimeFormatter fmt =
            (java.time.format.DateTimeFormatter) request.getAttribute("notificationTimeFmt");
    if (fmt == null) {
        fmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, HH:mm");
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats - Notification Center</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700,0..1&display=swap" rel="stylesheet"/>
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
                    fontFamily: {
                        "display": ["Manrope", "sans-serif"]
                    },
                    borderRadius: {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                },
            },
        }
    </script>
    <style>
        body {
            font-family: 'Manrope', sans-serif;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 font-display">
<div class="relative flex min-h-screen w-full flex-col overflow-x-hidden">
    <!-- Header -->
    <header class="sticky top-0 z-40 w-full border-b border-slate-200 dark:border-slate-800 bg-white/80 dark:bg-background-dark/80 backdrop-blur-md">
        <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div class="flex h-16 items-center justify-between">
                <div class="flex items-center gap-8">
                    <div class="flex items-center gap-3">
                        <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-primary text-white">
                            <span class="material-symbols-outlined">pets</span>
                        </div>
                        <h1 class="text-xl font-bold tracking-tight text-slate-900 dark:text-white leading-none">Anipats</h1>
                    </div>
                    <nav class="hidden md:flex items-center gap-6">
                        <a class="text-sm font-medium text-slate-600 dark:text-slate-400 hover:text-primary dark:hover:text-primary transition-colors"
                           href="<%= ctx %>/vet/dashboard">Dashboard</a>
                        <a class="text-sm font-medium text-slate-600 dark:text-slate-400 hover:text-primary dark:hover:text-primary transition-colors"
                           href="<%= ctx %>/vet/queue">Patients</a>
                        <span class="text-sm font-semibold text-primary">Notifications</span>
                    </nav>
                </div>
                <div class="flex items-center gap-4">
                    <div class="relative hidden sm:block">
                        <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400">
                            <span class="material-symbols-outlined text-xl">search</span>
                        </span>
                        <input class="block w-64 rounded-lg border-none bg-slate-100 dark:bg-slate-800 py-2 pl-10 pr-3 text-sm placeholder-slate-500 focus:ring-2 focus:ring-primary/50"
                               placeholder="Search notifications..." type="text"/>
                    </div>
                    <div class="h-10 w-10 overflow-hidden rounded-full border-2 border-slate-200 dark:border-slate-700">
                        <%
                            String avatarUrl = user.getProfilePictureUrl();
                            String initial = (user.getFullName() != null && !user.getFullName().isEmpty())
                                    ? String.valueOf(user.getFullName().charAt(0)) : "?";
                        %>
                        <% if (avatarUrl != null && !avatarUrl.isEmpty()) { %>
                            <img alt="Profile" class="h-full w-full object-cover" src="<%= ctx %><%= avatarUrl %>"/>
                        <% } else { %>
                            <div class="h-full w-full flex items-center justify-center bg-slate-200 dark:bg-slate-700 text-slate-600 dark:text-slate-200 font-semibold">
                                <%= initial %>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="mx-auto w-full max-w-5xl px-4 py-8 sm:px-6 lg:px-8">
        <div class="mb-8 flex flex-col md:flex-row md:items-end justify-between gap-4">
            <div>
                <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 dark:text-white">Notification Center</h2>
                <p class="mt-1 text-slate-500 dark:text-slate-400">
                    Notifications for <span class="font-semibold"><%= user.getFullName() %></span>
                </p>
            </div>
        </div>

        <div class="space-y-3">
            <% if (notifications.isEmpty()) { %>
                <div class="rounded-xl border border-dashed border-slate-300 dark:border-slate-700 bg-white/60 dark:bg-slate-900/60 p-8 text-center">
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                        You have no notifications yet.
                    </p>
                </div>
            <% } else { %>
                <% for (Notification n : notifications) {
                    String title = n.getTitle() != null ? n.getTitle() : "Notification";
                    String message = n.getMessage() != null ? n.getMessage() : "";
                    String time = n.getCreatedAt() != null ? n.getCreatedAt().format(fmt) : "";
                %>
                <div class="group relative flex items-start gap-4 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-4 shadow-sm transition-all hover:shadow-md">
                    <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                        <span class="material-symbols-outlined">notifications</span>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center justify-between gap-2">
                            <h4 class="text-base font-bold text-slate-900 dark:text-white"><%= title %></h4>
                            <span class="text-xs text-slate-400 whitespace-nowrap"><%= time %></span>
                        </div>
                        <p class="mt-1 text-sm text-slate-600 dark:text-slate-400 leading-relaxed"><%= message %></p>
                    </div>
                </div>
                <% } %>
            <% } %>
        </div>
    </main>
</div>
</body>
</html>

