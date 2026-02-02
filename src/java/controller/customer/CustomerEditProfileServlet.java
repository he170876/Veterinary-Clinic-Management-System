package controller.customer;

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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * GET: show edit profile form. POST: save full name, phone, address.
 */
@WebServlet(name = "CustomerEditProfileServlet", urlPatterns = {"/customer/edit-profile"})
public class CustomerEditProfileServlet extends HttpServlet {

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
        User user = (User) session.getAttribute("currentUser");
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/customer/edit-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        String ctx = request.getContextPath();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        if (fullName == null || fullName.isEmpty()) {
            response.sendRedirect(ctx + "/customer/edit-profile?error=" + URLEncoder.encode("Full name is required.", StandardCharsets.UTF_8));
            return;
        }

        user.setFullName(fullName);
        user.setPhone(phone != null && phone.isEmpty() ? null : phone);
        user.setAddress(address != null && address.isEmpty() ? null : address);

        boolean ok = userDAO.updateUser(user);
        if (ok) {
            session.setAttribute("currentUser", user);
            response.sendRedirect(ctx + "/customer/profile?updated=1");
        } else {
            response.sendRedirect(ctx + "/customer/edit-profile?error=" + URLEncoder.encode("Could not save. Please try again.", StandardCharsets.UTF_8));
        }
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }
}
