/*
 * Receptionist "View List Appointment" page controller.
 *
 * High-level flow (GET):
 * - Read query filters: status, fromDate, toDate, page
 * - Load appointments from AppointmentDAO
 * - Filter by date range, then map UI status tab → DB statuses
 * - Sort chronologically (AM before PM within the same date)
 * - Compute per-status counts for the dashboard cards
 * - Paginate results (fixed page size)
 * - Load supporting dropdown data (veterinarians/services) and notifications
 * - Forward to JSP view for rendering
 *
 * Notes:
 * - This file still contains NetBeans template scaffolding (processRequest/doPost).
 *   The application primarily uses doGet() for this screen.
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
import java.util.ArrayList;
import java.util.List;
import model.Appointment;
import model.Service;
import model.User;


/**
 * Serves receptionist list view at {@code /Receptionist/ViewListAppointment}.
 * This is the main receptionist "appointments table" page.
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
        // Template method from the original IDE-generated servlet.
        // This output is not used in the real UI; the app uses doGet() + JSP forwarding.
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
        // Query filters coming from the UI.
        String statusFilter = request.getParameter("status");
        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");

        // Date range rules:
        // - if both missing: today -> today + 6 days
        // - if only one bound is provided: infer the other as +/- 1 week
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
        
        // Load all appointments (includes customer/pet/vet/service fields, depending on schema).
        // We apply UI filters in-memory for this screen.
        List<Appointment> allAppointments = dao.getAllAppointments();

        // Apply date filter first (so counts match selected range).
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
        
        // Apply status tab filter (UI tab → DB status mapping).
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
                            case "Rejected":
                                return "Rejected".equalsIgnoreCase(status);
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

        // Sort for consistent display:
        // - earliest date first
        // - AM before PM within the same date
        list.sort((a, b) -> {
            if (a == null && b == null) return 0;
            if (a == null) return 1;
            if (b == null) return -1;

            java.time.LocalDateTime ta = a.getAppointmentTime();
            java.time.LocalDateTime tb = b.getAppointmentTime();
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;

            java.time.LocalDate da = ta.toLocalDate();
            java.time.LocalDate db = tb.toLocalDate();
            int byDate = da.compareTo(db);
            if (byDate != 0) return byDate;

            int slotA = "PM".equalsIgnoreCase(a.getTimeSlot()) ? 1 : 0; // AM first
            int slotB = "PM".equalsIgnoreCase(b.getTimeSlot()) ? 1 : 0; // AM first
            int bySlot = Integer.compare(slotA, slotB);
            if (bySlot != 0) return bySlot;

            return ta.compareTo(tb);
        });

        // Counters shown on the page (computed for the selected date range).
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

        int rejectedCount = (int) dateFiltered.stream()
                .filter(a -> a.getStatus() != null && "Rejected".equalsIgnoreCase(a.getStatus()))
                .count();
        
        // Pagination (fixed size keeps the UI layout stable).
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
        
        // Dropdown data used in appointment detail/reschedule actions.
        List<User> veterinarians = dao.getAllVeterinarians();

        // Notifications for receptionist header dropdown.
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
        request.setAttribute("rejectedCount", rejectedCount);
        ServiceDAO serviceDAO = new ServiceJdbcDAO();
        List<Service> generalServices = new ArrayList<>();
        for (Service s : serviceDAO.findAll()) {
            String cat = s != null && s.getCategory() != null ? s.getCategory().trim().toLowerCase() : "";
            if ("general".equals(cat)) {
                generalServices.add(s);
            }
        }
        request.setAttribute("services", generalServices);
        
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
