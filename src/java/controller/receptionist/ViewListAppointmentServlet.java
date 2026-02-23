/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.receptionist;

import dao.AppointmentDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
        
        List<Appointment> allAppointments = dao.getAllAppointments();
        List<Appointment> list = new java.util.ArrayList<>(allAppointments);
        
        // Filter by status if provided
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
            list = allAppointments.stream()
                    .filter(a -> {
                        String status = a.getStatus();
                        if (status == null) return false;
                        
                        // Map filter to actual database statuses
                        switch (statusFilter) {
                            case "Pending":
                                return "Scheduled".equalsIgnoreCase(status) || "Pending".equalsIgnoreCase(status);
                            case "Checked-in":
                                return "Checked-in".equalsIgnoreCase(status) || "Confirmed".equalsIgnoreCase(status);
                            case "In-Examination":
                                return "In-Examination".equalsIgnoreCase(status) || "In Progress".equalsIgnoreCase(status);
                            case "Completed":
                                return "Completed".equalsIgnoreCase(status) || "Done".equalsIgnoreCase(status);
                            case "Canceled":
                                return "Canceled".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status);
                            default:
                                return statusFilter.equalsIgnoreCase(status);
                        }
                    })
                    .collect(java.util.stream.Collectors.toList());
        }
        
        // Count by status
        int totalCount = allAppointments.size();
        int pendingCount = (int) allAppointments.stream()
                .filter(a -> a.getStatus() != null && ("Scheduled".equalsIgnoreCase(a.getStatus()) || "Pending".equalsIgnoreCase(a.getStatus())))
                .count();
        int checkedInCount = (int) allAppointments.stream()
                .filter(a -> a.getStatus() != null && ("Checked-in".equalsIgnoreCase(a.getStatus()) || "Confirmed".equalsIgnoreCase(a.getStatus())))
                .count();
        int inExaminationCount = (int) allAppointments.stream()
                .filter(a -> a.getStatus() != null && ("In-Examination".equalsIgnoreCase(a.getStatus()) || "In Progress".equalsIgnoreCase(a.getStatus())))
                .count();
        int doneCount = (int) allAppointments.stream()
                .filter(a -> a.getStatus() != null && ("Completed".equalsIgnoreCase(a.getStatus()) || "Done".equalsIgnoreCase(a.getStatus())))
                .count();
        int canceledCount = (int) allAppointments.stream()
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
        
        // Load all veterinarians for the dropdown
        List<User> veterinarians = dao.getAllVeterinarians();
        
        request.setAttribute("list", paginatedList);
        request.setAttribute("veterinarians", veterinarians);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalFiltered", totalFiltered);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "All");
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("checkedInCount", checkedInCount);
        request.setAttribute("inExaminationCount", inExaminationCount);
        request.setAttribute("doneCount", doneCount);
        request.setAttribute("canceledCount", canceledCount);
        
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
