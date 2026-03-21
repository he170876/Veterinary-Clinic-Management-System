<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pet" %>
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
<%
    Pet pet = (Pet) request.getAttribute("pet");
    String photoUrl = resolvePhotoUrl(request,
        pet != null ? pet.getPhotoUrl() : null,
        "https://via.placeholder.com/300/cccccc/666666?text=P");
    model.User currentUser = (model.User) session.getAttribute("currentUser");
    String currentRole = (currentUser != null && currentUser.getRole() != null) ? currentUser.getRole().getRoleName() : "";
    boolean isCustomerUser = "Customer".equalsIgnoreCase(currentRole);
    request.setAttribute("customerCurrentPage", "pets");
    request.setAttribute("customerHeaderTitle", "Edit Pet Profile");
    request.setAttribute("customerHeaderSubtitle", "Update your companion's information.");
    request.setAttribute("customerHeaderBackUrl", isCustomerUser ? request.getContextPath() + "/customer/dashboard" : null);
    request.setAttribute("customerHeaderDisplayName", currentUser != null && currentUser.getFullName() != null ? currentUser.getFullName() : "Customer");
    request.setAttribute("customerHeaderRoleText", "Pet Owner");
%>
<!DOCTYPE html>
<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Edit Pet Profile - Anipat</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700;900&amp;display=swap" rel="stylesheet"/>
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
<style>
        body {
            font-family: 'Public Sans', sans-serif;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-[#f5f2f0]">
<div class="flex h-screen overflow-hidden">
<jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
<main class="flex-1 flex flex-col overflow-y-auto">
<jsp:include page="/WEB-INF/includes/customer-header.jsp"/>
<div class="max-w-4xl mx-auto w-full px-8 py-8">
<nav class="flex items-center gap-2 mb-6">
<a class="text-gray-500 hover:text-primary text-sm font-medium transition-colors" href="#">My Pets</a>
<span class="text-gray-400 material-symbols-outlined text-base">chevron_right</span>
<span class="text-primary text-sm font-bold">Edit Pet Profile</span>
</nav>
<div class="mb-10">
<h2 class="text-[#181410] dark:text-white text-4xl font-black leading-tight tracking-[-0.033em]">Edit Pet Profile</h2>
<p class="text-gray-500 dark:text-gray-400 text-lg mt-1">Update your companion's information</p>
</div>
<div class="bg-white dark:bg-background-dark rounded-xl shadow-sm border border-gray-200 dark:border-gray-800 overflow-hidden">
<form class="p-8" method="post" action="<%= request.getContextPath() %>/pets?action=update" enctype="multipart/form-data">
<input type="hidden" name="petId" value="<%= pet != null ? pet.getPetId() : "" %>"/>
<div class="flex flex-col items-center justify-center mb-10 pb-10 border-b border-gray-100 dark:border-gray-800">
<div class="relative group">
<div id="photoPreview" class="size-32 rounded-full border-4 border-solid border-primary/20 flex items-center justify-center bg-gray-50 dark:bg-gray-900 overflow-hidden shadow-inner bg-cover bg-center" style="background-image: url('<%= photoUrl %>');"></div>
<label for="photoInput" class="absolute bottom-0 right-0 size-10 rounded-full bg-primary text-white flex items-center justify-center border-4 border-white dark:border-background-dark shadow-lg hover:scale-105 transition-transform cursor-pointer">
<span class="material-symbols-outlined text-xl">edit</span>
</label>
</div>
<div class="mt-4 text-center">
<h3 class="text-lg font-bold">Pet Photo</h3>
<p class="text-sm text-gray-500 mb-4">Click to update your pet's profile picture</p>
q<input type="file" id="photoInput" name="photo" accept="image/*" class="hidden" onchange="previewPhoto(this)"/>
<label for="photoInput" class="inline-flex items-center gap-2 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 text-gray-900 dark:text-white px-6 py-2 rounded-lg font-bold text-sm transition-colors cursor-pointer">
<span class="material-symbols-outlined text-lg">upload</span>
                                Upload New
                            </label>
</div>
</div>
<script>
function previewPhoto(source) {
    const input = source && source.files ? source : document.getElementById('photoInput');
    if (!input) {
        return;
    }

    const file = input.files && input.files.length > 0 ? input.files[0] : null;
    if (!file) {
        return;
    }

    if (!file.type || !file.type.startsWith('image/')) {
        alert('Please choose a valid image file.');
        input.value = '';
        return;
    }

    const preview = document.getElementById('photoPreview');
    if (!preview) {
        return;
    }

    const reader = new FileReader();
    reader.onload = function(e) {
        preview.style.backgroundImage = "url('" + e.target.result + "')";
    };
    reader.readAsDataURL(file);
}

function bindPhotoPreview() {
    const input = document.getElementById('photoInput');
    if (!input || input.dataset.previewBound === 'true') {
        return;
    }

    input.dataset.previewBound = 'true';

    input.addEventListener('click', function() {
        input.value = '';
    });

    input.addEventListener('change', function() {
        previewPhoto(input);
    });
}
</script>
<div class="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">
                                Pet Name <span class="text-primary">*</span>
</label>
<input name="name" class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" required="" type="text" value="<%= pet != null ? pet.getName() : "" %>"/>
</div>
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">
                                Species <span class="text-primary">*</span>
</label>
<input name="species" class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" required="" type="text" value="<%= pet != null ? pet.getSpecies() : "" %>"/>
</div>
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">Breed</label>
<input name="breed" class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" type="text" value="<%= pet != null && pet.getBreed() != null ? pet.getBreed() : "" %>"/>
</div>
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">Gender</label>
<div class="flex items-center gap-6 mt-1">
<label class="flex items-center gap-2 cursor-pointer group">
<input <%= pet != null && "Male".equals(pet.getGender()) ? "checked" : "" %> value="Male" class="size-5 text-primary focus:ring-primary border-gray-300 dark:border-gray-600 dark:bg-gray-800" name="gender" type="radio"/>
<span class="text-sm font-medium text-gray-600 dark:text-gray-400 group-hover:text-primary transition-colors">Male</span>
</label>
<label class="flex items-center gap-2 cursor-pointer group">
<input <%= pet != null && "Female".equals(pet.getGender()) ? "checked" : "" %> value="Female" class="size-5 text-primary focus:ring-primary border-gray-300 dark:border-gray-600 dark:bg-gray-800" name="gender" type="radio"/>
<span class="text-sm font-medium text-gray-600 dark:text-gray-400 group-hover:text-primary transition-colors">Female</span>
</label>
</div>
</div>
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">
                                Date of Birth
</label>
<input id="birthDate" name="birthDate" class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" type="date" value="<%= pet != null && pet.getBirthDate() != null ? pet.getBirthDate() : "" %>"/>
</div>
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">Weight (kg)</label>
<input name="weight" class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" step="0.1" type="number" min="0" onchange="validateWeight(this)" value="<%= pet != null && pet.getWeight() != null ? pet.getWeight() : "" %>"/>
<span id="weightError" class="text-primary text-xs mt-1" style="display:none;">Weight cannot be negative</span>
</div>
</div>
<div class="mt-12 flex flex-col-reverse sm:flex-row items-center justify-end gap-4 border-t border-gray-100 dark:border-gray-800 pt-8">
<button class="w-full sm:w-auto px-8 py-3 rounded-lg font-bold text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" type="button">
                            Cancel
                        </button>
<button class="w-full sm:w-auto px-10 py-3 rounded-lg bg-primary hover:bg-primary/90 text-white font-bold shadow-lg shadow-primary/20 transition-all flex items-center justify-center gap-2" type="submit">
<span class="material-symbols-outlined text-xl">save</span>
                            Save Changes
                        </button>
</div>
</form>
<script>
// Set max date to today for birth date validation
document.addEventListener('DOMContentLoaded', function() {
    bindPhotoPreview();

    const birthDateInput = document.getElementById('birthDate');
    if (birthDateInput) {
        const today = new Date().toISOString().split('T')[0];
        birthDateInput.max = today;
        
        // Validate on change
        birthDateInput.addEventListener('change', function() {
            const selectedDate = new Date(this.value);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            if (selectedDate > today) {
                alert('Ngày sinh không thể trong tương lai');
                this.value = '';
            }
        });
    }
});

// Validate weight cannot be negative
function validateWeight(input) {
    const weightError = document.getElementById('weightError');
    if (input.value !== '' && parseFloat(input.value) < 0) {
        weightError.style.display = 'block';
        input.value = '';
    } else {
        weightError.style.display = 'none';
    }
}
</script>
</div>
<div class="mt-6 text-center">
<p class="text-xs text-gray-500">
                    Last updated: October 24, 2023. Keeping information current ensures the best care for Buddy.
                </p>
</div>
</div>
</main>
</div>

</body></html>