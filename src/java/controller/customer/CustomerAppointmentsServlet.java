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
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import model.Appointment;
import model.Customer;
import model.User;

@WebServlet(name = "CustomerAppointmentsServlet", urlPatterns = {"/customer/appointments"})
public class CustomerAppointmentsServlet extends HttpServlet {

    private static final int PAGE_SIZE = 6;

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

        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException ignored) {
                currentPage = 1;
            }
        }
        if (currentPage < 1) {
            currentPage = 1;
        }

        String q = request.getParameter("q");
        if (q == null) {
            q = "";
        }
        String query = q.trim().toLowerCase();

        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");
        LocalDate fromDate = null;
        LocalDate toDate = null;

        try {
            if (fromDateParam != null && !fromDateParam.trim().isEmpty()) {
                fromDate = LocalDate.parse(fromDateParam.trim());
            }
            if (toDateParam != null && !toDateParam.trim().isEmpty()) {
                toDate = LocalDate.parse(toDateParam.trim());
            }
        } catch (Exception ignored) {
            fromDate = null;
            toDate = null;
        }

        List<Appointment> allAppointments = appointmentDAO.getAppointmentsByCustomerId(customerId);
        Set<Integer> pendingRescheduleIds = appointmentDAO.getPendingRescheduleAppointmentIdsByCustomer(customerId);

        LocalDate today = LocalDate.now();
        List<Appointment> baseFiltered = new ArrayList<>();
        for (Appointment appointment : allAppointments) {
            if (!matchesDateRange(appointment, fromDate, toDate)) {
                continue;
            }

            if (!query.isEmpty()) {
                String petName = appointment.getPet() != null && appointment.getPet().getName() != null
                        ? appointment.getPet().getName().toLowerCase() : "";
                String doctorName = appointment.getVeterinarianName() != null
                        ? appointment.getVeterinarianName().toLowerCase() : "";
                String serviceName = appointment.getService() != null
                        ? appointment.getService().toLowerCase() : "";

                if (!petName.contains(query)
                        && !doctorName.contains(query)
                        && !serviceName.contains(query)) {
                    continue;
                }
            }

            baseFiltered.add(appointment);
        }

        List<Appointment> filtered = new ArrayList<>();

        for (Appointment appointment : baseFiltered) {
            if (!matchesTab(appointment, tab, today)) {
                continue;
            }

            filtered.add(appointment);
        }

        request.setAttribute("customerCurrentPage", "appointments");
        request.setAttribute("user", user);
        request.setAttribute("tab", tab);
        request.setAttribute("q", q);
        request.setAttribute("fromDate", fromDate != null ? fromDate.toString() : "");
        request.setAttribute("toDate", toDate != null ? toDate.toString() : "");
        int totalFiltered = filtered.size();
        int totalPages = (int) Math.ceil((double) totalFiltered / PAGE_SIZE);
        if (totalPages == 0) {
            totalPages = 1;
        }
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int fromIndex = (currentPage - 1) * PAGE_SIZE;
        int toIndex = Math.min(fromIndex + PAGE_SIZE, totalFiltered);
        List<Appointment> pagedAppointments = filtered;
        if (!filtered.isEmpty()) {
            pagedAppointments = filtered.subList(fromIndex, toIndex);
        }

        request.setAttribute("appointments", pagedAppointments);
        request.setAttribute("pendingRescheduleIds", pendingRescheduleIds);
        request.setAttribute("upcomingCount", countByTab(baseFiltered, "upcoming", today));
        request.setAttribute("pastCount", countByTab(baseFiltered, "past", today));
        request.setAttribute("cancelledCount", countByTab(baseFiltered, "cancelled", today));
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalFiltered", totalFiltered);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("veterinarians", appointmentDAO.getAllVeterinarians());

        request.getRequestDispatcher("/WEB-INF/views/customer/appointments.jsp").forward(request, response);
    }

    private int countByTab(List<Appointment> appointments, String tab, LocalDate today) {
        int count = 0;
        for (Appointment appointment : appointments) {
            if (matchesTab(appointment, tab, today)) {
                count++;
            }
        }
        return count;
    }

    private boolean matchesDateRange(Appointment appointment, LocalDate fromDate, LocalDate toDate) {
        LocalDate appointmentDate = resolveAppointmentDate(appointment);
        if (appointmentDate == null) {
            return false;
        }

        if (fromDate != null && appointmentDate.isBefore(fromDate)) {
            return false;
        }
        if (toDate != null && appointmentDate.isAfter(toDate)) {
            return false;
        }
        return true;
    }

    private boolean matchesTab(Appointment appointment, String tab, LocalDate today) {
        String status = appointment.getStatus() != null ? appointment.getStatus().toLowerCase() : "";
        LocalDate appointmentDate = resolveAppointmentDate(appointment);

        if ("cancelled".equalsIgnoreCase(tab)) {
            return status.contains("cancel");
        }

        if ("past".equalsIgnoreCase(tab)) {
            if (status.contains("cancel")) {
                return false;
            }
            return appointmentDate != null && appointmentDate.isBefore(today);
        }

        if (status.contains("cancel")) {
            return false;
        }
        return appointmentDate == null || !appointmentDate.isBefore(today);
    }

    private LocalDate resolveAppointmentDate(Appointment appointment) {
        if (appointment == null) {
            return null;
        }
        if (appointment.getAppointmentDate() != null) {
            return appointment.getAppointmentDate();
        }
        if (appointment.getAppointmentTime() != null) {
            return appointment.getAppointmentTime().toLocalDate();
        }
        return null;
    }
}
