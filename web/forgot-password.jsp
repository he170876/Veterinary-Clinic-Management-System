<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String errorMsg = request.getParameter("error");
    String message = (String) request.getAttribute("message");
    if (message == null && "1".equals(request.getParameter("sent"))) message = "If that email is registered, we sent a reset link. Check your inbox and spam.";
    String devResetLink = (String) request.getAttribute("devResetLink");
    if (devResetLink == null) devResetLink = request.getParameter("devLink");
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Forgot Password - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
        tailwind.config = { darkMode: "class", theme: { extend: { colors: { "primary": "#f14437", "primary-dark": "#d6362b" }, fontFamily: { display: ["Manrope", "sans-serif"] } } } };
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
            <p class="text-lg font-medium opacity-90">Enter your email and we'll send you a link to reset your password.</p>
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
                <h2 class="text-3xl font-bold text-[#181411] dark:text-white mb-2">Forgot Password</h2>
                <p class="text-[#64748b] dark:text-gray-400 font-medium">Enter your Gmail address and we'll send you a reset link.</p>
                <p class="text-xs text-[#64748b] dark:text-gray-500 mt-2">Signed up with Google? You don't have a password in this app — use <a href="<%= ctx %>/login" class="text-primary font-semibold hover:underline">Sign in with Google</a> instead. To recover your Google account, use <a href="https://accounts.google.com/signin/recovery" target="_blank" rel="noopener" class="text-primary font-semibold hover:underline">Google's account recovery</a>.</p>
            </div>

            <% if (errorMsg != null && !errorMsg.isEmpty()) {
                try { errorMsg = java.net.URLDecoder.decode(errorMsg, "UTF-8"); } catch (Exception e) { }
            %>
            <div class="mb-4 rounded-lg border border-red-300 bg-red-50 dark:bg-red-900/20 dark:border-red-700 px-4 py-3 text-sm text-red-700 dark:text-red-300">
                <%= errorMsg %>
            </div>
            <% } %>

            <% if (message != null && !message.isEmpty()) { %>
            <div class="mb-4 rounded-lg border border-green-300 bg-green-50 dark:bg-green-900/20 dark:border-green-700 px-4 py-3 text-sm text-green-800 dark:text-green-200">
                <%= message %>
            </div>
            <% if (devResetLink != null && !devResetLink.isEmpty()) { %>
            <div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">
                <p class="font-semibold mb-1">No email configured? Use this link (valid 1 hour):</p>
                <a href="<%= devResetLink %>" class="break-all text-primary font-bold hover:underline"><%= devResetLink %></a>
            </div>
            <% } %>
            <% } else { %>

            <form class="space-y-5" method="post" action="<%= ctx %>/forgot-password">
                <div class="flex flex-col gap-2">
                    <label class="text-[#181411] dark:text-gray-200 text-sm font-semibold">Email Address</label>
                    <input class="w-full h-12 rounded-lg border border-[#e2e8f0] dark:border-gray-700 bg-white dark:bg-[#2d241b] px-4 text-[#181411] dark:text-white placeholder:text-[#94a3b8] focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                           placeholder="yourname@gmail.com"
                           type="email"
                           name="email"
                           maxlength="255"
                           pattern="[a-zA-Z0-9._%+-]+@gmail\.com"
                           title="Gmail address only."
                           required/>
                    <p class="text-xs text-[#64748b] dark:text-gray-400">Only Gmail (@gmail.com) is accepted.</p>
                </div>
                <button type="submit" class="w-full h-12 bg-primary hover:bg-primary-dark text-white font-bold rounded-lg shadow-lg shadow-primary/20 mt-4 active:scale-98">
                    Send Reset Link
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
