<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String token = (String) request.getAttribute("token");
    if (token == null) token = request.getParameter("token");
    String errorMsg = request.getParameter("error");
    if (errorMsg != null && !errorMsg.isEmpty()) {
        try { errorMsg = java.net.URLDecoder.decode(errorMsg, "UTF-8"); } catch (Exception e) { }
    }
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Reset Password - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
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
                    fontFamily: {
                        "display": ["Manrope", "sans-serif"]
                    },
                },
            },
        }
    </script>
    <style type="text/tailwindcss"> body { font-family: 'Manrope', sans-serif; } .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; } </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#181411] dark:text-white min-h-screen flex items-center justify-center">
<div class="flex flex-col lg:flex-row w-full min-h-screen">
    <div class="hidden lg:flex lg:w-1/2 bg-primary flex-col justify-center items-center p-12 text-white relative overflow-hidden">
        <div class="relative z-10 max-w-md text-center">
            <div class="flex justify-center mb-10">
                <div class="p-3 bg-white text-primary rounded-xl shadow-xl">
                    <span class="material-symbols-outlined !text-4xl">pets</span>
                </div>
            </div>
            <h1 class="text-4xl font-extrabold mb-6 tracking-tight">Anipats</h1>
            <p class="text-lg font-medium opacity-90">Set a new password for your account.</p>
        </div>
    </div>
    <div class="w-full lg:w-1/2 flex flex-col justify-center items-center p-6 sm:p-12 md:p-24 bg-white dark:bg-background-dark">
        <div class="w-full max-w-[440px]">
            <a href="<%= ctx %>/login" class="inline-flex items-center gap-2 text-[#64748b] dark:text-gray-400 hover:text-primary font-medium text-sm mb-4 -mt-2">
                <span class="material-symbols-outlined text-lg">arrow_back</span> Back to Login
            </a>
            <div class="lg:hidden flex items-center gap-3 mb-8">
                <div class="size-10 bg-primary text-white rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">pets</span>
                </div>
                <span class="text-2xl font-black text-[#181411] dark:text-white tracking-tight">Anipats</span>
            </div>
            <div class="mb-6">
                <h2 class="text-3xl font-bold text-[#181411] dark:text-white mb-2">Reset Password</h2>
                <p class="text-[#64748b] dark:text-gray-400 font-medium">Enter your new password below.</p>
            </div>

            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
            <div class="mb-4 rounded-lg border border-red-300 bg-red-50 dark:bg-red-900/20 dark:border-red-700 px-4 py-3 text-sm text-red-700 dark:text-red-300">
                <%= errorMsg %>
            </div>
            <% } %>

            <% if (token == null || token.isEmpty()) { %>
            <p class="text-[#64748b] dark:text-gray-400">Invalid or missing reset link. <a class="text-primary font-bold hover:underline" href="<%= ctx %>/forgot-password">Request a new link</a>.</p>
            <% } else { %>
            <form class="space-y-5" method="post" action="<%= ctx %>/reset-password">
                <input type="hidden" name="token" value="<%= token %>"/>
                <div class="flex flex-col gap-2">
                    <label class="text-[#181411] dark:text-gray-200 text-sm font-semibold">New Password</label>
                    <input class="w-full h-12 rounded-lg border border-[#e2e8f0] dark:border-gray-700 bg-white dark:bg-[#2d241b] px-4 text-[#181411] dark:text-white placeholder:text-[#94a3b8] focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                           placeholder="Min. 6 chars, 1 uppercase, 1 number"
                           type="password"
                           name="newPassword"
                           id="newPassword"
                           minlength="6"
                           maxlength="128"
                           required/>
                </div>
                <div class="flex flex-col gap-2">
                    <label class="text-[#181411] dark:text-gray-200 text-sm font-semibold">Confirm Password</label>
                    <input class="w-full h-12 rounded-lg border border-[#e2e8f0] dark:border-gray-700 bg-white dark:bg-[#2d241b] px-4 text-[#181411] dark:text-white placeholder:text-[#94a3b8] focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                           placeholder="Repeat new password"
                           type="password"
                           name="confirmPassword"
                           minlength="6"
                           maxlength="128"
                           required/>
                </div>
                <button type="submit" class="w-full h-12 bg-primary hover:bg-primary-dark text-white font-bold rounded-lg shadow-lg shadow-primary/20 mt-4 active:scale-98">
                    Reset Password
                </button>
            </form>
            <% } %>

            <p class="text-center text-sm text-[#64748b] dark:text-gray-400 mt-6">
                <a class="text-primary font-bold hover:text-primary-dark" href="<%= ctx %>/login">Back to Login</a>
            </p>
        </div>
    </div>
</div>
</body>
</html>
