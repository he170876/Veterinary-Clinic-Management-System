<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Appointment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    if (appointments == null) appointments = java.util.Collections.emptyList();
    int currentVetId = request.getAttribute("currentVetId") != null ? (Integer) request.getAttribute("currentVetId") : 0;
    boolean vetHasActiveExamination = Boolean.TRUE.equals(request.getAttribute("vetHasActiveExamination"));
    String roleTitle = (user.getRole() != null && user.getRole().getRoleName() != null)
        ? user.getRole().getRoleName() : "Veterinarian";
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Anipats - Arrived Patients Queue</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700,0..1&amp;display=swap" rel="stylesheet"/>
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
                        borderRadius: {"DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px"},
                    },
                },
            }
        </script>
        <style>
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
        </style>
    </head>
    <body class="bg-background-light dark:bg-background-dark font-display text-slate-900 dark:text-slate-100">
        <div class="flex h-screen overflow-hidden">
            <%@ include file="/WEB-INF/views/vet/_sidebar.jspf" %>
            <!-- Main Content -->
            <main class="flex-1 flex flex-col overflow-hidden">
                <header class="h-16 border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-between px-8">
                    <div class="flex items-center gap-4">
                        <h2 class="text-xl font-bold tracking-tight">Arrived Patients Queue</h2>
                    </div>
                    <div class="flex items-center gap-6">
                        <%@ include file="/WEB-INF/includes/vet-header-right.jspf" %>
                    </div>
                </header>
                <div class="flex-1 overflow-y-auto p-8">
                    <%
                        String examError = request.getParameter("error");
                        String completed = request.getParameter("completed");
                        String revisit = request.getParameter("revisit");
                        if ("notfound".equals(examError)) {
                    %>
                    <div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">Could not open examination: appointment not found.</div>
                    <% } else if ("locked".equals(examError)) { %>
                    <div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">Another veterinarian has already started this examination.</div>
                    <% } else if ("1".equals(completed)) { %>
                    <div class="mb-4 rounded-lg border border-green-300 bg-green-50 dark:bg-green-900/20 dark:border-green-700 px-4 py-3 text-sm text-green-800 dark:text-green-200">Examination completed. Visit and appointment have been marked as completed.</div>
                    <% } else if ("ok".equals(revisit)) { %>
                    <div class="mb-4 rounded-lg border border-green-300 bg-green-50 dark:bg-green-900/20 dark:border-green-700 px-4 py-3 text-sm text-green-800 dark:text-green-200">Follow-up appointment scheduled successfully.</div>
                    <% } else if ("error".equals(revisit)) { %>
                    <div class="mb-4 rounded-lg border border-red-300 bg-red-50 dark:bg-red-900/20 dark:border-red-700 px-4 py-3 text-sm text-red-800 dark:text-red-200">Could not create follow-up appointment. Please try again.</div>
                    <% } else if ("missing".equals(revisit) || "invalid".equals(revisit)) { %>
                    <div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">Please provide a valid date and time for the follow-up appointment.</div>
                    <% } else if ("unauthorized".equals(revisit)) { %>
                    <div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">You can only schedule follow-ups for your own patients.</div>
                    <% } else if ("notcheckedin".equals(request.getParameter("error"))) { %>
                    <div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">Patient must be checked in by receptionist first. They will appear here after check-in.</div>
                    <% } else if ("busy".equals(examError)) { %>
                    <div class="mb-4 rounded-lg border border-amber-300 bg-amber-50 dark:bg-amber-900/20 dark:border-amber-700 px-4 py-3 text-sm text-amber-800 dark:text-amber-200">You already have an examination in progress. Complete it before starting another one.</div>
                    <% } %>
                    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
                        <div>
                            <h3 class="text-2xl font-bold text-slate-900 dark:text-slate-100">Checked-in Today</h3>
                            <p class="text-slate-500 dark:text-slate-400 text-sm mt-1">Patients currently in the waiting room. Start examination when ready.</p>
                        </div>
                        <div class="relative w-full sm:w-72 sm:shrink-0">
                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-lg pointer-events-none">search</span>
                            <input class="pl-10 pr-4 py-2 bg-slate-100 dark:bg-slate-800 border-none rounded-lg text-sm w-full focus:ring-2 focus:ring-primary/50" placeholder="Search owner, pet, or phone..." type="text" id="searchQueue"/>
                        </div>
                    </div>
                    <div class="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Queue No.</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Pet Name</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Species/Breed</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Owner Name</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Phone</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Arrival Time</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Service/Reason</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Status</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider text-right">Action</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 dark:divide-slate-800" id="queueTableBody">
                                <%
                                    int rowNum = 1;
                                    for (Appointment ap : appointments) {
                                        String ownerName = ap.getCustomer() != null && ap.getCustomer().getUser() != null ? ap.getCustomer().getUser().getFullName() : "—";
                                        String phone = ap.getCustomerPhone() != null && !ap.getCustomerPhone().isEmpty()
                                                ? ap.getCustomerPhone()
                                                : (ap.getCustomer() != null && ap.getCustomer().getUser() != null && ap.getCustomer().getUser().getPhone() != null
                                                    ? ap.getCustomer().getUser().getPhone()
                                                    : "—");
                                        String petName = ap.getPet() != null ? ap.getPet().getName() : "—";
                                        String species = ap.getPet() != null && ap.getPet().getSpecies() != null ? ap.getPet().getSpecies() : "";
                                        String breed = ap.getPet() != null && ap.getPet().getBreed() != null ? ap.getPet().getBreed() : "";
                                        String speciesBreed = (species + " / " + breed).trim();
                                        if (speciesBreed.equals("/")) speciesBreed = "—";
                                        String timeStr = ap.getArrivalTime() != null ? ap.getArrivalTime().format(timeFmt) : "—";
                                        String service = ap.getService() != null ? ap.getService() : "—";
                                        String status = ap.getStatus() != null ? ap.getStatus() : "—";
                                        String queueNo = String.format("%03d", rowNum);
                                        String statusClass = "Checked-in".equalsIgnoreCase(status)
                                            ? "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
                                            : "bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-300";
                                %>
                                <%
                                        boolean isInExam = "In-Examination".equalsIgnoreCase(status);
                                        Integer rowVetId = ap.getVeterinarianId();
                                        boolean lockedByOtherVet = isInExam && rowVetId != null && rowVetId > 0 && rowVetId != currentVetId;
                                %>
                                <tr class="queue-row hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors <%= lockedByOtherVet ? "opacity-45 grayscale-[0.35]" : "" %>" data-pet-name="<%= petName %>" data-owner-name="<%= ownerName %>" data-phone="<%= phone %>">
                                    <td class="px-6 py-4 text-sm font-semibold text-slate-900 dark:text-slate-100"><%= queueNo %></td>
                                    <td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100"><%= petName %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= speciesBreed %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= ownerName %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= phone %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= timeStr %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= service %></td>
                                    <td class="px-6 py-4">
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium <%= statusClass %>"><%= status %></span>
                                    </td>
                                    <td class="px-6 py-4 text-right space-x-2">
                                        <% if (lockedByOtherVet) { %>
                                        <span class="inline-block bg-slate-200 dark:bg-slate-700 text-slate-500 dark:text-slate-400 px-4 py-2 rounded-lg text-sm font-bold">In Progress</span>
                                        <% } else { %>
                                        <a href="<%= ctx %>/vet/examination?id=<%= ap.getAppointmentId() %>" data-exam-action="<%= isInExam ? "continue" : "start" %>" class="vet-exam-action-link inline-block bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg text-sm font-bold transition-all shadow-sm"><%= isInExam ? "Continue" : "Start Examination" %></a>
                                        <% } %>
                                        <button type="button" class="inline-block bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 px-4 py-2 rounded-lg text-sm font-semibold transition-all shadow-sm"
                                            data-appointment-id="<%= ap.getAppointmentId() %>"
                                            onclick="openVetAppointmentDetail(this.getAttribute('data-appointment-id'))">
                                            Details
                                        </button>
                                    </td>
                                </tr>
                                <%
                                        rowNum++;
                                    }
                                    if (appointments.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="9" class="px-6 py-8 text-center text-slate-500 dark:text-slate-400">No checked-in patients for today. Patients appear here after receptionist checks them in.</td>
                                </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                        <div class="px-6 py-4 bg-slate-50 dark:bg-slate-800/50 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between">
                            <p class="text-sm text-slate-500 dark:text-slate-400">Showing <%= appointments.size() %> of <%= appointments.size() %> results</p>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <div id="vetQueueToast" class="fixed top-6 right-6 bg-amber-500 text-white px-6 py-3 rounded-xl shadow-lg hidden items-center gap-2 z-[3000] max-w-md">
            <span class="material-symbols-outlined shrink-0">info</span>
            <span id="vetQueueToastMessage" class="text-sm font-medium">Message</span>
        </div>

        <%@ include file="/WEB-INF/includes/vet-appointment-detail-modal.jspf" %>
        <script>
            var VET_HAS_ACTIVE_EXAMINATION = <%= vetHasActiveExamination ? "true" : "false" %>;
            function showVetQueueToast(message) {
                var toast = document.getElementById('vetQueueToast');
                var span = document.getElementById('vetQueueToastMessage');
                if (!toast || !span) return;
                span.textContent = message || '';
                toast.classList.remove('hidden');
                toast.classList.add('flex');
                setTimeout(function () {
                    toast.classList.add('hidden');
                    toast.classList.remove('flex');
                }, 3200);
            }
            (function () {
                var params = new URLSearchParams(window.location.search);
                if (params.get('error') === 'busy') {
                    showVetQueueToast('You already have an examination in progress. Complete it before starting another one.');
                }
            })();
            document.querySelectorAll('a.vet-exam-action-link').forEach(function (a) {
                a.addEventListener('click', function (e) {
                    if (VET_HAS_ACTIVE_EXAMINATION && a.getAttribute('data-exam-action') === 'start') {
                        e.preventDefault();
                        showVetQueueToast('You already have an examination in progress. Complete it before starting another one.');
                    }
                });
            });
            (function () {
                var search = document.getElementById('searchQueue');
                var rows = document.querySelectorAll('.queue-row');
                if (search && rows.length) {
                    search.addEventListener('input', function () {
                        var q = (this.value || '').toLowerCase().replace(/\s+/g, ' ').trim();
                        var qDigits = q.replace(/\D/g, '');
                        rows.forEach(function (row) {
                            var name = (row.getAttribute('data-pet-name') || '').toLowerCase();
                            var owner = (row.getAttribute('data-owner-name') || '').toLowerCase();
                            var phoneRaw = row.getAttribute('data-phone') || '';
                            var phone = phoneRaw.toLowerCase();
                            var phoneDigits = phoneRaw.replace(/\D/g, '');
                            var inPhone = phone.indexOf(q) >= 0
                                || (qDigits.length > 0 && phoneDigits.indexOf(qDigits) >= 0);
                            var show = !q || name.indexOf(q) >= 0 || owner.indexOf(q) >= 0 || inPhone;
                            row.style.display = show ? '' : 'none';
                        });
                    });
                }
            })();
        </script>
        <%@ include file="/WEB-INF/includes/vet-header-right-script.jspf" %>
    </body>
</html>
