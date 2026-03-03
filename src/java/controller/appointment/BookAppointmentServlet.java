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
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;

import org.mindrot.jbcrypt.BCrypt;
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
        String serviceIdStr = trim(request.getParameter("serviceId"));
        String petName = trim(request.getParameter("petName"));
        String petType = trim(request.getParameter("petType"));
        String appointmentDate = trim(request.getParameter("appointmentDate"));
        String appointmentTime = trim(request.getParameter("appointmentTime"));
        String notes = trim(request.getParameter("notes"));

        String ctx = request.getContextPath();
        String redirect = ctx + "/index.jsp";

        if (ownerName == null || ownerName.isEmpty() || email == null || email.isEmpty()
                || phone == null || phone.isEmpty() || serviceIdStr == null || serviceIdStr.isEmpty()
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

        int serviceId;
        LocalDateTime preferredDateTime;
        try {
            serviceId = Integer.parseInt(serviceIdStr);
            // Combine date and time from form into a single LocalDateTime object
            preferredDateTime = LocalDateTime.parse(appointmentDate + "T" + appointmentTime);
            if (serviceId <= 0) {
                throw new IllegalArgumentException("Invalid service selected.");
            }
        } catch (IllegalArgumentException | DateTimeParseException e) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Invalid data format for date or service.", StandardCharsets.UTF_8));
            return;
        }

        Connection conn = null;
        boolean newUserCreated = false; // Flag to track new user creation
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Step 1: Find or Create User and Customer
            Integer userId = null;
            Integer customerId = null;

            // Check if user exists by email
            try (PreparedStatement psFindUser = conn.prepareStatement("SELECT user_id FROM dbo.Users WHERE email = ?")) {
                psFindUser.setString(1, email);
                try (ResultSet rs = psFindUser.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                    }
                }
            }

            // If user does not exist, create them
            if (userId == null) {
                newUserCreated = true; // Set the flag
                String randomPassword = "DefaultPassword123"; // Placeholder password
                String hashedPassword = BCrypt.hashpw(randomPassword, BCrypt.gensalt());

                // Assuming 'Customer' role has role_id = 1
                String sqlCreateUser = "INSERT INTO dbo.Users (full_name, email, phone, password, role_id, status, created_at, updated_at) VALUES (?, ?, ?, ?, 1, 'Active', GETDATE(), GETDATE())";
                try (PreparedStatement psCreateUser = conn.prepareStatement(sqlCreateUser, Statement.RETURN_GENERATED_KEYS)) {
                    psCreateUser.setString(1, ownerName);
                    psCreateUser.setString(2, email);
                    psCreateUser.setString(3, phone);
                    psCreateUser.setString(4, hashedPassword);
                    psCreateUser.executeUpdate();
                    try (ResultSet generatedKeys = psCreateUser.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            userId = generatedKeys.getInt(1);
                        }
                    }
                }
            }

            if (userId == null) throw new SQLException("Failed to find or create user.");

            // Find or create customer linked to the user
            try (PreparedStatement psFindCustomer = conn.prepareStatement("SELECT customer_id FROM dbo.Customers WHERE user_id = ?")) {
                psFindCustomer.setInt(1, userId);
                try (ResultSet rs = psFindCustomer.executeQuery()) {
                    if (rs.next()) {
                        customerId = rs.getInt("customer_id");
                    }
                }
            }

            if (customerId == null) {
                String sqlCreateCustomer = "INSERT INTO dbo.Customers (user_id) VALUES (?)";
                try (PreparedStatement psCreateCustomer = conn.prepareStatement(sqlCreateCustomer, Statement.RETURN_GENERATED_KEYS)) {
                    psCreateCustomer.setInt(1, userId);
                    psCreateCustomer.executeUpdate();
                    try (ResultSet generatedKeys = psCreateCustomer.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            customerId = generatedKeys.getInt(1);
                        }
                    }
                }
            }

            if (customerId == null) throw new SQLException("Failed to find or create customer.");

            // Step 2: Find or Create Pet
            Integer petId = null;
            // Assuming a 'Pets' table exists
            String sqlFindPet = "SELECT pet_id FROM dbo.Pets WHERE name = ? AND customer_id = ?";
            try (PreparedStatement psFindPet = conn.prepareStatement(sqlFindPet)) {
                psFindPet.setString(1, petName);
                psFindPet.setInt(2, customerId);
                try (ResultSet rs = psFindPet.executeQuery()) {
                    if (rs.next()) {
                        petId = rs.getInt("pet_id");
                    }
                }
            }

            if (petId == null) {
                // Assuming 'Pets' table has columns: name, species, customer_id
                String sqlCreatePet = "INSERT INTO dbo.Pets (name, species, customer_id) VALUES (?, ?, ?)";
                try (PreparedStatement psCreatePet = conn.prepareStatement(sqlCreatePet, Statement.RETURN_GENERATED_KEYS)) {
                    psCreatePet.setString(1, petName);
                    psCreatePet.setString(2, petType);
                    psCreatePet.setInt(3, customerId);
                    psCreatePet.executeUpdate();
                    try (ResultSet generatedKeys = psCreatePet.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            petId = generatedKeys.getInt(1);
                        }
                    }
                }
            }

            if (petId == null) throw new SQLException("Failed to find or create pet.");

            // Step 3: Create the Appointment
            // veterinarian_id is left NULL to be assigned by a receptionist.
            // Assuming 'Appointments' table has a 'notes' column.
            String sqlCreateAppointment = "INSERT INTO dbo.Appointments (customer_id, pet_id, service_id, appointment_time, status, created_at, notes) VALUES (?, ?, ?, ?, 'Pending', GETDATE(), ?)";
            try (PreparedStatement psCreateAppt = conn.prepareStatement(sqlCreateAppointment)) {
                psCreateAppt.setInt(1, customerId);
                psCreateAppt.setInt(2, petId);
                psCreateAppt.setInt(3, serviceId);
                psCreateAppt.setTimestamp(4, Timestamp.valueOf(preferredDateTime));
                psCreateAppt.setString(5, notes == null ? "" : notes);

                int rowsAffected = psCreateAppt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Creating appointment failed, no rows affected.");
                }
            }

            conn.commit(); // Commit transaction
            if (newUserCreated) {
                response.sendRedirect(redirect + "?booked=2"); // Special message for new user
            } else {
                response.sendRedirect(redirect + "?booked=1"); // Standard message for existing user
            }

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException ex) {
                    System.err.println("Error during transaction rollback: " + ex.getMessage());
                }
            }
            e.printStackTrace(); // Log the full error to the server console
            String msg = "Booking could not be saved. Please try again or contact us.";
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode(msg, StandardCharsets.UTF_8));
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}
