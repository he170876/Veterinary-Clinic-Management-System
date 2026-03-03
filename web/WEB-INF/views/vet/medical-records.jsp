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
        <header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 flex items-center justify-between px-8 shrink-0">
            <div class="flex items-center gap-4">
                <h2 class="text-xl font-bold text-slate-900 dark:text-slate-100">Medical Records History</h2>
                <div class="flex items-center gap-2 px-3 py-1.5 bg-slate-100 dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700">
                    <span class="material-symbols-outlined text-slate-400 text-sm">search</span>
                    <input class="bg-transparent border-none p-0 text-sm focus:ring-0 w-64 placeholder:text-slate-400"
                           placeholder="Search records..." type="text"/>
                </div>
            </div>
            <div class="flex items-center gap-3">
                <button class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-slate-700 dark:text-slate-300 bg-slate-100 dark:bg-slate-800 rounded-lg hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors" type="button">
                    <span class="material-symbols-outlined text-sm">filter_list</span>
                    Filters
                </button>
                <button class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-white bg-primary rounded-lg hover:bg-primary/90 shadow-sm transition-colors" type="button" disabled>
                    <span class="material-symbols-outlined text-sm">add</span>
                    New Record
                </button>
            </div>
        </header>
        <div class="flex-1 overflow-auto p-8">
            <div class="bg-white dark:bg-slate-950 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
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
                <div class="px-6 py-4 bg-slate-50 dark:bg-slate-900/50 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between">
                    <p class="text-xs text-slate-500 font-medium">
                        Showing 1 to <%= records.isEmpty() ? 0 : records.size() %> records
                    </p>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>

