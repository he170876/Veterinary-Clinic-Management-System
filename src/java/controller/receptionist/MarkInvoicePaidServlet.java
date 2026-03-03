package controller.receptionist;

import dao.AppointmentDAO;
import dao.InvoiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

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
        String invoiceIdParam = request.getParameter("invoiceId");
        if (appIdParam == null || invoiceIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment");
            return;
        }

        int appointmentId;
        int invoiceId;
        try {
            appointmentId = Integer.parseInt(appIdParam);
            invoiceId = Integer.parseInt(invoiceIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment");
            return;
        }

        InvoiceDAO invoiceDao = new InvoiceDAO();
        AppointmentDAO appDao = new AppointmentDAO();

        invoiceDao.markAsPaid(invoiceId);
        appDao.updateAppointmentStatus(appointmentId, "Done");

        response.sendRedirect(request.getContextPath() + "/Receptionist/ViewListAppointment?status=Waiting-for-Payment&paid=1");
    }
}

