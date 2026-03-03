package controller.customer;

import dao.CustomerDAO;
import dao.VetMedicalRecordDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.MedicalRecordSummary;
import model.User;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "CustomerMedicalRecordsServlet", urlPatterns = {"/customer/records"})
public class CustomerMedicalRecordsServlet extends HttpServlet {

    private transient CustomerDAO customerDAO;

    @Override
    public void init() throws ServletException {
        this.customerDAO = new dao.impl.CustomerJdbcDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("currentUser");

        Optional<Customer> customerOpt = customerDAO.findByUserId(user.getUserId());
        if (!customerOpt.isPresent()) {
            request.setAttribute("user", user);
            request.setAttribute("records", Collections.emptyList());
            request.setAttribute("customerCurrentPage", "records");
            request.getRequestDispatcher("/WEB-INF/views/customer/records.jsp").forward(request, response);
            return;
        }

        Customer customer = customerOpt.get();
        VetMedicalRecordDAO recordDao = new VetMedicalRecordDAO();
        List<MedicalRecordSummary> records = recordDao.getRecordsForCustomer(customer.getCustomerId());

        request.setAttribute("user", user);
        request.setAttribute("records", records);
        request.setAttribute("customerCurrentPage", "records");
        request.setAttribute("dateFormatter", DateTimeFormatter.ofPattern("MMM dd, yyyy"));
        request.getRequestDispatcher("/WEB-INF/views/customer/records.jsp").forward(request, response);
    }
}

