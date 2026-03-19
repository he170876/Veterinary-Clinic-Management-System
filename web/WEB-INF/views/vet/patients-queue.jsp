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
                        <div class="relative max-w-xs">
                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-lg">search</span>
                            <input class="pl-10 pr-4 py-2 bg-slate-100 dark:bg-slate-800 border-none rounded-lg text-sm w-64 focus:ring-2 focus:ring-primary/50" placeholder="Search patients..." type="text" id="searchQueue"/>
                        </div>
                        <div class="flex items-center gap-3">
                            <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                            <div class="h-8 w-[1px] bg-slate-200 dark:bg-slate-800 mx-2"></div>
                            <div class="flex items-center gap-3">
                                <div class="text-right hidden sm:block">
                                    <p class="text-sm font-semibold leading-none"><%= user.getFullName() %></p>
                                    <p class="text-xs text-slate-500"><%= roleTitle %></p>
                                </div>
                                <div class="size-10 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold overflow-hidden">
                                    <% if (user.getProfilePictureUrl() != null && !user.getProfilePictureUrl().isEmpty()) { %>
                                    <img class="w-full h-full object-cover" src="<%= ctx %><%= user.getProfilePictureUrl() %>" alt="Profile"/>
                                    <% } else { %>
                                    <%= (user.getFullName() != null && !user.getFullName().isEmpty()) ? String.valueOf(user.getFullName().charAt(0)) : "?" %>
                                    <% } %>
                                </div>
                            </div>
                        </div>
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
                    <% } %>
                    <div class="mb-6 flex justify-between items-end">
                        <div>
                            <h3 class="text-2xl font-bold text-slate-900 dark:text-slate-100">Checked-in Today</h3>
                            <p class="text-slate-500 dark:text-slate-400 text-sm mt-1">Patients currently in the waiting room. Start examination when ready.</p>
                        </div>
                        <div class="flex gap-2">
                            <span class="inline-flex items-center px-3 py-1 rounded-full bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 text-xs font-semibold">
                                <span class="size-1.5 rounded-full bg-green-500 mr-2"></span>
                                <%= appointments.size() %> Active Now
                            </span>
                        </div>
                    </div>
                    <div class="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Queue No.</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Patient ID</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Pet Name</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Species/Breed</th>
                                    <th class="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Owner Name</th>
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
                                        String petName = ap.getPet() != null ? ap.getPet().getName() : "—";
                                        String species = ap.getPet() != null && ap.getPet().getSpecies() != null ? ap.getPet().getSpecies() : "";
                                        String breed = ap.getPet() != null && ap.getPet().getBreed() != null ? ap.getPet().getBreed() : "";
                                        String speciesBreed = (species + " / " + breed).trim();
                                        if (speciesBreed.equals("/")) speciesBreed = "—";
                                        String timeStr = ap.getArrivalTime() != null ? ap.getArrivalTime().format(timeFmt) : "—";
                                        String service = ap.getService() != null ? ap.getService() : "—";
                                        String status = ap.getStatus() != null ? ap.getStatus() : "—";
                                        int petId = ap.getPet() != null ? ap.getPet().getPetId() : 0;
                                        String patientId = "P-" + petId;
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
                                <tr class="queue-row hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors <%= lockedByOtherVet ? "opacity-40" : "" %>" data-pet-name="<%= petName %>" data-owner="<%= ownerName %>" data-id="<%= patientId %>">
                                    <td class="px-6 py-4 text-sm font-semibold text-slate-900 dark:text-slate-100"><%= queueNo %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= patientId %></td>
                                    <td class="px-6 py-4 text-sm font-bold text-slate-900 dark:text-slate-100"><%= petName %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= speciesBreed %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= ownerName %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= timeStr %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= service %></td>
                                    <td class="px-6 py-4">
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium <%= statusClass %>"><%= status %></span>
                                    </td>
                                    <td class="px-6 py-4 text-right space-x-2">
                                        <% if (lockedByOtherVet) { %>
                                        <span class="inline-block bg-slate-200 dark:bg-slate-700 text-slate-500 dark:text-slate-400 px-4 py-2 rounded-lg text-sm font-bold">In Progress</span>
                                        <% } else { %>
                                        <a href="<%= ctx %>/vet/examination?id=<%= ap.getAppointmentId() %>" class="inline-block bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg text-sm font-bold transition-all shadow-sm"><%= isInExam ? "Continue" : "Start Examination" %></a>
                                        <% } %>
                                        <button type="button" class="inline-block bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 px-4 py-2 rounded-lg text-sm font-semibold transition-all shadow-sm"
                                                onclick="openAppointmentDetail(<%= ap.getAppointmentId() %>)">
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

        <!-- Appointment Detail Modal -->
        <div id="vetAppointmentDetailModal" class="fixed inset-0 bg-black/40 z-[2000] items-center justify-center px-4 hidden">
            <div class="bg-white dark:bg-slate-900 rounded-2xl shadow-2xl max-w-xl w-full max-h-[90vh] overflow-y-auto p-6">
                <div class="flex items-start justify-between mb-4">
                    <div>
                        <h3 class="text-lg font-bold text-slate-900 dark:text-slate-100" id="v-detail-pet-name">Pet name</h3>
                        <p class="text-xs text-slate-500 dark:text-slate-400 mt-1" id="v-detail-status">Status</p>
                    </div>
                    <button type="button" class="p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800" onclick="closeVetDetailModal()">
                        <span class="material-symbols-outlined">close</span>
                    </button>
                </div>
                <div class="space-y-4 text-sm">
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <p class="text-xs text-slate-400">Owner</p>
                            <p class="font-semibold text-slate-800 dark:text-slate-100" id="v-detail-owner-name"></p>
                        </div>
                        <div>
                            <p class="text-xs text-slate-400">Phone</p>
                            <p class="font-semibold text-slate-800 dark:text-slate-100" id="v-detail-owner-phone"></p>
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <p class="text-xs text-slate-400">Date</p>
                            <p class="font-semibold text-slate-800 dark:text-slate-100" id="v-detail-date"></p>
                        </div>
                        <div>
                            <p class="text-xs text-slate-400">Service</p>
                            <p class="font-semibold text-slate-800 dark:text-slate-100" id="v-detail-service"></p>
                        </div>
                    </div>
                    <div>
                        <p class="text-xs text-slate-400">Address</p>
                        <p class="font-semibold text-slate-800 dark:text-slate-100" id="v-detail-owner-address"></p>
                    </div>
                    <div>
                        <p class="text-xs text-slate-400">Notes</p>
                        <p class="font-semibold text-slate-800 dark:text-slate-100" id="v-detail-notes"></p>
                    </div>
                </div>
                <div class="mt-6 flex justify-end">
                    <button type="button" class="px-4 py-2 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90" onclick="closeVetDetailModal()">Close</button>
                </div>
            </div>
        </div>

        <script>
            (function () {
                var search = document.getElementById('searchQueue');
                var rows = document.querySelectorAll('.queue-row');
                if (search && rows.length) {
                    search.addEventListener('input', function () {
                        var q = (this.value || '').toLowerCase();
                        rows.forEach(function (row) {
                            var name = (row.getAttribute('data-pet-name') || '').toLowerCase();
                            var owner = (row.getAttribute('data-owner') || '').toLowerCase();
                            var id = (row.getAttribute('data-id') || '').toLowerCase();
                            var show = !q || name.indexOf(q) >= 0 || owner.indexOf(q) >= 0 || id.indexOf(q) >= 0;
                            row.style.display = show ? '' : 'none';
                        });
                    });
                }
            })();

            function openAppointmentDetail(appointmentId) {
                fetch('<%= ctx %>/Receptionist/GetAppointmentDetail?appointmentId=' + appointmentId)
                        .then(function (r) {
                            return r.json();
                        })
                        .then(function (data) {
                            if (!data.success) {
                                alert(data.message || 'Could not load appointment detail.');
                                return;
                            }
                            var d = data.data || {};
                            var pet = d.pet || {};
                            var customer = d.customer || {};
                            var user = customer.user || {};

                            document.getElementById('v-detail-pet-name').textContent = pet.name || 'N/A';
                            document.getElementById('v-detail-status').textContent = d.status || 'N/A';
                            document.getElementById('v-detail-owner-name').textContent = user.fullName || 'N/A';
                            document.getElementById('v-detail-owner-phone').textContent = user.phone || 'N/A';
                            document.getElementById('v-detail-owner-address').textContent = user.address || 'N/A';
                            document.getElementById('v-detail-date').textContent = d.formattedDateWithSlot || 'N/A';
                            document.getElementById('v-detail-service').textContent = d.service || 'N/A';
                            document.getElementById('v-detail-notes').textContent = d.notes || 'N/A';

                            document.getElementById('vetAppointmentDetailModal').classList.remove('hidden');
                            document.getElementById('vetAppointmentDetailModal').classList.add('flex');
                        })
                        .catch(function () {
                            alert('An error occurred while loading details.');
                        });
            }

            function closeVetDetailModal() {
                var modal = document.getElementById('vetAppointmentDetailModal');
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            }
        </script>
    </body>
</html>
