<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String currentRole = (currentUser != null && currentUser.getRole() != null)
            ? currentUser.getRole().getRoleName() : "";
    boolean isCustomerUser = "Customer".equalsIgnoreCase(currentRole);

    Customer customer = (Customer) request.getAttribute("customer");
    Integer customerId = customer != null ? customer.getCustomerId() : null;
    request.setAttribute("customerCurrentPage", "pets");
%>
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Add New Pet - Anipat</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
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
<!-- Main Content Area -->
<main class="flex-1 flex flex-col overflow-y-auto">
<!-- Header -->
<header class="flex items-center justify-between border-b border-gray-200 dark:border-gray-800 bg-white dark:bg-background-dark px-8 py-4 sticky top-0 z-10">
<div class="flex-1 max-w-xl">
<div class="relative">
<span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xl">search</span>
<input class="w-full pl-10 pr-4 py-2 rounded-lg border-none bg-gray-100 dark:bg-gray-800 text-sm focus:ring-2 focus:ring-primary/50 transition-all" placeholder="Search pets, records..." type="text"/>
</div>
</div>
<div class="flex items-center gap-4">
<% if (isCustomerUser) { %>
<a class="px-4 py-2 rounded-lg bg-primary text-white text-sm font-bold hover:bg-primary/90 transition-colors" href="<%= request.getContextPath() %>/customer/dashboard">
Quay lại trang đầu
</a>
<% } %>
<%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
<%@ include file="/WEB-INF/includes/customer-profile-dropdown.jspf" %>
<button class="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300">
<span class="material-symbols-outlined">help_outline</span>
</button>
</div>
</header>
<!-- Page Body -->
<div class="max-w-4xl mx-auto w-full px-8 py-8">
<!-- Breadcrumbs -->
<nav class="flex items-center gap-2 mb-6">
<a class="text-gray-500 hover:text-primary text-sm font-medium transition-colors" href="<%= request.getContextPath() %>/pets">My Pets</a>
<span class="text-gray-400 material-symbols-outlined text-base">chevron_right</span>
<span class="text-primary text-sm font-bold">Add New Pet</span>
</nav>
<!-- Page Heading -->
<div class="mb-10">
<h2 class="text-[#181410] dark:text-white text-4xl font-black leading-tight tracking-[-0.033em]">Add New Pet</h2>
<p class="text-gray-500 dark:text-gray-400 text-lg mt-1">Tell us about your new companion</p>
</div>
<!-- Form Card -->
<div class="bg-white dark:bg-background-dark rounded-xl shadow-sm border border-gray-200 dark:border-gray-800 overflow-hidden">
<form class="p-8" method="post" action="<%= request.getContextPath() %>/pets?action=create" enctype="multipart/form-data">
<!-- Photo Upload Section -->
<div class="flex flex-col items-center justify-center mb-10 pb-10 border-b border-gray-100 dark:border-gray-800">
<div class="relative group">
<div id="photoPreview" class="size-32 rounded-full border-4 border-dashed border-gray-200 dark:border-gray-700 flex items-center justify-center bg-gray-50 dark:bg-gray-900 overflow-hidden bg-cover bg-center">
<span id="cameraIcon" class="material-symbols-outlined text-5xl text-gray-300 dark:text-gray-600">photo_camera</span>
</div>
</div>
<div class="mt-4 text-center">
<h3 class="text-lg font-bold">Pet Photo</h3>
<p class="text-sm text-gray-500 mb-4">Upload a clear photo of your pet (JPG, PNG, max 10MB)</p>
<input type="file" id="photoInput" name="photo" accept="image/*" class="hidden" onchange="previewPhoto(this)"/>
<label for="photoInput" class="inline-flex items-center gap-2 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 text-gray-900 dark:text-white px-6 py-2 rounded-lg font-bold text-sm transition-colors cursor-pointer">
<span class="material-symbols-outlined text-lg">upload</span>
                                    Upload Photo
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
    const cameraIcon = document.getElementById('cameraIcon');
    if (!preview) {
        return;
    }

    const reader = new FileReader();
    reader.onload = function(e) {
        preview.style.backgroundImage = "url('" + e.target.result + "')";
        preview.classList.remove('border-dashed');
        preview.classList.add('border-solid');
        if (cameraIcon) {
            cameraIcon.style.display = 'none';
        }
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
<!-- Basic Info Grid -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
<% if (isCustomerUser && customerId != null) { %>
<input type="hidden" name="customerId" value="<%= customerId %>"/>
<% } %>
<% if (!isCustomerUser) { %>
<!-- Customer ID (optional for staff) -->
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">
                                    Customer ID
</label>
    <input class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" name="customerId" placeholder="Enter customer ID" type="number" required=""/>
</div>
<% } %>
<!-- Pet Name -->
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">
                                    Pet Name <span class="text-primary">*</span>
</label>
<input class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" name="name" placeholder="Enter pet's name" required="" type="text"/>
</div>
<!-- Species -->
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">
                                    Species <span class="text-primary">*</span>
</label>
<select class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" name="species" required="">
<option disabled="" selected="" value="">Select species</option>
<option value="dog">Dog</option>
<option value="cat">Cat</option>
<option value="bird">Bird</option>
<option value="rabbit">Rabbit</option>
<option value="hamster">Hamster</option>
<option value="reptile">Reptile</option>
<option value="other">Other</option>
</select>
</div>
<!-- Breed -->
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">Breed</label>
<input class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" name="breed" placeholder="e.g. Golden Retriever" type="text"/>
</div>
<!-- Gender -->
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">Gender</label>
<div class="flex items-center gap-6 mt-1">
<label class="flex items-center gap-2 cursor-pointer group">
<input class="size-5 text-primary focus:ring-primary border-gray-300 dark:border-gray-600 dark:bg-gray-800" name="gender" type="radio" value="Male"/>
<span class="text-sm font-medium text-gray-600 dark:text-gray-400 group-hover:text-primary transition-colors">Male</span>
</label>
<label class="flex items-center gap-2 cursor-pointer group">
<input class="size-5 text-primary focus:ring-primary border-gray-300 dark:border-gray-600 dark:bg-gray-800" name="gender" type="radio" value="Female"/>
<span class="text-sm font-medium text-gray-600 dark:text-gray-400 group-hover:text-primary transition-colors">Female</span>
</label>
</div>
</div>
<!-- Date of Birth -->
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">
                                    Date of Birth <span class="text-primary">*</span>
</label>
<input class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" id="birthDate" name="birthDate" required="" type="date"/>
</div>
<!-- Weight -->
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">Weight</label>
<div class="relative">
<input class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" name="weight" placeholder="0.0" step="0.1" type="number" min="0" onchange="validateWeight(this)" oninput="validateWeight(this)"/>
<span class="absolute right-4 top-1/2 -translate-y-1/2 text-sm font-bold text-gray-400">kg</span>
</div>
<span id="weightError" class="text-primary text-xs mt-1" style="display:none;">Weight cannot be negative</span>
</div>
</div>
<!-- Action Bar -->
<div class="mt-12 flex flex-col-reverse sm:flex-row items-center justify-end gap-4 border-t border-gray-100 dark:border-gray-800 pt-8">
<a class="w-full sm:w-auto px-8 py-3 rounded-lg font-bold text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors text-center" href="<%= request.getContextPath() %>/pets">
                                Cancel
                            </a>
<button class="w-full sm:w-auto px-10 py-3 rounded-lg bg-primary hover:bg-primary/90 text-white font-bold shadow-lg shadow-primary/20 transition-all flex items-center justify-center gap-2" type="submit">
<span class="material-symbols-outlined text-xl">save</span>
                                Save Pet
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
<!-- Footer info -->
<div class="mt-6 text-center">
<p class="text-xs text-gray-500">
                        Information provided here helps us tailor health reminders and appointment scheduling for your pet.
                    </p>
</div>
</div>
</main>
</div>
</body></html>