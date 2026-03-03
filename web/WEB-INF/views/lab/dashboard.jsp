<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.LabTestRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    String techId = user.getUserId() + "-T";
    @SuppressWarnings("unchecked")
    List<LabTestRequest> pendingRequests =
            (List<LabTestRequest>) request.getAttribute("pendingRequests");
    if (pendingRequests == null) pendingRequests = java.util.Collections.emptyList();
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("hh:mm a");
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats Lab Technician Dashboard - FIFO Lab Queue</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
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
                    fontFamily: { "display": ["Manrope", "sans-serif"] },
                    borderRadius: { "DEFAULT": "0.125rem", "lg": "0.25rem", "xl": "0.5rem", "full": "9999px" },
                },
            },
        }
    </script>
    <style type="text/tailwindcss">
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 20; }
        @layer components {
            .table-header { @apply px-4 py-3 text-left text-[11px] font-bold text-slate-400 uppercase tracking-wider border-b border-slate-200 dark:border-slate-800; }
            .table-cell { @apply px-4 py-4 text-sm text-slate-700 dark:text-slate-300 border-b border-slate-100 dark:border-slate-800/50; }
            .nav-link { @apply flex items-center gap-3 px-4 py-2 text-slate-500 hover:text-primary transition-colors; }
            .nav-link-active { @apply flex items-center gap-3 px-4 py-2 text-primary border-r-2 border-primary bg-primary/5; }
            .btn-action-primary { @apply bg-primary text-white text-[10px] font-bold px-4 py-1.5 uppercase tracking-widest hover:brightness-110 transition-all flex items-center gap-2; }
            .btn-action-outline { @apply border border-primary text-primary text-[10px] font-bold px-4 py-1.5 uppercase tracking-widest hover:bg-primary/5 transition-all flex items-center gap-2; }
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-900 dark:text-slate-100 antialiased font-display">
<div class="flex h-screen overflow-hidden">
<aside class="w-60 bg-white dark:bg-neutral-dark border-r border-slate-200 dark:border-slate-800 flex flex-col py-8">
<div class="px-6 mb-10">
<div class="flex items-center gap-2">
<div class="size-2 bg-primary"></div>
<h1 class="text-sm font-black tracking-tighter uppercase">Anipats Lab</h1>
</div>
<p class="text-[10px] text-slate-400 mt-1 uppercase tracking-widest">Clinical Terminal</p>
</div>
<nav class="flex flex-col flex-1">
<a class="nav-link" href="<%= ctx %>/lab/dashboard">
<span class="material-symbols-outlined">analytics</span>
<span class="text-xs font-bold uppercase tracking-tight">Overview</span>
</a>
<a class="nav-link-active" href="<%= ctx %>/lab/dashboard">
<span class="material-symbols-outlined">list_alt</span>
<span class="text-xs font-bold uppercase tracking-tight">Lab Queue</span>
</a>
<a class="nav-link" href="#">
<span class="material-symbols-outlined">database</span>
<span class="text-xs font-bold uppercase tracking-tight">Archives</span>
</a>
<a class="nav-link" href="#">
<span class="material-symbols-outlined">science</span>
<span class="text-xs font-bold uppercase tracking-tight">Reagents</span>
</a>
<a class="nav-link mt-auto border-t border-slate-100 dark:border-slate-800" href="#">
<span class="material-symbols-outlined">settings</span>
<span class="text-xs font-bold uppercase tracking-tight">System Settings</span>
</a>
<a class="nav-link px-4 py-2" href="<%= ctx %>/logout">
<span class="material-symbols-outlined">logout</span>
<span class="text-xs font-bold uppercase tracking-tight">Sign out</span>
</a>
</nav>
</aside>
<main class="flex-1 flex flex-col overflow-hidden">
<header class="h-16 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-8 bg-white dark:bg-neutral-dark">
<div class="flex items-center gap-8">
<h2 class="text-sm font-bold text-slate-500 uppercase tracking-widest">Lab Queue</h2>
<div class="flex items-center gap-4 text-xs font-medium text-slate-400">
<span>Total: <%= pendingRequests.size() %></span>
<span class="w-px h-3 bg-slate-200"></span>
<span class="text-primary font-bold">FIFO Processing</span>
</div>
</div>
<div class="flex items-center gap-6">
<div class="relative">
<span class="material-symbols-outlined absolute left-0 top-1/2 -translate-y-1/2 text-slate-400">search</span>
<input class="bg-transparent border-none text-xs focus:ring-0 w-48 pl-7" placeholder="Filter by ID or Name..." type="text" id="filterQueue"/>
</div>
<div class="flex items-center gap-3 pl-6 border-l border-slate-200 dark:border-slate-800">
<span class="text-[10px] font-bold text-slate-500 uppercase">Tech ID: <%= techId %></span>
<span class="text-[10px] text-slate-400"><%= user.getFullName() %></span>
<div class="size-2 rounded-full bg-emerald-500"></div>
</div>
</div>
</header>
<div class="flex-1 overflow-auto flex">
<div class="flex-1 p-8">
<div class="bg-white dark:bg-neutral-dark border border-slate-200 dark:border-slate-800 shadow-sm">
<table class="w-full border-collapse">
<thead>
<tr class="bg-slate-50 dark:bg-slate-900/50">
<th class="table-header">Patient Info</th>
<th class="table-header">
<div class="flex items-center gap-2">
                                    Request Time
                                    <div class="flex flex-col items-center">
<span class="material-symbols-outlined text-[12px] text-primary leading-none">expand_less</span>
<span class="text-[8px] font-black text-primary -mt-1">OLD</span>
</div>
</div>
</th>
<th class="table-header">Doctor</th>
<th class="table-header">Test Type</th>
<th class="table-header text-right px-8">Actions</th>
<tbody class="divide-y divide-slate-100 dark:divide-slate-800" id="labQueueBody">
<% if (pendingRequests.isEmpty()) { %>
<tr>
    <td class="table-cell text-center text-slate-500 dark:text-slate-400 text-sm" colspan="5">
        No pending lab requests.
    </td>
</tr>
<% } else {
       for (LabTestRequest r : pendingRequests) {
           String petName = r.getPetName() != null ? r.getPetName() : "—";
           String species = r.getSpecies() != null ? r.getSpecies() : "";
           String patientLabel = petName + (species.isEmpty() ? "" : " (" + species + ")");
           String doctorName = r.getVeterinarianName() != null ? r.getVeterinarianName() : "—";
           String testName = r.getTestName() != null ? r.getTestName() : "—";
           String timeStr = r.getRequestTime() != null ? r.getRequestTime().format(timeFmt) : "—";
           String dateStr = r.getRequestTime() != null ? r.getRequestTime().format(dateFmt) : "—";
%>
<tr class="lab-row hover:bg-slate-50/50 dark:hover:bg-slate-800/30 transition-colors"
    data-request-id="<%= r.getRequestId() %>"
    data-visit-id="<%= r.getVisitId() %>"
    data-pet-name="<%= petName %>"
    data-test-name="<%= testName %>"
    data-doctor-name="<%= doctorName %>">
    <td class="table-cell">
        <div class="font-bold text-slate-900 dark:text-white">#V-<%= r.getVisitId() %></div>
        <div class="text-[11px] text-slate-400"><%= patientLabel %></div>
    </td>
    <td class="table-cell">
        <div class="font-bold text-slate-900 dark:text-white uppercase tracking-tighter"><%= timeStr %></div>
        <div class="text-[10px] text-slate-400"><%= dateStr %></div>
    </td>
    <td class="table-cell"><%= doctorName %></td>
    <td class="table-cell font-medium"><%= testName %></td>
    <td class="table-cell text-right px-8">
        <button type="button"
                class="btn-action-primary ml-auto select-request"
                data-request-id="<%= r.getRequestId() %>">
            <span class="material-symbols-outlined text-sm">upload_file</span>
            Upload Results
        </button>
    </td>
</tr>
<%     }
   } %>
</tbody>
</table>
<div class="p-4 bg-slate-50 dark:bg-slate-900/50 border-t border-slate-200 dark:border-slate-800 flex justify-center">
<button type="button" class="text-[11px] font-bold text-slate-400 uppercase tracking-widest hover:text-slate-600 transition-colors">Load More Records</button>
</div>
</div>
</div>
<aside class="w-96 border-l border-slate-200 dark:border-slate-800 bg-white dark:bg-neutral-dark p-8 overflow-y-auto">
<div class="mb-8">
<h3 class="text-xs font-black text-slate-400 uppercase tracking-[0.2em] mb-1">Result Entry</h3>
<p class="text-[11px] text-slate-500 uppercase">Inputting data for: <span class="text-primary font-bold" id="resultEntryId">#V-7422</span></p>
</div>
<form id="lab-result-form"
      action="<%= ctx %>/lab/result"
      method="post"
      class="space-y-6">
    <input type="hidden" name="requestId" id="requestIdInput" value=""/>
<div class="space-y-2">
<label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider">Test Subject Summary</label>
<div class="p-4 bg-slate-50 dark:bg-slate-900/50 border border-slate-100 dark:border-slate-800/50">
<div class="grid grid-cols-2 gap-4">
<div>
<p class="text-[9px] text-slate-400 uppercase">Test</p>
<p class="text-xs font-bold" id="resultEntryTest">Cytology - Needle</p>
</div>
<div>
<p class="text-[9px] text-slate-400 uppercase">Doctor</p>
<p class="text-xs font-bold" id="resultEntryDoctor">Dr. E. Smith</p>
</div>
</div>
</div>
</div>
<div class="space-y-2">
<label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider">Quantitative Findings</label>
<input name="resultValue"
       class="w-full bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-sm py-2 px-3 rounded focus:ring-primary focus:border-primary"
       placeholder="Value (e.g. 14.5 mg/dL)"
       type="text"/>
</div>
<div class="space-y-2">
<label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider">Clinical Observations</label>
<textarea name="resultNote"
          class="w-full bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-sm py-3 px-3 rounded focus:ring-primary focus:border-primary resize-none"
          placeholder="Document abnormal morphologies or specific diagnostic markers identified during analysis..."
          rows="6"></textarea>
</div>
<div class="space-y-2">
<label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider">Lab Technician Notes (Internal)</label>
<textarea name="techNotes"
          class="w-full bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-sm py-3 px-3 rounded focus:ring-primary focus:border-primary resize-none"
          placeholder="Reagent batches, equipment calibration notes..."
          rows="3"></textarea>
</div>
<div class="pt-4 flex flex-col gap-3">
<button type="submit"
        class="w-full bg-primary text-white font-bold py-3 text-xs uppercase tracking-widest hover:brightness-110 transition-all shadow-lg shadow-primary/10 rounded">
                            Submit Result to Doctor
                        </button>
<button type="button" class="w-full border border-slate-200 dark:border-slate-800 text-slate-400 font-bold py-2 text-[10px] uppercase tracking-widest hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors rounded">
                            Save Draft
                        </button>
</div>
<div class="mt-8 pt-8 border-t border-slate-100 dark:border-slate-800">
<div class="flex items-center gap-2 text-[10px] text-slate-400 uppercase font-medium">
<span class="material-symbols-outlined text-sm">verified_user</span>
                            Digitally signed as Tech <%= techId %>
                        </div>
</div>
</form>
</aside>
</div>
</main>
</div>
<script>
(function() {
    var filter = document.getElementById('filterQueue');
    var rows = document.querySelectorAll('.lab-row');
    if (filter && rows.length) {
        filter.addEventListener('input', function() {
            var q = (this.value || '').toLowerCase();
            rows.forEach(function(row) {
                var id = (row.getAttribute('data-request-id') || '').toLowerCase();
                var name = (row.getAttribute('data-pet-name') || '').toLowerCase();
                var show = !q || id.indexOf(q) >= 0 || name.indexOf(q) >= 0;
                row.style.display = show ? '' : 'none';
            });
        });
    }
    var resultEntryId = document.getElementById('resultEntryId');
    var resultEntryTest = document.getElementById('resultEntryTest');
    var resultEntryDoctor = document.getElementById('resultEntryDoctor');
    var requestIdInput = document.getElementById('requestIdInput');

    document.querySelectorAll('.select-request').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var row = this.closest('.lab-row');
            if (!row) return;

            var requestId = row.getAttribute('data-request-id') || '';
            var visitId = row.getAttribute('data-visit-id') || '';
            var testName = row.getAttribute('data-test-name') || '';
            var doctorName = row.getAttribute('data-doctor-name') || '';

            if (requestIdInput) requestIdInput.value = requestId;
            if (resultEntryId) resultEntryId.textContent = visitId ? '#V-' + visitId : ('#' + requestId);
            if (resultEntryTest) resultEntryTest.textContent = testName;
            if (resultEntryDoctor) resultEntryDoctor.textContent = doctorName;
        });
    });
})();
</script>
</body>
</html>
