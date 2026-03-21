<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.LabTestRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%!
    String escAttr(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
%>
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

    String q = (String) request.getAttribute("q");
    if (q == null) q = "";
    String qEsc = q.replace("&", "&amp;")
                   .replace("\"", "&quot;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;");
    Integer pageObj = (Integer) request.getAttribute("page");
    Integer pageSizeObj = (Integer) request.getAttribute("pageSize");
    Integer totalObj = (Integer) request.getAttribute("totalRecords");
    int pageNumber = pageObj != null ? pageObj : 1;
    int pageSize = pageSizeObj != null ? pageSizeObj : 10;
    int total = totalObj != null ? totalObj : pendingRequests.size();
    if (pageNumber < 1) pageNumber = 1;
    if (pageSize <= 0) pageSize = 10;
    int fromIndex = pendingRequests.isEmpty() ? 0 : (pageNumber - 1) * pageSize + 1;
    int toIndex = pendingRequests.isEmpty() ? 0 : (pageNumber - 1) * pageSize + pendingRequests.size();
    int totalPages = total == 0 ? 1 : (int) Math.ceil(total / (double) pageSize);
    String prevDisabledAttr = pageNumber <= 1 ? "disabled" : "";
    String prevExtraClass = pageNumber <= 1 ? " opacity-40 cursor-not-allowed" : "";
    String nextDisabledAttr = pageNumber >= totalPages ? "disabled" : "";
    String nextExtraClass = pageNumber >= totalPages ? " opacity-40 cursor-not-allowed" : "";

    String uploadOk = request.getParameter("upload");
    String uploadErr = request.getParameter("uploadError");
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats Lab Technician - Lab Queue (FIFO)</title>
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
<%
    request.setAttribute("labSidebarActive", "queue");
%>
<%@ include file="/WEB-INF/views/lab/_lab-sidebar.jspf" %>
<main class="flex-1 flex flex-col overflow-hidden">
<header class="h-16 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-8 bg-white dark:bg-neutral-dark">
<div class="flex items-center gap-8">
<h2 class="text-sm font-bold text-slate-500 uppercase tracking-widest">Lab Queue</h2>
<div class="flex items-center gap-4 text-xs font-medium text-slate-400">
<span>Total: <%= total %></span>
<span class="w-px h-3 bg-slate-200"></span>
<span class="text-primary font-bold">FIFO Processing</span>
</div>
</div>
<div class="flex items-center gap-6">
<form action="<%= ctx %>/lab/labqueue" method="get" class="relative">
    <span class="material-symbols-outlined absolute left-0 top-1/2 -translate-y-1/2 text-slate-400">search</span>
    <input name="q"
           value="<%= qEsc %>"
           class="bg-transparent border-none text-xs focus:ring-0 w-56 pl-7"
           placeholder="Search by pet, owner, request/visit ID..."
           type="text"/>
    <input type="hidden" name="page" value="1"/>
</form>
<%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
<div class="relative">
    <button type="button"
            id="lab-profile-toggle"
            class="size-10 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold overflow-hidden hover:brightness-95 transition-colors">
        <% if (user.getProfilePictureUrl() != null && !user.getProfilePictureUrl().isEmpty()) { %>
        <img class="w-full h-full object-cover" src="<%= ctx %><%= user.getProfilePictureUrl() %>" alt="Profile"/>
        <% } else { %>
        <%= (user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "?" %>
        <% } %>
    </button>
    <div id="lab-profile-menu"
         class="absolute right-0 mt-2 w-56 origin-top-right rounded-xl bg-white dark:bg-slate-900 shadow-lg border border-slate-200 dark:border-slate-800 z-50"
         style="display:none;">
        <a href="<%= ctx %>/lab/profile"
           class="block px-4 py-3 text-sm font-bold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors rounded-t-xl flex items-center gap-2">
            <span class="material-symbols-outlined text-base text-primary">person</span>
            <span>My Profile</span>
        </a>
        <a href="<%= ctx %>/logout"
           class="block px-4 py-3 text-sm font-bold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors rounded-b-xl flex items-center gap-2">
            <span class="material-symbols-outlined text-base text-primary">logout</span>
            <span>Sign out</span>
        </a>
    </div>
</div>
</div>
</header>
<div class="flex-1 overflow-auto flex">
<div class="flex-1 p-8">
<% if ("1".equals(uploadOk)) { %>
<div class="mb-4 p-4 bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800 text-emerald-800 dark:text-emerald-200 text-sm font-medium">
    Result uploaded successfully.
</div>
<% } %>
<% if (uploadErr != null && !uploadErr.isEmpty()) { %>
<div class="mb-4 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm font-medium">
    <%= java.net.URLDecoder.decode(uploadErr, "UTF-8") %>
</div>
<% } %>
<div id="upload-network-error" class="mb-4 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm font-medium hidden">
    Network issue: upload may have failed. Please check your internet connection and try again.
</div>
<div class="bg-white dark:bg-neutral-dark border border-slate-200 dark:border-slate-800 shadow-sm rounded-2xl overflow-hidden">
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
           String breed = r.getBreed() != null ? r.getBreed() : "—";
           String ownerName = r.getOwnerName() != null ? r.getOwnerName() : "—";
           String clinicalNotes = r.getClinicalNotes() != null ? r.getClinicalNotes() : "";
           String patientLabel = petName + (species.isEmpty() ? "" : " (" + species + ")");
           String doctorName = r.getVeterinarianName() != null ? r.getVeterinarianName() : "—";
           String testName = r.getTestName() != null ? r.getTestName() : "—";
           String timeStr = r.getRequestTime() != null ? r.getRequestTime().format(timeFmt) : "—";
           String dateStr = r.getRequestTime() != null ? r.getRequestTime().format(dateFmt) : "—";
%>
<tr class="lab-row hover:bg-slate-50/50 dark:hover:bg-slate-800/30 transition-colors"
    data-request-id="<%= r.getRequestId() %>"
    data-visit-id="<%= r.getVisitId() %>"
    data-pet-name="<%= escAttr(petName) %>"
    data-species="<%= escAttr(species) %>"
    data-breed="<%= escAttr(breed) %>"
    data-owner-name="<%= escAttr(ownerName) %>"
    data-test-name="<%= escAttr(testName) %>"
    data-doctor-name="<%= escAttr(doctorName) %>"
    data-clinical-notes="<%= escAttr(clinicalNotes) %>">
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
        <div class="flex items-center justify-end gap-2">
            <button type="button"
                    class="btn-action-outline view-request"
                    data-request-id="<%= r.getRequestId() %>">
                <span class="material-symbols-outlined text-sm">visibility</span>
                View Details
            </button>
            <button type="button"
                    class="btn-action-primary select-request"
                    data-request-id="<%= r.getRequestId() %>">
                <span class="material-symbols-outlined text-sm">upload_file</span>
                Upload Results
            </button>
        </div>
    </td>
</tr>
<%     }
   } %>
