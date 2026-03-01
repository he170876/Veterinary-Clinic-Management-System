package controller.customer;

import dao.CustomerDAO;
import dao.MedicalRecordDAO;
import dao.PetDAO;
import dao.impl.CustomerJdbcDAO;
import dao.impl.MedicalRecordJdbcDAO;
import dao.impl.PetJdbcDAO;
import model.Customer;
import model.MedicalRecord;
import model.Pet;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

/**
 * Servlet for handling medical history view requests.
 * Supports viewing medical history for specific pets or all customer pets.
 */
@WebServlet("/customer/medical-history")
public class MedicalHistoryServlet extends HttpServlet {

    private MedicalRecordDAO medicalRecordDAO;
    private PetDAO petDAO;
    private CustomerDAO customerDAO;
    private static final int RECORDS_PER_PAGE = 10;

    @Override
    public void init() throws ServletException {
        super.init();
        medicalRecordDAO = new MedicalRecordJdbcDAO();
        petDAO = new PetJdbcDAO();
        customerDAO = new CustomerJdbcDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        
        // Verify user is a customer
        if (!"Customer".equals(user.getRole().getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }

        // Get customer ID from user
        Optional<Customer> customerOpt = customerDAO.findByUserId(user.getUserId());
        if (customerOpt.isEmpty()) {
            request.setAttribute("error", "Customer profile not found.");
            request.getRequestDispatcher("/WEB-INF/views/customer/medical-history.jsp")
                    .forward(request, response);
            return;
        }
        Customer customer = customerOpt.get();
        
        // Get filter parameters
        String petIdParam = request.getParameter("petId");
        String startDateParam = request.getParameter("startDate");
        String endDateParam = request.getParameter("endDate");
        String pageParam = request.getParameter("page");
        
        Integer petId = null;
        LocalDateTime startDate = null;
        LocalDateTime endDate = null;
        int currentPage = 1;
        
        // Parse pet ID
        if (petIdParam != null && !petIdParam.isEmpty()) {
            try {
                petId = Integer.parseInt(petIdParam);
            } catch (NumberFormatException e) {
                // Ignore invalid pet ID
            }
        }
        
        // Parse dates
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        try {
            if (startDateParam != null && !startDateParam.isEmpty()) {
                startDate = LocalDateTime.parse(startDateParam + "T00:00:00");
            }
            if (endDateParam != null && !endDateParam.isEmpty()) {
                endDate = LocalDateTime.parse(endDateParam + "T23:59:59");
            }
        } catch (Exception e) {
            System.err.println("[MedicalHistoryServlet] Date parse error: " + e.getMessage());
        }
        
        // Parse page number
        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) currentPage = 1;
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
        
        // Calculate pagination
        int offset = (currentPage - 1) * RECORDS_PER_PAGE;
        
        // Get medical records with filters
        List<MedicalRecord> medicalRecords = medicalRecordDAO.getMedicalRecordsWithFilter(
                customer.getCustomerId(), petId, startDate, endDate, offset, RECORDS_PER_PAGE);
        
        // Get total count for pagination
        int totalRecords = medicalRecordDAO.countMedicalRecordsWithFilter(
                customer.getCustomerId(), petId, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        // Get all customer's pets for the pet selector
        List<Pet> customerPets = petDAO.findByCustomerId(customer.getCustomerId());
        
        // Get selected pet details if filtering by pet
        Pet selectedPet = null;
        if (petId != null) {
            Optional<Pet> petOpt = petDAO.findById(petId);
            if (petOpt.isPresent()) {
                selectedPet = petOpt.get();
            }
        }

        // Set attributes for JSP
        request.setAttribute("user", user);
        request.setAttribute("selectedPet", selectedPet);
        request.setAttribute("medicalRecords", medicalRecords != null ? medicalRecords : new java.util.ArrayList<>());
        request.setAttribute("customerPets", customerPets);
        request.setAttribute("customerCurrentPage", "medical-history");
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("startDate", startDateParam);
        request.setAttribute("endDate", endDateParam);
        request.setAttribute("selectedPetId", petId);

        // Forward to JSP
        request.getRequestDispatcher("/WEB-INF/views/customer/medical-history.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Medical history viewing doesn't require POST, redirect to GET
        doGet(request, response);
    }
}
