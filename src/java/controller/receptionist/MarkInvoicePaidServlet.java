package controller.receptionist;

import dao.AppointmentDAO;
import dao.InvoiceDAO;
import dao.NotificationDAO;
import dao.VisitDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.Visit;

import java.io.IOException;

/**
 * Receptionist confirms payment for an appointment: mark invoice as Paid and set appointment status to Done.
 */
@WebServlet("/Receptionist/MarkInvoicePaid")
public class MarkInvoicePaidServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // This endpoint is called from the receptionist invoice modal.
        // It supports BOTH:
        // - normal HTML form/navigation (redirect)
        // - AJAX fetch() (JSON)
        // We infer which to use via Accept / X-Requested-With headers (sendJsonOrRedirect()).
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user.getRole() == null || !"Receptionist".equalsIgnoreCase(user.getRole().getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 1) Read/validate appointmentId (+ optional invoiceId).
        String appIdParam = request.getParameter("appointmentId");
        String invoiceIdParam = request.getParameter("invoiceId"); // optional
        if (appIdParam == null || appIdParam.isEmpty()) {
            sendJsonOrRedirect(request, response, false, "Missing appointmentId",
                    request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment");
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(appIdParam);
        } catch (NumberFormatException e) {
            sendJsonOrRedirect(request, response, false, "Invalid appointmentId",
                    request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment");
            return;
        }

        int invoiceId = 0;
        if (invoiceIdParam != null && !invoiceIdParam.isEmpty()) {
            try {
                invoiceId = Integer.parseInt(invoiceIdParam);
            } catch (NumberFormatException ignored) {
                invoiceId = 0;
            }
        }

        InvoiceDAO invoiceDao = new InvoiceDAO();
        AppointmentDAO appDao = new AppointmentDAO();

        // 2) Resolve invoice id:
        // - UI may pass invoiceId if known
        // - otherwise we fetch the latest invoice for that appointment
        // If UI didn't provide invoiceId, fetch the latest invoice for this appointment.
        if (invoiceId <= 0) {
            invoiceId = invoiceDao.getLatestInvoiceIdByAppointmentId(appointmentId);
        }

        if (invoiceId <= 0) {
            // 3) If invoice still not found, try to create a placeholder invoice (total = 0).
            // This covers cases where vet completed but had no billable services recorded.
            // If vet completed but didn't generate invoice (e.g. total = 0),
            // create a placeholder invoice so receptionist can confirm payment.
            VisitDAO visitDao = new VisitDAO();
            Visit visit = visitDao.getByAppointmentId(appointmentId);
            if (visit == null || visit.getVisitId() <= 0) {
                sendJsonOrRedirect(request, response, false, "Invoice not found for this appointment.",
                        request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment");
                return;
            }

            invoiceId = invoiceDao.create(visit.getVisitId(), 0.0, "Recorded");
            if (invoiceId <= 0) {
                sendJsonOrRedirect(request, response, false, "Invoice not found for this appointment.",
                        request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment");
                return;
            }
        }

        // 4) Mark invoice Paid. If this fails we stop early (do NOT mark appointment Done).
        boolean paid = invoiceDao.markAsPaid(invoiceId);
        if (!paid) {
            sendJsonOrRedirect(request, response, false, "Unable to mark invoice as Paid.",
                    request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment");
            return;
        }

        // 5) Business state transition: after payment, appointment is Done.
        appDao.updateAppointmentStatus(appointmentId, "Done");

        // 6) Optional: notify the customer that their visit is completed (in-app notification dropdown).
        int customerUserId = appDao.getCustomerUserIdForAppointment(appointmentId);
        if (customerUserId > 0) {
            String title = "Visit completed";
            String message = "Your visit for Appointment #" + appointmentId + " is complete. Thank you for choosing our clinic.";
            final int maxLen = 255;
            if (message.length() > maxLen) {
                message = message.substring(0, maxLen - 3) + "...";
            }
            new NotificationDAO().create(customerUserId, title, message);
        }

        sendJsonOrRedirect(request, response, true, "Payment confirmed successfully.",
                request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment&paid=1");
    }

    private void sendJsonOrRedirect(HttpServletRequest request,
            HttpServletResponse response,
            boolean success,
            String message,
            String redirectUrl) throws IOException {

        // We support both:
        // - normal navigation (redirect)
        // - AJAX (JSON response)
        // The UI uses fetch() with Accept: application/json.
        String accept = request.getHeader("Accept");
        String xrw = request.getHeader("X-Requested-With");
        boolean wantsJson = (accept != null && accept.contains("application/json"))
                || (xrw != null && "XMLHttpRequest".equalsIgnoreCase(xrw));

        if (!wantsJson) {
            response.sendRedirect(redirectUrl);
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        String json = "{\"success\":" + (success ? "true" : "false") + ","
                + "\"message\":\"" + escapeJson(message) + "\""
                + "}";
        response.getWriter().write(json);
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}

