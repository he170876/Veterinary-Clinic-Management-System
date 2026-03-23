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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
        String[] serviceIdValues = request.getParameterValues("serviceIds");
        String petName = trim(request.getParameter("petName"));
        String petType = trim(request.getParameter("petType"));
        String appointmentDate = trim(request.getParameter("appointmentDate"));
        String timeSlotRaw = trim(request.getParameter("timeSlot"));
        String notes = trim(request.getParameter("notes"));

        String ctx = request.getContextPath();
        String redirect = ctx + "/index.jsp";

        // DEBUG: print all inbound fields so we can identify what is missing.
        System.out.println("[BOOK_DEBUG] ownerName='" + ownerName + "', email='" + email + "', phone='" + phone
                + "', petName='" + petName + "', petType='" + petType + "', appointmentDate='" + appointmentDate
                + "', timeSlotRaw='" + timeSlotRaw + "', notesLen=" + (notes == null ? 0 : notes.length()));
        if (serviceIdValues == null) {
            System.out.println("[BOOK_DEBUG] serviceIds is null");
        } else {
            System.out.println("[BOOK_DEBUG] serviceIds count=" + serviceIdValues.length + ", values=" + String.join(",", serviceIdValues));
        }

        List<String> missingFields = new ArrayList<>();
        if (isBlank(ownerName)) missingFields.add("ownerName");
        if (isBlank(email)) missingFields.add("email");
        if (isBlank(phone)) missingFields.add("phone");
        if (isBlank(petName)) missingFields.add("petName");
        if (isBlank(petType)) missingFields.add("petType");
        if (isBlank(appointmentDate)) missingFields.add("appointmentDate");
        if (isBlank(timeSlotRaw)) missingFields.add("timeSlot");

        if (!missingFields.isEmpty()) {
            System.out.println("[BOOK_DEBUG] Missing required fields: " + String.join(",", missingFields));
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Please fill in all required fields. Missing: " + String.join(", ", missingFields), StandardCharsets.UTF_8));
            return;
        }

        if (serviceIdValues == null || serviceIdValues.length == 0) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                + URLEncoder.encode("Please select at least one service.", StandardCharsets.UTF_8));
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

        String normalizedTimeSlot = normalizeTimeSlot(timeSlotRaw);
        if (normalizedTimeSlot == null) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Please choose a valid booking slot (Morning or Afternoon).", StandardCharsets.UTF_8));
            return;
        }

        List<Integer> serviceIds = new ArrayList<>();
        LocalDate preferredDate;
        try {
            preferredDate = LocalDate.parse(appointmentDate);
            for (String rawServiceId : serviceIdValues) {
                int parsed = Integer.parseInt(trim(rawServiceId));
                if (parsed <= 0) {
                    throw new IllegalArgumentException("Invalid service selected.");
                }
                if (!serviceIds.contains(parsed)) {
                    serviceIds.add(parsed);
                }
            }
            if (serviceIds.isEmpty()) {
                throw new IllegalArgumentException("Invalid service selected.");
            }
        } catch (Exception e) {
            response.sendRedirect(redirect + "?bookError=1&bookMessage="
                    + URLEncoder.encode("Invalid data format for date, slot or service.", StandardCharsets.UTF_8));
            return;
        }

                if (!ValidationUtil.isBookableDateSlot(preferredDate, normalizedTimeSlot)) {
                    response.sendRedirect(redirect + "?bookError=1&bookMessage="
                        + URLEncoder.encode("Selected time slot has passed. Please choose a different slot or date.", StandardCharsets.UTF_8));
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

            // Step 3: Create appointment using whichever schema exists in this environment.
            Set<String> appointmentColumns = getAppointmentsTableColumns(conn);
            boolean hasAppointmentTime = appointmentColumns.contains("appointment_time");
            boolean hasAppointmentDate = appointmentColumns.contains("appointment_date");
            boolean hasTimeSlotColumn = appointmentColumns.contains("time_slot");
            boolean hasServiceId = appointmentColumns.contains("service_id");
            boolean hasAppointmentServiceTable = hasAppointmentServiceTable(conn);
            boolean hasNotes = appointmentColumns.contains("notes");
            boolean hasPhone = appointmentColumns.contains("phone");
            boolean hasVeterinarianId = appointmentColumns.contains("veterinarian_id");
            boolean hasCreatedAt = appointmentColumns.contains("created_at");

            if (!hasAppointmentTime && !hasAppointmentDate) {
                throw new SQLException("Appointments table is missing appointment date/time columns.");
            }

            if (!hasAppointmentTime && hasAppointmentDate && !hasTimeSlotColumn) {
                throw new SQLException("Appointments table is missing time_slot column for slot booking.");
            }

            StringBuilder columnSql = new StringBuilder("customer_id, pet_id");
            StringBuilder valueSql = new StringBuilder("?, ?");

            if (hasVeterinarianId) {
                columnSql.append(", veterinarian_id");
                valueSql.append(", NULL");
            }

            if (hasServiceId) {
                columnSql.append(", service_id");
                valueSql.append(", ?");
            }

            if (hasAppointmentTime) {
                columnSql.append(", appointment_time");
                valueSql.append(", ?");
            } else {
                columnSql.append(", appointment_date");
                valueSql.append(", ?");
                if (hasTimeSlotColumn) {
                    columnSql.append(", time_slot");
                    valueSql.append(", ?");
                }
            }

            columnSql.append(", status");
            valueSql.append(", ?");

            if (hasCreatedAt) {
                columnSql.append(", created_at");
                valueSql.append(", GETDATE()");
            }

            if (hasNotes) {
                columnSql.append(", notes");
                valueSql.append(", ?");
            }

            if (hasPhone) {
                columnSql.append(", phone");
                valueSql.append(", ?");
            }

            String sqlCreateAppointment = "INSERT INTO dbo.Appointments (" + columnSql + ") VALUES (" + valueSql + ")";
            Integer appointmentId = null;
            try (PreparedStatement psCreateAppt = conn.prepareStatement(sqlCreateAppointment, Statement.RETURN_GENERATED_KEYS)) {
                int index = 1;
                psCreateAppt.setInt(index++, customerId);
                psCreateAppt.setInt(index++, petId);

                if (hasServiceId) {
                    psCreateAppt.setInt(index++, serviceIds.get(0));
                }

                if (hasAppointmentTime) {
                    psCreateAppt.setTimestamp(index++, Timestamp.valueOf(toSlotDateTime(preferredDate, normalizedTimeSlot)));
                } else {
                    psCreateAppt.setDate(index++, java.sql.Date.valueOf(preferredDate));
                    if (hasTimeSlotColumn) {
                        psCreateAppt.setString(index++, normalizedTimeSlot);
                    }
                }

                psCreateAppt.setString(index++, "Pending");

                if (hasNotes) {
                    psCreateAppt.setString(index++, notes == null ? "" : notes);
                }

                if (hasPhone) {
                    psCreateAppt.setString(index++, phone);
                }

                int rowsAffected = psCreateAppt.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Creating appointment failed, no rows affected.");
                }

                try (ResultSet generatedKeys = psCreateAppt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        appointmentId = generatedKeys.getInt(1);
                    }
                }
            }

            if (appointmentId == null) {
                throw new SQLException("Could not get appointment id after insert.");
            }

            if (hasAppointmentServiceTable) {
                for (Integer serviceId : serviceIds) {
                    if (serviceId == null || serviceId <= 0) {
                        continue;
                    }
                    upsertAppointmentService(conn, appointmentId, serviceId);
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

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String normalizeTimeSlot(String value) {
        if (value == null) {
            return null;
        }
        String normalized = value.trim().toLowerCase();
        if ("morning".equals(normalized) || "am".equals(normalized)) {
            return "AM";
        }
        if ("afternoon".equals(normalized) || "pm".equals(normalized)) {
            return "PM";
        }
        return null;
    }

    private LocalDateTime toSlotDateTime(LocalDate date, String normalizedTimeSlot) {
        int hour = "PM".equalsIgnoreCase(normalizedTimeSlot) ? 14 : 8;
        return date.atTime(hour, 0);
    }

    private Set<String> getAppointmentsTableColumns(Connection con) {
        Set<String> columns = new HashSet<>();
        String probeSql = "SELECT TOP 0 * FROM dbo.Appointments";
        try (PreparedStatement ps = con.prepareStatement(probeSql);
             ResultSet rs = ps.executeQuery()) {
            ResultSetMetaData meta = rs.getMetaData();
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                String column = meta.getColumnName(i);
                if (column != null) {
                    columns.add(column.trim().toLowerCase());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return columns;
    }

    private boolean hasAppointmentServiceTable(Connection con) {
        String sql = "SELECT 1 FROM sys.tables WHERE name = 'appointment_service'";
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private void upsertAppointmentService(Connection con, int appointmentId, int serviceId) throws SQLException {
        String sql = """
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.appointment_service
                WHERE appointment_id = ? AND service_id = ?
            )
            BEGIN
                INSERT INTO dbo.appointment_service (appointment_id, service_id)
                VALUES (?, ?)
            END
            """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, serviceId);
            ps.setInt(3, appointmentId);
            ps.setInt(4, serviceId);
            ps.executeUpdate();
        }
    }
}
