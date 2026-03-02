package controller.blog;

import dao.BlogDAO;
import dao.impl.BlogJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/admin/update-blog-status")
public class UpdateBlogStatusServlet extends HttpServlet {

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
        String filterStatus = request.getParameter("status"); // đây là FILTER
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
            String newStatus = trim(request.getParameter("newStatus"));

            // ====== VALIDATION ======

            if (!blogDAO.existsById(blogId)) {
                response.sendRedirect(redirectUrl + "&error=Blog+not+found");
                return;
            }

            if (!"Draft".equals(newStatus) && !"Published".equals(newStatus)) {
                response.sendRedirect(redirectUrl + "&error=Invalid+status");
                return;
            }

            // ====== UPDATE STATUS ======
            blogDAO.updateStatus(blogId, newStatus);

            response.sendRedirect(redirectUrl + "&success=Status+updated");

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