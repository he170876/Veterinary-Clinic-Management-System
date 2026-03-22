package controller.receptionist;

import dao.AppointmentDAO;
import dao.InvoiceDAO;
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

        // If UI didn't provide invoiceId, fetch the latest invoice for this appointment.
        if (invoiceId <= 0) {
            invoiceId = invoiceDao.getLatestInvoiceIdByAppointmentId(appointmentId);
        }

        if (invoiceId <= 0) {
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

        boolean paid = invoiceDao.markAsPaid(invoiceId);
        if (!paid) {
            sendJsonOrRedirect(request, response, false, "Unable to mark invoice as Paid.",
                    request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment");
            return;
        }

        appDao.updateAppointmentStatus(appointmentId, "Done");

        sendJsonOrRedirect(request, response, true, "Payment confirmed successfully.",
                request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment&paid=1");
    }

    private void sendJsonOrRedirect(HttpServletRequest request,
            HttpServletResponse response,
            boolean success,
            String message,
            String redirectUrl) throws IOException {

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

