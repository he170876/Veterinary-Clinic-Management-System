<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String denyMessage = (String) request.getAttribute("denyMessage");
    if (denyMessage == null || denyMessage.trim().isEmpty()) {
        denyMessage = "Bạn không có quyền truy cập nội dung này.";
    }

    String backUrl = (String) request.getAttribute("backUrl");
    if (backUrl == null || backUrl.trim().isEmpty()) {
        backUrl = request.getContextPath() + "/customer/dashboard";
    }
%>
<!DOCTYPE html>
<html class="light" lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Access Denied</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;700;800&amp;display=swap" rel="stylesheet"/>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f14337",
                        "background-light": "#f8f7f5",
                        "background-dark": "#23190f"
                    },
                    fontFamily: {
                        "display": ["Manrope", "sans-serif"]
                    }
                }
            }
        }
    </script>
    <style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 500, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-white min-h-screen flex items-center justify-center px-4">
<div class="w-full max-w-xl bg-white dark:bg-[#2d2116] border border-[#f5f2f0] dark:border-[#3d2f23] rounded-2xl p-8 shadow-sm">
    <div class="flex items-center gap-4 mb-4">
        <div class="size-12 rounded-full bg-red-100 dark:bg-red-900/25 flex items-center justify-center">
            <span class="material-symbols-outlined text-red-600">lock</span>
        </div>
        <h1 class="text-2xl font-extrabold tracking-tight">Access Denied</h1>
    </div>
    <p class="text-[#6b5b4a] dark:text-[#c7b9aa] leading-relaxed mb-6"><%= denyMessage %></p>
    <div class="flex flex-col sm:flex-row gap-3">
        <a href="<%= backUrl %>" class="flex-1 inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg bg-primary text-white font-bold hover:bg-primary/90 transition-colors">
            <span class="material-symbols-outlined text-[18px]">arrow_back</span>
            Quay lại trang đầu
        </a>
        <a href="<%= request.getContextPath() %>/pets" class="flex-1 inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg border border-[#e9dfd8] dark:border-[#4a3b2f] text-[#4a3a2d] dark:text-[#e5d9cf] font-bold hover:bg-[#f8f3ef] dark:hover:bg-[#3a2d23] transition-colors">
            <span class="material-symbols-outlined text-[18px]">pets</span>
            Về danh sách thú cưng
        </a>
    </div>
</div>
</body>
</html>
