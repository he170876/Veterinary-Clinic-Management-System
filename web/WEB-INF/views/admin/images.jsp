<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Image Management - Anipat</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <script id="tailwind-config">
            tailwind.config = {
                darkMode: "class",
                theme: {
                    extend: {
                        colors: {
                            "primary": "#ff7b00",
                            "background-light": "#ffffff",
                            "background-dark": "#16181d",
                        },
                        fontFamily: {
                            "display": ["Manrope"]
                        },
                        borderRadius: {"DEFAULT": "0.5rem", "lg": "1rem", "xl": "1.5rem", "full": "9999px"},
                    },
                },
            }
        </script>
        <style type="text/tailwindcss">
            body { font-family: 'Manrope', sans-serif; }
            .soft-shadow { box-shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.08); }
            .sidebar-item-active { background-color: #f4ede6; border-radius: 0.75rem; }
            .dark .sidebar-item-active { background-color: #1a1c22; }
            .image-preview { max-width: 200px; max-height: 200px; object-fit: cover; border-radius: 0.5rem; }
        </style>
    </head>
    <body class="bg-background-light dark:bg-background-dark font-display text-[#1d140c] dark:text-white transition-colors duration-200">
        <div class="flex min-h-screen">
            <!-- Sidebar -->
            <aside class="w-64 border-r border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark hidden lg:flex flex-col p-6 sticky top-0 h-screen">
                <div class="flex items-center gap-3 mb-8">
                    <div class="size-10 rounded-full bg-primary flex items-center justify-center text-white">
                        <span class="material-symbols-outlined">pets</span>
                    </div>
                    <div class="flex flex-col">
                        <h1 class="text-lg font-bold leading-tight">Anipat</h1>
                        <p class="text-[#a17145] text-xs font-medium">Veterinary Clinic</p>
                    </div>
                </div>
                <nav class="flex flex-col gap-2 flex-1">
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm font-semibold">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                        <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">medical_services</span>
                        <span class="text-sm font-semibold">Services</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 sidebar-item-active text-primary" href="#">
                        <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">image</span>
                        <span class="text-sm font-bold">Images</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                        <span class="material-symbols-outlined">group</span>
                        <span class="text-sm font-semibold">Staff</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                        <span class="material-symbols-outlined">description</span>
                        <span class="text-sm font-semibold">Reports</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="#">
                        <span class="material-symbols-outlined">settings</span>
                        <span class="text-sm font-semibold">Settings</span>
                    </a>
                </nav>
            </aside>

            <!-- Main Content -->
            <main class="flex-1 flex flex-col min-w-0 bg-[#fcfaf8] dark:bg-[#0f1115]">
                <!-- Header -->
                <header class="h-16 border-b border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark flex items-center justify-between px-6 gap-8 sticky top-0 z-10">
                    <div class="flex items-center gap-4 lg:hidden">
                        <div class="size-8 rounded-full bg-primary flex items-center justify-center text-white">
                            <span class="material-symbols-outlined text-lg">pets</span>
                        </div>
                    </div>
                    <div class="flex-1">
                        <div class="relative group max-w-2xl">
                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#a17145] group-focus-within:text-primary transition-colors">search</span>
                            <input class="w-full bg-[#f4ede6] dark:bg-gray-800 border-none rounded-xl py-2 pl-11 pr-4 text-sm focus:ring-2 focus:ring-primary/20 transition-all placeholder-[#a17145]/60" placeholder="Search images..." type="text" id="searchInput" onkeyup="filterImages()"/>
                        </div>
                    </div>
                    <div class="flex items-center gap-4">
                        <button class="size-10 rounded-full border border-[#eadbcd] dark:border-gray-800 flex items-center justify-center hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-colors relative">
                            <span class="material-symbols-outlined text-xl text-[#a17145]">notifications</span>
                        </button>
                        <div class="h-8 w-px bg-[#eadbcd] dark:border-gray-800 mx-1"></div>
                        <button class="flex items-center gap-2 pl-2 pr-1 py-1 rounded-full hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-all border border-transparent hover:border-[#eadbcd] dark:hover:border-gray-700">
                            <div class="size-8 rounded-full bg-cover bg-center border border-white dark:border-gray-700 shadow-sm" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuAYUCJ5rFUlr81fchNgluov8XqF0omAMzcfRI6nmGwV8EbFQxDeqFbQ2PwK2MKwmUSKZit9vi8bIYew6GamGqmcFBwcGpAYU-bsg_UlBH_Iyq3v1Tw3iOUpKfVh7-O0zJ8tNEHwIneejfmZjDaWpXXIebkX_Wngol2e-sAKBsguK_Eoh0Ei9Um081oSK5oCR6I8GRroVTLARRcp1703Dl_8kP8qgtUq9GiIWG-D7MNPw2LA8xy1lh2GUpxleoam1XNeO1icd6fRSUI');"></div>
                            <span class="material-symbols-outlined text-[#a17145]">expand_more</span>
                        </button>
                    </div>
                </header>

                <!-- Page Content -->
                <div class="p-8 max-w-6xl mx-auto w-full flex flex-col gap-6">
                    <div class="flex flex-col @[480px]:flex-row justify-between items-start @[480px]:items-end gap-4">
                        <div class="flex flex-col gap-1">
                            <div class="flex items-center gap-2 mb-1">
                                <span class="text-[#a17145] text-sm font-medium">Management</span>
                                <span class="text-[#eadbcd] dark:text-gray-700">/</span>
                                <span class="text-[#1d140c] dark:text-white text-sm font-bold">Images</span>
                            </div>
                            <h2 class="text-2xl font-bold tracking-tight">Homepage Images</h2>
                            <p class="text-[#a17145] text-sm">Manage homepage and section images.</p>
                        </div>
                        <button onclick="openAddImageModal()" class="px-6 py-3 bg-primary hover:bg-[#e66f00] text-white rounded-xl font-bold shadow-lg shadow-primary/20 flex items-center gap-2 transition-all hover:scale-[1.02] active:scale-[0.98]">
                            <span class="material-symbols-outlined">add_photo_alternate</span>
                            <span>Add Image</span>
                        </button>
                    </div>

                    <!-- Images Grid Grouped by Section -->
                    <div id="imagesContainer">
                        <c:choose>
                            <c:when test="${empty imagesBySection}">
                                <div class="soft-shadow rounded-xl border border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark p-12 text-center">
                                    <div class="flex flex-col items-center gap-3">
                                        <span class="material-symbols-outlined text-5xl opacity-50 text-[#a17145]">image_not_supported</span>
                                        <h3 class="font-bold text-lg">No images found</h3>
                                        <p class="text-sm text-[#a17145]">Upload your first image to get started!</p>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="entry" items="${imagesBySection}">
                                    <div class="mb-8 section-group">
                                        <h3 class="text-xl font-bold text-[#1d140c] dark:text-white mb-4 flex items-center gap-2">
                                            <span class="material-symbols-outlined text-primary">folder</span>
                                            ${entry.key}
                                            <span class="text-sm font-normal text-[#a17145] ml-2">(${fn:length(entry.value)})</span>
                                        </h3>
                                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                            <c:forEach var="image" items="${entry.value}">
                                                <div class="soft-shadow rounded-xl border border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark overflow-hidden image-card" data-image-id="${image.id}" data-image-title="${image.title}" data-image-section="${image.section}" data-image-url="${image.url}" data-image-alt="${image.altText}" data-image-sort="${image.sortOrder}">
                                                    <!-- Image Preview -->
                                                    <div class="relative w-full h-48 bg-gray-200 dark:bg-gray-700 overflow-hidden group">
                                                        <img src="${pageContext.request.contextPath}${image.url}" alt="${image.altText}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"/>
                                                        <div class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center gap-2">
                                                            <button onclick="openEditImageModal(${image.id})" class="p-2 bg-white text-primary rounded-lg hover:scale-110 transition-transform" title="Edit">
                                                                <span class="material-symbols-outlined">edit</span>
                                                            </button>
                                                            <button onclick="deleteImage(${image.id})" class="p-2 bg-red-500 text-white rounded-lg hover:scale-110 transition-transform" title="Delete">
                                                                <span class="material-symbols-outlined">delete</span>
                                                            </button>
                                                        </div>
                                                    </div>

                                                    <!-- Image Details -->
                                                    <div class="p-4 flex flex-col gap-3">
                                                        <div class="flex flex-col gap-1">
                                                            <h3 class="font-bold text-[#1d140c] dark:text-white">${image.title}</h3>
                                                            <p class="text-xs text-[#a17145]">${image.altText}</p>
                                                        </div>
                                                        <div class="flex items-center justify-between pt-2 border-t border-[#eadbcd] dark:border-gray-700">
                                                            <div class="flex flex-col gap-1">
                                                                <span class="text-xs font-medium text-[#a17145]">Section</span>
                                                                <span class="text-sm font-bold text-[#1d140c] dark:text-white">${image.section}</span>
                                                            </div>
                                                            <div class="flex flex-col gap-1 items-end">
                                                                <span class="text-xs font-medium text-[#a17145]">Order</span>
                                                                <span class="text-sm font-bold text-primary">#${image.sortOrder}</span>
                                                            </div>
                                                        </div>
                                                        <p class="text-xs text-[#a17145] mt-2">${fn:replace(fn:substring(image.createdAt, 0, 16), 'T', ' ')}</p>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Stats Row -->
                    <div class="soft-shadow rounded-xl border border-[#eadbcd] dark:border-gray-800 bg-background-light dark:bg-background-dark px-6 py-4 flex items-center justify-between">
                        <p class="text-sm text-[#a17145]">Total images: <span class="font-bold text-[#1d140c] dark:text-white" id="imageCount">0</span></p>
                    </div>
                </div>
            </main>
        </div>

        <!-- Add/Edit Image Modal -->
        <div id="imageModal" class="hidden fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
            <div class="bg-background-light dark:bg-background-dark rounded-xl max-w-md w-full soft-shadow border border-[#eadbcd] dark:border-gray-800">
                <div class="flex items-center justify-between p-6 border-b border-[#eadbcd] dark:border-gray-800">
                    <h3 class="text-xl font-bold">
                        <span id="modalTitle">Add New Image</span>
                    </h3>
                    <button onclick="closeImageModal()" class="text-[#a17145] hover:text-primary">
                        <span class="material-symbols-outlined">close</span>
                    </button>
                </div>

                <form id="imageForm" method="POST" action="${pageContext.request.contextPath}/admin/images" enctype="multipart/form-data" class="p-6 flex flex-col gap-4">
                    <input type="hidden" name="action" id="formAction" value="create">
                    <input type="hidden" name="imageId" id="imageId">

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-semibold text-[#1d140c] dark:text-white">Title <span class="text-red-500">*</span></label>
                        <input type="text" name="title" id="title" required class="px-4 py-2 border border-[#eadbcd] dark:border-gray-700 rounded-lg bg-background-light dark:bg-gray-800 text-[#1d140c] dark:text-white focus:ring-2 focus:ring-primary/20 transition-all" placeholder="Image title">
                    </div>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-semibold text-[#1d140c] dark:text-white">Image File <span class="text-red-500">*</span><span class="text-xs text-[#a17145] font-normal ml-1">(Only for new images)</span></label>
                        <input type="file" name="imageFile" id="imageFile" accept="image/jpeg,image/png,image/gif,image/webp" class="px-4 py-2 border border-[#eadbcd] dark:border-gray-700 rounded-lg bg-background-light dark:bg-gray-800 text-[#1d140c] dark:text-white focus:ring-2 focus:ring-primary/20 transition-all file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-primary file:text-white hover:file:bg-primary/90 cursor-pointer" id="imageFileInput">
                        <p class="text-xs text-[#a17145]">Max size: 10MB. Supported: JPG, PNG, GIF, WebP</p>
                    </div>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-semibold text-[#1d140c] dark:text-white">Alt Text <span class="text-red-500">*</span></label>
                        <input type="text" name="altText" id="altText" required class="px-4 py-2 border border-[#eadbcd] dark:border-gray-700 rounded-lg bg-background-light dark:bg-gray-800 text-[#1d140c] dark:text-white focus:ring-2 focus:ring-primary/20 transition-all" placeholder="Alternative text for accessibility">
                    </div>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-semibold text-[#1d140c] dark:text-white">Section <span class="text-red-500">*</span></label>
                        <select name="section" id="section" required class="px-4 py-2 border border-[#eadbcd] dark:border-gray-700 rounded-lg bg-background-light dark:bg-gray-800 text-[#1d140c] dark:text-white focus:ring-2 focus:ring-primary/20 transition-all">
                            <option value="">Select a section</option>
                            <option value="about">About</option>
                            <option value="banner">Banner</option>
                            <option value="services">Services</option>
                            <option value="team">Team</option>
                            <option value="testimonials">Testimonials</option>
                            <option value="gallery">Gallery</option>
                            <option value="home">Home</option>
                        </select>
                    </div>

                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-semibold text-[#1d140c] dark:text-white">Sort Order</label>
                        <input type="number" name="sortOrder" id="sortOrder" min="0" class="px-4 py-2 border border-[#eadbcd] dark:border-gray-700 rounded-lg bg-background-light dark:bg-gray-800 text-[#1d140c] dark:text-white focus:ring-2 focus:ring-primary/20 transition-all" placeholder="0" value="0">
                    </div>

                    <div class="flex gap-3 pt-4 border-t border-[#eadbcd] dark:border-gray-800">
                        <button type="button" onclick="closeImageModal()" class="flex-1 px-4 py-2 border border-[#eadbcd] dark:border-gray-700 text-[#1d140c] dark:text-white rounded-lg hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-all font-semibold">
                            Cancel
                        </button>
                        <button type="submit" class="flex-1 px-4 py-2 bg-primary hover:bg-[#e66f00] text-white rounded-lg transition-all font-semibold">
                            Save Image
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openAddImageModal() {
                document.getElementById('modalTitle').textContent = 'Add New Image';
                document.getElementById('formAction').value = 'create';
                document.getElementById('imageFile').required = true;
                document.getElementById('imageForm').reset();
                document.getElementById('imageId').value = '';
                document.getElementById('imageModal').classList.remove('hidden');
            }
            
            function openEditImageModal(imageId) {
                // Get image data from the card element
                const card = document.querySelector('[data-image-id="' + imageId + '"]');
                if (!card) {
                    alert('Image not found');
                    return;
                }
                
                document.getElementById('modalTitle').textContent = 'Edit Image';
                document.getElementById('formAction').value = 'update';
                document.getElementById('imageFile').required = false;
                document.getElementById('imageId').value = card.dataset.imageId;
                document.getElementById('title').value = card.dataset.imageTitle;
                document.getElementById('altText').value = card.dataset.imageAlt;
                document.getElementById('section').value = card.dataset.imageSection;
                document.getElementById('sortOrder').value = card.dataset.imageSort;
                document.getElementById('imageFile').value = '';
                document.getElementById('imageModal').classList.remove('hidden');
            }
            
            function closeImageModal() {
                document.getElementById('imageModal').classList.add('hidden');
            }
            
            function deleteImage(imageId) {
                if (confirm('Are you sure you want to delete this image?')) {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '${pageContext.request.contextPath}/admin/images/delete/' + imageId;
                    document.body.appendChild(form);
                    form.submit();
                }
            }
            
            function filterImages() {
                const searchInput = document.getElementById('searchInput').value.toLowerCase();
                const sections = document.querySelectorAll('.section-group');
                
                sections.forEach(section => {
                    const cards = section.querySelectorAll('.image-card');
                    let hasVisibleCards = false;
                    
                    cards.forEach(card => {
                        const title = card.dataset.imageTitle.toLowerCase();
                        const sectionName = card.dataset.imageSection.toLowerCase();
                        
                        if (title.includes(searchInput) || sectionName.includes(searchInput)) {
                            card.style.display = '';
                            hasVisibleCards = true;
                            } else {
                                card.style.display = 'none';
                            }
                        });
                        
                        if (hasVisibleCards) {
                            section.style.display = '';
                            } else {
                                section.style.display = 'none';
                            }
                        });
                    }
                    
                    // Close modal when clicking outside
                    document.addEventListener('DOMContentLoaded', function() {
                        const imageModal = document.getElementById('imageModal');
                        if (imageModal) {
                            imageModal.addEventListener('click', function(e) {
                                if (e.target === this) {
                                    closeImageModal();
                                }
                            });
                        }
                        
                        // Handle form submission
                        const imageForm = document.getElementById('imageForm');
                        if (imageForm) {
                            imageForm.addEventListener('submit', function(e) {
                                // Validate file on create
                                const action = document.getElementById('formAction').value;
                                const fileInput = document.getElementById('imageFile');
                                
                                if (action === 'create' && (!fileInput.files || fileInput.files.length === 0)) {
                                    e.preventDefault();
                                    alert('Please select an image file');
                                    return;
                                }
                            });
                        }
                        
                        // Calculate and display total image count
                        const imageCountEl = document.getElementById('imageCount');
                        if (imageCountEl) {
                            imageCountEl.textContent = document.querySelectorAll('.image-card').length;
                        }
                    });
                </script>
            </body>
        </html>
