<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Notification" %>
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
                %>
                <div class="px-4 py-3 border-b border-slate-100 dark:border-slate-800 last:border-b-0
                            hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
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
                </div>
                <% } %>
                <% } %>
            </div>
        </div>
        <div class="px-4 py-2 border-t border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/60 text-right">
            <a href="<%= notifCtx %>/notifications"
               class="text-[11px] font-semibold text-primary hover:underline">View notification center</a>
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
                    html += '<div class="px-4 py-3 border-b border-slate-100 dark:border-slate-800 last:border-b-0 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">';
                    html += '<div class="flex items-start gap-3">';
                    html += '<div class="mt-0.5"><span class="material-symbols-outlined text-sm text-primary">notifications</span></div>';
                    html += '<div class="flex-1">';
                    html += '<p class="text-xs font-semibold text-slate-800 dark:text-slate-100">' + title + '</p>';
                    html += '<p class="text-xs text-slate-500 dark:text-slate-400 mt-1 break-words">' + message + '</p>';
                    if (time) {
                        html += '<p class="text-[10px] text-slate-400 mt-1">' + time + '</p>';
                    }
                    html += '</div></div></div>';
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

