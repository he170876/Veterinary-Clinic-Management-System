/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.receptionist;

import dao.AppointmentDAO;
import dao.NotificationDAO;
import dao.ServiceDAO;
import dao.impl.ServiceJdbcDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import model.Appointment;
import model.User;


/**
 *
 * @author admin
 */
@WebServlet("/Receptionist/ViewListAppointment")
public class ViewListAppointmentServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ViewListAppointmentServlet</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ViewListAppointmentServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        AppointmentDAO dao = new AppointmentDAO();
        String statusFilter = request.getParameter("status");
        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");

        // Handle date range filter (default: current week Monday-Sunday)
        DateTimeFormatter paramFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate today = LocalDate.now();
        LocalDate fromDate = null;
        LocalDate toDate = null;

        try {
            if (fromDateParam != null && !fromDateParam.isEmpty()) {
                fromDate = LocalDate.parse(fromDateParam, paramFormatter);
            }
            if (toDateParam != null && !toDateParam.isEmpty()) {
                toDate = LocalDate.parse(toDateParam, paramFormatter);
            }
        } catch (Exception e) {
            // If parsing fails, we'll fall back to current week below
            fromDate = null;
            toDate = null;
        }

        // Default to today -> today + 6 days if no valid range provided
        if (fromDate == null && toDate == null) {
            fromDate = today;
            toDate = today.plusDays(6);
        }

        // Normalize if only one bound is provided
        if (fromDate == null && toDate != null) {
            fromDate = toDate.minusWeeks(1);
        } else if (fromDate != null && toDate == null) {
            toDate = fromDate.plusWeeks(1);
        }

        // Copies used inside lambdas must be effectively final
        final LocalDate rangeStart = fromDate;
        final LocalDate rangeEnd = toDate;
        
        List<Appointment> allAppointments = dao.getAllAppointments();

        // Apply date range filter
        List<Appointment> dateFiltered = allAppointments.stream()
                .filter(a -> a.getAppointmentTime() != null)
                .filter(a -> {
                    LocalDate d = a.getAppointmentTime().toLocalDate();
                    if (rangeStart != null && d.isBefore(rangeStart)) return false;
                    if (rangeEnd != null && d.isAfter(rangeEnd)) return false;
                    return true;
                })
                .collect(java.util.stream.Collectors.toList());

        List<Appointment> list = new java.util.ArrayList<>(dateFiltered);
        
        // Filter by status if provided (within the selected date range)
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
            list = dateFiltered.stream()
                    .filter(a -> {
                        String status = a.getStatus();
                        if (status == null) return false;

                        // Map filter to actual database statuses
                        switch (statusFilter) {
                            case "Pending":
                                return "Scheduled".equalsIgnoreCase(status)
                                        || "Pending".equalsIgnoreCase(status)
                                        || "Reschedule-Requested".equalsIgnoreCase(status);
                            case "Confirmed":
                                return "Confirmed".equalsIgnoreCase(status);
                            case "Checked-in":
                                return "Checked-in".equalsIgnoreCase(status);
                            case "In-Examination":
                                return "In-Examination".equalsIgnoreCase(status) || "In Progress".equalsIgnoreCase(status);
                            case "Done":
                            case "Completed":
                                return "Completed".equalsIgnoreCase(status) || "Done".equalsIgnoreCase(status);
                            case "Waiting-for-Payment":
                                return "Waiting-for-Payment".equalsIgnoreCase(status) || "Waiting for Payment".equalsIgnoreCase(status);
                            case "Canceled":
                                return "Canceled".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status);
                            default:
                                return statusFilter.equalsIgnoreCase(status);
                        }
                    })
                    .collect(java.util.stream.Collectors.toList());
        }

        // Sort by appointment time (upcoming first) when viewing "All" or no specific filter
        if (statusFilter == null || statusFilter.isEmpty() || "All".equalsIgnoreCase(statusFilter)) {
            list.sort(java.util.Comparator.comparing(Appointment::getAppointmentTime));
        }

        // Count by status (within the selected date range)
        int totalCount = dateFiltered.size();
        int pendingCount = (int) dateFiltered.stream()
            .filter(a -> a.getStatus() != null
                && ("Scheduled".equalsIgnoreCase(a.getStatus())
                || "Pending".equalsIgnoreCase(a.getStatus())
                || "Reschedule-Requested".equalsIgnoreCase(a.getStatus())))
                .count();
        int confirmedCount = (int) dateFiltered.stream()
                .filter(a -> a.getStatus() != null && "Confirmed".equalsIgnoreCase(a.getStatus()))
                .count();
        int checkedInCount = (int) dateFiltered.stream()
                .filter(a -> a.getStatus() != null && "Checked-in".equalsIgnoreCase(a.getStatus()))
                .count();
        int inExaminationCount = (int) dateFiltered.stream()
                .filter(a -> a.getStatus() != null && ("In-Examination".equalsIgnoreCase(a.getStatus()) || "In Progress".equalsIgnoreCase(a.getStatus())))
                .count();
        int doneCount = (int) dateFiltered.stream()
                .filter(a -> a.getStatus() != null && ("Completed".equalsIgnoreCase(a.getStatus()) || "Done".equalsIgnoreCase(a.getStatus())))
                .count();
        int waitingForPaymentCount = (int) dateFiltered.stream()
                .filter(a -> a.getStatus() != null && ("Waiting-for-Payment".equalsIgnoreCase(a.getStatus()) || "Waiting for Payment".equalsIgnoreCase(a.getStatus())))
                .count();
        int canceledCount = (int) dateFiltered.stream()
                .filter(a -> a.getStatus() != null && ("Canceled".equalsIgnoreCase(a.getStatus()) || "Cancelled".equalsIgnoreCase(a.getStatus())))
                .count();
        
        // Pagination: 4 appointments per page
        int pageSize = 4;
        int totalFiltered = list.size();
        int totalPages = (int) Math.ceil((double) totalFiltered / pageSize);
        if (totalPages == 0) totalPages = 1;
        
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        
        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalFiltered);
        List<Appointment> paginatedList = list.subList(fromIndex, toIndex);

        // Prepare date values for view
        String fromDateValue = fromDate != null ? fromDate.format(paramFormatter) : "";
        String toDateValue = toDate != null ? toDate.format(paramFormatter) : "";
        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("MMMM dd, yyyy");
        String displayDateRange;
        if (fromDate != null && toDate != null) {
            if (fromDate.equals(toDate)) {
                displayDateRange = fromDate.format(displayFormatter);
            } else {
                displayDateRange = fromDate.format(displayFormatter) + " - " + toDate.format(displayFormatter);
            }
        } else {
            displayDateRange = "All time";
        }
        
        // Load all veterinarians for the dropdown
        List<User> veterinarians = dao.getAllVeterinarians();

        // Notifications for receptionist user (if logged in)
        NotificationDAO ndao = new NotificationDAO();
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session != null) {
            Object currentUserObj = session.getAttribute("currentUser");
            if (currentUserObj instanceof User) {
                User currentUser = (User) currentUserObj;
                request.setAttribute("notifications", ndao.getRecentForUser(currentUser.getUserId(), 10));
                request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
            }
        }
        
        request.setAttribute("list", paginatedList);
        request.setAttribute("veterinarians", veterinarians);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalFiltered", totalFiltered);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "All");
        request.setAttribute("fromDate", fromDateValue);
        request.setAttribute("toDate", toDateValue);
        request.setAttribute("displayDateRange", displayDateRange);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("confirmedCount", confirmedCount);
        request.setAttribute("checkedInCount", checkedInCount);
        request.setAttribute("inExaminationCount", inExaminationCount);
        request.setAttribute("doneCount", doneCount);
        request.setAttribute("waitingForPaymentCount", waitingForPaymentCount);
        request.setAttribute("canceledCount", canceledCount);
        ServiceDAO serviceDAO = new ServiceJdbcDAO();
        request.setAttribute("services", serviceDAO.findAll());
        
        request.getRequestDispatcher("/WEB-INF/views/Receptionist/ViewListAppointment.jsp")
                .forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