</tbody>
</table>
<div class="px-6 py-4 bg-slate-50 dark:bg-slate-900/50 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between">
    <div class="flex items-center gap-6">
        <p class="text-xs text-slate-500 font-medium whitespace-nowrap">
            Showing <%= fromIndex %> to <%= toIndex %> of <%= total %> requests (FIFO)
            <% if (!q.isEmpty()) { %>
                for "<span class="font-semibold"><%= qEsc %></span>"
            <% } %>
        </p>
        <div class="flex items-center gap-2 border-l border-slate-200 dark:border-slate-700 pl-6">
            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Go to page</span>
            <form action="<%= ctx %>/lab/labqueue" method="get" class="flex items-center gap-1">
                <input type="hidden" name="q" value="<%= qEsc %>"/>
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
        <form action="<%= ctx %>/lab/labqueue" method="get">
            <input type="hidden" name="q" value="<%= qEsc %>"/>
            <input type="hidden" name="page" value="<%= pageNumber - 1 %>"/>
            <button type="submit"
                    class="flex items-center gap-1 px-3 py-1.5 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors<%= prevExtraClass %>"
                    <%= prevDisabledAttr %>>
                <span class="material-symbols-outlined text-sm">chevron_left</span>
                <span class="text-xs font-bold">Previous</span>
            </button>
        </form>
        <form action="<%= ctx %>/lab/labqueue" method="get">
            <input type="hidden" name="q" value="<%= qEsc %>"/>
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
<aside class="w-96 border-l border-slate-200 dark:border-slate-800 p-6 overflow-y-auto">
<div class="bg-white dark:bg-neutral-dark rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm p-6">
<div class="mb-8">
<h3 class="text-xs font-black text-slate-400 uppercase tracking-[0.2em] mb-1">Result Entry</h3>
<p class="text-[11px] text-slate-500 uppercase">Inputting data for: <span class="text-primary font-bold" id="resultEntryId">#V-7422</span></p>
</div>
<form id="lab-result-form"
      action="<%= ctx %>/lab/result"
      method="post"
      class="space-y-6">
    <input type="hidden" name="requestId" id="requestIdInput" value=""/>
    <input type="hidden" name="q" value="<%= qEsc %>"/>
    <input type="hidden" name="page" value="<%= pageNumber %>"/>
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
        class="w-full btn-action-primary justify-center !py-3 !rounded-lg !text-[10px] shadow-lg shadow-primary/10">
                            Submit Result to Doctor
                        </button>
<button type="button" class="w-full btn-action-outline justify-center !py-3 !rounded-lg !text-[10px]">
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

