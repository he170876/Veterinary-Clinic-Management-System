package controller.appointment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.DBContext;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import utils.ValidationUtil;

/**
 * Handles POST from the landing-page booking form (guest appointment requests).
 * Saves to AppointmentRequests and redirects back to index with success or error.
 */
@WebServlet(name = "BookAppointmentServlet", urlPatterns = {"/book"})
public class BookAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());

        String ownerName = trim(request.getParameter("ownerName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String service = trim(request.getParameter("service"));
        String petName = trim(request.getParameter("petName"));
        String petType = trim(request.getParameter("petType"));
        String appointmentDate = trim(request.getParameter("appointmentDate"));
        String appointmentTime = trim(request.getParameter("appointmentTime"));
        String notes = trim(request.getParameter("notes"));

        String ctx = request.getContextPath();
        String redirect = ctx + "/index.jsp";

        if (ownerName == null || ownerName.isEmpty() || email == null || email.isEmpty()
                || phone == null || phone.isEmpty() || service == null || service.isEmpty()
                || petName == null || petName.isEmpty() || petType == null || petType.isEmpty()
                || appointmentDate == null || appointmentDate.isEmpty()
                || appointmentTime == null || appointmentTime.isEmpty()) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Please fill in all required fields.", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidOwnerOrPetName(ownerName)) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Owner name must be 1-100 letters and spaces only.", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidEmailFormat(email)) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Please enter a valid email address.", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidPhone(phone)) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Phone must be 10 digits starting with 0 (e.g. 0123456789).", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isValidOwnerOrPetName(petName)) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Pet name must be 1-100 letters and spaces only.", StandardCharsets.UTF_8));
            return;
        }
        if (!ValidationUtil.isDateNotInPast(appointmentDate)) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Preferred date cannot be in the past.", StandardCharsets.UTF_8));
            return;
        }
        if (notes != null && notes.length() > ValidationUtil.NOTES_MAX_LENGTH) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Notes must be at most " + ValidationUtil.NOTES_MAX_LENGTH + " characters.", StandardCharsets.UTF_8));
            return;
        }

        Date preferredDate;
        try {
            preferredDate = Date.valueOf(appointmentDate);
        } catch (IllegalArgumentException e) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Invalid date format.", StandardCharsets.UTF_8));
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            String sql = "INSERT INTO AppointmentRequests (owner_name, email, phone, service, pet_name, pet_type, preferred_date, preferred_time, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, ownerName);
                ps.setString(2, email);
                ps.setString(3, phone);
                ps.setString(4, service);
                ps.setString(5, petName);
                ps.setString(6, petType);
                ps.setDate(7, preferredDate);
                ps.setString(8, appointmentTime);
                ps.setString(9, notes == null ? "" : notes);
                ps.executeUpdate();
            }
            response.sendRedirect(redirect + "?booked=1");
        } catch (SQLException e) {
            String msg = "Booking could not be saved. Please try again or contact us.";
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode(msg, StandardCharsets.UTF_8));
        }
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }
}
