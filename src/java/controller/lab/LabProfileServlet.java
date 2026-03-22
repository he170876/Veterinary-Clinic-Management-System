package controller.lab;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Lab staff profile read-only page with change password modal, same flow as vet profile.
 */
@WebServlet(name = "LabProfileServlet", urlPatterns = {"/lab/profile"})
public class LabProfileServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserJdbcDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("currentUser");
        User fresh = userDAO.findById(sessionUser.getUserId()).orElse(sessionUser);
        session.setAttribute("currentUser", fresh);
        request.setAttribute("user", fresh);

        request.getRequestDispatcher("/WEB-INF/views/lab/profile.jsp").forward(request, response);
    }
}
