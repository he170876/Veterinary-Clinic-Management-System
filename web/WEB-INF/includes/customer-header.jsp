<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    String headerTitle = (String) request.getAttribute("customerHeaderTitle");
    String headerSubtitle = (String) request.getAttribute("customerHeaderSubtitle");
    String headerActionUrl = (String) request.getAttribute("customerHeaderActionUrl");
    String headerActionLabel = (String) request.getAttribute("customerHeaderActionLabel");
    String headerActionIcon = (String) request.getAttribute("customerHeaderActionIcon");
    String headerDisplayName = (String) request.getAttribute("customerHeaderDisplayName");
    String headerRoleText = (String) request.getAttribute("customerHeaderRoleText");
    String headerAvatarInitial = (String) request.getAttribute("customerHeaderAvatarInitial");

    if (headerActionIcon == null || headerActionIcon.trim().isEmpty()) {
        headerActionIcon = "arrow_back";
    }

    User headerUser = (User) request.getAttribute("user");
    if (headerUser == null && session != null) {
        headerUser = (User) session.getAttribute("currentUser");
    }

    if (headerDisplayName == null || headerDisplayName.trim().isEmpty()) {
        if (headerUser != null && headerUser.getFullName() != null && !headerUser.getFullName().trim().isEmpty()) {
            headerDisplayName = headerUser.getFullName();
        } else if (headerUser != null && headerUser.getEmail() != null) {
            headerDisplayName = headerUser.getEmail();
        } else {
            headerDisplayName = "Customer";
        }
    }

    if (headerRoleText == null || headerRoleText.trim().isEmpty()) {
        headerRoleText = "Pet Owner";
    }

    if (headerAvatarInitial == null || headerAvatarInitial.trim().isEmpty()) {
        headerAvatarInitial = headerDisplayName.length() > 0
                ? headerDisplayName.substring(0, 1).toUpperCase()
                : "?";
    }
%>
<header class="sticky top-0 z-10 flex items-center justify-between px-8 py-4 border-b border-slate-200 dark:border-slate-800 bg-white/95 dark:bg-background-dark/85 backdrop-blur-sm">
    <div class="flex items-center gap-4">
        <div>
            <h2 class="text-xl font-bold tracking-tight text-slate-900 dark:text-slate-100"><%= headerTitle != null ? headerTitle : "" %></h2>
            <% if (headerSubtitle != null && !headerSubtitle.trim().isEmpty()) { %>
            <p class="text-sm text-slate-500"><%= headerSubtitle %></p>
            <% } %>
        </div>
    </div>

    <div class="flex items-center gap-4">
        <% if (headerActionUrl != null && !headerActionUrl.trim().isEmpty() && headerActionLabel != null && !headerActionLabel.trim().isEmpty()) { %>
        <a href="<%= headerActionUrl %>" class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 font-medium flex items-center gap-2 text-sm">
            <span class="material-symbols-outlined text-lg"><%= headerActionIcon %></span>
            <%= headerActionLabel %>
        </a>
        <% } %>

        <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
        <div class="h-8 w-px bg-slate-200 dark:bg-slate-700"></div>

        <div class="text-right hidden sm:block">
            <p class="text-sm font-bold text-slate-900 dark:text-slate-100"><%= headerDisplayName %></p>
            <p class="text-xs text-slate-500"><%= headerRoleText %></p>
        </div>

        <div class="bg-primary/10 rounded-full size-10 border-2 border-primary/20 flex items-center justify-center text-primary font-bold text-lg">
            <%= headerAvatarInitial %>
        </div>
    </div>
</header>
