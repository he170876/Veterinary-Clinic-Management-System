<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Dashboard - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f14437",
                        "primary-dark": "#d6362b",
                        "background-light": "#fcfcfc",
                        "background-dark": "#1a1614",
                    },
                    fontFamily: {
                        "display": ["Manrope", "sans-serif"]
                    },
                },
            },
        }
    </script>
    <style>
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-background-light min-h-screen">
    <!-- Top Navigation -->
    <nav class="bg-white shadow-sm border-b border-gray-100">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center gap-3">
                    <div class="size-10 bg-primary text-white rounded-lg flex items-center justify-center">
                        <span class="material-symbols-outlined">pets</span>
                    </div>
                    <span class="text-xl font-black text-gray-900 tracking-tight">Anipats</span>
                </div>
                <div class="flex items-center gap-4">
                    <span class="text-sm text-gray-600">Welcome, <strong><%= user.getFullName() %></strong></span>
                    <a href="<%= request.getContextPath() %>/logout" 
                       class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                        <span class="material-symbols-outlined text-lg">logout</span>
                        Logout
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Welcome Banner -->
        <div class="bg-gradient-to-r from-primary to-red-400 rounded-2xl p-8 text-white mb-8">
            <h1 class="text-3xl font-bold mb-2">Welcome back, <%= user.getFullName() %>!</h1>
            <p class="text-white/90">Manage your pets, appointments, and medical records all in one place.</p>
        </div>

        <!-- Quick Stats -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
                <div class="flex items-center gap-4">
                    <div class="size-12 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">pets</span>
                    </div>
                    <div>
                        <p class="text-2xl font-bold text-gray-900">0</p>
                        <p class="text-sm text-gray-500">My Pets</p>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
                <div class="flex items-center gap-4">
                    <div class="size-12 bg-green-100 text-green-600 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">calendar_month</span>
                    </div>
                    <div>
                        <p class="text-2xl font-bold text-gray-900">0</p>
                        <p class="text-sm text-gray-500">Appointments</p>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
                <div class="flex items-center gap-4">
                    <div class="size-12 bg-purple-100 text-purple-600 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">medical_information</span>
                    </div>
                    <div>
                        <p class="text-2xl font-bold text-gray-900">0</p>
                        <p class="text-sm text-gray-500">Medical Records</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <h2 class="text-xl font-bold text-gray-900 mb-4">Quick Actions</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <a href="#" class="flex items-center gap-3 bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-primary hover:shadow-md transition-all">
                <div class="size-10 bg-primary/10 text-primary rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">add</span>
                </div>
                <span class="font-semibold text-gray-700">Add Pet</span>
            </a>
            <a href="#" class="flex items-center gap-3 bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-primary hover:shadow-md transition-all">
                <div class="size-10 bg-primary/10 text-primary rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">event</span>
                </div>
                <span class="font-semibold text-gray-700">Book Appointment</span>
            </a>
            <a href="#" class="flex items-center gap-3 bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-primary hover:shadow-md transition-all">
                <div class="size-10 bg-primary/10 text-primary rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">history</span>
                </div>
                <span class="font-semibold text-gray-700">View History</span>
            </a>
            <a href="#" class="flex items-center gap-3 bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-primary hover:shadow-md transition-all">
                <div class="size-10 bg-primary/10 text-primary rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">person</span>
                </div>
                <span class="font-semibold text-gray-700">My Profile</span>
            </a>
        </div>

        <!-- Account Info -->
        <div class="mt-8 bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <h2 class="text-lg font-bold text-gray-900 mb-4">Account Information</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="text-sm text-gray-500">Full Name</label>
                    <p class="font-medium text-gray-900"><%= user.getFullName() %></p>
                </div>
                <div>
                    <label class="text-sm text-gray-500">Email</label>
                    <p class="font-medium text-gray-900"><%= user.getEmail() %></p>
                </div>
                <div>
                    <label class="text-sm text-gray-500">Phone</label>
                    <p class="font-medium text-gray-900"><%= user.getPhone() != null ? user.getPhone() : "Not set" %></p>
                </div>
                <div>
                    <label class="text-sm text-gray-500">Account Status</label>
                    <p class="font-medium text-green-600"><%= user.getStatus() %></p>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
