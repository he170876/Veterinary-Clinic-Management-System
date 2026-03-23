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
import model.Appointment;
import model.Customer;
import model.User;
import utils.ValidationUtil;

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
        String requestedSlotRaw = request.getParameter("requestedTimeSlot");
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
                || requestedSlotRaw == null || requestedSlotRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=missing_datetime");
            return;
        }

        String requestedSlot = ValidationUtil.normalizeBookingSlot(requestedSlotRaw);
        if (requestedSlot == null) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=invalid_datetime");
            return;
        }

        LocalDateTime requestedDateTime;
        try {
            LocalDate requestedDate = LocalDate.parse(requestedDateRaw.trim());
            if (!ValidationUtil.isBookableDateSlot(requestedDate, requestedSlot)) {
                response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=slot_passed");
                return;
            }

            LocalTime requestedTime;
            if ("morning".equals(requestedSlot)) {
                requestedTime = LocalTime.of(8, 0);
            } else if ("afternoon".equals(requestedSlot)) {
                requestedTime = LocalTime.of(14, 0);
            } else {
                throw new IllegalArgumentException("Invalid time slot");
            }
            requestedDateTime = LocalDateTime.of(requestedDate, requestedTime);
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=invalid_datetime");
            return;
        }

        String cleanedReason = reason != null ? reason.trim() : null;

        Appointment currentAppointment = appointmentDAO.getAppointmentDetailByCustomer(
                appointmentId,
                customerOpt.get().getCustomerId());
        if (currentAppointment == null) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=invalid_appointment");
            return;
        }

        LocalDate currentDate = currentAppointment.getAppointmentDate();
        if (currentDate == null && currentAppointment.getAppointmentTime() != null) {
            currentDate = currentAppointment.getAppointmentTime().toLocalDate();
        }

        String currentSlot = ValidationUtil.normalizeBookingSlot(currentAppointment.getTimeSlot());
        if (currentSlot == null && currentAppointment.getAppointmentTime() != null) {
            currentSlot = currentAppointment.getAppointmentTime().getHour() < 12 ? "morning" : "afternoon";
        }

        if (currentDate != null && requestedDateTime.toLocalDate().equals(currentDate)
                && requestedSlot.equals(currentSlot)) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=same_slot");
            return;
        }

        // Customer should see conflict feedback immediately instead of waiting for receptionist approval.
        if (appointmentDAO.hasCustomerAppointmentConflictExcluding(
                customerOpt.get().getCustomerId(),
                requestedDateTime,
                30,
                appointmentId)) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=conflict_slot");
            return;
        }

        boolean success = appointmentDAO.createRescheduleRequest(
                appointmentId,
                customerOpt.get().getCustomerId(),
                requestedDateTime,
            requestedSlot,
                cleanedReason
        );

        if (success) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&requested=1");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=request_failed");
    }
}
