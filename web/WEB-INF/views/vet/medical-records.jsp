<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.MedicalRecordSummary" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<MedicalRecordSummary> records = (List<MedicalRecordSummary>) request.getAttribute("records");
    if (records == null) records = java.util.Collections.emptyList();
    java.time.format.DateTimeFormatter dateFormatter =
            (java.time.format.DateTimeFormatter) request.getAttribute("dateFormatter");
    if (dateFormatter == null) {
        dateFormatter = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");
    }
    String q = (String) request.getAttribute("q");
    if (q == null) q = "";
    String fromDate = (String) request.getAttribute("fromDate");
    if (fromDate == null || fromDate.trim().isEmpty()) fromDate = java.time.LocalDate.now().toString();
    String toDate = (String) request.getAttribute("toDate");
    if (toDate == null || toDate.trim().isEmpty()) toDate = java.time.LocalDate.now().toString();
    String qEsc = q.replace("&", "&amp;")
                   .replace("\"", "&quot;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;");
    String fromDateEsc = fromDate.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
    String toDateEsc = toDate.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
    Integer pageObj = (Integer) request.getAttribute("page");
    Integer pageSizeObj = (Integer) request.getAttribute("pageSize");
    Integer totalObj = (Integer) request.getAttribute("totalRecords");
    int pageNumber = pageObj != null ? pageObj : 1;
    int pageSize = pageSizeObj != null ? pageSizeObj : 10;
    int total = totalObj != null ? totalObj : records.size();
    if (pageNumber < 1) pageNumber = 1;
    if (pageSize <= 0) pageSize = 10;
    int fromIndex = records.isEmpty() ? 0 : (pageNumber - 1) * pageSize + 1;
    int toIndex = records.isEmpty() ? 0 : (pageNumber - 1) * pageSize + records.size();
    int totalPages = total == 0 ? 1 : (int) Math.ceil(total / (double) pageSize);
    String prevDisabledAttr = pageNumber <= 1 ? "disabled" : "";
    String prevExtraClass = pageNumber <= 1 ? " opacity-40 cursor-not-allowed" : "";
    String nextDisabledAttr = pageNumber >= totalPages ? "disabled" : "";
    String nextExtraClass = pageNumber >= totalPages ? " opacity-40 cursor-not-allowed" : "";
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats Medical Records History List</title>
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
                    fontFamily: {
                        "display": ["Manrope"]
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
    <style type="text/tailwindcss">
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 font-display">
<div class="flex min-h-screen">
    <%@ include file="/WEB-INF/views/vet/_sidebar.jspf" %>
    <main class="flex-1 flex flex-col h-screen overflow-hidden">
        <header class="h-16 flex items-center justify-between px-8 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 shrink-0 z-10">
            <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-primary">stethoscope</span>
                <h2 class="text-lg font-bold text-slate-900 dark:text-slate-100">Medical Records History</h2>
            </div>
            <%@ include file="/WEB-INF/includes/vet-header-right.jspf" %>
        </header>
        <div class="flex-1 overflow-auto p-8">
            <div class="bg-white dark:bg-slate-950 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden flex flex-col">
                <!-- Search + date range filters -->
                <div class="p-4 border-b border-slate-200 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/20">
                    <form action="<%= ctx %>/vet/records" method="get" class="grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_180px_180px_auto] gap-3 items-end">
                        <div class="relative max-w-2xl">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">search</span>
                            <input name="q"
                                   value="<%= qEsc %>"
                                   class="w-full pl-12 pr-4 py-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all placeholder:text-slate-400"
                                   placeholder="Search by pet, owner, or record ID..."
                                   type="text"/>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">From date</label>
                            <input type="date" name="fromDate" value="<%= fromDateEsc %>"
                                   class="w-full py-2.5 px-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none"/>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">To date</label>
                            <input type="date" name="toDate" value="<%= toDateEsc %>"
                                   class="w-full py-2.5 px-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-sm focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none"/>
                        </div>
                        <div>
                            <button type="submit" class="w-full px-4 py-2.5 rounded-xl bg-primary text-white text-sm font-bold hover:bg-primary/90 transition-colors">
                                Apply
                            </button>
                        </div>
                        <input type="hidden" name="page" value="1"/>
                    </form>
                </div>
                <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                    <tr class="bg-slate-50 dark:bg-slate-900/50 border-b border-slate-200 dark:border-slate-800">
                        <th class="px-6 py-4 font-bold text-slate-400 uppercase text-[10px] tracking-wider">Record ID</th>
                        <th class="px-6 py-4 font-bold text-slate-400 uppercase text-[10px] tracking-wider">Patient ID</th>
                        <th class="px-6 py-4 font-bold text-slate-400 uppercase text-[10px] tracking-wider">Pet Name</th>
                        <th class="px-6 py-4 font-bold text-slate-400 uppercase text-[10px] tracking-wider">Examination Date</th>
                        <th class="px-6 py-4 font-bold text-slate-400 uppercase text-[10px] tracking-wider">Attending Doctor</th>
                        <th class="px-6 py-4 font-bold text-slate-400 uppercase text-[10px] tracking-wider">Primary Diagnosis</th>
                        <th class="px-6 py-4 font-bold text-slate-400 uppercase text-[10px] tracking-wider text-right">Action</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 dark:divide-slate-900">
                    <%
                        if (records.isEmpty()) {
                    %>
                    <tr>
                        <td class="px-6 py-6 text-center text-sm text-slate-500 dark:text-slate-400" colspan="7">
                            No medical records found yet. Complete an examination to create the first record.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (MedicalRecordSummary r : records) {
                                String recordCode = "MR-" + r.getRecordId();
                                String patientId = r.getPatientCode() != null ? r.getPatientCode() : "";
                                String petName = r.getPetName() != null ? r.getPetName() : "";
                                String doctorName = r.getVeterinarianName() != null ? r.getVeterinarianName() : "";
                                String examDate = r.getExaminationDate() != null ? r.getExaminationDate().format(dateFormatter) : "";
                                String diagnosis = r.getPrimaryDiagnosis() != null ? r.getPrimaryDiagnosis() : "—";
                    %>
                    <tr class="hover:bg-slate-50/50 dark:hover:bg-slate-900/30 transition-colors group">
                        <td class="px-6 py-4">
                            <span class="text-sm font-bold text-slate-900 dark:text-slate-100"><%= recordCode %></span>
                        </td>
                        <td class="px-6 py-4 text-sm font-medium text-slate-600 dark:text-slate-400"><%= patientId %></td>
                        <td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100"><%= petName %></td>
                        <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= examDate %></td>
                        <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= doctorName %></td>
                        <td class="px-6 py-4">
                            <span class="px-2.5 py-1 text-xs font-semibold bg-primary/5 text-primary rounded-full border border-primary/10">
                                <%= diagnosis %>
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <a href="<%= ctx %>/vet/record?id=<%= r.getRecordId() %>"
                               class="inline-flex items-center px-4 py-1.5 bg-primary text-white text-xs font-bold rounded-lg hover:bg-primary/90 transition-colors">
                                View Record
                            </a>
                        </td>
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                    </table>
                </div>
                <div class="px-6 py-4 bg-slate-50 dark:bg-slate-900/50 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between">
                    <div class="flex items-center gap-6">
                        <p class="text-xs text-slate-500 font-medium whitespace-nowrap">
                            Showing <%= fromIndex %> to <%= toIndex %> of <%= total %> records (Earliest first)
                            <% if (!q.isEmpty()) { %>
                                for "<span class="font-semibold"><%= qEsc %></span>"
                            <% } %>
                        </p>
                        <div class="flex items-center gap-2 border-l border-slate-200 dark:border-slate-700 pl-6">
                            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Go to page</span>
                            <form action="<%= ctx %>/vet/records" method="get" class="flex items-center gap-1">
                                <input type="hidden" name="q" value="<%= qEsc %>"/>
                                <input type="hidden" name="fromDate" value="<%= fromDateEsc %>"/>
                                <input type="hidden" name="toDate" value="<%= toDateEsc %>"/>
                                <input class="w-16 h-8 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-lg text-xs font-bold text-center focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                       name="page"
                                       type="number"
                                       min="1"
                                       max="<%= totalPages %>"
                                       value="<%= pageNumber %>"/>
                            </form>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <form action="<%= ctx %>/vet/records" method="get">
                            <input type="hidden" name="q" value="<%= qEsc %>"/>
                            <input type="hidden" name="fromDate" value="<%= fromDateEsc %>"/>
                            <input type="hidden" name="toDate" value="<%= toDateEsc %>"/>
                            <input type="hidden" name="page" value="<%= pageNumber - 1 %>"/>
                            <button type="submit"
                                    class="flex items-center gap-1 px-3 py-1.5 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors<%= prevExtraClass %>"
                                    <%= prevDisabledAttr %>>
                                <span class="material-symbols-outlined text-sm">chevron_left</span>
                                <span class="text-xs font-bold">Previous</span>
                            </button>
                        </form>
                        <form action="<%= ctx %>/vet/records" method="get">
                            <input type="hidden" name="q" value="<%= qEsc %>"/>
                            <input type="hidden" name="fromDate" value="<%= fromDateEsc %>"/>
                            <input type="hidden" name="toDate" value="<%= toDateEsc %>"/>
                            <input type="hidden" name="page" value="<%= pageNumber + 1 %>"/>
                            <button type="submit"
                                    class="flex items-center gap-1 px-3 py-1.5 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors<%= nextExtraClass %>"
                                    <%= nextDisabledAttr %>>
                                <span class="text-xs font-bold">Next</span>
                                <span class="material-symbols-outlined text-sm">chevron_right</span>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
<%@ include file="/WEB-INF/includes/vet-header-right-script.jspf" %>
</body>
</html>

