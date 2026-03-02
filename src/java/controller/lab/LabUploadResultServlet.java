package controller.lab;

import dao.LabTestRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * POST: Submit lab result for a request. Saves to LabTestResults and sets request status to Completed.
 */
@WebServlet(name = "LabUploadResultServlet", urlPatterns = {"/lab/result"})
public class LabUploadResultServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String requestIdParam = request.getParameter("requestId");
        if (requestIdParam == null || requestIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/lab/dashboard");
            return;
        }

        int requestId;
        try {
            requestId = Integer.parseInt(requestIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/lab/dashboard");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        LabTestRequestDAO dao = new LabTestRequestDAO();
        int labStaffId = dao.getLabStaffIdByUserId(user.getUserId());
        if (labStaffId <= 0) {
            response.sendRedirect(request.getContextPath() + "/lab/dashboard");
            return;
        }

        String resultValue = request.getParameter("resultValue");
        String resultNote = request.getParameter("resultNote");
        String techNotes = request.getParameter("techNotes");
        if (resultValue == null) resultValue = "";
        if (resultNote == null) resultNote = "";
        if (techNotes != null && !techNotes.isEmpty()) {
            resultNote = resultNote.isEmpty() ? techNotes : resultNote + "\n[Tech notes] " + techNotes;
        }

        dao.saveResult(requestId, resultValue, resultNote, labStaffId);
        response.sendRedirect(request.getContextPath() + "/lab/dashboard");
    }
}
