<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.InvoiceDAO" %>
<%
    InvoiceDAO.AppointmentInvoiceView invoiceData = (InvoiceDAO.AppointmentInvoiceView) request.getAttribute("invoiceData");
    if (invoiceData == null) {
        response.sendRedirect(request.getContextPath() + "/Receptionist/ViewListAppointment");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Invoice #<%= invoiceData.getInvoiceId() > 0 ? invoiceData.getInvoiceId() : invoiceData.getAppointmentId() %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @media print {
            .no-print { display: none !important; }
            body { background: #fff !important; }
        }
    </style>
</head>
<body class="bg-slate-100 text-slate-800">
<div class="max-w-5xl mx-auto p-6">
    <div class="no-print mb-4 flex gap-2">
        <a href="<%= request.getContextPath() %>/Receptionist/ViewListAppointment"
           class="px-4 py-2 rounded-lg border border-slate-300 bg-white hover:bg-slate-50">Back</a>
        <button type="button" onclick="window.print()"
                class="px-4 py-2 rounded-lg bg-primary text-white hover:opacity-90"
                style="background:#ff7b00;">Print</button>
    </div>

    <jsp:include page="invoice-inner.jsp"/>
</div>
</body>
</html>
