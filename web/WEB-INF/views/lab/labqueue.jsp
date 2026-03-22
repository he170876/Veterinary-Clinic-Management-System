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
    <title>Anipats Lab Technician Dashboard</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&amp;family=Inter:wght@400;500;600&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "surface-tint": "#994700",
                        "tertiary": "#006397",
                        "on-secondary-fixed": "#321300",
                        "on-tertiary-fixed": "#001d31",
                        "background": "#faf9f7",
                        "secondary-fixed": "#ffdbc8",
                        "primary-fixed": "#ffdbc8",
                        "inverse-surface": "#2f3130",
                        "on-secondary-fixed-variant": "#71370b",
                        "tertiary-container": "#00a9fd",
                        "tertiary-fixed": "#cce5ff",
                        "on-secondary": "#ffffff",
                        "error": "#ba1a1a",
                        "surface": "#faf9f7",
                        "primary": "#FF7A00",
                        "secondary-fixed-dim": "#ffb68a",
                        "on-error-container": "#93000a",
                        "on-error": "#ffffff",
                        "outline": "#8c7263",
                        "on-secondary-container": "#783d11",
                        "surface-bright": "#faf9f7",
                        "on-primary": "#ffffff",
                        "surface-container-highest": "#e3e2e0",
                        "inverse-on-surface": "#f1f1ef",
                        "surface-container": "#efeeec",
                        "on-surface-variant": "#584235",
                        "secondary": "#8e4e21",
                        "on-surface": "#1a1c1b",
                        "secondary-container": "#ffab76",
                        "on-tertiary-fixed-variant": "#004b73",
                        "primary-container": "#FF7A00",
                        "on-background": "#1a1c1b",
                        "outline-variant": "#e0c0af",
                        "surface-container-lowest": "#ffffff",
                        "surface-dim": "#dadad8",
                        "on-tertiary-container": "#003b5c",
                        "surface-container-low": "#f4f3f1",
                        "on-primary-fixed": "#321300",
                        "on-primary-fixed-variant": "#743500",
                        "surface-container-high": "#e9e8e6",
                        "surface-variant": "#e3e2e0",
                        "inverse-primary": "#ffb68a",
                        "on-primary-container": "#5d2900",
                        "primary-fixed-dim": "#ffb68a",
                        "error-container": "#ffdad6",
                        "on-tertiary": "#ffffff",
                        "tertiary-fixed-dim": "#92ccff"
                    },
                    fontFamily: {
                        "headline": ["Manrope", "sans-serif"],
                        "body": ["Inter", "sans-serif"],
                        "label": ["Inter", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"},
                },
            },
        }
    </script>
    <style>
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        body { font-family: 'Inter', sans-serif; }
        h1, h2, h3, .font-headline { font-family: 'Manrope', sans-serif; }
        #result-panel {
            transform: translateX(100%);
            transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        #result-panel.open { transform: translateX(0); }
        .main-panel-open { margin-right: 400px !important; }
    </style>
</head>
<body class="bg-surface text-on-surface antialiased overflow-hidden">
<%
    request.setAttribute("labSidebarActive", "queue");
%>
<%@ include file="/WEB-INF/views/lab/_lab-sidebar.jspf" %>

