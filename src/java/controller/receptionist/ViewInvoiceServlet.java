package controller.receptionist;

import dao.InvoiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

public class ViewInvoiceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // This servlet renders an invoice view for a given appointmentId.
        //
        // It is used in 2 ways:
        // 1) Full page view (/Receptionist/ViewInvoice?appointmentId=...) for normal navigation.
        // 2) Fragment view (?fragment=1) to load only the "invoice card" HTML into a modal via fetch().
        //
        // Access control: receptionist only.
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (!isReceptionist(user)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String appIdParam = request.getParameter("appointmentId");
        if (appIdParam == null || appIdParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/Receptionist/ViewListAppointment");
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(appIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/Receptionist/ViewListAppointment");
            return;
        }

        InvoiceDAO invoiceDAO = new InvoiceDAO();
        // The DAO returns a single view model that includes:
        // - invoice header fields (customer, pet, scheduled slot, check-in time)
        // - service lines (aggregated)
        InvoiceDAO.AppointmentInvoiceView invoiceData = invoiceDAO.getAppointmentInvoiceView(appointmentId);
        if (invoiceData == null) {
            response.sendRedirect(request.getContextPath() + "/Receptionist/ViewListAppointment");
            return;
        }

        request.setAttribute("invoiceData", invoiceData);
        boolean fragment = "1".equals(request.getParameter("fragment"))
                || "true".equalsIgnoreCase(request.getParameter("fragment"));
        String target = fragment
                ? "/WEB-INF/views/Receptionist/invoice-inner.jsp"
                : "/WEB-INF/views/Receptionist/invoice.jsp";
        // invoice-inner.jsp contains only the printable card content; invoice.jsp wraps it with page chrome.
        request.getRequestDispatcher(target).forward(request, response);
    }

    /** Same normalization as {@code RoleBasedAccessFilter} (trim, case, spaces). */
    private static boolean isReceptionist(User user) {
        if (user.getRole() == null || user.getRole().getRoleName() == null) {
            return false;
        }
        String role = user.getRole().getRoleName().trim().toLowerCase().replace("_", "").replace(" ", "");
        return "receptionist".equals(role);
    }
}
