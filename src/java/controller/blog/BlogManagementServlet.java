package controller.blog;

import dao.BlogDAO;
import dao.impl.BlogJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/blog-management")
public class BlogManagementServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/blog-management.jsp";
    private static final int PAGE_SIZE = 5;

    private BlogDAO blogDAO;

    @Override
    public void init() {
        blogDAO = new BlogJdbcDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        // ===== SORTING (NEW VERSION) =====
        String sort = request.getParameter("sort");

        if (sort == null || sort.isBlank()) {
            sort = "date_desc"; // default: newest first
        }

        // ===== PAGING =====
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) {
                page = 1;
            }
        } catch (Exception ignored) {
        }

        int offset = (page - 1) * PAGE_SIZE;

        // ===== CALL DAO =====
        List<?> blogs = blogDAO.search(
                keyword,
                status,
                sort,
                offset,
                PAGE_SIZE
        );

        int total = blogDAO.countSearch(keyword, status);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        // ===== SEND DATA TO JSP =====
        request.setAttribute("blogs", blogs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBlogs", total);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("sort", sort);

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
