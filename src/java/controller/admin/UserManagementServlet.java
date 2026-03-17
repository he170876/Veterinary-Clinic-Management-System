package controller.admin;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserManagementServlet", urlPatterns = {"/owner/user-management"})
public class UserManagementServlet extends HttpServlet {
    
    private final UserDAO userDAO = new UserJdbcDAO();
    private static final String VIEW = "/WEB-INF/views/admin/user-management.jsp";
    private static final int PAGE_SIZE = 5;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = trim(request.getParameter("keyword"));
        String roleIdRaw = request.getParameter("filterRoleId");
        String status = trim(request.getParameter("filterStatus"));
        
        Integer roleId = null;
        if (roleIdRaw != null && !roleIdRaw.isEmpty()) {
            try {
                roleId = Integer.parseInt(roleIdRaw);
            } catch (NumberFormatException ignored) {
            }
        }
        
        if (status != null && status.isEmpty()) {
            status = null;
        }

        /* ===== SORT (SAFE) ===== */
        String sortParam = request.getParameter("sort");
        String sort = "id_desc"; // default
        if ("id_asc".equalsIgnoreCase(sortParam)) {
            sort = "id_asc";
        }

        /* ===== PAGINATION ===== */
        int currentPage = 1;
        String pageRaw = request.getParameter("page");
        
        if (pageRaw != null) {
            try {
                currentPage = Integer.parseInt(pageRaw);
                if (currentPage < 1) {
                    currentPage = 1;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        
        int totalRecords = userDAO.countUsers(keyword, roleId, status);
        int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
        
        if (totalPages > 0 && currentPage > totalPages) {
            currentPage = totalPages;
        }
        
        int offset = (currentPage - 1) * PAGE_SIZE;
        
        List<User> users = userDAO.filterUsers(
                keyword,
                roleId,
                status,
                sort,
                offset,
                PAGE_SIZE
        );
        
        request.setAttribute("users", users);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalUsers", totalRecords);
        request.setAttribute("sort", sort);
        
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
    
    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}
