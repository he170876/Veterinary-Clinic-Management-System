<%@ page language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Notification" %>
<%@ page import="model.User" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%
    // Use a unique variable name to avoid clashing with parent JSPs
    String notifCtx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    if (notifications == null) notifications = java.util.Collections.emptyList();
    java.time.format.DateTimeFormatter fmt =
            (java.time.format.DateTimeFormatter) request.getAttribute("notificationTimeFmt");
    if (fmt == null) {
        fmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, HH:mm");
    }
    boolean hasUnread = false;
    for (Notification n : notifications) {
        if (!n.isRead()) {
            hasUnread = true;
            break;
        }
    }

    String notifCenterHref = notifCtx + "/notifications";
    String notifCenterLabel = "View notification center";
    Object currentUserObj = session != null ? session.getAttribute("currentUser") : null;
    if (currentUserObj instanceof User) {
        User notifUser = (User) currentUserObj;
        String notifRoleName = notifUser.getRole() != null ? notifUser.getRole().getRoleName() : null;
        String notifRoleNormalized = notifRoleName != null
                ? notifRoleName.trim().toLowerCase().replace(" ", "").replace("_", "").replace("-", "")
                : "";
        if ("receptionist".equals(notifRoleNormalized) || "frontdesk".equals(notifRoleNormalized)) {
            notifCenterHref = notifCtx + "/Receptionist/ManageAppointmentRequests";
            notifCenterLabel = "View request center";
        }
    }
%>
<div class="relative inline-block text-left" id="notif-root" data-base-url="<%= notifCtx %>">
    <button type="button"
            class="relative p-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors"
            id="notif-toggle">
        <span class="material-symbols-outlined">notifications</span>
        <% if (hasUnread) { %>
        <span class="absolute top-2 right-2 size-2 bg-primary rounded-full border-2 border-white dark:border-slate-900"></span>
        <% } %>
    </button>
    <div id="notif-menu"
         class="absolute right-0 mt-2 w-80 origin-top-right rounded-xl bg-white dark:bg-slate-900 shadow-lg border border-slate-200 dark:border-slate-800 z-50"
         style="display:none;">
        <div class="px-4 py-3 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
            <p class="text-sm font-semibold text-slate-800 dark:text-slate-100">Notifications</p>
            <span id="notif-count" class="text-xs text-slate-400"><%= notifications.size() %> items</span>
        </div>
        <div class="max-h-80 overflow-y-auto custom-scrollbar">
            <div id="notif-items">
                <% if (notifications.isEmpty()) { %>
                <div class="px-4 py-6 text-center text-sm text-slate-500 dark:text-slate-400">
                    No notifications yet.
                </div>
                <% } else { %>
                <% for (Notification n : notifications) {
                    String title = n.getTitle() != null ? n.getTitle() : "Notification";
                    String message = n.getMessage() != null ? n.getMessage() : "";
                    String time = n.getCreatedAt() != null ? n.getCreatedAt().format(fmt) : "";
                    int appointmentId = n.getNotificationId() < 0 ? -n.getNotificationId() : -1;
                    if (appointmentId <= 0) {
                        java.util.regex.Matcher m = java.util.regex.Pattern.compile("Appointment #(\\d+)|appointmentId=(\\d+)", java.util.regex.Pattern.CASE_INSENSITIVE).matcher(message);
                        if (m.find()) {
                            try {
                                String idGroup = m.group(1) != null ? m.group(1) : m.group(2);
                                appointmentId = Integer.parseInt(idGroup);
                            } catch (Exception ignore) {
                                appointmentId = -1;
                            }
                        }
                    }

                    String titleLower = title != null ? title.toLowerCase() : "";
                    boolean isRequestNotification = n.getNotificationId() < 0
                            || (titleLower.contains("request")
                            && (titleLower.contains("reschedule") || titleLower.contains("doctor change")));

                    String reqType = "All";
                    if (titleLower.contains("reschedule")) {
                        reqType = "Reschedule";
                    } else if (titleLower.contains("doctor")) {
                        reqType = "DoctorChange";
                    }

                    String itemHref = null;
                    if (isRequestNotification && appointmentId > 0) {
                        itemHref = notifCtx + "/Receptionist/ManageAppointmentRequests?requestType="
                                + URLEncoder.encode(reqType, StandardCharsets.UTF_8)
                                + "&appointmentId=" + appointmentId;
                    }
                %>
                <div class="px-4 py-3 border-b border-slate-100 dark:border-slate-800 last:border-b-0 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                    <% if (itemHref != null) { %>
                    <a href="<%= itemHref %>" class="block">
                    <% } %>
                    <div class="flex items-start gap-3">
                        <div class="mt-0.5">
                            <span class="material-symbols-outlined text-sm text-primary">notifications</span>
                        </div>
                        <div class="flex-1">
                            <p class="text-xs font-semibold text-slate-800 dark:text-slate-100"><%= title %></p>
                            <p class="text-xs text-slate-500 dark:text-slate-400 mt-1 break-words"><%= message %></p>
                            <% if (!time.isEmpty()) { %>
                            <p class="text-[10px] text-slate-400 mt-1"><%= time %></p>
                            <% } %>
                        </div>
                    </div>
                    <% if (itemHref != null) { %>
                    </a>
                    <% } %>
                </div>
                <% } %>
                <% } %>
            </div>
        </div>
        <div class="px-4 py-2 border-t border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/60 text-right">
            <a href="<%= notifCenterHref %>"
               class="text-[11px] font-semibold text-primary hover:underline"><%= notifCenterLabel %></a>
        </div>
    </div>
