package controller.customer;

import dao.AppointmentDAO;
import dao.CustomerDAO;
import dao.impl.CustomerJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Optional;
import model.Appointment;
import model.Customer;
import model.User;

@WebServlet(name = "CustomerAppointmentDetailServlet", urlPatterns = {"/customer/appointments/detail"})
public class CustomerAppointmentDetailServlet extends HttpServlet {

    private transient CustomerDAO customerDAO;
    private transient AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        customerDAO = new CustomerJdbcDAO();
        appointmentDAO = new AppointmentDAO();
    }

    private Optional<Customer> resolveCurrentCustomer(User user) {
        if (user == null) {
            return Optional.empty();
        }

        Optional<Customer> customerOpt = customerDAO.findByUserId(user.getUserId());
        if (customerOpt.isPresent()) {
            return customerOpt;
        }

        try {
            Customer customer = new Customer();
            customer.setUser(user);
            customerDAO.create(customer);
            return customerDAO.findByUserId(user.getUserId());
        } catch (Exception ex) {
            return Optional.empty();
        }
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
        Optional<Customer> customerOpt = resolveCurrentCustomer(user);
        if (!customerOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?error=customer_not_found");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?error=missing_appointment");
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?error=invalid_appointment");
            return;
        }

        Appointment appointment = appointmentDAO.getAppointmentDetailByCustomer(
                appointmentId,
                customerOpt.get().getCustomerId()
        );

        if (appointment == null) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?error=appointment_not_found");
            return;
        }

        request.setAttribute("customerCurrentPage", "appointments");
        request.setAttribute("user", user);
        request.setAttribute("appointment", appointment);
        request.getRequestDispatcher("/WEB-INF/views/customer/appointment-detail.jsp").forward(request, response);
    }
}