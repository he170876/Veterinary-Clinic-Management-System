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

    // =========================
    // GET - View + Filter + Paging
    // =========================
    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {
        }

        int offset = (page - 1) * PAGE_SIZE;

        List<?> blogs = blogDAO.search(keyword, status, offset, PAGE_SIZE);
        int total = blogDAO.countSearch(keyword, status);

        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        request.setAttribute("blogs", blogs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    // =========================
    // POST - Delete / Toggle Status
    // =========================
    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int id = Integer.parseInt(request.getParameter("id"));

        if ("delete".equals(action)) {
            blogDAO.delete(id);
        }

        if ("toggle".equals(action)) {
            blogDAO.toggleStatus(id);
        }

        response.sendRedirect(request.getContextPath() + "/admin/blog-management");
    }
}
