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
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Optional;
import model.Customer;
import model.User;

@WebServlet(name = "CustomerRescheduleRequestServlet", urlPatterns = {"/customer/appointments/request-reschedule"})
public class CustomerRescheduleRequestServlet extends HttpServlet {

    private transient CustomerDAO customerDAO;
    private transient AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        customerDAO = new CustomerJdbcDAO();
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        Optional<Customer> customerOpt = customerDAO.findByUserId(user.getUserId());
        if (!customerOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?error=customer_not_found");
            return;
        }

        String appointmentIdRaw = request.getParameter("appointmentId");
        String requestedDateRaw = request.getParameter("requestedDate");
        String requestedTimeRaw = request.getParameter("requestedTime");
        String reason = request.getParameter("reason");
        String tab = request.getParameter("tab");

        if (tab == null || tab.trim().isEmpty()) {
            tab = "upcoming";
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(appointmentIdRaw);
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=invalid_appointment");
            return;
        }

        if (requestedDateRaw == null || requestedDateRaw.trim().isEmpty()
                || requestedTimeRaw == null || requestedTimeRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=missing_datetime");
            return;
        }

        LocalDateTime requestedDateTime;
        try {
            LocalDate requestedDate = LocalDate.parse(requestedDateRaw.trim());
            LocalTime requestedTime = LocalTime.parse(requestedTimeRaw.trim());
            requestedDateTime = LocalDateTime.of(requestedDate, requestedTime);
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=invalid_datetime");
            return;
        }

        String cleanedReason = reason != null ? reason.trim() : null;
        boolean success = appointmentDAO.createRescheduleRequest(
                appointmentId,
                customerOpt.get().getCustomerId(),
                requestedDateTime,
                cleanedReason
        );

        if (success) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&requested=1");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=request_failed");
    }
}
