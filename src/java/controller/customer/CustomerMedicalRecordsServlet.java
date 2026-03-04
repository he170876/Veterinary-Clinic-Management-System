package controller.customer;

import dao.CustomerDAO;
import dao.MedicalRecordDAO;
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

/**
 * Customer-facing list of completed medical records.
 * <ul>
 *   <li>Map <code>currentUser</code> sang {@link Customer} bằng {@link CustomerDAO#findByUserId(int)}.</li>
 *   <li>Lấy danh sách {@link model.MedicalRecordSummary} bằng
 *       {@link MedicalRecordDAO#getRecordsForCustomer(int)} – chỉ những visit có appointment
 *       trạng thái <code>Done</code> hoặc <code>Completed</code> (tức đã thanh toán/xác nhận).</li>
 *   <li>Đặt <code>customerCurrentPage = "records"</code> để sidebar highlight đúng.</li>
 *   <li>Forward sang <code>customer/records.jsp</code>, nơi khách hàng xem lịch sử khám cho tất cả pets của họ.</li>
 * </ul>
 */
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
        MedicalRecordDAO recordDao = new MedicalRecordDAO();
        List<MedicalRecordSummary> records = recordDao.getRecordsForCustomer(customer.getCustomerId());

        request.setAttribute("user", user);
        request.setAttribute("records", records);
        request.setAttribute("customerCurrentPage", "records");
        request.setAttribute("dateFormatter", DateTimeFormatter.ofPattern("MMM dd, yyyy"));
        request.getRequestDispatcher("/WEB-INF/views/customer/records.jsp").forward(request, response);
    }
}

