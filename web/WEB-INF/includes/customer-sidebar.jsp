<%-- Shared customer sidebar: include from dashboard, profile, edit-profile, pets, medical-history, appointments. Set request.setAttribute("customerCurrentPage", "dashboard"|"profile"|"edit-profile"|"pets"|"medical-history"|"appointments") to highlight active link. --%>
<%
    String ctx = request.getContextPath();
    String currentPage = request.getAttribute("customerCurrentPage") != null ? (String) request.getAttribute("customerCurrentPage") : "";
    model.User sidebarUser = (model.User) request.getAttribute("user");
    if (sidebarUser == null && session != null) sidebarUser = (model.User) session.getAttribute("currentUser");
    String sidebarName = (sidebarUser != null && sidebarUser.getFullName() != null && !sidebarUser.getFullName().isEmpty()) ? sidebarUser.getFullName() : (sidebarUser != null ? sidebarUser.getEmail() : "");
%>
<aside class="w-64 border-r border-[#f4f0f0] bg-white dark:bg-background-dark flex flex-col justify-between p-4 sticky top-0 h-screen shrink-0">
    <div class="flex flex-col gap-8">
        <a href="<%= ctx %>/index.jsp" class="flex gap-3 items-center">
            <div class="bg-primary rounded-full size-10 flex items-center justify-center text-white">
                <span class="material-symbols-outlined">pets</span>
            </div>
            <div class="flex flex-col">
                <h1 class="text-[#181111] dark:text-white text-base font-bold leading-normal">Anipats</h1>
                <p class="text-[#896461] text-xs font-normal leading-normal">Veterinary Medical Center</p>
            </div>
        </a>
        <nav class="flex flex-col gap-2">
            <a class="flex items-center gap-3 px-3 py-2 text-[#181111] dark:text-white hover:bg-background-light dark:hover:bg-white/10 rounded-xl transition-colors <%= "dashboard".equals(currentPage) ? "bg-primary/10 text-primary" : "" %>" href="<%= ctx %>/customer/dashboard">
                <span class="material-symbols-outlined">dashboard</span>
                <p class="text-sm font-medium">Dashboard</p>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 rounded-xl transition-colors <%= "pets".equals(currentPage) ? "bg-primary/10 text-primary" : "text-[#181111] dark:text-white hover:bg-background-light dark:hover:bg-white/10" %>" href="<%= ctx %>/pets">
                <span class="material-symbols-outlined">pets</span>
                <p class="text-sm font-medium">My Pets</p>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 rounded-xl transition-colors <%= "appointments".equals(currentPage) ? "bg-primary/10 text-primary" : "text-[#181111] dark:text-white hover:bg-background-light dark:hover:bg-white/10" %>" href="<%= ctx %>/customer/appointments">
                <span class="material-symbols-outlined">calendar_today</span>
                <p class="text-sm font-medium">Appointments</p>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 text-[#181111] dark:text-white hover:bg-background-light dark:hover:bg-white/10 rounded-xl transition-colors <%= "medical-history".equals(currentPage) ? "bg-primary/10 text-primary" : "" %>" href="<%= ctx %>/customer/medical-history">
                <span class="material-symbols-outlined">medical_services</span>
                <p class="text-sm font-medium">Medical Records</p>
            </a>

        </nav>
    </div>
</aside>
