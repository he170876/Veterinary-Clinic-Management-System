<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

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
                <a href="create-blog"
                   class="px-6 py-3 bg-orange-500 text-white font-bold rounded-xl hover:bg-orange-600 transition">
                    + Create Blog
                </a>
            </div>
        </section>

        <main class="py-10">
            <div class="max-w-[1200px] mx-auto px-6">

                <!-- FILTER -->
                <form action="blog-management" method="get"
                      class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">

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
                    <div class="flex gap-3">
                        <button type="submit"
                                class="flex-1 bg-orange-500 text-white font-bold rounded-xl py-3 hover:bg-orange-600 transition">
                            Filter
                        </button>

                        <a href="blog-management?page=1"
                           class="flex-1 bg-gray-200 text-gray-700 font-bold rounded-xl py-3
                           flex items-center justify-center hover:bg-gray-300 transition">
                            Clear
                        </a>
                    </div>

                </form>

                <!-- TABLE -->
                <div class="bg-white rounded-2xl shadow overflow-x-auto">
                    <table class="min-w-full text-sm">
                        <thead class="bg-gray-100">
                            <tr>
                                <th class="px-6 py-4">ID</th>
                                <th class="px-6 py-4">Title</th>
                                <th class="px-6 py-4">Category</th>
                                <th class="px-6 py-4">Author ID</th>
                                <th class="px-6 py-4">Status</th>
                                <th class="px-6 py-4">Created At</th>
                                <th class="px-6 py-4 text-center w-[220px]">Actions</th>
                            </tr>
                        </thead>

                        <tbody class="divide-y">
                            <c:forEach items="${blogs}" var="b">
                                <tr class="hover:bg-gray-50 transition">
                                    <td class="px-6 py-4">${b.blogId}</td>

                                    <td class="px-6 py-4 font-semibold">
                                        <c:out value="${b.title}" />
                                    </td>

                                    <td class="px-6 py-4">
                                        <c:out value="${b.category}" default="N/A"/>
                                    </td>

                                    <td class="px-6 py-4">
                                        ${b.authorUserId}
                                    </td>

                                    <td class="px-6 py-4">
                                        <span class="px-3 py-1 rounded-full text-xs font-bold
                                              ${b.status=='Published'?'status-published':'status-draft'}">
                                            ${b.status}
                                        </span>
                                    </td>

                                    <!-- Date giữ nguyên để bạn xử lý ở BE -->
                                    <td class="px-6 py-4 text-gray-600">
                                        ${b.createdAt}
                                    </td>

                                    <!-- ACTION BUTTONS -->
                                    <td class="px-6 py-4">
                                        <div class="flex justify-center items-center gap-2">

                                            <button type="button"
                                                    onclick="openModal(
                                                                    '${b.title}',
                                                                    '${b.category}',
                                                                    '${b.status}',
                                                                    '${b.authorUserId}',
                                                                    '${b.createdAt}',
                                                                    `${b.content}`
                                                                    )"
                                                    class="min-w-[60px] text-center px-3 py-1.5 text-xs font-semibold rounded-lg
                                                    bg-blue-500 text-white hover:bg-blue-600 transition">
                                                View
                                            </button>

                                            <a href="edit-blog?id=${b.blogId}"
                                               class="min-w-[60px] text-center px-3 py-1.5 text-xs font-semibold rounded-lg
                                               bg-amber-500 text-white hover:bg-amber-600 transition">
                                                Edit
                                            </a>

                                            <a href="delete-blog?id=${b.blogId}"
                                               onclick="return confirm('Delete this blog?')"
                                               class="min-w-[60px] text-center px-3 py-1.5 text-xs font-semibold rounded-lg
                                               bg-red-500 text-white hover:bg-red-600 transition">
                                                Delete
                                            </a>

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
                            <a href="blog-management?page=${currentPage-1}&keyword=${param.keyword}&status=${param.status}"
                               class="px-4 py-2 rounded-lg bg-gray-200 font-bold hover:bg-gray-300">
                                Prev
                            </a>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="blog-management?page=${i}&keyword=${param.keyword}&status=${param.status}"
                               class="px-4 py-2 rounded-lg font-bold
                               ${i == currentPage ? 'bg-orange-500 text-white' : 'bg-gray-100 hover:bg-gray-200'}">
                                ${i}
                            </a>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <a href="blog-management?page=${currentPage+1}&keyword=${param.keyword}&status=${param.status}"
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

            <div class="bg-white w-[700px] max-h-[90vh] overflow-y-auto rounded-2xl shadow-xl p-8 relative">

                <!-- Close Button -->
                <button onclick="closeModal()"
                        class="absolute top-4 right-4 text-gray-500 hover:text-black text-xl">
                    ✕
                </button>

                <h2 id="modalTitle" class="text-2xl font-bold mb-4"></h2>

                <div class="text-sm text-gray-500 mb-4 space-y-1">
                    <div><b>Category:</b> <span id="modalCategory"></span></div>
                    <div><b>Status:</b> <span id="modalStatus"></span></div>
                    <div><b>Author ID:</b> <span id="modalAuthor"></span></div>
                    <div><b>Created At:</b> <span id="modalDate"></span></div>
                </div>

                <hr class="my-4">

                <div id="modalContent"
                     class="prose max-w-none text-gray-700 whitespace-pre-line">
                </div>

            </div>
        </div>

        <script>
            function openModal(title, category, status, author, date, content) {
                document.getElementById("modalTitle").innerText = title;
                document.getElementById("modalCategory").innerText = category || "N/A";
                document.getElementById("modalStatus").innerText = status;
                document.getElementById("modalAuthor").innerText = author;
                document.getElementById("modalDate").innerText = date;
                document.getElementById("modalContent").innerText = content;

                const modal = document.getElementById("blogModal");
                modal.classList.remove("hidden");
                modal.classList.add("flex");
            }

            function closeModal() {
                const modal = document.getElementById("blogModal");
                modal.classList.remove("flex");
                modal.classList.add("hidden");
            }

            // Click outside to close
            window.onclick = function (event) {
                const modal = document.getElementById("blogModal");
                if (event.target === modal) {
                    closeModal();
                }
            }
        </script>

    </body>
</html>