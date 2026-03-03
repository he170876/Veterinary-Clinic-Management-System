package controller.blog;

import dao.BlogDAO;
import dao.impl.BlogJdbcDAO;
import model.Blog;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import model.User;

@WebServlet("/admin/create-blog")
public class CreateBlogServlet extends HttpServlet {

    private BlogDAO blogDAO;

    @Override
    public void init() {
        blogDAO = new BlogJdbcDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            // =========================
            // 1️⃣ LẤY FILTER + PAGING
            // =========================
            String page = request.getParameter("page");
            String keyword = request.getParameter("keyword");
            String categoryFilter = request.getParameter("category");
            String statusFilter = request.getParameter("status");

            // =========================
            // 2️⃣ LẤY DATA FORM
            // =========================
            String title = trim(request.getParameter("title"));
            String category = trim(request.getParameter("blogCategory"));
            String slug = trim(request.getParameter("slug"));
            String thumbnailUrl = trim(request.getParameter("thumbnailUrl"));
            String metaDescription = trim(request.getParameter("metaDescription"));
            String content = trim(request.getParameter("content"));
            String status = trim(request.getParameter("blogStatus"));

            HttpSession session = request.getSession(false);

            if (session == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            User user = (User) session.getAttribute("currentUser");

            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            Integer authorId = user.getUserId();

            // =========================
            // 3️⃣ VALIDATE
            // =========================
            if (authorId == null) {
                redirectWithFilter(response, request, page, keyword,
                        categoryFilter, statusFilter, "Unauthorized");
                return;
            }

            if (title == null || title.isEmpty()) {
                redirectWithFilter(response, request, page, keyword,
                        categoryFilter, statusFilter, "Title is required");
                return;
            }

            if (title.length() > 200) {
                redirectWithFilter(response, request, page, keyword,
                        categoryFilter, statusFilter, "Title too long");
                return;
            }

            if (slug == null || slug.isEmpty()) {
                redirectWithFilter(response, request, page, keyword,
                        categoryFilter, statusFilter, "Slug is required");
                return;
            }

            if (blogDAO.existsBySlug(slug)) {
                redirectWithFilter(response, request, page, keyword,
                        categoryFilter, statusFilter, "Slug already exists");
                return;
            }

            if (status == null
                    || (!status.equals("Draft") && !status.equals("Published"))) {
                redirectWithFilter(response, request, page, keyword,
                        categoryFilter, statusFilter, "Invalid status");
                return;
            }

            // =========================
            // 4️⃣ TẠO BLOG OBJECT
            // =========================
            Blog blog = new Blog();
            blog.setTitle(title);
            blog.setCategory(category);
            blog.setSlug(slug);
            blog.setThumbnailUrl(thumbnailUrl);
            blog.setMetaDescription(metaDescription);
            blog.setContent(content);
            blog.setStatus(status);
            blog.setAuthorUserId(authorId);
            blog.setCreatedAt(LocalDateTime.now());
            blog.setUpdatedAt(null);

            // =========================
            // 5️⃣ INSERT
            // =========================
            int newBlogId = blogDAO.insert(blog);

            if (newBlogId > 0) {
                redirectWithFilter(response, request, page, keyword,
                        categoryFilter, statusFilter, "Created", true);
            } else {
                redirectWithFilter(response, request, page, keyword,
                        categoryFilter, statusFilter, "Create failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/admin/blog-management?error=System+error");
        }
    }

    // =========================
    // UTIL METHODS
    // =========================
    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private void redirectWithFilter(HttpServletResponse response,
            HttpServletRequest request,
            String page,
            String keyword,
            String category,
            String status,
            String message) throws IOException {

        redirectWithFilter(response, request, page,
                keyword, category, status, message, false);
    }

    private void redirectWithFilter(HttpServletResponse response,
            HttpServletRequest request,
            String page,
            String keyword,
            String category,
            String status,
            String message,
            boolean success) throws IOException {

        StringBuilder url = new StringBuilder(
                request.getContextPath()
                + "/admin/blog-management?"
        );

        url.append(success ? "success=" : "error=");
        url.append(URLEncoder.encode(message, StandardCharsets.UTF_8));

        if (page != null && !page.isBlank()) {
            url.append("&page=").append(page);
        }

        if (keyword != null && !keyword.isBlank()) {
            url.append("&keyword=").append(
                    URLEncoder.encode(keyword, StandardCharsets.UTF_8));
        }

        if (category != null && !category.isBlank()) {
            url.append("&category=").append(
                    URLEncoder.encode(category, StandardCharsets.UTF_8));
        }

        if (status != null && !status.isBlank()) {
            url.append("&status=").append(status);
        }

        response.sendRedirect(url.toString());
    }
}
