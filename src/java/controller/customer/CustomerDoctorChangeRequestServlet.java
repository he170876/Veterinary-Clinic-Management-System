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
import model.Customer;
import model.User;

@WebServlet(name = "CustomerDoctorChangeRequestServlet", urlPatterns = {"/customer/appointments/request-doctor-change"})
public class CustomerDoctorChangeRequestServlet extends HttpServlet {

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
        String preferredDoctorIdRaw = request.getParameter("preferredDoctorId");
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

        int preferredDoctorId;
        try {
            preferredDoctorId = Integer.parseInt(preferredDoctorIdRaw);
            if (preferredDoctorId <= 0) {
                response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=invalid_doctor");
                return;
            }
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=invalid_doctor");
            return;
        }

        String cleanedReason = reason != null ? reason.trim() : "";

        if (cleanedReason.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=missing_reason");
            return;
        }

        boolean success = appointmentDAO.createDoctorChangeRequest(
                appointmentId,
                customerOpt.get().getCustomerId(),
                preferredDoctorId,
                cleanedReason
        );

        if (success) {
            response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&doctorRequested=1");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=" + tab + "&error=doctor_request_failed");
    }
}
