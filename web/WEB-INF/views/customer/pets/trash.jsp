<%@ page import="java.util.List,java.time.LocalDate,java.time.Period,model.Pet,model.Customer,model.User" %>
<%@ page import="java.net.URLEncoder" %>
<%!
    private String resolvePhotoUrl(jakarta.servlet.http.HttpServletRequest request, String rawPhotoUrl, String fallbackUrl) {
        if (rawPhotoUrl == null || rawPhotoUrl.trim().isEmpty()) {
            return fallbackUrl;
        }

        String value = rawPhotoUrl.trim().replace("\\", "/");
        if (value.startsWith("http://") || value.startsWith("https://")) {
            return value;
        }

        if (value.matches("^[A-Za-z]:/.*")) {
            int lastSlash = value.lastIndexOf('/');
            String fileName = lastSlash >= 0 ? value.substring(lastSlash + 1) : value;
            value = "uploads/pets/" + fileName;
        }

        while (value.startsWith("/")) {
            value = value.substring(1);
        }
        return request.getContextPath() + "/" + value;
    }
%>
<!DOCTYPE html>
<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Trash - Deleted Pets</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700;900&amp;display=swap" rel="stylesheet"/>
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
                        "display": ["Public Sans", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"},
                },
            },
        }
    </script>
<style type="text/tailwindcss">
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-[#f8f7f5]">
<%
    List<Pet> deletedPets = (List<Pet>) request.getAttribute("deletedPets");
    if (deletedPets == null) {
        deletedPets = new java.util.ArrayList<>();
    }
    User currentUser = (User) session.getAttribute("currentUser");
    String currentRole = (currentUser != null && currentUser.getRole() != null) ? currentUser.getRole().getRoleName() : "";
    boolean isCustomerUser = "Customer".equalsIgnoreCase(currentRole);
    String returnUrl = request.getContextPath() + "/pets";
    String encodedReturnUrl = "";
    try {
        encodedReturnUrl = URLEncoder.encode(returnUrl, "UTF-8");
    } catch (Exception ex) {
        encodedReturnUrl = "";
    }
    request.setAttribute("customerCurrentPage", "pets");
%>
<div class="flex h-screen overflow-hidden">
<jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
<main class="flex-1 flex flex-col overflow-y-auto">
<header class="flex items-center justify-between bg-white dark:bg-[#2d2116] border-b border-[#f5f2f0] dark:border-[#3d2f23] px-8 py-4 sticky top-0 z-10">
<div class="flex items-center gap-4 flex-1">
<h2 class="text-xl font-bold tracking-tight">Deleted Pets (Trash)</h2>
</div>
<% if (isCustomerUser) { %>
<a href="<%= request.getContextPath() %>/customer/dashboard" class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 font-medium flex items-center gap-2 text-sm">
    <span class="material-symbols-outlined text-lg">arrow_back</span>
    Quay lại trang đầu
</a>
<% } %>
</header>
<div class="p-8 max-w-7xl mx-auto w-full">
<div class="bg-orange-50 border-l-4 border-orange-500 p-4 mb-6">
<div class="flex items-start gap-3">
<span class="material-symbols-outlined text-orange-500">info</span>
<div>
<p class="font-medium text-orange-800">Soft Delete Active</p>
<p class="text-sm text-orange-700">Deleted pets are stored here and can be restored or permanently deleted.</p>
</div>
</div>
</div>

<div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] overflow-hidden">
<div class="overflow-x-auto">
<table class="w-full text-left border-collapse">
<thead>
<tr class="bg-[#fcfbf9] dark:bg-[#34281d] border-b border-[#f5f2f0] dark:border-[#3d2f23]">
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Pet Info</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Species</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a]">Deleted Date</th>
<th class="px-6 py-4 text-xs font-bold uppercase tracking-wider text-[#8d755e] dark:text-[#a68e7a] text-right">Actions</th>
</tr>
</thead>
<tbody class="divide-y divide-[#f5f2f0] dark:divide-[#3d2f23]">
<%
    if (deletedPets.isEmpty()) {
%>
<tr>
    <td class="px-6 py-12 text-center text-[#8d755e]" colspan="4">
        <div class="flex flex-col items-center gap-3">
            <span class="material-symbols-outlined text-6xl text-gray-300">delete_outline</span>
            <p class="font-medium">No deleted pets</p>
            <p class="text-sm">Trash is empty</p>
        </div>
    </td>
</tr>
<%
    } else {
        for (Pet pet : deletedPets) {
            String petName = pet.getName() != null ? pet.getName() : "(No name)";
            String species = pet.getSpecies() != null ? pet.getSpecies() : "N/A";
            String fallbackPhotoUrl = "https://via.placeholder.com/150/cccccc/666666?text=" + (species != null ? species.substring(0,1) : "P");
            String photoUrl = resolvePhotoUrl(request, pet.getPhotoUrl(), fallbackPhotoUrl);
%>
<tr class="hover:bg-[#fcfbf9] dark:hover:bg-[#34281d] transition-colors">
    <td class="px-6 py-4">
        <div class="flex items-center gap-4">
            <div class="size-12 rounded-lg bg-cover bg-center border border-[#f5f2f0] dark:border-[#3d2f23] opacity-60" style='background-image: url("<%= photoUrl %>");'></div>
            <div>
                <p class="font-bold text-gray-500"><%= petName %></p>
                <p class="text-xs text-[#8d755e]">ID: <%= pet.getPetId() %></p>
            </div>
        </div>
    </td>
    <td class="px-6 py-4 text-sm text-gray-500"><%= species %></td>
    <td class="px-6 py-4 text-sm text-gray-500">Recently</td>
    <td class="px-6 py-4">
        <div class="flex items-center justify-end gap-2">
            <a class="px-3 py-1.5 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm font-medium flex items-center gap-1" href="<%= request.getContextPath() %>/pets?action=restore&id=<%= pet.getPetId() %>&returnUrl=<%= encodedReturnUrl %>" title="Restore">
                <span class="material-symbols-outlined text-sm">restore</span>
                Restore
            </a>
<!--            <button type="button" class="px-3 py-1.5 bg-red-600 text-white rounded-lg hover:bg-red-700 text-sm font-medium flex items-center gap-1 permanent-delete-btn" data-pet-id="<%= pet.getPetId() %>" data-pet-name="<%= petName %>" title="Delete Forever">
                <span class="material-symbols-outlined text-sm">delete_forever</span>
                Delete Forever
            </button>-->
        </div>
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
</div>
</main>
</div>

<!-- Permanent Delete Confirmation Modal -->
<div id="permanentDeleteModal" class="hidden fixed inset-0 bg-black/50 flex items-center justify-center z-50">
    <div class="bg-white dark:bg-[#2d2116] rounded-xl shadow-2xl max-w-md w-full mx-4 overflow-hidden">
        <div class="p-6">
            <div class="flex items-center gap-4 mb-4">
                <div class="size-12 rounded-full bg-red-100 dark:bg-red-900/20 flex items-center justify-center">
                    <span class="material-symbols-outlined text-red-600 text-2xl">delete_forever</span>
                </div>
                <div>
                    <h3 class="text-xl font-bold text-red-600">Permanent Delete</h3>
                    <p class="text-sm text-[#8d755e]">This action cannot be undone!</p>
                </div>
            </div>
            <p class="text-gray-700 dark:text-gray-300 mb-6">
                Are you sure you want to permanently delete <strong id="permanentDeletePetName"></strong>?<br>
                <span class="text-sm text-red-600 font-medium">⚠️ This will remove ALL data and uploaded photos forever!</span>
            </p>
            <div class="flex gap-3">
                <button onclick="closePermanentDeleteModal()" class="flex-1 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-100 font-medium">
                    Cancel
                </button>
                <button onclick="executePermanentDelete()" class="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 font-bold">
                    Delete Forever
                </button>
            </div>
        </div>
    </div>
</div>

<script>
let permanentDeletePetId = null;

// Event delegation for permanent delete buttons
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.permanent-delete-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var petId = this.getAttribute('data-pet-id');
            var petName = this.getAttribute('data-pet-name');
            confirmPermanentDelete(petId, petName);
        });
    });
});

function confirmPermanentDelete(petId, petName) {
    permanentDeletePetId = petId;
    document.getElementById('permanentDeletePetName').textContent = petName;
    document.getElementById('permanentDeleteModal').classList.remove('hidden');
}

function closePermanentDeleteModal() {
    document.getElementById('permanentDeleteModal').classList.add('hidden');
    permanentDeletePetId = null;
}

function executePermanentDelete() {
    if (permanentDeletePetId) {
        window.location.href = '<%= request.getContextPath() %>/pets?action=hardDelete&id=' + permanentDeletePetId + '&returnUrl=<%= encodedReturnUrl %>';
    }
}
</script>

</body></html>