<!-- Request Details Modal -->
<div id="modalRequestDetails" class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
    <div class="w-full max-w-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 shadow-2xl overflow-hidden">
        <div class="px-6 pt-6 pb-4 flex items-center justify-between border-b border-slate-200 dark:border-slate-800">
            <div>
                <h2 class="text-lg font-bold text-slate-900 dark:text-slate-100">Lab Request Details</h2>
                <p class="text-xs text-slate-500 dark:text-slate-400 mt-1">Review request context before uploading results.</p>
            </div>
            <button type="button" id="btnCloseRequestDetails" class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div class="p-6 space-y-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 bg-slate-50 dark:bg-slate-900/50 border border-slate-200 dark:border-slate-800 p-4">
                <div>
                    <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Patient</p>
                    <p class="text-sm font-bold text-slate-900 dark:text-slate-100" id="detailPatient">—</p>
                </div>
                <div>
                    <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Breed</p>
                    <p class="text-sm font-bold text-slate-900 dark:text-slate-100" id="detailBreed">—</p>
                </div>
                <div>
                    <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Owner</p>
                    <p class="text-sm font-bold text-slate-900 dark:text-slate-100" id="detailOwner">—</p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Doctor</p>
                    <p class="text-sm font-semibold text-slate-900 dark:text-slate-100" id="detailDoctor">—</p>
                </div>
                <div>
                    <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Lab Test Type</p>
                    <p class="text-sm font-semibold text-slate-900 dark:text-slate-100" id="detailTestType">—</p>
                </div>
            </div>

            <div>
                <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Clinical Notes</p>
                <div class="mt-2 p-4 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 min-h-[120px]">
                    <p class="text-sm text-slate-700 dark:text-slate-300 whitespace-pre-wrap" id="detailClinicalNotes">—</p>
                </div>
            </div>

            <div class="flex justify-end gap-2 pt-2">
                <button type="button" id="btnCloseRequestDetails2" class="px-4 py-2 border border-slate-200 dark:border-slate-700 text-sm font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800">
                    Close
                </button>
            </div>
        </div>
    </div>
</div>
</aside>
</div>
</main>
</div>
<script>
(function() {
    var form = document.getElementById('lab-result-form');
    var networkBanner = document.getElementById('upload-network-error');
    var submitBtn = form ? form.querySelector('button[type="submit"]') : null;
    var pendingTimer = null;
    if (form) {
        form.addEventListener('submit', function() {
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.classList.add('opacity-70', 'cursor-not-allowed');
                submitBtn.textContent = 'Uploading...';
            }
            if (networkBanner) networkBanner.classList.add('hidden');
            if (pendingTimer) clearTimeout(pendingTimer);
            pendingTimer = setTimeout(function() {
                // If we are still on the page after a while, likely network/server issue.
                if (networkBanner) networkBanner.classList.remove('hidden');
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.classList.remove('opacity-70', 'cursor-not-allowed');
                    submitBtn.textContent = 'Submit Result to Doctor';
                }
            }, 12000);
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

    // View request details modal
    var modal = document.getElementById('modalRequestDetails');
    var close1 = document.getElementById('btnCloseRequestDetails');
    var close2 = document.getElementById('btnCloseRequestDetails2');
    function hideModal() {
        if (!modal) return;
        modal.classList.add('hidden');
        modal.classList.remove('flex');
    }
    function showModal() {
        if (!modal) return;
        modal.classList.remove('hidden');
        modal.classList.add('flex');
    }
    if (close1) close1.addEventListener('click', hideModal);
    if (close2) close2.addEventListener('click', function(e) { e.preventDefault(); hideModal(); });
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) hideModal();
        });
    }

    var elPatient = document.getElementById('detailPatient');
    var elBreed = document.getElementById('detailBreed');
    var elOwner = document.getElementById('detailOwner');
    var elDoctor = document.getElementById('detailDoctor');
    var elTestType = document.getElementById('detailTestType');
    var elNotes = document.getElementById('detailClinicalNotes');

    document.querySelectorAll('.view-request').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var row = this.closest('.lab-row');
            if (!row) return;
            var pet = row.getAttribute('data-pet-name') || '—';
            var species = row.getAttribute('data-species') || '';
            var owner = row.getAttribute('data-owner-name') || '—';
            var breed = row.getAttribute('data-breed') || '—';
            var doctor = row.getAttribute('data-doctor-name') || '—';
            var test = row.getAttribute('data-test-name') || '—';
            var notes = row.getAttribute('data-clinical-notes') || '';

            if (elPatient) elPatient.textContent = species ? (pet + ' (' + species + ')') : pet;
            if (elBreed) elBreed.textContent = breed;
            if (elOwner) elOwner.textContent = owner;
            if (elDoctor) elDoctor.textContent = doctor;
            if (elTestType) elTestType.textContent = test;
            if (elNotes) elNotes.textContent = notes && notes.trim() ? notes : 'No clinical notes provided for this request.';

            showModal();
        });
    });

    // Profile dropdown toggle (header)
    var labToggle = document.getElementById('lab-profile-toggle');
    var labMenu = document.getElementById('lab-profile-menu');
    if (labToggle && labMenu) {
        labToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            labMenu.style.display = (labMenu.style.display === 'none' || labMenu.style.display === '') ? 'block' : 'none';
        });
        document.addEventListener('click', function(e) {
            if (!labMenu.contains(e.target) && !labToggle.contains(e.target)) {
                labMenu.style.display = 'none';
            }
        });
    }
})();
</script>
</body>
</html>

