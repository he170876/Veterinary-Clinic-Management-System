package controller.receptionist;

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
 * Serves the logged-in receptionist's profile page.
 */
@WebServlet(name = "ReceptionistProfileServlet", urlPatterns = {"/Receptionist/profile"})
public class ReceptionistProfileServlet extends HttpServlet {

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
        User user = userDAO.findById(sessionUser.getUserId()).orElse(sessionUser);
        session.setAttribute("currentUser", user);

        String ctx = request.getContextPath();

        if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
            session.setAttribute("pendingPhoneRequired", Boolean.TRUE);
            response.sendRedirect(ctx + "/Receptionist/edit-profile?required=phone");
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/Receptionist/profile.jsp").forward(request, response);
    }
}
