<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Content Management - Anipat</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <script>
            tailwind.config = {
                darkMode: "class",
                theme: {
                    extend: {
                        colors: {
                            "primary": "#ff7b00",
                            "background-light": "#ffffff",
                            "background-dark": "#16181d"
                        },
                        fontFamily: {
                            "display": ["Manrope", "sans-serif"]
                        }
                    }
                }
            };
        </script>
        <style type="text/tailwindcss">
            body { font-family: 'Manrope', sans-serif; }
            .soft-shadow { box-shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.08); }
            .sidebar-item-active { background-color: #f4ede6; border-radius: 0.75rem; }
            .dark .sidebar-item-active { background-color: #1a1c22; }
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
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/dashboard">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm font-semibold">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/user-management">
                        <span class="material-symbols-outlined">group</span>
                        <span class="text-sm font-semibold">User Management</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/services">
                        <span class="material-symbols-outlined" >medical_services</span>
                        <span class="text-sm font-semibold">Services</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 sidebar-item-active text-primary" href="#">
                        <span class="material-symbols-outlined"  style="font-variation-settings: 'FILL' 1">edit_document</span>
                        <span class="text-sm font-bold">Content</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] dark:hover:bg-gray-800 rounded-xl transition-all" href="${pageContext.request.contextPath}/owner/images">
                        <span class="material-symbols-outlined">image</span>
                        <span class="text-sm font-semibold">Images</span>
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
                            <input class="w-full bg-[#f4ede6] dark:bg-gray-800 border-none rounded-xl py-2 pl-11 pr-4 text-sm focus:ring-2 focus:ring-primary/20 transition-all placeholder-[#a17145]/60" placeholder="Search content keys..." type="text" id="searchInput" onkeyup="filterContentKeys()"/>
                        </div>
                    </div>
                    <div class="flex items-center gap-4">
                        <button class="size-10 rounded-full border border-[#eadbcd] dark:border-gray-800 flex items-center justify-center hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-colors relative">
                            <span class="material-symbols-outlined text-xl text-[#a17145]">notifications</span>
                        </button>
                        <div class="h-8 w-px bg-[#eadbcd] dark:border-gray-800 mx-1"></div>
                        <div class="relative">
                            <button type="button" id="admin-profile-toggle"
                                    class="flex items-center gap-2 pl-2 pr-1 py-1 rounded-full hover:bg-[#f4ede6] dark:hover:bg-gray-800 transition-all border border-transparent hover:border-[#eadbcd] dark:hover:border-gray-700">
                                <%@ include file="_owner_header_avatar.jspf" %>
                                <span class="material-symbols-outlined text-[#a17145]">expand_more</span>
                            </button>
                            <div id="admin-profile-menu"
                                 class="absolute right-0 mt-2 w-56 origin-top-right rounded-xl bg-white shadow-lg border border-slate-200 z-50"
                                 style="display:none;">
                                <a href="${pageContext.request.contextPath}/owner/profile"
                                   class="block px-4 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50 transition-colors rounded-t-xl flex items-center gap-2">
                                    <span class="material-symbols-outlined text-base text-primary">person</span>
                                    <span>My Profile</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/logout"
                                   class="block px-4 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50 transition-colors rounded-b-xl flex items-center gap-2">
                                    <span class="material-symbols-outlined text-base text-primary">logout</span>
                                    <span>Sign out</span>
                                </a>
                            </div>
                        </div>
                    </div>
                </header>

                <!-- Page Content -->
                <div class="p-8 max-w-6xl mx-auto w-full flex flex-col gap-6">
                    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                        <div>
                            <div class="flex items-center gap-2 mb-1">
                                <span class="text-[#a17145] text-sm font-medium">Management</span>
                                <span class="text-[#eadbcd] dark:text-gray-700">/</span>
                                <span class="text-[#1d140c] dark:text-white text-sm font-bold">Content</span>
                            </div>
                            <h2 class="text-2xl font-black tracking-tight">Landing Content Manager</h2>
                            <p class="text-[#87684f] text-sm mt-1">Edit text and image mapping by content key. Save as draft then publish.</p>
                        </div>
                        <div class="flex flex-wrap gap-2">
                            <a class="px-4 py-2 rounded-lg border border-[#eadbcd] hover:bg-[#f4ede6] font-semibold" href="${pageContext.request.contextPath}/index.jsp" target="_blank">View Published</a>
                            <a class="px-4 py-2 rounded-lg border border-[#eadbcd] hover:bg-[#f4ede6] font-semibold" href="${pageContext.request.contextPath}/index.jsp?contentMode=draft&contentLocale=${locale}" target="_blank">Preview Draft</a>
                            <form method="post" action="${pageContext.request.contextPath}/owner/content" class="inline">
                                <input type="hidden" name="action" value="publish_all"/>
                                <input type="hidden" name="locale" value="${locale}"/>
                                <button type="submit" class="px-4 py-2 rounded-lg bg-primary text-white font-bold hover:bg-[#ea7100]">Publish All Drafts</button>
                            </form>
                        </div>
                    </div>

                    <c:if test="${not empty param.saved}">
                        <div class="rounded-xl border border-green-200 bg-green-50 text-green-800 px-4 py-3 text-sm">
                            Saved draft: <span class="font-bold">${fn:escapeXml(param.saved)}</span>
                        </div>
                    </c:if>
                    <c:if test="${not empty param.published}">
                        <div class="rounded-xl border border-blue-200 bg-blue-50 text-blue-800 px-4 py-3 text-sm">
                            Published key: <span class="font-bold">${fn:escapeXml(param.published)}</span>
                        </div>
                    </c:if>
                    <c:if test="${publishedAllCount != null}">
                        <div class="rounded-xl border border-blue-200 bg-blue-50 text-blue-800 px-4 py-3 text-sm">
                            <p>Published drafts: <span class="font-bold">${publishedAllCount}</span></p>
                            <c:if test="${not empty publishedAllKeys}">
                                <p class="mt-2 font-semibold">Published keys:</p>
                                <div class="mt-1 flex flex-wrap gap-2">
                                    <c:forEach var="keyName" items="${publishedAllKeys}">
                                        <span class="px-2 py-1 rounded-md bg-white border border-blue-200 text-xs font-semibold text-blue-900">${fn:escapeXml(keyName)}</span>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </c:if>
                    <c:if test="${not empty param.error}">
                        <div class="rounded-xl border border-red-200 bg-red-50 text-red-800 px-4 py-3 text-sm">
                            ${fn:escapeXml(param.error)}
                        </div>
                    </c:if>

                    <section class="rounded-2xl border border-[#eadbcd] bg-white p-5">
                        <h3 class="text-lg font-black mb-4">Text Keys</h3>
                        <div id="text-keys-root" class="grid grid-cols-1 gap-4">
                            <c:forEach var="entry" items="${textDefaults}">
                                <c:set var="item" value="${contentByKey[entry.key]}"/>
                                <form method="post" action="${pageContext.request.contextPath}/owner/content" class="border border-[#f1e6da] rounded-xl p-4 text-key-item" data-key="${fn:escapeXml(entry.key)}">
                                    <div class="flex flex-col lg:flex-row lg:items-center gap-3">
                                        <div class="lg:w-1/3">
                                            <p class="text-xs font-bold uppercase tracking-widest text-[#8f725e]">${fn:escapeXml(entry.key)}</p>
                                            <p class="text-xs text-[#b0917b] mt-1">Status: ${item != null ? fn:escapeXml(item.status) : 'default'}</p>
                                        </div>
                                        <div class="lg:w-2/3 flex flex-col gap-2">
                                            <textarea name="valueText" rows="3" class="w-full rounded-lg border-[#e7d7c8] focus:ring-primary focus:border-primary">${fn:escapeXml(item != null && not empty item.valueText ? item.valueText : entry.value)}</textarea>
                                            <div class="flex flex-wrap gap-2">
                                                <input type="hidden" name="locale" value="${locale}"/>
                                                <input type="hidden" name="keyName" value="${fn:escapeXml(entry.key)}"/>
                                                <input type="hidden" name="valueType" value="textarea"/>
                                                <button type="submit" name="action" value="save_text" class="px-3 py-2 rounded-lg border border-[#e7d7c8] font-semibold hover:bg-[#fff5ea]">Save Draft</button>
                                                <button type="submit" name="action" value="publish_key" class="px-3 py-2 rounded-lg bg-primary text-white font-bold hover:bg-[#ea7100]">Publish Key</button>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </c:forEach>
                        </div>
                    </section>

                    <section class="rounded-2xl border border-[#eadbcd] bg-white p-5">
                        <h3 class="text-lg font-black mb-4">Image Keys</h3>
                        <div id="image-keys-root" class="grid grid-cols-1 gap-4">
                            <c:forEach var="entry" items="${imageLabels}">
                                <c:set var="item" value="${contentByKey[entry.key]}"/>
                                <form method="post" action="${pageContext.request.contextPath}/owner/content" class="border border-[#f1e6da] rounded-xl p-4 image-key-item" data-key="${fn:escapeXml(entry.key)}">
                                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-3 items-end">
                                        <div>
                                            <p class="text-xs font-bold uppercase tracking-widest text-[#8f725e]">${fn:escapeXml(entry.key)}</p>
                                            <p class="text-sm font-semibold mt-1">${fn:escapeXml(entry.value)}</p>
                                            <p class="text-xs text-[#b0917b] mt-1">Status: ${item != null ? fn:escapeXml(item.status) : 'default'}</p>
                                        </div>
                                        <div>
                                            <label class="text-xs font-semibold text-[#8f725e]">Choose Image</label>
                                            <select name="imageId" class="w-full rounded-lg border-[#e7d7c8] focus:ring-primary focus:border-primary js-image-select">
                                                <option value="">-- Select image --</option>
                                                <c:forEach var="img" items="${images}">
                                                    <option value="${img.id}" data-url="${fn:escapeXml(img.url)}" data-title="${fn:escapeXml(img.title)}" data-alt="${fn:escapeXml(img.altText)}" ${item != null && item.imageId == img.id ? 'selected' : ''}>#${img.id} - ${fn:escapeXml(img.title)} (${fn:escapeXml(img.section)})</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="flex flex-wrap gap-2">
                                            <input type="hidden" name="locale" value="${locale}"/>
                                            <input type="hidden" name="keyName" value="${fn:escapeXml(entry.key)}"/>
                                            <button type="submit" name="action" value="save_image" class="px-3 py-2 rounded-lg border border-[#e7d7c8] font-semibold hover:bg-[#fff5ea]">Save Draft</button>
                                            <button type="submit" name="action" value="publish_key" class="px-3 py-2 rounded-lg bg-primary text-white font-bold hover:bg-[#ea7100]">Publish Key</button>
                                        </div>
                                    </div>
                                    <div class="mt-3 rounded-lg border border-[#f1e6da] bg-[#fffaf3] p-3">
                                        <p class="text-xs font-semibold text-[#8f725e] mb-2">Preview</p>
                                        <div class="flex items-start gap-3">
                                            <img class="hidden js-image-preview-img h-20 w-28 rounded-md object-cover border border-[#eadbcd] bg-white" alt="Selected preview"/>
                                            <div class="text-xs text-[#8f725e] js-image-preview-meta">No image selected.</div>
                                        </div>
                                    </div>
                                </form>
                            </c:forEach>
                        </div>
                    </section>
                </div>
            </main>
        </div>

        <script>
            (function () {
                function extractCategoryFromKey(key) {
                    if (!key) {
                        return "other";
                    }
                    const firstDot = key.indexOf(".");
                    if (firstDot === -1) {
                        return key;
                    }
                    const secondDot = key.indexOf(".", firstDot + 1);
                    if (secondDot === -1) {
                        return key;
                    }
                    return key.substring(0, secondDot);
                }
                
                function formatCategoryLabel(category) {
                    const labelMap = {
                        "home.meta": "Meta",
                        "home.topbar": "Topbar",
                        "home.hero": "Hero",
                        "home.stats": "Stats",
                        "home.services": "Services",
                        "home.about": "About",
                        "home.team": "Team",
                        "home.footer": "Footer",
                        "home.book_modal": "Book Modal"
                    };
                    return labelMap[category] || category.replace(/^home\./, "").replace(/_/g, " ");
                }
                
                function groupFormsIntoAccordion(rootId, itemClass, preferredOrder) {
                    const root = document.getElementById(rootId);
                    if (!root) {
                        return;
                    }
                    
                    const forms = Array.from(root.querySelectorAll("." + itemClass));
                    if (forms.length === 0) {
                        return;
                    }
                    
                    const groups = new Map();
                    forms.forEach(function (formEl) {
                        const key = formEl.getAttribute("data-key") || "";
                        const category = extractCategoryFromKey(key);
                        if (!groups.has(category)) {
                            groups.set(category, []);
                        }
                        groups.get(category).push(formEl);
                    });
                    
                    const dynamicCats = Array.from(groups.keys()).filter(function (cat) {
                        return preferredOrder.indexOf(cat) === -1;
                    }).sort();
                    const renderOrder = preferredOrder.filter(function (cat) {
                        return groups.has(cat);
                    }).concat(dynamicCats);
                    
                    root.innerHTML = "";
                    
                    renderOrder.forEach(function (category, idx) {
                        const details = document.createElement("details");
                        details.className = "rounded-xl border border-[#eadbcd] overflow-hidden bg-[#fffcf8]";
                        if (idx === 0) {
                            details.open = true;
                        }
                        
                        const summary = document.createElement("summary");
                        summary.className = "list-none cursor-pointer select-none px-4 py-3 bg-[#fff5ea] hover:bg-[#ffe9d3] transition-colors";
                        
                        const row = document.createElement("div");
                        row.className = "flex items-center justify-between gap-3";
                        
                        const title = document.createElement("p");
                        title.className = "text-sm font-extrabold tracking-wide text-[#7a5130]";
                        title.textContent = formatCategoryLabel(category);
                        
                        const right = document.createElement("div");
                        right.className = "flex items-center gap-2 text-[#a17145]";
                        
                        const count = document.createElement("span");
                        count.className = "text-xs font-bold bg-white border border-[#eadbcd] rounded-full px-2 py-1";
                        count.textContent = groups.get(category).length + " keys";
                        
                        const icon = document.createElement("span");
                        icon.className = "material-symbols-outlined text-base";
                        icon.textContent = "expand_more";
                        
                        right.appendChild(count);
                        right.appendChild(icon);
                        row.appendChild(title);
                        row.appendChild(right);
                        summary.appendChild(row);
                        
                        const content = document.createElement("div");
                        content.className = "p-4 grid grid-cols-1 gap-4 bg-white";
                        
                        groups.get(category).forEach(function (formEl) {
                            content.appendChild(formEl);
                        });
                        
                        details.appendChild(summary);
                        details.appendChild(content);
                        root.appendChild(details);
                    });
                }

                function storageKey(suffix) {
                    return "owner-content-" + suffix;
                }

                function captureDetailsState(rootId) {
                    var root = document.getElementById(rootId);
                    if (!root) {
                        return [];
                    }
                    return Array.from(root.querySelectorAll(":scope > details")).map(function (d) {
                        return !!d.open;
                    });
                }

                function restoreDetailsState(rootId, state) {
                    if (!Array.isArray(state)) {
                        return;
                    }
                    var root = document.getElementById(rootId);
                    if (!root) {
                        return;
                    }
                    Array.from(root.querySelectorAll(":scope > details")).forEach(function (d, idx) {
                        d.open = !!state[idx];
                    });
                }

                function persistEditingViewState() {
                    try {
                        sessionStorage.setItem(storageKey("scrollY"), String(window.scrollY || 0));
                        sessionStorage.setItem(storageKey("text-open"), JSON.stringify(captureDetailsState("text-keys-root")));
                        sessionStorage.setItem(storageKey("image-open"), JSON.stringify(captureDetailsState("image-keys-root")));
                        sessionStorage.setItem(storageKey("ts"), String(Date.now()));
                    } catch (e) {
                        // no-op
                    }
                }

                function restoreEditingViewState() {
                    try {
                        var tsRaw = sessionStorage.getItem(storageKey("ts"));
                        var ts = tsRaw ? parseInt(tsRaw, 10) : 0;
                        if (!ts || (Date.now() - ts) > 60000) {
                            return;
                        }

                        var textStateRaw = sessionStorage.getItem(storageKey("text-open"));
                        var imageStateRaw = sessionStorage.getItem(storageKey("image-open"));
                        restoreDetailsState("text-keys-root", textStateRaw ? JSON.parse(textStateRaw) : []);
                        restoreDetailsState("image-keys-root", imageStateRaw ? JSON.parse(imageStateRaw) : []);

                        var yRaw = sessionStorage.getItem(storageKey("scrollY"));
                        var y = yRaw ? parseInt(yRaw, 10) : 0;
                        if (!isNaN(y) && y > 0) {
                            setTimeout(function () {
                                window.scrollTo(0, y);
                            }, 0);
                        }
                    } catch (e) {
                        // no-op
                    } finally {
                        sessionStorage.removeItem(storageKey("scrollY"));
                        sessionStorage.removeItem(storageKey("text-open"));
                        sessionStorage.removeItem(storageKey("image-open"));
                        sessionStorage.removeItem(storageKey("ts"));
                    }
                }

                function wirePersistStateOnSubmit() {
                    document.querySelectorAll('form[action$="/owner/content"]').forEach(function (formEl) {
                        formEl.addEventListener("submit", function () {
                            persistEditingViewState();
                        });
                    });
                }
                
                function normalizeImageUrl(rawUrl) {
                    if (!rawUrl) {
                        return "";
                    }
                    if (/^https?:\/\//i.test(rawUrl)) {
                        return rawUrl;
                    }
                    var contextPath = "${pageContext.request.contextPath}";
                    if (rawUrl.charAt(0) === "/") {
                        return contextPath + rawUrl;
                    }
                    return contextPath + "/" + rawUrl;
                }
                
                function updateImagePreview(selectEl) {
                    if (!selectEl) {
                        return;
                    }
                    var form = selectEl.closest("form");
                    if (!form) {
                        return;
                    }
                    
                    var imgEl = form.querySelector(".js-image-preview-img");
                    var metaEl = form.querySelector(".js-image-preview-meta");
                    if (!imgEl || !metaEl) {
                        return;
                    }
                    
                    var selectedOption = selectEl.options[selectEl.selectedIndex];
                    var hasSelection = selectedOption && selectedOption.value;
                    if (!hasSelection) {
                        imgEl.classList.add("hidden");
                        imgEl.removeAttribute("src");
                        metaEl.textContent = "No image selected.";
                        return;
                    }
                    
                    var imageUrl = normalizeImageUrl(selectedOption.getAttribute("data-url") || "");
                    var imageTitle = selectedOption.getAttribute("data-title") || "Untitled";
                    var imageAlt = selectedOption.getAttribute("data-alt") || "No alt text";
                    
                    if (imageUrl) {
                        imgEl.src = imageUrl;
                        imgEl.alt = imageAlt;
                        imgEl.classList.remove("hidden");
                        } else {
                            imgEl.classList.add("hidden");
                            imgEl.removeAttribute("src");
                        }
                        
                        var normalizedTitle = (imageTitle || "").trim();
                        var normalizedAlt = (imageAlt || "").trim();
                        var sameTitleAndAlt = normalizedTitle.toLowerCase() === normalizedAlt.toLowerCase();
                        
                        if (sameTitleAndAlt) {
                            metaEl.innerHTML = "<span class=\"font-semibold text-[#6d4a2f]\">Title:</span> " + normalizedTitle;
                            } else {
                                metaEl.innerHTML = "<span class=\"font-semibold text-[#6d4a2f]\">Title:</span> " + normalizedTitle
                                + "<br/><span class=\"font-semibold text-[#6d4a2f]\">Alt:</span> " + normalizedAlt;
                            }
                        }
                        
                        function initImagePreviews(rootId) {
                            var root = document.getElementById(rootId);
                            if (!root) {
                                return;
                            }
                            root.querySelectorAll("select.js-image-select").forEach(function (selectEl) {
                                updateImagePreview(selectEl);
                                selectEl.addEventListener("change", function () {
                                    updateImagePreview(selectEl);
                                });
                            });
                        }

                        window.filterContentKeys = function () {
                            var input = document.getElementById("searchInput");
                            var keyword = input ? input.value.toLowerCase().trim() : "";

                            document.querySelectorAll(".text-key-item, .image-key-item").forEach(function (formEl) {
                                var key = (formEl.getAttribute("data-key") || "").toLowerCase();
                                formEl.style.display = (!keyword || key.indexOf(keyword) !== -1) ? "" : "none";
                            });

                            document.querySelectorAll("details").forEach(function (detailsEl) {
                                var hasVisibleItems = Array.from(detailsEl.querySelectorAll(".text-key-item, .image-key-item")).some(function (item) {
                                    return item.style.display !== "none";
                                });
                                detailsEl.style.display = hasVisibleItems ? "" : "none";
                            });
                        };
                        
                        document.addEventListener("DOMContentLoaded", function () {
                            groupFormsIntoAccordion(
                            "text-keys-root",
                            "text-key-item",
                            [
                            "home.meta", "home.topbar", "home.hero",
                            "home.stats", "home.services", "home.about",
                            "home.team", "home.footer", "home.book_modal"
                            ]
                            );
                            
                            groupFormsIntoAccordion(
                            "image-keys-root",
                            "image-key-item",
                            ["home.hero", "home.about", "home.team", "home.services", "home.footer"]
                            );

                            restoreEditingViewState();
                            wirePersistStateOnSubmit();

                            initImagePreviews("image-keys-root");

                            var profileToggle = document.getElementById("admin-profile-toggle");
                            var profileMenu = document.getElementById("admin-profile-menu");
                            if (profileToggle && profileMenu) {
                                profileToggle.addEventListener("click", function (event) {
                                    event.stopPropagation();
                                    profileMenu.style.display = profileMenu.style.display === "block" ? "none" : "block";
                                });

                                document.addEventListener("click", function (event) {
                                    if (!profileMenu.contains(event.target) && !profileToggle.contains(event.target)) {
                                        profileMenu.style.display = "none";
                                    }
                                });
                            }
                        });
                    })();
                </script>
            </body>
        </html>
