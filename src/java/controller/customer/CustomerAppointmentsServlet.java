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
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import model.Appointment;
import model.Customer;
import model.User;

@WebServlet(name = "CustomerAppointmentsServlet", urlPatterns = {"/customer/appointments"})
public class CustomerAppointmentsServlet extends HttpServlet {

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
            response.sendRedirect(request.getContextPath() + "/customer/dashboard?error=customer_not_found");
            return;
        }

        int customerId = customerOpt.get().getCustomerId();
        String tab = request.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "upcoming";
        }

        String q = request.getParameter("q");
        if (q == null) {
            q = "";
        }
        String query = q.trim().toLowerCase();

        List<Appointment> allAppointments = appointmentDAO.getAppointmentsByCustomerId(customerId);
        Set<Integer> pendingRescheduleIds = appointmentDAO.getPendingRescheduleAppointmentIdsByCustomer(customerId);

        LocalDateTime now = LocalDateTime.now();
        List<Appointment> filtered = new ArrayList<>();

        for (Appointment appointment : allAppointments) {
            if (!matchesTab(appointment, tab, now)) {
                continue;
            }

            if (!query.isEmpty()) {
                String petName = appointment.getPet() != null && appointment.getPet().getName() != null
                        ? appointment.getPet().getName().toLowerCase() : "";
                String doctor = appointment.getVeterinarianName() != null
                        ? appointment.getVeterinarianName().toLowerCase() : "";
                String service = appointment.getService() != null
                        ? appointment.getService().toLowerCase() : "";
                if (!petName.contains(query) && !doctor.contains(query) && !service.contains(query)) {
                    continue;
                }
            }

            filtered.add(appointment);
        }

        request.setAttribute("customerCurrentPage", "appointments");
        request.setAttribute("user", user);
        request.setAttribute("tab", tab);
        request.setAttribute("q", q);
        request.setAttribute("appointments", filtered);
        request.setAttribute("pendingRescheduleIds", pendingRescheduleIds);
        request.setAttribute("upcomingCount", countByTab(allAppointments, "upcoming", now));
        request.setAttribute("pastCount", countByTab(allAppointments, "past", now));
        request.setAttribute("cancelledCount", countByTab(allAppointments, "cancelled", now));

        request.getRequestDispatcher("/WEB-INF/views/customer/appointments.jsp").forward(request, response);
    }

    private int countByTab(List<Appointment> appointments, String tab, LocalDateTime now) {
        int count = 0;
        for (Appointment appointment : appointments) {
            if (matchesTab(appointment, tab, now)) {
                count++;
            }
        }
        return count;
    }

    private boolean matchesTab(Appointment appointment, String tab, LocalDateTime now) {
        String status = appointment.getStatus() != null ? appointment.getStatus().toLowerCase() : "";
        LocalDateTime time = appointment.getAppointmentTime();

        if ("cancelled".equalsIgnoreCase(tab)) {
            return status.contains("cancel");
        }

        if ("past".equalsIgnoreCase(tab)) {
            if (status.contains("cancel")) {
                return false;
            }
            return time != null && time.isBefore(now);
        }

        if (status.contains("cancel")) {
            return false;
        }
        return time == null || !time.isBefore(now);
    }
}
