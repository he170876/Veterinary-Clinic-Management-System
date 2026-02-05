<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    
    // Check if customer_id is provided in URL parameter for testing
    String customerIdParam = request.getParameter("customer_id");
    
    if (customerIdParam != null && !customerIdParam.isEmpty()) {
        // URL parameter takes precedence - use it to create/update test customer
        try {
            int testCustomerId = Integer.parseInt(customerIdParam);
            customer = new Customer();
            customer.setCustomerId(testCustomerId);
            session.setAttribute("customer", customer);
        } catch (NumberFormatException e) {
            // Invalid parameter, keep existing customer or create default
            if (customer == null) {
                customer = new Customer();
                customer.setCustomerId(1);
                session.setAttribute("customer", customer);
            }
        }
    } else if (customer == null) {
        // No URL parameter and no session customer - create default test customer with ID 1
        customer = new Customer();
        customer.setCustomerId(1);
        session.setAttribute("customer", customer);
    }
    
    Integer customerId = customer != null ? customer.getCustomerId() : null;
%>
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Add New Pet - Anipat</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200;300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
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
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"},
                },
            },
        }
    </script>
<style>
        body {
            font-family: 'Manrope', sans-serif;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-[#f5f2f0]">
<div class="flex h-screen overflow-hidden">
<!-- Sidebar Navigation -->
<aside class="w-64 border-r border-gray-200 dark:border-gray-800 bg-white dark:bg-background-dark hidden md:flex flex-col justify-between p-4">
<div class="flex flex-col gap-8">
<div class="flex items-center gap-3 px-2">
<div class="bg-primary rounded-lg p-1 text-white">
<span class="material-symbols-outlined text-3xl">pets</span>
</div>
<div class="flex flex-col">
<h1 class="text-[#181410] dark:text-white text-lg font-bold leading-tight">Anipat</h1>
<p class="text-gray-500 text-xs font-normal">Pet Management</p>
</div>
</div>
<nav class="flex flex-col gap-2">
<a class="flex items-center gap-3 px-3 py-2 text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg" href="#">
<span class="material-symbols-outlined">dashboard</span>
<span class="text-sm font-medium">Dashboard</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 bg-primary/10 text-primary rounded-lg" href="#">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">pets</span>
<span class="text-sm font-medium">My Pets</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg" href="#">
<span class="material-symbols-outlined">medical_services</span>
<span class="text-sm font-medium">Medical Records</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg" href="#">
<span class="material-symbols-outlined">calendar_today</span>
<span class="text-sm font-medium">Appointments</span>
</a>
<a class="flex items-center gap-3 px-3 py-2 text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg" href="#">
<span class="material-symbols-outlined">settings</span>
<span class="text-sm font-medium">Settings</span>
</a>
</nav>
</div>
<div class="flex items-center gap-3 border-t border-gray-100 dark:border-gray-800 pt-4">
<div class="bg-center bg-no-repeat aspect-square bg-cover rounded-full size-10" data-alt="Profile photo of the user" style='background-image: url("https://lh3.googleusercontent.com/aida-public/AB6AXuCNjCYz5ElV09GP68HLQU99MlT9I6woiAsDeGuSR5fndELAT97y0IMovkZXhNd5cpvC2a6bXv2wJ-BZZaUWNF-6iPNYTtUkhylyd5QCMEhDJSJHBZw_GQjX3xl21XzTdwJR4EBlITr3AQOp4x5Kzvm6y-AKhcG_oQkdcTqKcpkQc-OiaHHIPkzqb6ZHoVkODYfGKl9i9qv39a2Eeni1c0ucpXoIkGWEsVJv_lC-KTuqgKmZfFbuV16VNpbzp5kzntnKgvBH1-85HQ");'></div>
<div class="flex flex-col overflow-hidden">
<p class="text-sm font-bold truncate">Alex Johnson</p>
<p class="text-xs text-gray-500 truncate">Pro Account</p>
</div>
</div>
</aside>
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
<button class="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 relative">
<span class="material-symbols-outlined">notifications</span>
<span class="absolute top-2 right-2.5 w-2 h-2 bg-primary rounded-full border-2 border-white dark:border-background-dark"></span>
</button>
<button class="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300">
<span class="material-symbols-outlined">help_outline</span>
</button>
</div>
</header>
<!-- Page Body -->
<div class="max-w-4xl mx-auto w-full px-8 py-8">
<!-- Breadcrumbs -->
<nav class="flex items-center gap-2 mb-6">
<a class="text-gray-500 hover:text-primary text-sm font-medium transition-colors" href="#">My Pets</a>
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
<input type="file" id="photoInput" name="photo" accept="image/*" class="hidden" onchange="previewPhoto(event)"/>
<label for="photoInput" class="inline-flex items-center gap-2 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 text-gray-900 dark:text-white px-6 py-2 rounded-lg font-bold text-sm transition-colors cursor-pointer">
<span class="material-symbols-outlined text-lg">upload</span>
                                    Upload Photo
                                </label>
</div>
</div>
<script>
function previewPhoto(event) {
    const file = event.target.files[0];
    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            const preview = document.getElementById('photoPreview');
            preview.style.backgroundImage = `url('${e.target.result}')`;
            preview.classList.remove('border-dashed');
            document.getElementById('cameraIcon').style.display = 'none';
        };
        reader.readAsDataURL(file);
    }
}
</script>
<!-- Basic Info Grid -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
<!-- Customer ID (optional for staff) -->
<div class="flex flex-col gap-2">
<label class="text-sm font-bold text-gray-700 dark:text-gray-300">
                                    Customer ID
</label>
<% if (customerId != null) { %>
    <!-- Customer logged in - show readonly display -->
    <div class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-gray-100">
        <%= customerId %>
    </div>
    <input type="hidden" name="customerId" value="<%= customerId %>"/>
<% } else { %>
    <!-- No logged-in customer - allow input for admin/staff -->
    <input class="w-full px-4 py-3 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:ring-2 focus:ring-primary focus:border-primary transition-all" name="customerId" placeholder="Enter customer ID" type="number" required=""/>
<% } %>
</div>
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