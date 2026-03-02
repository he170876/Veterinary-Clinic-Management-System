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
    <title>My Medical Records - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script>
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
    <style>
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display min-h-screen">
<div class="flex min-h-screen">
    <%
        request.setAttribute("customerCurrentPage", "records");
    %>
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    <!-- Main Content -->
    <main class="flex-1 flex flex-col min-w-0 overflow-y-auto">
        <div class="max-w-6xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8">
            <div class="flex items-center justify-between mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">My Medical Records</h1>
                    <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                        Completed visits whose payments have been confirmed by the clinic.
                    </p>
                </div>
            </div>
            <div class="bg-white dark:bg-background-dark rounded-xl border border-gray-100 dark:border-white/10 shadow-sm overflow-hidden">
                <table class="w-full text-left border-collapse">
                    <thead>
                    <tr class="bg-slate-50 dark:bg-slate-900/40 border-b border-slate-200 dark:border-slate-800">
                        <th class="px-6 py-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider">Record ID</th>
                        <th class="px-6 py-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider">Patient ID</th>
                        <th class="px-6 py-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider">Pet Name</th>
                        <th class="px-6 py-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider">Examination Date</th>
                        <th class="px-6 py-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider">Doctor</th>
                        <th class="px-6 py-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider">Diagnosis</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 dark:divide-slate-900">
                    <%
                        if (records.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="6" class="px-6 py-10 text-center text-sm text-slate-500 dark:text-slate-400">
                            You don't have any completed medical records yet. After your visit is paid, records will appear here.
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
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>
</body>
</html>

