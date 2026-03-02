package controller.blog;

import dao.BlogDAO;
import dao.impl.BlogJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/admin/edit-blog")
public class EditBlogServlet extends HttpServlet {

    private BlogDAO blogDAO;

    @Override
    public void init() {
        blogDAO = new BlogJdbcDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // ====== Giữ lại filter khi redirect ======
        String keyword = request.getParameter("keyword");
        String filterStatus = request.getParameter("status");
        String page = request.getParameter("page");
        String sort = request.getParameter("sort");

        String redirectUrl = request.getContextPath()
                + "/admin/blog-management?"
                + "keyword=" + safe(keyword)
                + "&status=" + safe(filterStatus)
                + "&page=" + safe(page)
                + "&sort=" + safe(sort);

        try {

            // ====== Lấy dữ liệu ======
            int blogId = Integer.parseInt(request.getParameter("blogId"));
            String title = trim(request.getParameter("title"));
            String category = trim(request.getParameter("category"));
            String slug = trim(request.getParameter("slug"));
            String thumbnailUrl = trim(request.getParameter("thumbnailUrl"));
            String metaDescription = trim(request.getParameter("metaDescription"));
            String content = trim(request.getParameter("content"));
            String status = trim(request.getParameter("editStatus"));

            // ====== VALIDATION ======

            if (title == null || title.isEmpty()) {
                response.sendRedirect(redirectUrl + "&error=Title+is+required");
                return;
            }

            if (content == null || content.isEmpty()) {
                response.sendRedirect(redirectUrl + "&error=Content+is+required");
                return;
            }

            if (!"Draft".equals(status) && !"Published".equals(status)) {
                response.sendRedirect(redirectUrl + "&error=Invalid+status");
                return;
            }

            if (!blogDAO.existsById(blogId)) {
                response.sendRedirect(redirectUrl + "&error=Blog+not+found");
                return;
            }

            // Nếu có slug → kiểm tra trùng (trừ chính nó)
            if (slug != null && !slug.isEmpty()) {
                if (blogDAO.existsBySlugExceptId(slug, blogId)) {
                    response.sendRedirect(redirectUrl + "&error=Slug+already+exists");
                    return;
                }
            }

            // ====== UPDATE ======
            blogDAO.update(
                    blogId,
                    title,
                    category,
                    slug,
                    thumbnailUrl,
                    metaDescription,
                    content,
                    status
            );

            response.sendRedirect(redirectUrl + "&success=Updated");

        } catch (NumberFormatException e) {
            response.sendRedirect(redirectUrl + "&error=Invalid+ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(redirectUrl + "&error=System+error");
        }
    }

    // ====== Helper methods ======
    private String trim(String s) {
        return s == null ? null : s.trim();
    }

    private String safe(String s) {
        return s == null ? "" : s;
    }
}