<main class="ml-64 mr-0 min-h-screen relative transition-all duration-300 ease-out" id="main-content">
    <header class="fixed top-0 right-0 left-64 h-16 z-40 bg-stone-50/80 dark:bg-stone-950/80 backdrop-blur-md flex justify-between items-center px-8 border-b border-stone-100/80">
        <div class="flex items-center gap-6">
            <h1 class="text-lg font-black uppercase tracking-widest text-stone-900 dark:text-stone-50 font-headline">Lab Queue</h1>
            <div class="h-4 w-px bg-stone-300"></div>
            <div class="flex items-center gap-4 text-xs font-bold text-stone-500">
                <span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-primary"></span> Total: <%= total %></span>
                <span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-stone-300"></span> FIFO Processing</span>
            </div>
        </div>
        <div class="flex items-center gap-6">
            <form action="<%= ctx %>/lab/labqueue" method="get" class="relative">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-stone-400 text-lg pointer-events-none">search</span>
                <input name="q" value="<%= qEsc %>"
                       class="bg-surface-container border-none rounded-full pl-10 pr-4 py-1.5 text-sm w-64 focus:ring-2 focus:ring-primary/20 transition-all"
                       placeholder="Search by pet, owner, request/visit ID..."
                       type="text"/>
                <input type="hidden" name="page" value="1"/>
            </form>
            <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
            <div class="relative">
                <button type="button" id="lab-profile-toggle"
                        class="w-9 h-9 rounded-full overflow-hidden border border-stone-200 hover:ring-2 hover:ring-primary/20 transition-all flex items-center justify-center bg-primary/10 text-primary font-bold text-sm">
                    <% if (user.getProfilePictureUrl() != null && !user.getProfilePictureUrl().isEmpty()) { %>
                    <img class="w-full h-full object-cover" src="<%= ctx %><%= user.getProfilePictureUrl() %>" alt="Profile"/>
                    <% } else { %>
                    <%= (user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "?" %>
                    <% } %>
                </button>
                <div id="lab-profile-menu"
                     class="absolute right-0 mt-2 w-56 origin-top-right rounded-xl bg-white dark:bg-slate-900 shadow-lg border border-stone-200 dark:border-slate-800 z-50"
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

    <div class="pt-24 px-8 pb-12 overflow-y-auto max-h-screen">
        <% if ("1".equals(uploadOk)) { %>
        <div class="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-medium">
            Result uploaded successfully.
        </div>
        <% } %>
        <% if (uploadErr != null && !uploadErr.isEmpty()) { %>
        <div class="mb-6 p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 text-sm font-medium">
            <%= java.net.URLDecoder.decode(uploadErr, "UTF-8") %>
        </div>
        <% } %>
        <div id="upload-network-error" class="mb-6 p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 text-sm font-medium hidden">
            Network issue: upload may have failed. Please check your internet connection and try again.
        </div>

        <div class="flex justify-between items-end mb-8">
            <div>
                <h2 class="text-3xl font-extrabold text-stone-900 tracking-tight font-headline">Active Specimens</h2>
                <p class="text-stone-500 mt-1">Manage and process clinical samples in queue order (FIFO).</p>
            </div>
        </div>

        <% if (pendingRequests.isEmpty()) { %>
        <div class="rounded-2xl border border-stone-200 bg-surface-container-lowest p-6 text-center text-stone-500">
            <span class="material-symbols-outlined text-2xl text-stone-400 mb-2 inline-block">inbox</span>
            <p class="font-bold text-stone-700">No pending lab requests.</p>
            <p class="text-sm mt-1">New requests will appear here after veterinarians submit them.</p>
        </div>
        <% } else { %>
        <div class="space-y-4">
            <div class="grid grid-cols-12 gap-4 px-6 py-3 text-[10px] font-black uppercase tracking-[0.15em] text-stone-400">
                <div class="col-span-2">Pet name</div>
                <div class="col-span-2">Request Time</div>
                <div class="col-span-3">Doctor</div>
                <div class="col-span-3">Test Type</div>
                <div class="col-span-2 text-right">Actions</div>
            </div>
            <%
                for (int idx = 0; idx < pendingRequests.size(); idx++) {
                    LabTestRequest r = pendingRequests.get(idx);
                    boolean isFirst = idx == 0;
                    String petName = r.getPetName() != null ? r.getPetName() : "—";
                    String species = r.getSpecies() != null ? r.getSpecies() : "";
                    String breed = r.getBreed() != null ? r.getBreed() : "—";
                    String ownerName = r.getOwnerName() != null ? r.getOwnerName() : "—";
                    String clinicalNotes = r.getClinicalNotes() != null ? r.getClinicalNotes() : "";
                    String doctorName = r.getVeterinarianName() != null ? r.getVeterinarianName() : "—";
                    String testName = r.getTestName() != null ? r.getTestName() : "—";
                    String timeStr = r.getRequestTime() != null ? r.getRequestTime().format(timeFmt) : "—";
                    String dateStr = r.getRequestTime() != null ? r.getRequestTime().format(dateFmt) : "—";
                String rowCard = isFirst
                        ? "grid grid-cols-12 gap-4 items-center bg-surface-container-lowest p-6 rounded-xl shadow-[0_10px_40px_rgba(26,28,27,0.04)] border-l-4 border-primary lab-row"
                        : "grid grid-cols-12 gap-4 items-center bg-surface-container-low p-6 rounded-xl hover:bg-surface-container-lowest transition-colors group lab-row";
            %>
            <div class="<%= rowCard %>"
                 data-request-id="<%= r.getRequestId() %>"
                 data-visit-id="<%= r.getVisitId() %>"
                 data-pet-name="<%= escAttr(petName) %>"
                 data-species="<%= escAttr(species) %>"
                 data-breed="<%= escAttr(breed) %>"
                 data-owner-name="<%= escAttr(ownerName) %>"
                 data-test-name="<%= escAttr(testName) %>"
                 data-doctor-name="<%= escAttr(doctorName) %>"
                 data-clinical-notes="<%= escAttr(clinicalNotes) %>">
                <div class="col-span-2">
                    <p class="text-base font-extrabold text-stone-900"><%= petName %><% if (!species.isEmpty()) { %> <span class="text-sm font-semibold text-stone-500">(<%= species %>)</span><% } %></p>
                    <p class="text-[11px] text-stone-400 mt-0.5">Visit #V-<%= r.getVisitId() %></p>
                </div>
                <div class="col-span-2">
                    <span class="text-sm font-medium text-stone-900"><%= timeStr %></span>
                    <span class="text-[10px] text-stone-400 block"><%= dateStr %></span>
                </div>
                <div class="col-span-3">
                    <span class="text-sm font-semibold text-stone-900"><%= doctorName %></span>
                </div>
                <div class="col-span-3">
                    <span class="text-sm text-stone-600"><%= testName %></span>
                </div>
                <div class="col-span-2 text-right">
                    <div class="flex items-center justify-end gap-2 flex-wrap">
                        <button type="button"
                                class="view-request border border-stone-200 text-stone-600 hover:bg-stone-50 px-3 py-2 rounded-lg text-xs font-bold transition-all inline-flex items-center gap-1">
                            <span class="material-symbols-outlined text-sm">visibility</span>
                            View
                        </button>
                        <button type="button"
                                class="select-request bg-primary/10 text-primary hover:bg-primary hover:text-white px-4 py-2 rounded-lg text-xs font-bold transition-all inline-flex items-center gap-1">
                            <span class="material-symbols-outlined text-sm">upload_file</span>
                            Upload Result
                        </button>
                    </div>
                </div>
            </div>
            <% } %>
        </div>

        <div class="mt-8 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 px-2">
            <p class="text-xs text-stone-500 font-medium">
                Showing <%= fromIndex %> to <%= toIndex %> of <%= total %> requests (FIFO)
                <% if (!q.isEmpty()) { %> for "<span class="font-semibold"><%= qEsc %></span>"<% } %>
            </p>
            <div class="flex items-center gap-4 flex-wrap">
                <form action="<%= ctx %>/lab/labqueue" method="get" class="flex items-center gap-2">
                    <input type="hidden" name="q" value="<%= qEsc %>"/>
                    <span class="text-[10px] font-bold text-stone-400 uppercase">Page</span>
                    <input class="w-16 h-8 bg-white border border-stone-200 rounded-lg text-xs font-bold text-center focus:ring-2 focus:ring-primary/20 outline-none"
                           name="page" type="number" min="1" max="<%= totalPages %>" value="<%= pageNumber %>"/>
                </form>
                <form action="<%= ctx %>/lab/labqueue" method="get">
                    <input type="hidden" name="q" value="<%= qEsc %>"/>
                    <input type="hidden" name="page" value="<%= pageNumber - 1 %>"/>
                    <button type="submit"
                            class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg border border-stone-200 text-stone-600 hover:bg-stone-100 transition-colors<%= prevExtraClass %>"
                            <%= prevDisabledAttr %>>
                        <span class="material-symbols-outlined text-sm">chevron_left</span>
                        <span class="text-xs font-bold">Previous</span>
                    </button>
                </form>
                <form action="<%= ctx %>/lab/labqueue" method="get">
                    <input type="hidden" name="q" value="<%= qEsc %>"/>
                    <input type="hidden" name="page" value="<%= pageNumber + 1 %>"/>
                    <button type="submit"
                            class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg border border-stone-200 text-stone-600 hover:bg-stone-100 transition-colors<%= nextExtraClass %>"
                            <%= nextDisabledAttr %>>
                        <span class="text-xs font-bold">Next</span>
                        <span class="material-symbols-outlined text-sm">chevron_right</span>
                    </button>
                </form>
            </div>
        </div>
        <% } %>
    </div>
</main>

<% if (!pendingRequests.isEmpty()) { %>
<aside class="fixed right-0 top-0 h-screen w-[400px] bg-white shadow-2xl z-[60] flex flex-col border-l border-stone-100" id="result-panel">
    <div class="p-8 border-b border-stone-50 shrink-0">
        <div class="flex justify-between items-start mb-6">
            <div>
                <h2 class="text-lg font-black tracking-tight uppercase text-stone-900 font-headline">Result Entry</h2>
                <p class="text-[10px] font-bold text-slate-500 mt-1" id="resultEntryHint">Select a specimen and click <span class="text-primary">Upload Result</span>.</p>
                <p class="text-[10px] font-bold text-primary tracking-widest mt-2 hidden" id="resultEntryActiveLabel">INPUTTING DATA FOR: <span id="resultEntryId">—</span></p>
            </div>
            <button type="button" id="btnCloseResultPanel" class="text-stone-400 hover:text-stone-900 transition-colors" aria-label="Close">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div class="bg-stone-50 rounded-xl p-4 flex gap-4">
            <div class="flex-1 min-w-0">
                <p class="text-[10px] font-black uppercase text-stone-400 tracking-tighter">Test Type</p>
                <p class="text-sm font-bold text-stone-800 truncate" id="resultEntryTest">—</p>
            </div>
            <div class="w-px bg-stone-200 shrink-0"></div>
            <div class="flex-1 min-w-0">
                <p class="text-[10px] font-black uppercase text-stone-400 tracking-tighter">Requesting Doctor</p>
                <p class="text-sm font-bold text-stone-800 truncate" id="resultEntryDoctor">—</p>
            </div>
        </div>
    </div>

    <form id="lab-result-form"
          action="<%= ctx %>/lab/result"
          method="post"
          enctype="multipart/form-data"
          class="flex flex-col flex-1 min-h-0 opacity-50 pointer-events-none transition-opacity"
          data-awaiting-selection="true">
        <input type="hidden" name="requestId" id="requestIdInput" value=""/>
        <input type="hidden" name="q" value="<%= qEsc %>"/>
        <input type="hidden" name="page" value="<%= pageNumber %>"/>

        <div class="flex-1 overflow-y-auto p-8 space-y-6">
            <section>
                <label class="text-[11px] font-black uppercase tracking-widest text-stone-500 mb-2 block">Lab result image <span class="text-red-500">*</span></label>
                <label class="border-2 border-dashed border-stone-200 rounded-2xl p-6 flex flex-col items-center justify-center text-center cursor-pointer hover:border-primary transition-colors bg-stone-50/50 group">
                    <input type="file" name="labImage" id="labImageFile" class="sr-only" accept="image/jpeg,image/png,image/gif,image/webp"/>
                    <div id="lab-image-preview-wrap" class="hidden w-full mb-3">
                        <img id="lab-image-preview" src="" alt="Preview" class="max-h-48 mx-auto rounded-lg object-contain border border-stone-200"/>
                    </div>
                    <div id="lab-image-placeholder" class="flex flex-col items-center">
                        <div class="w-12 h-12 rounded-full bg-primary/5 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
                            <span class="material-symbols-outlined text-primary">upload_file</span>
                        </div>
                        <p class="text-sm font-bold text-stone-800">Tap to choose image</p>
                        <p class="text-xs text-stone-400 mt-1">JPG, PNG, GIF, WebP — max 10MB</p>
                    </div>
                </label>
                <p id="lab-image-err" class="hidden text-xs text-red-600 font-semibold mt-1">Please select an image.</p>
            </section>
            <section>
                <label class="text-[11px] font-black uppercase tracking-widest text-stone-500 mb-2 block">Text note <span class="text-red-500">*</span></label>
                <textarea name="resultNote" id="resultNoteInput" rows="8" disabled
                          class="w-full min-h-[180px] bg-stone-50 border border-stone-200 rounded-xl p-4 text-sm focus:ring-2 focus:ring-primary/20 placeholder:text-stone-400 resize-none"
                          placeholder="Clinical findings and interpretation (required)"></textarea>
                <p id="lab-note-err" class="hidden text-xs text-red-600 font-semibold mt-1">Please enter the text note.</p>
            </section>
        </div>
        <div class="p-8 bg-white border-t border-stone-50 space-y-3 shrink-0">
            <button type="submit" id="lab-result-submit" disabled
                    class="w-full bg-primary text-white py-4 rounded-full font-bold text-sm shadow-lg shadow-primary/20 hover:-translate-y-0.5 active:translate-y-px transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:translate-y-0">
                Submit Result to Doctor
            </button>
            <div class="flex items-center gap-2 text-[10px] text-stone-400 uppercase font-medium pt-2">
                <span class="material-symbols-outlined text-sm">verified_user</span>
                Digitally signed as Tech <%= techId %>
            </div>
        </div>
    </form>
</aside>

<%-- Request Details Modal --%>
<div id="modalRequestDetails" class="fixed inset-0 z-[70] hidden items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
    <div class="w-full max-w-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 shadow-2xl overflow-hidden rounded-2xl">
        <div class="px-6 pt-6 pb-4 flex items-center justify-between border-b border-slate-200 dark:border-slate-800">
            <div>
                <h2 class="text-lg font-bold text-slate-900 dark:text-slate-100 font-headline">Lab Request Details</h2>
                <p class="text-xs text-slate-500 dark:text-slate-400 mt-1">Review request context before uploading results.</p>
            </div>
            <button type="button" id="btnCloseRequestDetails" class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div class="p-6 space-y-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 bg-slate-50 dark:bg-slate-900/50 border border-slate-200 dark:border-slate-800 p-4 rounded-xl">
                <div>
                    <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Pet</p>
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
                <div class="mt-2 p-4 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 min-h-[120px] rounded-xl">
                    <p class="text-sm text-slate-700 dark:text-slate-300 whitespace-pre-wrap" id="detailClinicalNotes">—</p>
                </div>
            </div>
            <div class="flex justify-end gap-2 pt-2">
                <button type="button" id="btnCloseRequestDetails2" class="px-4 py-2 border border-slate-200 dark:border-slate-700 text-sm font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 rounded-lg">
                    Close
                </button>
            </div>
        </div>
    </div>
</div>
<% } %>

<script>
(function() {
    var form = document.getElementById('lab-result-form');
    var networkBanner = document.getElementById('upload-network-error');
    var submitBtn = document.getElementById('lab-result-submit');
    var mainContent = document.getElementById('main-content');
    var resultPanel = document.getElementById('result-panel');
    var btnClosePanel = document.getElementById('btnCloseResultPanel');
    var pendingTimer = null;

    function openResultPanel() {
        if (resultPanel) resultPanel.classList.add('open');
        if (mainContent) mainContent.classList.add('main-panel-open');
    }
    function closeResultPanel() {
        if (resultPanel) resultPanel.classList.remove('open');
        if (mainContent) mainContent.classList.remove('main-panel-open');
    }
    if (btnClosePanel) btnClosePanel.addEventListener('click', closeResultPanel);

    if (form) {
        form.addEventListener('submit', function(e) {
            var rid = document.getElementById('requestIdInput');
            if (!rid || !rid.value.trim()) {
                e.preventDefault();
                return false;
            }
            var rn = document.getElementById('resultNoteInput');
            var imgInput = document.getElementById('labImageFile');
            var imgErr = document.getElementById('lab-image-err');
            var noteErr = document.getElementById('lab-note-err');
            if (imgErr) imgErr.classList.add('hidden');
            if (noteErr) noteErr.classList.add('hidden');
            var noteOk = rn && rn.value.trim().length > 0;
            var fileOk = imgInput && imgInput.files && imgInput.files.length > 0;
            if (!noteOk) {
                e.preventDefault();
                if (noteErr) noteErr.classList.remove('hidden');
                return false;
            }
            if (!fileOk) {
                e.preventDefault();
                if (imgErr) imgErr.classList.remove('hidden');
                return false;
            }
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.classList.add('opacity-70', 'cursor-not-allowed');
                submitBtn.textContent = 'Uploading...';
            }
            if (networkBanner) networkBanner.classList.add('hidden');
            if (pendingTimer) clearTimeout(pendingTimer);
            pendingTimer = setTimeout(function() {
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
    var resultEntryHint = document.getElementById('resultEntryHint');
    var resultEntryActiveLabel = document.getElementById('resultEntryActiveLabel');
    var resultNoteInput = document.getElementById('resultNoteInput');
    var labImageFile = document.getElementById('labImageFile');
    var labImagePreview = document.getElementById('lab-image-preview');
    var labImagePreviewWrap = document.getElementById('lab-image-preview-wrap');
    var labImagePlaceholder = document.getElementById('lab-image-placeholder');

    if (labImageFile) {
        labImageFile.addEventListener('change', function() {
            var f = labImageFile.files && labImageFile.files[0];
            if (f && labImagePreview && labImagePreviewWrap) {
                var url = URL.createObjectURL(f);
                labImagePreview.src = url;
                labImagePreviewWrap.classList.remove('hidden');
                if (labImagePlaceholder) labImagePlaceholder.classList.add('hidden');
            } else if (labImagePreviewWrap) {
                labImagePreviewWrap.classList.add('hidden');
                if (labImagePlaceholder) labImagePlaceholder.classList.remove('hidden');
            }
        });
    }

    function activateResultEntryPanel(requestId, visitId, testName, doctorName) {
        if (requestIdInput) requestIdInput.value = requestId;
        if (resultEntryId) resultEntryId.textContent = visitId ? '#V-' + visitId : ('REQ #' + requestId);
        if (resultEntryTest) {
            resultEntryTest.textContent = testName || '—';
            resultEntryTest.classList.remove('text-stone-400');
            resultEntryTest.classList.add('text-stone-800');
        }
        if (resultEntryDoctor) {
            resultEntryDoctor.textContent = doctorName || '—';
            resultEntryDoctor.classList.remove('text-stone-400');
            resultEntryDoctor.classList.add('text-stone-800');
        }
        if (resultEntryHint) resultEntryHint.classList.add('hidden');
        if (resultEntryActiveLabel) resultEntryActiveLabel.classList.remove('hidden');
        if (form) {
            form.classList.remove('opacity-50', 'pointer-events-none');
            form.removeAttribute('data-awaiting-selection');
        }
        if (resultNoteInput) {
            resultNoteInput.disabled = false;
            resultNoteInput.value = '';
        }
        if (labImageFile) {
            labImageFile.value = '';
        }
        if (labImagePreviewWrap) labImagePreviewWrap.classList.add('hidden');
        if (labImagePlaceholder) labImagePlaceholder.classList.remove('hidden');
        if (labImagePreview) labImagePreview.src = '';
        var imgErr = document.getElementById('lab-image-err');
        var noteErr = document.getElementById('lab-note-err');
        if (imgErr) imgErr.classList.add('hidden');
        if (noteErr) noteErr.classList.add('hidden');
        if (submitBtn) submitBtn.disabled = false;
        openResultPanel();
    }

    document.querySelectorAll('.select-request').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var row = this.closest('.lab-row');
            if (!row) return;
            var requestId = row.getAttribute('data-request-id') || '';
            var visitId = row.getAttribute('data-visit-id') || '';
            var testName = row.getAttribute('data-test-name') || '';
            var doctorName = row.getAttribute('data-doctor-name') || '';
            activateResultEntryPanel(requestId, visitId, testName, doctorName);
        });
    });

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
