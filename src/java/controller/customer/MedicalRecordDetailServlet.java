package controller.customer;

import dao.CustomerDAO;
import dao.LabTestRequestDAO;
import dao.MedicalRecordDAO;
import dao.VetMedicalRecordDAO;
import dao.impl.CustomerJdbcDAO;
import dao.impl.MedicalRecordJdbcDAO;
import model.LabTestRequest;
import model.Customer;
import model.MedicalRecord;
import model.Prescription;
import model.RecordServiceLine;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Servlet for viewing medical record details.
 */
@WebServlet("/customer/medical-record-detail")
public class MedicalRecordDetailServlet extends HttpServlet {

    private MedicalRecordDAO medicalRecordDAO;
    private CustomerDAO customerDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        medicalRecordDAO = new MedicalRecordJdbcDAO();
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
        
        // Get record ID parameter
        String recordIdParam = request.getParameter("id");
        if (recordIdParam == null || recordIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/medical-history");
            return;
        }
        
        try {
            int recordId = Integer.parseInt(recordIdParam);
            
                // Get medical record with ownership check
                Optional<MedicalRecord> recordOpt = medicalRecordDAO.getMedicalRecordByIdAndCustomer(
                    recordId, customer.getCustomerId());
            if (recordOpt.isEmpty()) {
                request.setAttribute("error", "Medical record not found.");
                request.getRequestDispatcher("/WEB-INF/views/customer/medical-history.jsp")
                        .forward(request, response);
                return;
            }
            
            MedicalRecord record = recordOpt.get();

            VetMedicalRecordDAO vetMedicalRecordDAO = new VetMedicalRecordDAO();
            List<Prescription> prescriptions = vetMedicalRecordDAO.getPrescriptionsByRecordId(record.getRecordId());
            List<RecordServiceLine> services = vetMedicalRecordDAO.getServicesForRecord(record.getRecordId());

            LabTestRequestDAO labTestRequestDAO = new LabTestRequestDAO();
            List<LabTestRequest> labRequests = labTestRequestDAO.getByVisitId(record.getVisitId());

            double totalAmount = 0.0;
            for (RecordServiceLine line : services) {
                if (line.getPrice() != null && line.getQuantity() > 0) {
                    totalAmount += line.getPrice() * line.getQuantity();
                }
            }
            
            // Set attributes for JSP
            request.setAttribute("user", user);
            request.setAttribute("medicalRecord", record);
            request.setAttribute("labRequests", labRequests);
            request.setAttribute("prescriptions", prescriptions);
            request.setAttribute("services", services);
            request.setAttribute("totalAmount", totalAmount);
            request.setAttribute("customerCurrentPage", "medical-history");

            // Forward to detail JSP
            request.getRequestDispatcher("/WEB-INF/views/customer/medical-record-detail.jsp")
                    .forward(request, response);
                    
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/medical-history");
        }
    }
}