</div>
<script>
    (function () {
        const root = document.getElementById('notif-root');
        if (!root) return;
        const btn = document.getElementById('notif-toggle');
        const menu = document.getElementById('notif-menu');
        const itemsEl = document.getElementById('notif-items');
        const countEl = document.getElementById('notif-count');
        if (!btn || !menu || !itemsEl || !countEl) return;
        function isOpen() {
            return menu.style.display !== 'none';
        }
        function open() {
            menu.style.display = 'block';
        }
        function close() {
            menu.style.display = 'none';
        }
        btn.addEventListener('click', function (e) {
            e.stopPropagation();
            if (isOpen()) close(); else open();
        });
        document.addEventListener('click', function () {
            if (isOpen()) close();
        });

        function escapeHtml(str) {
            return str.replace(/[&<>"']/g, function (c) {
                switch (c) {
                    case '&': return '&amp;';
                    case '<': return '&lt;';
                    case '>': return '&gt;';
                    case '"': return '&quot;';
                    case "'": return '&#39;';
                    default: return c;
                }
            });
        }

        function renderNotifications(data) {
            if (!Array.isArray(data)) return;
            if (data.length === 0) {
                itemsEl.innerHTML = '<div class="px-4 py-6 text-center text-sm text-slate-500 dark:text-slate-400">No notifications yet.</div>';
            } else {
                let html = '';
                data.forEach(function (n) {
                    const title = escapeHtml(n.title || 'Notification');
                    const message = escapeHtml(n.message || '');
                    const time = escapeHtml(n.time || '');
                    const rawTitle = (n.title || '').toLowerCase();
                    const rawMessage = n.message || '';
                    const isRequestNotification = (typeof n.id === 'number' && n.id < 0)
                        || (rawTitle.indexOf('request') !== -1
                        && (rawTitle.indexOf('reschedule') !== -1 || rawTitle.indexOf('doctor change') !== -1));
                    let requestType = 'All';
                    if (rawTitle.indexOf('reschedule') !== -1) requestType = 'Reschedule';
                    else if (rawTitle.indexOf('doctor') !== -1) requestType = 'DoctorChange';

                    let appointmentId = null;
                    if (typeof n.id === 'number' && n.id < 0) {
                        appointmentId = String(Math.abs(n.id));
                    }
                    if (!appointmentId) {
                        const idMatch = rawMessage.match(/Appointment #(\d+)|appointmentId=(\d+)/i);
                        if (idMatch) appointmentId = idMatch[1] || idMatch[2];
                    }

                    let itemHref = null;
                    if (isRequestNotification && appointmentId) {
                        itemHref = base + '/Receptionist/ManageAppointmentRequests?requestType=' + encodeURIComponent(requestType) + '&appointmentId=' + encodeURIComponent(appointmentId);
                    }

                    html += '<div class="px-4 py-3 border-b border-slate-100 dark:border-slate-800 last:border-b-0 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">';
                    if (itemHref) html += '<a href="' + itemHref + '" class="block">';
                    html += '<div class="flex items-start gap-3">';
                    html += '<div class="mt-0.5"><span class="material-symbols-outlined text-sm text-primary">notifications</span></div>';
                    html += '<div class="flex-1">';
                    html += '<p class="text-xs font-semibold text-slate-800 dark:text-slate-100">' + title + '</p>';
                    html += '<p class="text-xs text-slate-500 dark:text-slate-400 mt-1 break-words">' + message + '</p>';
                    if (time) {
                        html += '<p class="text-[10px] text-slate-400 mt-1">' + time + '</p>';
                    }
                    html += '</div></div>';
                    if (itemHref) html += '</a>';
                    html += '</div>';
                });
                itemsEl.innerHTML = html;
            }
            countEl.textContent = data.length + ' items';
        }

        const base = root.getAttribute('data-base-url') || '';
        const pollUrl = base + '/notifications/poll';

        async function poll() {
            try {
                const res = await fetch(pollUrl, { headers: { 'Accept': 'application/json' } });
                if (!res.ok) return;
                const data = await res.json();
                renderNotifications(data);
            } catch (e) {
                // ignore
            }
        }

        // Initial poll and then every 10 seconds
        poll();
        setInterval(poll, 10000);
    })();
</script>

