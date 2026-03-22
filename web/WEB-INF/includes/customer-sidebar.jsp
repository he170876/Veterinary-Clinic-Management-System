<%-- Customer sidebar — aligned with Vet / Receptionist (Anipats + slate theme) --%>
<%
    String ctx = request.getContextPath();
    String currentPage = request.getAttribute("customerCurrentPage") != null ? (String) request.getAttribute("customerCurrentPage") : "";
    Object sidebarUserObj = request.getAttribute("user");
    model.User sidebarUser = (sidebarUserObj instanceof model.User) ? (model.User) sidebarUserObj : null;
    if (sidebarUser == null && session != null) {
        Object sessionUserObj = session.getAttribute("currentUser");
        if (sessionUserObj instanceof model.User) {
            sidebarUser = (model.User) sessionUserObj;
        }
    }
%>
<aside class="hidden lg:flex w-64 flex-shrink-0 border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex-col">
    <div class="p-6 flex items-center gap-3">
        <div class="size-10 bg-primary rounded-lg flex items-center justify-center text-white">
            <span class="material-symbols-outlined text-2xl">pets</span>
        </div>
        <div>
            <h1 class="text-xl font-bold tracking-tight text-slate-900 dark:text-white">Anipats</h1>
            <p class="text-xs text-slate-500 dark:text-slate-400 font-medium">Veterinary Care</p>
        </div>
    </div>
    <nav class="flex-1 px-4 space-y-2 mt-4">
        <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-colors text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800<%= "dashboard".equals(currentPage) ? " bg-primary/10 text-primary" : "" %>"
           href="<%= ctx %>/customer/dashboard">
            <span class="material-symbols-outlined">dashboard</span>
            <span>Dashboard</span>
        </a>
        <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-colors text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800<%= "pets".equals(currentPage) ? " bg-primary/10 text-primary" : "" %>"
           href="<%= ctx %>/pets">
            <span class="material-symbols-outlined">pets</span>
            <span>My Pets</span>
        </a>
        <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-colors text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800<%= "appointments".equals(currentPage) ? " bg-primary/10 text-primary" : "" %>"
           href="<%= ctx %>/customer/appointments">
            <span class="material-symbols-outlined">calendar_today</span>
            <span>Appointments</span>
        </a>
        <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-colors text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800<%= "medical-history".equals(currentPage) ? " bg-primary/10 text-primary" : "" %>"
           href="<%= ctx %>/customer/medical-history">
            <span class="material-symbols-outlined">medical_services</span>
            <span>Medical Records</span>
        </a>
    </nav>
</aside>
