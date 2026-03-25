<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.InvoiceDAO" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    InvoiceDAO.AppointmentInvoiceView invoiceData = (InvoiceDAO.AppointmentInvoiceView) request.getAttribute("invoiceData");
    if (invoiceData == null) {
        return;
    }

    DateTimeFormatter dtFmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    DateTimeFormatter dFmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    String bookedAt = invoiceData.getBookedAt() != null ? invoiceData.getBookedAt().format(dtFmt) : "N/A";
    String appointmentSlot = "N/A";
    if (invoiceData.getAppointmentDate() != null && invoiceData.getTimeSlot() != null && !invoiceData.getTimeSlot().isBlank()) {
        appointmentSlot = invoiceData.getAppointmentDate().format(dFmt) + " " + invoiceData.getTimeSlot().toUpperCase();
    } else if (invoiceData.getAppointmentTimeLegacy() != null) {
        appointmentSlot = invoiceData.getAppointmentTimeLegacy().format(dtFmt);
    }
    String checkInAt = invoiceData.getCheckInAt() != null ? invoiceData.getCheckInAt().format(dtFmt) : "N/A";
%>
<div class="bg-white dark:bg-slate-900 rounded-2xl shadow p-8 border border-slate-200 dark:border-slate-700 text-slate-800 dark:text-slate-200" id="invoicePrintArea">
    <div class="flex items-start justify-between border-b border-slate-200 dark:border-slate-700 pb-5">
        <div>
            <h1 class="text-2xl font-bold">Appointment Invoice</h1>
            <p class="text-sm text-slate-500 dark:text-slate-400 mt-1">Appointment #<%= invoiceData.getAppointmentId() %></p>
        </div>
        <div class="text-right">
            <p class="text-sm text-slate-500 dark:text-slate-400">Invoice ID</p>
            <p class="text-lg font-semibold"><%= invoiceData.getInvoiceId() > 0 ? invoiceData.getInvoiceId() : "N/A" %></p>
        </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
        <div class="space-y-2">
            <p><span class="font-semibold">Booking date &amp; time:</span> <%= bookedAt %></p>
            <p><span class="font-semibold">Scheduled appointment:</span> <%= appointmentSlot %></p>
            <p><span class="font-semibold">Check-in date &amp; time:</span> <%= checkInAt %></p>
            <p><span class="font-semibold">Pet name:</span> <%= invoiceData.getPetName() != null ? invoiceData.getPetName() : "N/A" %></p>
            <p><span class="font-semibold">Species:</span> <%= invoiceData.getPetSpecies() != null ? invoiceData.getPetSpecies() : "N/A" %></p>
        </div>
        <div class="space-y-2">
            <p><span class="font-semibold">Customer phone:</span> <%= invoiceData.getCustomerPhone() != null ? invoiceData.getCustomerPhone() : "N/A" %></p>
            <p><span class="font-semibold">Customer email:</span> <%= invoiceData.getCustomerEmail() != null ? invoiceData.getCustomerEmail() : "N/A" %></p>
            <p><span class="font-semibold">Veterinarian:</span> <%= invoiceData.getVeterinarianName() != null ? invoiceData.getVeterinarianName() : "N/A" %></p>
            <p><span class="font-semibold">Paying receptionist:</span> <%= invoiceData.getReceptionistName() != null ? invoiceData.getReceptionistName() : "N/A" %></p>
        </div>
    </div>

    <div class="mt-8">
        <h2 class="text-lg font-semibold mb-3">Services</h2>
        <div class="overflow-hidden rounded-xl border border-slate-200 dark:border-slate-700">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 dark:bg-slate-800/80">
                <tr>
                    <th class="text-left px-4 py-3">Service</th>
                    <th class="text-center px-4 py-3">Qty</th>
                    <th class="text-right px-4 py-3">Unit price</th>
                    <th class="text-right px-4 py-3">Line total</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (invoiceData.getServiceLines().isEmpty()) {
                %>
                <tr>
                    <td colspan="4" class="px-4 py-4 text-center text-slate-500">No services recorded.</td>
                </tr>
                <%
                    } else {
                        for (InvoiceDAO.InvoiceLine line : invoiceData.getServiceLines()) {
                %>
                <tr class="border-t border-slate-100 dark:border-slate-700">
                    <td class="px-4 py-3"><%= line.getServiceName() != null ? line.getServiceName() : "N/A" %></td>
                    <td class="px-4 py-3 text-center">x<%= line.getQuantity() %></td>
                    <td class="px-4 py-3 text-right">$<%= String.format("%.2f", line.getUnitPrice()) %></td>
                    <td class="px-4 py-3 text-right">$<%= String.format("%.2f", line.getLineTotal()) %></td>
                </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-6 flex justify-end">
        <div class="w-full max-w-xs border border-slate-200 dark:border-slate-700 rounded-xl p-4 bg-slate-50 dark:bg-slate-800/50">
            <div class="flex items-center justify-between text-base font-semibold">
                <span>Total Amount</span>
                <span>$<%= String.format("%.2f", invoiceData.getTotalAmount()) %></span>
            </div>
        </div>
    </div>
</div>
