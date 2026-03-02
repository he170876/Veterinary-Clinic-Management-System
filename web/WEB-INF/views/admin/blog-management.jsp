<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Blog Management</title>

        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&display=swap" rel="stylesheet"/>

        <style>
            body {
                font-family: 'Manrope', sans-serif;
            }

            .status-draft {
                background-color: #fef9c3;
                color: #854d0e;
                border: 2px solid #eab308;
            }

            .status-published {
                background-color: #dcfce7;
                color: #166534;
                border: 2px solid #22c55e;
            }
        </style>
    </head>

    <body class="bg-[#fdf8f1] text-[#181111]">

        <!-- NAVBAR -->
        <header class="bg-white shadow">
            <div class="max-w-[1200px] mx-auto px-6 py-4 flex justify-between items-center">
                <h1 class="text-2xl font-black">Anipats CMS</h1>
                <nav class="space-x-6 font-semibold">
                    <a href="index.jsp">Dashboard</a>
                    <a href="blog-management" class="text-orange-500">Blog Management</a>
                    <a href="logout">Logout</a>
                </nav>
            </div>
        </header>

        <!-- TITLE -->
        <section class="py-8 bg-[#fff7ed]">
            <div class="max-w-[1200px] mx-auto px-6 flex justify-between items-center">
                <div>
                    <h2 class="text-4xl font-black">Blog Management</h2>
                    <p class="mt-2 text-[#896163]">Manage system blog posts</p>
                </div>
                <button type="button"
                        onclick="openCreateModal()"
                        class="px-6 py-3 bg-orange-500 text-white font-bold rounded-xl hover:bg-orange-600 transition">
                    + Create Blog
                </button>
            </div>
        </section>

        <main class="py-10">
            <div class="max-w-[1200px] mx-auto px-6">

                <!-- FILTER -->
                <form action="blog-management" method="get"
                      class="grid grid-cols-1 md:grid-cols-6 gap-4 mb-8">

                    <input type="hidden" name="page" value="1"/>

                    <!-- Search -->
                    <input name="keyword" value="${param.keyword}"
                           placeholder="Search blog title..."
                           class="rounded-xl border px-4 py-3"/>

                    <!-- Status -->
                    <select name="status" class="rounded-xl border px-4 py-3">
                        <option value="">All status</option>
                        <option value="Draft" ${param.status=='Draft'?'selected':''}>Draft</option>
                        <option value="Published" ${param.status=='Published'?'selected':''}>Published</option>
                    </select>

                    <!-- Buttons -->
                    <div class="flex gap-3 col-span-2">
                        <button type="submit"
                                class="flex-1 bg-orange-500 text-white font-bold rounded-xl py-3 hover:bg-orange-600 transition">
                            Filter
                        </button>

                        <a href="blog-management?page=1&sort=date_desc"
                           class="flex-1 bg-gray-200 text-gray-700 font-bold rounded-xl py-3
                           flex items-center justify-center hover:bg-gray-300 transition">
                            Clear
                        </a>
                    </div>

                </form>

                <!-- ALERT MESSAGE -->
                <c:if test="${not empty param.error}">
                    <div class="mb-6 p-4 rounded-xl bg-red-100 border border-red-400 text-red-700 font-semibold">
                        ${param.error}
                    </div>
                </c:if>

                <c:if test="${not empty param.success}">
                    <div class="mb-6 p-4 rounded-xl bg-green-100 border border-green-400 text-green-700 font-semibold">
                        ${param.success}
                    </div>
                </c:if>

                <!-- TABLE -->
                <div class="bg-white rounded-2xl shadow overflow-x-auto">
                    <table class="min-w-full table-fixed text-sm">

                        <thead class="bg-gray-100">
                            <tr>
                                <!-- ID -->
                                <th class="w-[70px] px-4 py-3 text-left">
                                    <form method="get" action="blog-management"
                                          class="inline-flex items-center gap-1">

                                        <input type="hidden" name="keyword" value="${param.keyword}" />
                                        <input type="hidden" name="status" value="${param.status}" />
                                        <input type="hidden" name="page" value="1" />

                                        <input type="hidden" name="sort"
                                               value="${sort == 'id_asc' ? 'id_desc' : 'id_asc'}" />

                                        ID

                                        <button type="submit"
                                                class="ml-1 font-bold text-orange-600 hover:scale-110 transition">
                                            <c:choose>
                                                <c:when test="${sort eq 'id_asc'}">↑</c:when>
                                                <c:when test="${sort eq 'id_desc'}">↓</c:when>
                                                <c:otherwise>↕</c:otherwise>
                                            </c:choose>
                                        </button>
                                    </form>
                                </th>

                                <!-- Title -->
                                <th class="w-[280px] px-4 py-3 text-left">
                                    Title
                                </th>

                                <!-- Category -->
                                <th class="w-[150px] px-4 py-3 text-left">
                                    Category
                                </th>

                                <!-- Author -->
                                <th class="w-[90px] px-4 py-3 text-center">
                                    Author
                                </th>

                                <!-- Status -->
                                <th class="w-[120px] px-4 py-3 text-center">
                                    Status
                                </th>

                                <!-- Created Date -->
                                <th class="w-[170px] px-4 py-3 text-left">
                                    <form method="get" action="blog-management"
                                          class="inline-flex items-center gap-1">

                                        <input type="hidden" name="keyword" value="${param.keyword}" />
                                        <input type="hidden" name="status" value="${param.status}" />
                                        <input type="hidden" name="page" value="1" />

                                        <input type="hidden" name="sort"
                                               value="${sort == 'date_asc' ? 'date_desc' : 'date_asc'}" />

                                        Created Date

                                        <button type="submit"
                                                class="ml-1 font-bold text-orange-600 hover:scale-110 transition">
                                            <c:choose>
                                                <c:when test="${sort eq 'date_asc'}">↑</c:when>
                                                <c:when test="${sort eq 'date_desc'}">↓</c:when>
                                                <c:otherwise>↕</c:otherwise>
                                            </c:choose>
                                        </button>
                                    </form>
                                </th>

                                <!-- Actions -->
                                <th class="w-[220px] px-4 py-3 text-center">
                                    Actions
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y">
                            <c:forEach items="${blogs}" var="b">
                                <tr class="hover:bg-gray-50 transition">

                                    <!-- ID -->
                                    <td class="px-4 py-3">
                                        ${b.blogId}
                                    </td>

                                    <!-- Title -->
                                    <td class="px-4 py-3 font-semibold truncate">
                                        <c:out value="${b.title}" />
                                    </td>

                                    <!-- Category -->
                                    <td class="px-4 py-3 truncate">
                                        <c:out value="${b.category}" default="N/A"/>
                                    </td>

                                    <!-- Author -->
                                    <td class="px-4 py-3 text-center">
                                        ${b.authorUserId}
                                    </td>

                                    <!-- Status -->
                                    <td class="px-4 py-3 text-center">
                                        <span class="px-3 py-1 rounded-full text-xs font-bold
                                              ${b.status=='Published'?'status-published':'status-draft'}">
                                            ${b.status}
                                        </span>
                                    </td>

                                    <!-- Created Date -->
                                    <td class="px-4 py-3 text-gray-600">
                                        ${b.createdAt}
                                    </td>

                                    <!-- Actions -->
                                    <td class="px-4 py-3">
                                        <div class="flex justify-center items-center gap-2">

                                            <button type="button"
                                                    class="viewBtn min-w-[60px] text-center px-3 py-1.5 text-xs font-semibold rounded-lg
                                                    bg-blue-500 text-white hover:bg-blue-600 transition"

                                                    data-id="${b.blogId}"
                                                    data-title="${fn:escapeXml(b.title)}"
                                                    data-category="${fn:escapeXml(b.category)}"
                                                    data-status="${b.status}"
                                                    data-author="${b.authorUserId}"
                                                    data-created="${b.createdAt}"
                                                    data-updated="${b.updatedAt}"
                                                    data-slug="${fn:escapeXml(b.slug)}"
                                                    data-thumbnail="${fn:escapeXml(b.thumbnailUrl)}"
                                                    data-meta="${fn:escapeXml(b.metaDescription)}"
                                                    data-content="${fn:escapeXml(b.content)}">

                                                View
                                            </button>

                                            <button type="button"
                                                    class="editBtn min-w-[60px] text-center px-3 py-1.5 text-xs font-semibold rounded-lg
                                                    bg-amber-500 text-white hover:bg-amber-600 transition"

                                                    data-id="${b.blogId}"
                                                    data-title="${fn:escapeXml(b.title)}"
                                                    data-category="${fn:escapeXml(b.category)}"
                                                    data-status="${b.status}"
                                                    data-slug="${fn:escapeXml(b.slug)}"
                                                    data-thumbnail="${fn:escapeXml(b.thumbnailUrl)}"
                                                    data-meta="${fn:escapeXml(b.metaDescription)}"
                                                    data-content="${fn:escapeXml(b.content)}">

                                                Edit
                                            </button>

                                        </div>
                                    </td>

                                </tr>
                            </c:forEach>

                            <c:if test="${empty blogs}">
                                <tr>
                                    <td colspan="7" class="text-center py-10 text-gray-500">
                                        No blogs found
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>

                    </table>
                </div>

                <!-- PAGINATION INFO -->
                <div class="flex justify-between items-center mt-4 text-sm text-gray-600">

                    <c:set var="from" value="${(currentPage - 1) * pageSize + 1}" />
                    <c:set var="to" value="${currentPage * pageSize}" />

                    <c:if test="${to > totalBlogs}">
                        <c:set var="to" value="${totalBlogs}" />
                    </c:if>

                    <div>
                        Showing
                        <b>${from}</b>
                        to
                        <b>${to}</b>
                        of
                        <b>${totalBlogs}</b>
                        blogs
                    </div>
                </div>

                <!-- PAGINATION -->
                <c:if test="${totalPages > 1}">
                    <div class="flex justify-center items-center gap-2 mt-8">

                        <c:if test="${currentPage > 1}">
                            <a href="blog-management?page=${currentPage-1}&keyword=${param.keyword}&status=${param.status}&sort=${sort}"
                               class="px-4 py-2 rounded-lg bg-gray-200 font-bold hover:bg-gray-300">
                                Prev
                            </a>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="blog-management?page=${i}&keyword=${param.keyword}&status=${param.status}&sort=${sort}"
                               class="px-4 py-2 rounded-lg font-bold
                               ${i == currentPage ? 'bg-orange-500 text-white' : 'bg-gray-100 hover:bg-gray-200'}">
                                ${i}
                            </a>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <a href="blog-management?page=${currentPage+1}&keyword=${param.keyword}&status=${param.status}&sort=${sort}"
                               class="px-4 py-2 rounded-lg bg-gray-200 font-bold hover:bg-gray-300">
                                Next
                            </a>
                        </c:if>

                    </div>
                </c:if>

            </div>
        </main>

        <footer class="bg-[#181111] text-white py-10 mt-20 text-center opacity-70">
            © 2026 Anipats CMS
        </footer>

        <!-- BLOG VIEW MODAL -->
        <div id="blogModal"
             class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">

            <div class="bg-white w-[800px] max-h-[90vh] overflow-y-auto rounded-2xl shadow-xl p-8 relative">

                <button onclick="closeModal()"
                        class="absolute top-4 right-4 text-gray-500 hover:text-black text-xl">
                    ✕
                </button>

                <h2 id="modalTitle" class="text-3xl font-bold mb-6"></h2>

                <!-- META INFO -->
                <div class="grid grid-cols-2 gap-4 text-sm text-gray-600">

                    <div><b>ID:</b> <span id="modalId"></span></div>
                    <div><b>Status:</b> <span id="modalStatus"></span></div>

                    <div><b>Category:</b> <span id="modalCategory"></span></div>
                    <div><b>Author ID:</b> <span id="modalAuthor"></span></div>

                    <div><b>Slug:</b> <span id="modalSlug"></span></div>
                    <div><b>Created At:</b> <span id="modalDate"></span></div>

                    <div><b>Updated At:</b> <span id="modalUpdated"></span></div>

                </div>

                <hr class="my-6">

                <!-- Thumbnail -->
                <div id="modalThumbnailWrapper" class="mb-6 hidden">
                    <img id="modalThumbnail"
                         class="w-full rounded-xl shadow">
                </div>

                <!-- Meta Description -->
                <div class="mb-6">
                    <h3 class="font-semibold text-lg mb-2">Meta Description</h3>
                    <p id="modalMeta" class="text-gray-600"></p>
                </div>

                <hr class="my-6">

                <!-- Content -->
                <div>
                    <h3 class="font-semibold text-lg mb-3">Content</h3>
                    <div id="modalContent"
                         class="prose max-w-none text-gray-700 whitespace-pre-line">
                    </div>
                </div>

            </div>
        </div>

        <!-- BLOG EDIT MODAL -->
        <div id="editModal"
             class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">

            <div class="bg-white w-[900px] max-h-[95vh] overflow-y-auto rounded-2xl shadow-xl p-8 relative">

                <button onclick="closeEditModal()"
                        class="absolute top-4 right-4 text-gray-500 hover:text-black text-xl">
                    ✕
                </button>

                <h2 class="text-3xl font-bold mb-6">Edit Blog</h2>

                <!-- ALERT MESSAGE -->
                <c:if test="${not empty param.error}">
                    <div class="mb-6 p-4 rounded-xl bg-red-100 border border-red-400 text-red-700 font-semibold">
                        ${param.error}
                    </div>
                </c:if>

                <c:if test="${not empty param.success}">
                    <div class="mb-6 p-4 rounded-xl bg-green-100 border border-green-400 text-green-700 font-semibold">
                        ${param.success}
                    </div>
                </c:if>

                <form method="post" action="edit-blog">

                    <input type="hidden" name="blogId" id="editId"/>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                        <!-- Title -->
                        <div class="col-span-2">
                            <label class="font-semibold">Title</label>
                            <input type="text" name="title" id="editTitle"
                                   class="w-full rounded-xl border px-4 py-3" required/>
                        </div>

                        <!-- Category -->
                        <div>
                            <label class="font-semibold">Category</label>
                            <input type="text" name="category" id="editCategory"
                                   class="w-full rounded-xl border px-4 py-3"/>
                        </div>

                        <!-- Status -->
                        <div>
                            <label class="font-semibold">Status</label>
                            <select name="editStatus" id="editStatus"
                                    class="w-full rounded-xl border px-4 py-3">
                                <option value="Draft">Draft</option>
                                <option value="Published">Published</option>
                            </select>
                        </div>

                        <!-- Slug -->
                        <div class="col-span-2">
                            <label class="font-semibold">Slug</label>
                            <input type="text" name="slug" id="editSlug"
                                   class="w-full rounded-xl border px-4 py-3"/>
                        </div>

                        <!-- Thumbnail -->
                        <div class="col-span-2">
                            <label class="font-semibold">Thumbnail URL</label>
                            <input type="text" name="thumbnailUrl" id="editThumbnail"
                                   class="w-full rounded-xl border px-4 py-3"/>
                        </div>

                        <!-- Meta -->
                        <div class="col-span-2">
                            <label class="font-semibold">Meta Description</label>
                            <textarea name="metaDescription" id="editMeta"
                                      rows="3"
                                      class="w-full rounded-xl border px-4 py-3"></textarea>
                        </div>

                        <!-- Content -->
                        <div class="col-span-2">
                            <label class="font-semibold">Content</label>
                            <textarea name="content" id="editContent"
                                      rows="10"
                                      class="w-full rounded-xl border px-4 py-3"
                                      required></textarea>
                        </div>

                    </div>

                    <div class="flex justify-end gap-3 mt-8">
                        <button type="button"
                                onclick="closeEditModal()"
                                class="px-6 py-3 bg-gray-200 rounded-xl font-bold hover:bg-gray-300">
                            Cancel
                        </button>

                        <button type="submit"
                                class="px-6 py-3 bg-orange-500 text-white rounded-xl font-bold hover:bg-orange-600">
                            Save Changes
                        </button>
                    </div>

                </form>

            </div>
        </div>

        <script>
            /* ================= VIEW MODAL ================= */

            function openModal(id, title, category, status, author,
                    createdAt, updatedAt, slug,
                    thumbnailUrl, metaDescription, content) {

                document.getElementById("modalId").innerText = id;
                document.getElementById("modalTitle").innerText = title;
                document.getElementById("modalCategory").innerText = category || "N/A";
                document.getElementById("modalStatus").innerText = status;
                document.getElementById("modalAuthor").innerText = author;
                document.getElementById("modalDate").innerText = createdAt;
                document.getElementById("modalUpdated").innerText = updatedAt || "N/A";
                document.getElementById("modalSlug").innerText = slug || "N/A";
                document.getElementById("modalMeta").innerText = metaDescription || "N/A";
                document.getElementById("modalContent").innerText = content;

                if (thumbnailUrl && thumbnailUrl !== "null") {
                    document.getElementById("modalThumbnail").src = thumbnailUrl;
                    document.getElementById("modalThumbnailWrapper").classList.remove("hidden");
                } else {
                    document.getElementById("modalThumbnailWrapper").classList.add("hidden");
                }

                const modal = document.getElementById("blogModal");
                modal.classList.remove("hidden");
                modal.classList.add("flex");
            }

            function closeModal() {
                const modal = document.getElementById("blogModal");
                modal.classList.remove("flex");
                modal.classList.add("hidden");
            }

            document.querySelectorAll(".viewBtn").forEach(btn => {
                btn.addEventListener("click", function () {
                    openModal(
                            this.dataset.id,
                            this.dataset.title,
                            this.dataset.category,
                            this.dataset.status,
                            this.dataset.author,
                            this.dataset.created,
                            this.dataset.updated,
                            this.dataset.slug,
                            this.dataset.thumbnail,
                            this.dataset.meta,
                            this.dataset.content
                            );
                });
            });

            /* ================= EDIT MODAL ================= */

            function openEditModal(id, title, category, status, slug,
                    thumbnailUrl, metaDescription, content) {

                document.getElementById("editId").value = id;
                document.getElementById("editTitle").value = title;
                document.getElementById("editCategory").value = category || "";
                document.getElementById("editStatus").value = status;
                document.getElementById("editSlug").value = slug || "";
                document.getElementById("editThumbnail").value = thumbnailUrl || "";
                document.getElementById("editMeta").value = metaDescription || "";
                document.getElementById("editContent").value = content;

                const modal = document.getElementById("editModal");
                modal.classList.remove("hidden");
                modal.classList.add("flex");
            }

            function closeEditModal() {
                const modal = document.getElementById("editModal");
                modal.classList.remove("flex");
                modal.classList.add("hidden");
            }

            document.querySelectorAll(".editBtn").forEach(btn => {
                btn.addEventListener("click", function () {
                    openEditModal(
                            this.dataset.id,
                            this.dataset.title,
                            this.dataset.category,
                            this.dataset.status,
                            this.dataset.slug,
                            this.dataset.thumbnail,
                            this.dataset.meta,
                            this.dataset.content
                            );
                });
            });

        </script>

        <!-- BLOG CREATE MODAL -->
        <div id="createModal"
             class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">

            <div class="bg-white w-[900px] max-h-[95vh] overflow-y-auto rounded-2xl shadow-xl p-8 relative">

                <button onclick="closeCreateModal()"
                        class="absolute top-4 right-4 text-gray-500 hover:text-black text-xl">
                    ✕
                </button>

                <h2 class="text-3xl font-bold mb-6">Create Blog</h2>

                <!-- ALERT MESSAGE -->
                <c:if test="${not empty param.error}">
                    <div class="mb-6 p-4 rounded-xl bg-red-100 border border-red-400 text-red-700 font-semibold">
                        ${param.error}
                    </div>
                </c:if>

                <c:if test="${not empty param.success}">
                    <div class="mb-6 p-4 rounded-xl bg-green-100 border border-green-400 text-green-700 font-semibold">
                        ${param.success}
                    </div>
                </c:if>

                <form method="post" action="create-blog">

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                        <input type="hidden" name="page" value="${currentPage}">
                        <input type="hidden" name="keyword" value="${keyword}">
                        <input type="hidden" name="status" value="${param.status}">

                        <!-- Title -->
                        <div class="col-span-2">
                            <label class="font-semibold">Title</label>
                            <input type="text" name="title"
                                   class="w-full rounded-xl border px-4 py-3" required/>
                        </div>

                        <!-- Category -->
                        <div>
                            <label class="font-semibold">Category</label>
                            <input type="text" name="category"
                                   class="w-full rounded-xl border px-4 py-3"/>
                        </div>

                        <!-- Status -->
                        <div>
                            <label class="font-semibold">Status</label>
                            <select name="blogStatus"
                                    class="w-full rounded-xl border px-4 py-3">
                                <option value="Draft">Draft</option>
                                <option value="Published">Published</option>
                            </select>
                        </div>

                        <!-- Slug -->
                        <div class="col-span-2">
                            <label class="font-semibold">Slug</label>
                            <input type="text" name="slug"
                                   class="w-full rounded-xl border px-4 py-3" required/>
                        </div>

                        <!-- Thumbnail -->
                        <div class="col-span-2">
                            <label class="font-semibold">Thumbnail URL</label>
                            <input type="text" name="thumbnailUrl"
                                   class="w-full rounded-xl border px-4 py-3"/>
                        </div>

                        <!-- Meta -->
                        <div class="col-span-2">
                            <label class="font-semibold">Meta Description</label>
                            <textarea name="metaDescription"
                                      rows="3"
                                      class="w-full rounded-xl border px-4 py-3"></textarea>
                        </div>

                        <!-- Content -->
                        <div class="col-span-2">
                            <label class="font-semibold">Content</label>
                            <textarea name="content"
                                      rows="10"
                                      class="w-full rounded-xl border px-4 py-3"
                                      required></textarea>
                        </div>

                    </div>

                    <div class="flex justify-end gap-3 mt-8">
                        <button type="button"
                                onclick="closeCreateModal()"
                                class="px-6 py-3 bg-gray-200 rounded-xl font-bold hover:bg-gray-300">
                            Cancel
                        </button>

                        <button type="submit"
                                class="px-6 py-3 bg-orange-500 text-white rounded-xl font-bold hover:bg-orange-600">
                            Create
                        </button>
                    </div>

                </form>

            </div>
        </div>

        <script>
            /* ================= CREATE MODAL ================= */

            function openCreateModal() {
                const modal = document.getElementById("createModal");
                modal.classList.remove("hidden");
                modal.classList.add("flex");
            }

            function closeCreateModal() {
                const modal = document.getElementById("createModal");
                modal.classList.remove("flex");
                modal.classList.add("hidden");
            }

            window.onclick = function (event) {
                const blogModal = document.getElementById("blogModal");
                const editModal = document.getElementById("editModal");
                const createModal = document.getElementById("createModal");

                if (event.target === blogModal)
                    closeModal();
                if (event.target === editModal)
                    closeEditModal();
                if (event.target === createModal)
                    closeCreateModal();
            };
        </script>
    </body>
</html>