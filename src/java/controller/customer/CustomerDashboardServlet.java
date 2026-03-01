package controller.customer;

import dao.CustomerDAO;
import dao.MedicalRecordDAO;
import dao.impl.CustomerJdbcDAO;
import dao.impl.MedicalRecordJdbcDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.MedicalRecord;
import model.User;
import service.PetService;
import service.impl.PetServiceImpl;

/**
 * Servlet for customer dashboard.
 */
@WebServlet(name = "CustomerDashboardServlet", urlPatterns = {"/customer/dashboard"})
public class CustomerDashboardServlet extends HttpServlet {

    private transient CustomerDAO customerDAO;
    private transient PetService petService;
    private transient MedicalRecordDAO medicalRecordDAO;

    @Override
    public void init() throws ServletException {
        customerDAO = new CustomerJdbcDAO();
        petService = new PetServiceImpl();
        medicalRecordDAO = new MedicalRecordJdbcDAO();
    }

    private Optional<Customer> resolveCurrentCustomer(User user) {
        if (user == null) {
            return Optional.empty();
        }

        Optional<Customer> customerOpt = customerDAO.findByUserId(user.getUserId());
        if (customerOpt.isPresent()) {
            return customerOpt;
        }

        try {
            Customer newCustomer = new Customer();
            newCustomer.setUser(user);
            customerDAO.create(newCustomer);
            return customerDAO.findByUserId(user.getUserId());
        } catch (Exception ex) {
            return Optional.empty();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        String ctx = request.getContextPath();

        // Force customer to add phone if missing (e.g. Google account)
        if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
            session.setAttribute("pendingPhoneRequired", Boolean.TRUE);
            response.sendRedirect(ctx + "/customer/edit-profile?required=phone");
            return;
        }

        int petCount = 0;
        Optional<Customer> customerOpt = resolveCurrentCustomer(user);
        if (customerOpt.isPresent()) {
            petCount = petService.getPetsByCustomerId(customerOpt.get().getCustomerId()).size();
        }

        // Get recent medical records (limit to 4)
        List<MedicalRecord> recentMedicalRecords = new ArrayList<>();
        if (customerOpt.isPresent()) {
            recentMedicalRecords = medicalRecordDAO.getRecentMedicalHistoryByCustomer(
                customerOpt.get().getCustomerId(), 4);
        }

        request.setAttribute("user", user);
        request.setAttribute("petCount", petCount);
        request.setAttribute("recentMedicalRecords", recentMedicalRecords);
        request.getRequestDispatcher("/WEB-INF/views/customer/dashboard.jsp").forward(request, response);
    }
}
