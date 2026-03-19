package dao;

import model.Appointment;
import model.Customer;
import model.Pet;
import model.User;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class AppointmentDAO extends DBContext {

    private static final int DEFAULT_SERVICE_DURATION_MINUTES = 30;
    private static final int DEFAULT_BOOKING_BUFFER_MINUTES = 5;
    public static final int MAX_BOOKINGS_PER_DAY = 3;

    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();

        String sql = """
            SELECT
                a.appointment_id,
                a.appointment_date,
                a.time_slot,
                a.status,
                a.veterinarian_id,
                a.service_id,
                s.name AS service_name,

                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,

                c.customer_id,
                u.full_name AS customer_name,
                u.phone      AS customer_phone,
                
                vet_user.full_name AS veterinarian_name

            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0
            ORDER BY a.appointment_date, a.time_slot
        """;

        String legacySql = """
            SELECT
                a.appointment_id,
                a.appointment_time,
                a.status,
                a.veterinarian_id,
                a.service_id,
                s.name AS service_name,

                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,

                c.customer_id,
                u.full_name AS customer_name,
                u.phone      AS customer_phone,

                vet_user.full_name AS veterinarian_name

            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0
            ORDER BY a.appointment_time
        """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {
                Appointment ap = new Appointment();
                ap.setAppointmentId(rs.getInt("appointment_id"));

                java.sql.Date apptDate = rs.getDate("appointment_date");
                String timeSlot = rs.getString("time_slot");

                if (apptDate != null) {
                    ap.setAppointmentDate(apptDate.toLocalDate());
                }
                ap.setTimeSlot(timeSlot);

                // Derive a legacy appointmentTime value from date + slot so that
                // existing code that still relies on appointmentTime continues to work.
                if (apptDate != null) {
                    java.time.LocalTime defaultTime;
                    if (timeSlot != null && timeSlot.equalsIgnoreCase("AM")) {
                        defaultTime = java.time.LocalTime.of(9, 0);
                    } else if (timeSlot != null && timeSlot.equalsIgnoreCase("PM")) {
                        defaultTime = java.time.LocalTime.of(15, 0);
                    } else {
                        // If slot is missing, default to midday so it still falls on the correct date
                        defaultTime = java.time.LocalTime.of(12, 0);
                    }
                    ap.setAppointmentTime(java.time.LocalDateTime.of(apptDate.toLocalDate(), defaultTime));
                }
                ap.setStatus(rs.getString("status"));
                ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                ap.setService(rs.getString("service_name"));

                // Pet
                Pet pet = new Pet();
                pet.setPetId(rs.getInt("pet_id"));
                pet.setName(rs.getString("pet_name"));
                pet.setPhotoURL(rs.getString("pet_photo"));
                ap.setPet(pet);

                // Customer with User
                Customer cus = new Customer();
                cus.setCustomerId(rs.getInt("customer_id"));
                User customerUser = new User();
                customerUser.setFullName(rs.getString("customer_name"));
                customerUser.setPhone(rs.getString("customer_phone"));
                cus.setUser(customerUser);
                ap.setCustomer(cus);
                ap.setCustomerPhone(rs.getString("customer_phone"));
                
                String vetName = rs.getString("veterinarian_name");
                if (vetName != null) {
                    ap.setVeterinarianName(vetName);
                }

                list.add(ap);
            }

            return list;
        } catch (Exception ignored) {
            // Fallback for legacy schema using appointment_time.
            list.clear();
        }

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(legacySql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                Appointment ap = new Appointment();
                ap.setAppointmentId(rs.getInt("appointment_id"));

                Timestamp appointmentTs = rs.getTimestamp("appointment_time");
                if (appointmentTs != null) {
                    LocalDateTime appointmentTime = appointmentTs.toLocalDateTime();
                    ap.setAppointmentTime(appointmentTime);
                    ap.setAppointmentDate(appointmentTime.toLocalDate());
                    ap.setTimeSlot(appointmentTime.getHour() < 12 ? "AM" : "PM");
                }
                ap.setStatus(rs.getString("status"));
                ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                ap.setService(rs.getString("service_name"));

                Pet pet = new Pet();
                pet.setPetId(rs.getInt("pet_id"));
                pet.setName(rs.getString("pet_name"));
                pet.setPhotoURL(rs.getString("pet_photo"));
                ap.setPet(pet);

                Customer cus = new Customer();
                cus.setCustomerId(rs.getInt("customer_id"));
                User customerUser = new User();
                customerUser.setFullName(rs.getString("customer_name"));
                customerUser.setPhone(rs.getString("customer_phone"));
                cus.setUser(customerUser);
                ap.setCustomer(cus);
                ap.setCustomerPhone(rs.getString("customer_phone"));

                String vetName = rs.getString("veterinarian_name");
                if (vetName != null) {
                    ap.setVeterinarianName(vetName);
                }

                list.add(ap);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Returns appointments for a given date (any status), ordered by time.
     * Includes pet species/breed for queue display.
     */
    public List<Appointment> getAppointmentsForDate(LocalDate date) {
        List<Appointment> list = new ArrayList<>();
        String sql = """
            SELECT
                a.appointment_id,
                a.appointment_time,
                a.status,
                a.veterinarian_id,
                a.service_id,
                s.name AS service_name,
                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,
                p.species,
                p.breed,
                c.customer_id,
                u.full_name AS customer_name,
                vet_user.full_name AS veterinarian_name
            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0
              AND CAST(a.appointment_time AS DATE) = ?
            ORDER BY a.appointment_time
            """;
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setObject(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));
                    ap.setAppointmentTime(rs.getTimestamp("appointment_time").toLocalDateTime());
                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setService(rs.getString("service_name"));
                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setPhotoURL(rs.getString("pet_photo"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    ap.setPet(pet);
                    Customer cus = new Customer();
                    cus.setCustomerId(rs.getInt("customer_id"));
                    User customerUser = new User();
                    customerUser.setFullName(rs.getString("customer_name"));
                    cus.setUser(customerUser);
                    ap.setCustomer(cus);
                    String vetName = rs.getString("veterinarian_name");
                    if (vetName != null) ap.setVeterinarianName(vetName);
                    list.add(ap);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns the veterinarian_id for a user (from users table) who is a vet.
     * Returns 0 if the user is not in the veterinarians table.
     */
    public int getVeterinarianIdByUserId(int userId) {
        String sql = "SELECT veterinarian_id FROM veterinarians WHERE user_id = ?";
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("veterinarian_id") : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Returns the receptionist_id for a user who is a receptionist.
     * Used for check-in to set Visits.staff_id. Returns 0 if not a receptionist.
     */
    public int getReceptionistIdByUserId(int userId) {
        String sql = "SELECT receptionist_id FROM Receptionists WHERE user_id = ?";
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("receptionist_id") : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Map veterinarian_id -> Users.user_id (for notifications). Returns 0 if not found. */
    public int getUserIdByVeterinarianId(int veterinarianId) {
        if (veterinarianId <= 0) return 0;
        String sql = """
            SELECT u.user_id
            FROM Veterinarians v
            JOIN Users u ON v.user_id = u.user_id
            WHERE v.veterinarian_id = ?
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("user_id") : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getVeterinarianIdByAppointmentId(int appointmentId) {
        if (appointmentId <= 0) return 0;
        String sql = """
            SELECT veterinarian_id
            FROM appointments
            WHERE appointment_id = ?
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int vetId = rs.getInt("veterinarian_id");
                    return vetId > 0 ? vetId : 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Returns today's appointments assigned to a specific veterinarian, limited to
     * Only Checked-in (patient has been checked in by receptionist).
     */
    public List<Appointment> getAppointmentsForDateByVeterinarian(LocalDate date, int veterinarianId) {
        if (veterinarianId <= 0) {
            return new ArrayList<>();
        }
        List<Appointment> list = new ArrayList<>();
        String sql = """
            SELECT
                a.appointment_id,
                a.appointment_time,
                a.status,
                a.veterinarian_id,
                a.service_id,
                s.name AS service_name,
                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,
                p.species,
                p.breed,
                c.customer_id,
                u.full_name AS customer_name,
                vet_user.full_name AS veterinarian_name
            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0
              AND CAST(a.appointment_time AS DATE) = ?
              AND a.veterinarian_id = ?
              AND a.status = 'Checked-in'
            ORDER BY a.appointment_time
            """;
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setObject(1, date);
            ps.setInt(2, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));
                    ap.setAppointmentTime(rs.getTimestamp("appointment_time").toLocalDateTime());
                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setService(rs.getString("service_name"));
                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setPhotoURL(rs.getString("pet_photo"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    ap.setPet(pet);
                    Customer cus = new Customer();
                    cus.setCustomerId(rs.getInt("customer_id"));
                    User customerUser = new User();
                    customerUser.setFullName(rs.getString("customer_name"));
                    cus.setUser(customerUser);
                    String vetName = rs.getString("veterinarian_name");
                    if (vetName != null) ap.setVeterinarianName(vetName);
                    list.add(ap);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Today's appointments for a vet (any status: Confirmed, Checked-in, Scheduled) for dashboard.
     */
    public List<Appointment> getTodayAppointmentsByVeterinarianForDashboard(int veterinarianId) {
        return getAppointmentsForDateByVeterinarianAllStatuses(LocalDate.now(), veterinarianId);
    }

    /**
     * Returns all Checked-in appointments for a given date (any veterinarian),
     * ordered by arrival_time if present, otherwise by appointment slot.
     *
     * Assumption: Appointments.arrival_time is NULL at create time and set when receptionist checks in.
     * For existing data with NULL arrival_time, we temporarily derive:
     * - AM -> 09:00
     * - PM -> 15:00
     */
    public List<Appointment> getCheckedInAppointmentsForDate(LocalDate date) {
        List<Appointment> list = new ArrayList<>();
        String sql = """
            SELECT a.appointment_id,
                   a.arrival_time,
                   a.appointment_date,
                   a.time_slot,
                   a.status,
                   a.veterinarian_id,
                   a.service_id,
                   s.name AS service_name,
                   p.pet_id,
                   p.name AS pet_name,
                   p.photoUrl AS pet_photo,
                   p.species,
                   p.breed,
                   c.customer_id,
                   u.full_name AS customer_name,
                   vet_user.full_name AS veterinarian_name
            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0
              AND a.appointment_date = ?
              AND a.status = 'Checked-in'
            ORDER BY COALESCE(
                a.arrival_time,
                DATEADD(hour, CASE WHEN UPPER(COALESCE(a.time_slot, 'AM')) = 'PM' THEN 15 ELSE 9 END, CAST(a.appointment_date AS datetime))
            )
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));
                    java.sql.Timestamp at = rs.getTimestamp("arrival_time");
                    java.sql.Date d = rs.getDate("appointment_date");
                    String slot = rs.getString("time_slot");
                    if (at != null) {
                        ap.setArrivalTime(at.toLocalDateTime());
                    } else if (d != null) {
                        boolean isPm = slot != null && slot.equalsIgnoreCase("PM");
                        ap.setArrivalTime(d.toLocalDate().atTime(isPm ? 15 : 9, 0));
                    }
                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setService(rs.getString("service_name"));
                    if (d != null) ap.setAppointmentDate(d.toLocalDate());
                    ap.setTimeSlot(slot);

                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setPhotoURL(rs.getString("pet_photo"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    ap.setPet(pet);

                    Customer cus = new Customer();
                    cus.setCustomerId(rs.getInt("customer_id"));
                    User customerUser = new User();
                    customerUser.setFullName(rs.getString("customer_name"));
                    cus.setUser(customerUser);
                    ap.setCustomer(cus);

                    String vetName = rs.getString("veterinarian_name");
                    if (vetName != null) {
                        ap.setVeterinarianName(vetName);
                    }

                    list.add(ap);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Shared veterinarian queue for today:
     * - Checked-in appointments (actionable)
     * - In-Examination appointments (visible, may be locked by another vet)
     * Ordered by arrival_time.
     */
    public List<Appointment> getVetQueueAppointmentsForDate(LocalDate date) {
        List<Appointment> list = new ArrayList<>();
        String sql = """
            SELECT a.appointment_id,
                   a.arrival_time,
                   a.appointment_date,
                   a.time_slot,
                   a.status,
                   a.veterinarian_id,
                   a.service_id,
                   s.name AS service_name,
                   p.pet_id,
                   p.name AS pet_name,
                   p.photoUrl AS pet_photo,
                   p.species,
                   p.breed,
                   c.customer_id,
                   u.full_name AS customer_name,
                   vet_user.full_name AS veterinarian_name
            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0
              AND a.appointment_date = ?
              AND a.status IN ('Checked-in', 'In-Examination')
            ORDER BY COALESCE(
                a.arrival_time,
                DATEADD(hour, CASE WHEN UPPER(COALESCE(a.time_slot, 'AM')) = 'PM' THEN 15 ELSE 9 END, CAST(a.appointment_date AS datetime))
            )
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));
                    java.sql.Timestamp at = rs.getTimestamp("arrival_time");
                    java.sql.Date d = rs.getDate("appointment_date");
                    String slot = rs.getString("time_slot");
                    if (at != null) {
                        ap.setArrivalTime(at.toLocalDateTime());
                    } else if (d != null) {
                        boolean isPm = slot != null && slot.equalsIgnoreCase("PM");
                        ap.setArrivalTime(d.toLocalDate().atTime(isPm ? 15 : 9, 0));
                    }
                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setService(rs.getString("service_name"));
                    if (d != null) ap.setAppointmentDate(d.toLocalDate());
                    ap.setTimeSlot(slot);

                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setPhotoURL(rs.getString("pet_photo"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    ap.setPet(pet);

                    Customer cus = new Customer();
                    cus.setCustomerId(rs.getInt("customer_id"));
                    User customerUser = new User();
                    customerUser.setFullName(rs.getString("customer_name"));
                    cus.setUser(customerUser);
                    ap.setCustomer(cus);

                    String vetName = rs.getString("veterinarian_name");
                    if (vetName != null) ap.setVeterinarianName(vetName);

                    list.add(ap);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Appointment> getAppointmentsForDateByVeterinarianAllStatuses(LocalDate date, int veterinarianId) {
        if (veterinarianId <= 0) return new ArrayList<>();
        List<Appointment> list = new ArrayList<>();
        String legacySql = """
            SELECT a.appointment_id, a.appointment_time, a.status, a.veterinarian_id, a.service_id, s.name AS service_name,
                   p.pet_id, p.name AS pet_name, p.photoUrl AS pet_photo, p.species, p.breed,
                   c.customer_id, u.full_name AS customer_name, vet_user.full_name AS veterinarian_name
            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
                        WHERE p.isDeleted = 0 AND CAST(a.appointment_time AS DATE) = ?
                            AND (a.veterinarian_id = ? OR a.veterinarian_id IS NULL)
                            AND a.status IN ('Pending', 'Confirmed', 'Checked-in', 'Scheduled', 'In-Examination')
            ORDER BY a.appointment_time
            """;
        String dateSlotSql = """
            SELECT a.appointment_id, a.appointment_date, a.time_slot, a.status, a.veterinarian_id, a.service_id, s.name AS service_name,
                   p.pet_id, p.name AS pet_name, p.photoUrl AS pet_photo, p.species, p.breed,
                   c.customer_id, u.full_name AS customer_name, vet_user.full_name AS veterinarian_name
            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
                        WHERE p.isDeleted = 0 AND a.appointment_date = ?
                            AND (a.veterinarian_id = ? OR a.veterinarian_id IS NULL)
                            AND a.status IN ('Pending', 'Confirmed', 'Checked-in', 'Scheduled', 'In-Examination')
            ORDER BY CASE WHEN UPPER(COALESCE(a.time_slot, 'AM')) = 'PM' THEN 1 ELSE 0 END, a.appointment_date
            """;
        try (Connection con = getConnection()) {
            Set<String> appointmentColumns = getAppointmentsTableColumns(con);
            boolean hasDateSlot = appointmentColumns.contains("appointment_date")
                    && appointmentColumns.contains("time_slot");
            String sql = hasDateSlot ? dateSlotSql : legacySql;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setDate(1, java.sql.Date.valueOf(date));
                ps.setInt(2, veterinarianId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Appointment ap = hasDateSlot
                                ? mapAppointmentFromDateSlotRs(rs)
                                : mapAppointmentFromRs(rs);
                        list.add(ap);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Appointment mapAppointmentFromDateSlotRs(ResultSet rs) throws SQLException {
        Appointment ap = new Appointment();
        ap.setAppointmentId(rs.getInt("appointment_id"));

        java.sql.Date appointmentDate = rs.getDate("appointment_date");
        String timeSlot = rs.getString("time_slot");
        if (appointmentDate != null) {
            LocalDate date = appointmentDate.toLocalDate();
            ap.setAppointmentDate(date);
            ap.setTimeSlot(timeSlot);

            boolean isPm = timeSlot != null && ("PM".equalsIgnoreCase(timeSlot) || "afternoon".equalsIgnoreCase(timeSlot));
            ap.setAppointmentTime(date.atTime(isPm ? 14 : 8, 0));
        }

        ap.setStatus(rs.getString("status"));
        ap.setVeterinarianId(rs.getInt("veterinarian_id"));
        ap.setService(rs.getString("service_name"));

        Pet pet = new Pet();
        pet.setPetId(rs.getInt("pet_id"));
        pet.setName(rs.getString("pet_name"));
        pet.setPhotoURL(rs.getString("pet_photo"));
        pet.setSpecies(rs.getString("species"));
        pet.setBreed(rs.getString("breed"));
        ap.setPet(pet);

        Customer cus = new Customer();
        cus.setCustomerId(rs.getInt("customer_id"));
        User customerUser = new User();
        customerUser.setFullName(rs.getString("customer_name"));
        cus.setUser(customerUser);
        ap.setCustomer(cus);

        String vetName = rs.getString("veterinarian_name");
        if (vetName != null) {
            ap.setVeterinarianName(vetName);
        }

        return ap;
    }

    private Appointment mapAppointmentFromRs(ResultSet rs) throws SQLException {
        Appointment ap = new Appointment();
        ap.setAppointmentId(rs.getInt("appointment_id"));
        Timestamp appointmentTs = rs.getTimestamp("appointment_time");
        if (appointmentTs != null) {
            LocalDateTime appointmentTime = appointmentTs.toLocalDateTime();
            ap.setAppointmentTime(appointmentTime);
            ap.setAppointmentDate(appointmentTime.toLocalDate());
            ap.setTimeSlot(appointmentTime.getHour() < 12 ? "AM" : "PM");
        }
        ap.setStatus(rs.getString("status"));
        ap.setVeterinarianId(rs.getInt("veterinarian_id"));
        ap.setService(rs.getString("service_name"));
        Pet pet = new Pet();
        pet.setPetId(rs.getInt("pet_id"));
        pet.setName(rs.getString("pet_name"));
        pet.setPhotoURL(rs.getString("pet_photo"));
        pet.setSpecies(rs.getString("species"));
        pet.setBreed(rs.getString("breed"));
        ap.setPet(pet);
        Customer cus = new Customer();
        cus.setCustomerId(rs.getInt("customer_id"));
        User customerUser = new User();
        customerUser.setFullName(rs.getString("customer_name"));
        cus.setUser(customerUser);
        String vetName = rs.getString("veterinarian_name");
        if (vetName != null) ap.setVeterinarianName(vetName);
        return ap;
    }

    /** Count today's appointments for a vet. */
    public int countTodayAppointmentsByVet(int veterinarianId) {
        if (veterinarianId <= 0) return 0;
        String legacySql = "SELECT COUNT(*) FROM appointments a JOIN pets p ON a.pet_id = p.pet_id WHERE p.isDeleted = 0 AND CAST(a.appointment_time AS DATE) = CAST(GETDATE() AS DATE) AND a.veterinarian_id = ?";
        String dateSlotSql = "SELECT COUNT(*) FROM appointments a JOIN pets p ON a.pet_id = p.pet_id WHERE p.isDeleted = 0 AND a.appointment_date = CAST(GETDATE() AS DATE) AND a.veterinarian_id = ?";
        try (Connection con = getConnection()) {
            Set<String> appointmentColumns = getAppointmentsTableColumns(con);
            boolean hasDateSlot = appointmentColumns.contains("appointment_date")
                    && appointmentColumns.contains("time_slot");
            String sql = hasDateSlot ? dateSlotSql : legacySql;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, veterinarianId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getInt(1) : 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Count today's appointments with service containing 'Surgery' for a vet. */
    public int countSurgeriesTodayByVet(int veterinarianId) {
        if (veterinarianId <= 0) return 0;
        String legacySql = """
            SELECT COUNT(*) FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0 AND CAST(a.appointment_time AS DATE) = CAST(GETDATE() AS DATE)
              AND a.veterinarian_id = ? AND (s.name LIKE '%Surgery%' OR s.name LIKE '%surgery%')
            """;
        String dateSlotSql = """
            SELECT COUNT(*) FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0 AND a.appointment_date = CAST(GETDATE() AS DATE)
              AND a.veterinarian_id = ? AND (s.name LIKE '%Surgery%' OR s.name LIKE '%surgery%')
            """;
        try (Connection con = getConnection()) {
            Set<String> appointmentColumns = getAppointmentsTableColumns(con);
            boolean hasDateSlot = appointmentColumns.contains("appointment_date")
                    && appointmentColumns.contains("time_slot");
            String sql = hasDateSlot ? dateSlotSql : legacySql;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, veterinarianId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getInt(1) : 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Count follow-up appointments this week (today through +7 days) for a vet. */
    public int countFollowUpsThisWeek(int veterinarianId) {
        if (veterinarianId <= 0) return 0;
        String legacySql = """
            SELECT COUNT(*) FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            WHERE p.isDeleted = 0 AND a.veterinarian_id = ?
              AND CAST(a.appointment_time AS DATE) > CAST(GETDATE() AS DATE)
              AND CAST(a.appointment_time AS DATE) <= DATEADD(day, 7, CAST(GETDATE() AS DATE))
            """;
        String dateSlotSql = """
            SELECT COUNT(*) FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            WHERE p.isDeleted = 0 AND a.veterinarian_id = ?
              AND a.appointment_date > CAST(GETDATE() AS DATE)
              AND a.appointment_date <= DATEADD(day, 7, CAST(GETDATE() AS DATE))
            """;
        try (Connection con = getConnection()) {
            Set<String> appointmentColumns = getAppointmentsTableColumns(con);
            boolean hasDateSlot = appointmentColumns.contains("appointment_date")
                    && appointmentColumns.contains("time_slot");
            String sql = hasDateSlot ? dateSlotSql : legacySql;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, veterinarianId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getInt(1) : 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Appointment getAppointmentDetail(int appointmentId) {
        String sql = """
            SELECT
                a.appointment_id,
                a.appointment_date,
                a.time_slot,
                a.status,
                a.veterinarian_id,
                a.service_id,
                s.name AS service_name,

                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight,

                c.customer_id,
                u.full_name AS customer_name,
                u.email AS customer_email,
                u.phone AS customer_phone,
                u.address AS customer_address,

                vet_user.full_name AS veterinarian_name

            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.appointment_id = ?
        """;

        String legacySql = """
            SELECT
                a.appointment_id,
                a.appointment_time,
                a.status,
                a.veterinarian_id,
                a.service_id,
                s.name AS service_name,

                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight,

                c.customer_id,
                u.full_name AS customer_name,
                u.email AS customer_email,
                u.phone AS customer_phone,
                u.address AS customer_address,

                vet_user.full_name AS veterinarian_name

            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.appointment_id = ?
        """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));

                    java.sql.Date apptDate = rs.getDate("appointment_date");
                    String timeSlot = rs.getString("time_slot");
                    if (apptDate != null) {
                        ap.setAppointmentDate(apptDate.toLocalDate());
                    }
                    ap.setTimeSlot(timeSlot);

                    if (apptDate != null) {
                        java.time.LocalTime defaultTime;
                        if (timeSlot != null && timeSlot.equalsIgnoreCase("AM")) {
                            defaultTime = java.time.LocalTime.of(9, 0);
                        } else if (timeSlot != null && timeSlot.equalsIgnoreCase("PM")) {
                            defaultTime = java.time.LocalTime.of(15, 0);
                        } else {
                            defaultTime = java.time.LocalTime.of(12, 0);
                        }
                        ap.setAppointmentTime(java.time.LocalDateTime.of(apptDate.toLocalDate(), defaultTime));
                    }
                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setService(rs.getString("service_name"));
                    ap.setServiceId(rs.getObject("service_id") != null ? rs.getInt("service_id") : null);
                    ap.setVeterinarianName(rs.getString("veterinarian_name"));

                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setPhotoURL(rs.getString("pet_photo"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    pet.setGender(rs.getString("gender"));
                    java.sql.Date bd = rs.getDate("birth_date");
                    if (bd != null) pet.setBirthDate(bd.toLocalDate());
                    double w = rs.getDouble("weight");
                    if (!rs.wasNull()) pet.setWeight(w);
                    ap.setPet(pet);

                    Customer cus = new Customer();
                    cus.setCustomerId(rs.getInt("customer_id"));
                    User customerUser = new User();
                    customerUser.setFullName(rs.getString("customer_name"));
                    customerUser.setEmail(rs.getString("customer_email"));
                    customerUser.setPhone(rs.getString("customer_phone"));
                    customerUser.setAddress(rs.getString("customer_address"));
                    cus.setUser(customerUser);
                    ap.setCustomer(cus);

                    return ap;
                }
            }
        } catch (Exception ignored) {
            // Fallback for legacy schema using appointment_time.
        }

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(legacySql)
        ) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));

                    Timestamp appointmentTs = rs.getTimestamp("appointment_time");
                    if (appointmentTs != null) {
                        LocalDateTime appointmentTime = appointmentTs.toLocalDateTime();
                        ap.setAppointmentTime(appointmentTime);
                        ap.setAppointmentDate(appointmentTime.toLocalDate());
                        ap.setTimeSlot(appointmentTime.getHour() < 12 ? "AM" : "PM");
                    }
                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setService(rs.getString("service_name"));
                    ap.setServiceId(rs.getObject("service_id") != null ? rs.getInt("service_id") : null);
                    ap.setVeterinarianName(rs.getString("veterinarian_name"));

                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setPhotoURL(rs.getString("pet_photo"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    pet.setGender(rs.getString("gender"));
                    java.sql.Date bd = rs.getDate("birth_date");
                    if (bd != null) {
                        pet.setBirthDate(bd.toLocalDate());
                    }
                    double w = rs.getDouble("weight");
                    if (!rs.wasNull()) {
                        pet.setWeight(w);
                    }
                    ap.setPet(pet);

                    Customer cus = new Customer();
                    cus.setCustomerId(rs.getInt("customer_id"));
                    User customerUser = new User();
                    customerUser.setFullName(rs.getString("customer_name"));
                    customerUser.setEmail(rs.getString("customer_email"));
                    customerUser.setPhone(rs.getString("customer_phone"));
                    customerUser.setAddress(rs.getString("customer_address"));
                    cus.setUser(customerUser);
                    ap.setCustomer(cus);

                    return ap;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Appointment getAppointmentDetailByCustomer(int appointmentId, int customerId) {
        String sql = """
            SELECT
                a.appointment_id,
                a.appointment_date,
                a.time_slot,
                a.status,
                a.veterinarian_id,
                a.service_id,
                a.notes,
                s.name AS service_name,

                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight,

                c.customer_id,
                u.full_name AS customer_name,
                u.email AS customer_email,
                u.phone AS customer_phone,
                u.address AS customer_address,

                vet_user.full_name AS veterinarian_name

            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.appointment_id = ?
              AND a.customer_id = ?
              AND (p.isDeleted = 0 OR p.isDeleted IS NULL)
        """;

        String legacySql = """
            SELECT
                a.appointment_id,
                a.appointment_time,
                a.status,
                a.veterinarian_id,
                a.service_id,
                a.notes,
                s.name AS service_name,

                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight,

                c.customer_id,
                u.full_name AS customer_name,
                u.email AS customer_email,
                u.phone AS customer_phone,
                u.address AS customer_address,

                vet_user.full_name AS veterinarian_name

            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.appointment_id = ?
              AND a.customer_id = ?
              AND (p.isDeleted = 0 OR p.isDeleted IS NULL)
        """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));

                    java.sql.Date apptDate = rs.getDate("appointment_date");
                    String timeSlot = rs.getString("time_slot");
                    if (apptDate != null) {
                        ap.setAppointmentDate(apptDate.toLocalDate());
                    }
                    ap.setTimeSlot(timeSlot);

                    if (apptDate != null) {
                        java.time.LocalTime defaultTime;
                        if (timeSlot != null && (timeSlot.equalsIgnoreCase("AM") || timeSlot.equalsIgnoreCase("morning"))) {
                            defaultTime = java.time.LocalTime.of(9, 0);
                        } else if (timeSlot != null && (timeSlot.equalsIgnoreCase("PM") || timeSlot.equalsIgnoreCase("afternoon"))) {
                            defaultTime = java.time.LocalTime.of(15, 0);
                        } else {
                            defaultTime = java.time.LocalTime.of(12, 0);
                        }
                        ap.setAppointmentTime(java.time.LocalDateTime.of(apptDate.toLocalDate(), defaultTime));
                    }

                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setService(rs.getString("service_name"));
                    ap.setServiceId(rs.getObject("service_id") != null ? rs.getInt("service_id") : null);
                    ap.setNotes(rs.getString("notes"));
                    ap.setVeterinarianName(rs.getString("veterinarian_name"));

                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setPhotoURL(rs.getString("pet_photo"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    pet.setGender(rs.getString("gender"));
                    java.sql.Date bd = rs.getDate("birth_date");
                    if (bd != null) pet.setBirthDate(bd.toLocalDate());
                    double w = rs.getDouble("weight");
                    if (!rs.wasNull()) pet.setWeight(w);
                    ap.setPet(pet);

                    Customer cus = new Customer();
                    cus.setCustomerId(rs.getInt("customer_id"));
                    User customerUser = new User();
                    customerUser.setFullName(rs.getString("customer_name"));
                    customerUser.setEmail(rs.getString("customer_email"));
                    customerUser.setPhone(rs.getString("customer_phone"));
                    customerUser.setAddress(rs.getString("customer_address"));
                    cus.setUser(customerUser);
                    ap.setCustomer(cus);

                    return ap;
                }
            }
        } catch (Exception ignored) {
            // Fallback for legacy schema using appointment_time.
        }

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(legacySql)
        ) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));

                    Timestamp appointmentTs = rs.getTimestamp("appointment_time");
                    if (appointmentTs != null) {
                        LocalDateTime appointmentTime = appointmentTs.toLocalDateTime();
                        ap.setAppointmentTime(appointmentTime);
                        ap.setAppointmentDate(appointmentTime.toLocalDate());
                        ap.setTimeSlot(appointmentTime.getHour() < 12 ? "AM" : "PM");
                    }

                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setService(rs.getString("service_name"));
                    ap.setServiceId(rs.getObject("service_id") != null ? rs.getInt("service_id") : null);
                    ap.setNotes(rs.getString("notes"));
                    ap.setVeterinarianName(rs.getString("veterinarian_name"));

                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setPhotoURL(rs.getString("pet_photo"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    pet.setGender(rs.getString("gender"));
                    java.sql.Date bd = rs.getDate("birth_date");
                    if (bd != null) pet.setBirthDate(bd.toLocalDate());
                    double w = rs.getDouble("weight");
                    if (!rs.wasNull()) pet.setWeight(w);
                    ap.setPet(pet);

                    Customer cus = new Customer();
                    cus.setCustomerId(rs.getInt("customer_id"));
                    User customerUser = new User();
                    customerUser.setFullName(rs.getString("customer_name"));
                    customerUser.setEmail(rs.getString("customer_email"));
                    customerUser.setPhone(rs.getString("customer_phone"));
                    customerUser.setAddress(rs.getString("customer_address"));
                    cus.setUser(customerUser);
                    ap.setCustomer(cus);

                    return ap;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<User> getAllVeterinarians() {
        List<User> list = new ArrayList<>();
        String sql = """
            SELECT v.veterinarian_id, u.full_name
            FROM veterinarians v
            JOIN users u ON v.user_id = u.user_id
            WHERE u.status = 'Active'
            ORDER BY u.full_name
        """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                User vet = new User();
                vet.setUserId(rs.getInt("veterinarian_id"));
                vet.setFullName(rs.getString("full_name"));
                list.add(vet);
            }
        }catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateAppointmentDoctor(int appointmentId, Integer veterinarianId) {
        String sql = "UPDATE appointments SET veterinarian_id = ? WHERE appointment_id = ?";
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            if (veterinarianId != null && veterinarianId > 0) {
                ps.setInt(1, veterinarianId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public boolean updateAppointmentStatus(int appointmentId, String status) {
        String sql = "UPDATE appointments SET status = ? WHERE appointment_id = ?";
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Sets arrival_time = NOW for check-in flow. */
    public boolean setArrivalTimeNow(int appointmentId) {
        String sql = "UPDATE appointments SET arrival_time = GETDATE() WHERE appointment_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Atomically starts an examination from shared queue.
     * Only the first vet who clicks Start on a Checked-in appointment can claim it.
     */
    public boolean startExamination(int appointmentId, int veterinarianId) {
        String sql = """
            UPDATE appointments
            SET status = 'In-Examination',
                veterinarian_id = ?
            WHERE appointment_id = ?
              AND status = 'Checked-in'
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, veterinarianId);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Creates a new appointment (e.g. for schedule revisit). Returns the new appointment_id or 0 on failure. */
    public int create(int petId, int customerId, int veterinarianId, LocalDateTime appointmentTime, String status, Integer serviceId) {
        String sql = "INSERT INTO appointments (pet_id, customer_id, veterinarian_id, appointment_time, status, service_id) OUTPUT INSERTED.appointment_id VALUES (?, ?, ?, ?, ?, ?)";

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, petId);
            ps.setInt(2, customerId);
            ps.setInt(3, veterinarianId);
            ps.setTimestamp(4, Timestamp.valueOf(appointmentTime));
            ps.setString(5, status != null ? status : "Confirmed");
            ps.setObject(6, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    /** Creates a pending appointment for an existing customer booking flow. */
    public int createCustomerBooking(int petId, int customerId, Integer veterinarianId, LocalDateTime appointmentTime, Integer serviceId, String notes) {
        if (appointmentTime == null) {
            return 0;
        }

        try (Connection con = getConnection()) {
            Set<String> appointmentColumns = getAppointmentsTableColumns(con);
            if (appointmentColumns.isEmpty()) {
                return 0;
            }

            boolean hasAppointmentTime = appointmentColumns.contains("appointment_time");
            boolean hasAppointmentDate = appointmentColumns.contains("appointment_date");
            boolean hasTimeSlot = appointmentColumns.contains("time_slot");
            boolean hasNotes = appointmentColumns.contains("notes");
            boolean hasPhone = appointmentColumns.contains("phone");

            if (!hasAppointmentTime && !hasAppointmentDate) {
                return 0;
            }

            StringBuilder columnSql = new StringBuilder();
            StringBuilder valueSql = new StringBuilder();

            columnSql.append("pet_id, customer_id, veterinarian_id");
            valueSql.append("?, ?, ?");

            if (hasAppointmentTime) {
                columnSql.append(", appointment_time");
                valueSql.append(", ?");
            } else {
                columnSql.append(", appointment_date");
                valueSql.append(", ?");
                if (hasTimeSlot) {
                    columnSql.append(", time_slot");
                    valueSql.append(", ?");
                }
            }

            columnSql.append(", status");
            valueSql.append(", ?");

            if (appointmentColumns.contains("service_id")) {
                columnSql.append(", service_id");
                valueSql.append(", ?");
            }

            if (appointmentColumns.contains("created_at")) {
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

            String sql = "INSERT INTO appointments (" + columnSql + ") OUTPUT INSERTED.appointment_id VALUES (" + valueSql + ")";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                int index = 1;
                ps.setInt(index++, petId);
                ps.setInt(index++, customerId);
                if (veterinarianId != null && veterinarianId > 0) {
                    ps.setInt(index++, veterinarianId);
                } else {
                    ps.setNull(index++, java.sql.Types.INTEGER);
                }

                if (hasAppointmentTime) {
                    ps.setTimestamp(index++, Timestamp.valueOf(appointmentTime));
                } else {
                    ps.setDate(index++, java.sql.Date.valueOf(appointmentTime.toLocalDate()));
                    if (hasTimeSlot) {
                        ps.setString(index++, appointmentTime.getHour() < 12 ? "AM" : "PM");
                    }
                }

                ps.setString(index++, "Pending");

                if (appointmentColumns.contains("service_id")) {
                    ps.setObject(index++, serviceId);
                }

                if (hasNotes) {
                    ps.setString(index++, notes != null ? notes : "");
                }

                if (hasPhone) {
                    String customerPhone = getCustomerPhoneByCustomerId(con, customerId);
                    ps.setString(index++, customerPhone != null ? customerPhone : "");
                }

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    private Set<String> getAppointmentsTableColumns(Connection con) {
        Set<String> columns = new HashSet<>();
        String probeSql = "SELECT TOP 0 * FROM appointments";
        try (
            PreparedStatement ps = con.prepareStatement(probeSql);
            ResultSet rs = ps.executeQuery()
        ) {
            java.sql.ResultSetMetaData meta = rs.getMetaData();
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

    private String getCustomerPhoneByCustomerId(Connection con, int customerId) {
        String sql = "SELECT TOP 1 u.phone FROM customers c JOIN users u ON c.user_id = u.user_id WHERE c.customer_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("phone");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Creates a pending appointment with date + AM/PM slot (receptionist booking).
     * arrival_time is NULL by default and only set on receptionist check-in.
     * Table includes phone (NOT NULL). Pass phone from request.
     */
    public int createWithDateAndSlot(int petId, int customerId, Integer serviceId, LocalDate appointmentDate, String timeSlot, String notes, String phone) {
        String sql = """
            INSERT INTO appointments (
                pet_id,
                customer_id,
                veterinarian_id,
                appointment_date,
                time_slot,
                status,
                service_id,
                created_at,
                notes,
                phone
            )
            OUTPUT INSERTED.appointment_id
            VALUES (?, ?, NULL, ?, ?, 'Pending', ?, GETDATE(), ?, ?)
            """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, petId);
            ps.setInt(2, customerId);
            ps.setDate(3, java.sql.Date.valueOf(appointmentDate));
            ps.setString(4, timeSlot != null && (timeSlot.equalsIgnoreCase("AM") || timeSlot.equalsIgnoreCase("PM")) ? timeSlot.toUpperCase() : "AM");
            ps.setObject(5, serviceId);
            ps.setString(6, notes != null ? notes : "");
            ps.setString(7, phone != null ? phone : "");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Creates an emergency appointment: status=Checked-In, service_id=NULL,
     * appointment_date=today, time_slot=AM if current hour &lt; 12 else PM, type=Emergency.
     */
    public int createEmergencyAppointment(int petId, int customerId, String phone) {
        java.time.LocalDate today = java.time.LocalDate.now();
        String timeSlot = java.time.LocalTime.now().getHour() < 12 ? "AM" : "PM";

        String sql = """
            INSERT INTO appointments (
                pet_id,
                customer_id,
                veterinarian_id,
                appointment_date,
                time_slot,
                arrival_time,
                status,
                service_id,
                created_at,
                notes,
                phone,
                type
            )
            OUTPUT INSERTED.appointment_id
            VALUES (?, ?, NULL, ?, ?, GETDATE(), 'Checked-in', NULL, GETDATE(), '', ?, 'Emergency')
            """;
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, petId);
            ps.setInt(2, customerId);
            ps.setDate(3, java.sql.Date.valueOf(today));
            ps.setString(4, timeSlot);
            ps.setString(5, phone != null ? phone : "");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Counts how many active (non-cancelled, non-completed) bookings a customer
     * has already made for a specific date via the customer booking flow.
     * Used to enforce the daily booking cap (MAX_BOOKINGS_PER_DAY).
     */
    public int countCustomerBookingsOnDate(int customerId, java.time.LocalDate date) {
        String sql = """
            SELECT COUNT(*)
            FROM appointments
            WHERE customer_id = ?
              AND CAST(appointment_time AS DATE) = ?
              AND LOWER(COALESCE(status, '')) NOT LIKE '%cancel%'
              AND LOWER(COALESCE(status, '')) NOT LIKE '%complete%'
              AND LOWER(COALESCE(status, '')) <> 'done'
        """;
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, customerId);
            ps.setDate(2, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean hasCustomerAppointmentConflict(int customerId, LocalDateTime appointmentTime) {
        return hasCustomerAppointmentConflict(customerId, appointmentTime, DEFAULT_SERVICE_DURATION_MINUTES);
    }

    public boolean hasCustomerAppointmentConflict(int customerId, LocalDateTime appointmentTime, int requestedDurationMinutes) {
        String sql = """
            SELECT
                a.appointment_time,
                s.duration,
                s.category,
                s.name AS service_name
            FROM appointments a
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.customer_id = ?
              AND a.appointment_time IS NOT NULL
              AND LOWER(COALESCE(a.status, '')) NOT LIKE '%cancel%'
              AND LOWER(COALESCE(a.status, '')) NOT LIKE '%complete%'
              AND LOWER(COALESCE(a.status, '')) <> 'done'
        """;
        return hasAppointmentOverlap(sql, customerId, appointmentTime, requestedDurationMinutes, DEFAULT_BOOKING_BUFFER_MINUTES);
    }

    public boolean hasPetAppointmentConflict(int petId, LocalDateTime appointmentTime) {
        return hasPetAppointmentConflict(petId, appointmentTime, DEFAULT_SERVICE_DURATION_MINUTES);
    }

    public boolean hasPetAppointmentConflict(int petId, LocalDateTime appointmentTime, int requestedDurationMinutes) {
        String sql = """
            SELECT
                a.appointment_time,
                s.duration,
                s.category,
                s.name AS service_name
            FROM appointments a
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.pet_id = ?
              AND a.appointment_time IS NOT NULL
              AND LOWER(COALESCE(a.status, '')) NOT LIKE '%cancel%'
              AND LOWER(COALESCE(a.status, '')) NOT LIKE '%complete%'
              AND LOWER(COALESCE(a.status, '')) <> 'done'
        """;
        return hasAppointmentOverlap(sql, petId, appointmentTime, requestedDurationMinutes, DEFAULT_BOOKING_BUFFER_MINUTES);
    }

    public boolean hasVeterinarianAppointmentConflict(int veterinarianId, LocalDateTime appointmentTime) {
        return hasVeterinarianAppointmentConflict(veterinarianId, appointmentTime, DEFAULT_SERVICE_DURATION_MINUTES);
    }

    public boolean hasVeterinarianAppointmentConflict(int veterinarianId, LocalDateTime appointmentTime, int requestedDurationMinutes) {
        String sql = """
            SELECT
                a.appointment_time,
                s.duration,
                s.category,
                s.name AS service_name
            FROM appointments a
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.veterinarian_id = ?
              AND a.appointment_time IS NOT NULL
              AND LOWER(COALESCE(a.status, '')) NOT LIKE '%cancel%'
              AND LOWER(COALESCE(a.status, '')) NOT LIKE '%complete%'
              AND LOWER(COALESCE(a.status, '')) <> 'done'
        """;
        return hasAppointmentOverlap(sql, veterinarianId, appointmentTime, requestedDurationMinutes, DEFAULT_BOOKING_BUFFER_MINUTES);
    }

    private boolean hasAppointmentOverlap(String sql, int entityId, LocalDateTime requestedStart,
            int requestedDurationMinutes, int bufferMinutes) {
        if (requestedStart == null) {
            return false;
        }

        int safeBuffer = Math.max(0, bufferMinutes);
        int effectiveRequestedDuration = resolveEffectiveDurationMinutes(requestedDurationMinutes, null, null);
        LocalDateTime requestedEnd = requestedStart.plusMinutes((long) effectiveRequestedDuration + safeBuffer);

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, entityId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timestamp existingTs = rs.getTimestamp("appointment_time");
                    if (existingTs == null) {
                        continue;
                    }

                    LocalDateTime existingStart = existingTs.toLocalDateTime();
                    Integer existingDuration = rs.getObject("duration", Integer.class);
                    String existingCategory = rs.getString("category");
                    String existingServiceName = rs.getString("service_name");

                    int effectiveExistingDuration = resolveEffectiveDurationMinutes(existingDuration, existingCategory, existingServiceName);
                    LocalDateTime existingEnd = existingStart.plusMinutes((long) effectiveExistingDuration + safeBuffer);

                    if (requestedStart.isBefore(existingEnd) && existingStart.isBefore(requestedEnd)) {
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private int resolveEffectiveDurationMinutes(Integer rawDuration, String category, String serviceName) {
        if (rawDuration != null && rawDuration > 0) {
            return rawDuration;
        }

        String normalizedCategory = normalizeDurationHint(category);
        if (normalizedCategory.contains("vaccine")) {
            return 15;
        }
        if (normalizedCategory.contains("checkup") || normalizedCategory.contains("preventive")) {
            return 20;
        }
        if (normalizedCategory.contains("xray") || normalizedCategory.contains("x-ray")
                || normalizedCategory.contains("radiology") || normalizedCategory.contains("blood")
                || normalizedCategory.contains("lab")) {
            return 25;
        }
        if (normalizedCategory.contains("consult") || normalizedCategory.contains("surgery")
                || normalizedCategory.contains("emergency")) {
            return 30;
        }

        String normalizedServiceName = normalizeDurationHint(serviceName);
        if (normalizedServiceName.contains("vaccine")) {
            return 15;
        }
        if (normalizedServiceName.contains("checkup") || normalizedServiceName.contains("general check")) {
            return 20;
        }
        if (normalizedServiceName.contains("xray") || normalizedServiceName.contains("x-ray")
                || normalizedServiceName.contains("blood") || normalizedServiceName.contains("lab")) {
            return 25;
        }
        if (normalizedServiceName.contains("consult") || normalizedServiceName.contains("surgery")
                || normalizedServiceName.contains("emergency")) {
            return 30;
        }

        return DEFAULT_SERVICE_DURATION_MINUTES;
    }

    private int resolveEffectiveDurationMinutes(int rawDuration, String category, String serviceName) {
        return resolveEffectiveDurationMinutes(Integer.valueOf(rawDuration), category, serviceName);
    }

    private String normalizeDurationHint(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    public boolean rescheduleAppointment(int appointmentId, java.util.Date newDate, java.sql.Time newTime) {
        String sql = "UPDATE appointments SET appointment_time = ?, status = 'Pending' WHERE appointment_id = ?";
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            // Combine date and time into a timestamp
            java.sql.Timestamp timestamp = new java.sql.Timestamp(newDate.getTime() + newTime.getTime());
            ps.setTimestamp(1, timestamp);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Appointment> getAppointmentsByCustomerId(int customerId) {
        List<Appointment> list = new ArrayList<>();

        String legacySql = """
            SELECT
                a.appointment_id,
                a.appointment_time,
                a.status,
                a.veterinarian_id,
                s.name AS service_name,
                p.pet_id,
                p.name AS pet_name,
                vet_user.full_name AS veterinarian_name
            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.customer_id = ?
              AND (p.isDeleted = 0 OR p.isDeleted IS NULL)
            ORDER BY a.appointment_time DESC
        """;

        String dateSlotSql = """
            SELECT
                a.appointment_id,
                a.appointment_date,
                a.time_slot,
                a.status,
                a.veterinarian_id,
                s.name AS service_name,
                p.pet_id,
                p.name AS pet_name,
                vet_user.full_name AS veterinarian_name
            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE a.customer_id = ?
              AND (p.isDeleted = 0 OR p.isDeleted IS NULL)
            ORDER BY a.appointment_date DESC, a.time_slot DESC
        """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(legacySql)
        ) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));
                    Timestamp appointmentTs = rs.getTimestamp("appointment_time");
                    if (appointmentTs != null) {
                        ap.setAppointmentTime(appointmentTs.toLocalDateTime());
                    }
                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setVeterinarianName(rs.getString("veterinarian_name"));
                    ap.setService(rs.getString("service_name"));

                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    ap.setPet(pet);

                    list.add(ap);
                }
            }
            return list;
        } catch (Exception ignored) {
            list.clear();
        }

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(dateSlotSql)
        ) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment ap = new Appointment();
                    ap.setAppointmentId(rs.getInt("appointment_id"));

                    java.sql.Date apptDate = rs.getDate("appointment_date");
                    String timeSlot = rs.getString("time_slot");
                    if (apptDate != null) {
                        ap.setAppointmentDate(apptDate.toLocalDate());
                    }
                    ap.setTimeSlot(timeSlot);

                    if (apptDate != null) {
                        java.time.LocalTime defaultTime;
                        if (timeSlot != null && ("AM".equalsIgnoreCase(timeSlot) || "morning".equalsIgnoreCase(timeSlot))) {
                            defaultTime = java.time.LocalTime.of(8, 0);
                        } else if (timeSlot != null && ("PM".equalsIgnoreCase(timeSlot) || "afternoon".equalsIgnoreCase(timeSlot))) {
                            defaultTime = java.time.LocalTime.of(14, 0);
                        } else {
                            defaultTime = java.time.LocalTime.NOON;
                        }
                        ap.setAppointmentTime(LocalDateTime.of(apptDate.toLocalDate(), defaultTime));
                    }

                    ap.setStatus(rs.getString("status"));
                    ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                    ap.setVeterinarianName(rs.getString("veterinarian_name"));
                    ap.setService(rs.getString("service_name"));

                    Pet pet = new Pet();
                    pet.setPetId(rs.getInt("pet_id"));
                    pet.setName(rs.getString("pet_name"));
                    ap.setPet(pet);

                    list.add(ap);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Set<Integer> getPendingRescheduleAppointmentIdsByCustomer(int customerId) {
        Set<Integer> appointmentIds = new HashSet<>();
        String sql = """
            SELECT appointment_id
            FROM appointments
            WHERE customer_id = ?
              AND status = 'Reschedule-Requested'
        """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    appointmentIds.add(rs.getInt("appointment_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return appointmentIds;
    }

    public boolean createRescheduleRequest(int appointmentId, int customerId, LocalDateTime requestedAppointmentTime, String reason) {
        String derivedSlot = requestedAppointmentTime != null && requestedAppointmentTime.getHour() < 12
                ? "morning" : "afternoon";
        return createRescheduleRequest(appointmentId, customerId, requestedAppointmentTime, derivedSlot, reason);
    }

    public boolean createRescheduleRequest(int appointmentId, int customerId, LocalDateTime requestedAppointmentTime, String requestedTimeSlot, String reason) {
        String normalizedRequestedSlot = normalizeRequestedTimeSlot(requestedTimeSlot);
        if (requestedAppointmentTime == null || isPastDate(requestedAppointmentTime) || normalizedRequestedSlot == null) {
            return false;
        }

        String findSql = """
            SELECT appointment_time, status, pet_id
            FROM appointments
            WHERE appointment_id = ? AND customer_id = ?
        """;

        String updateStatusSql = """
            UPDATE appointments
            SET status = 'Reschedule-Requested'
            WHERE appointment_id = ? AND customer_id = ?
        """;

        String notifySql = """
            INSERT INTO Notifications (user_id, title, message)
            SELECT u.user_id, ?, ?
            FROM Receptionists r
            JOIN Users u ON r.user_id = u.user_id
            WHERE u.status = 'Active'
        """;

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            LocalDateTime oldTime;
            String currentStatus;
            int petId;
            try (PreparedStatement findPs = con.prepareStatement(findSql)) {
                findPs.setInt(1, appointmentId);
                findPs.setInt(2, customerId);
                try (ResultSet rs = findPs.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                    Timestamp oldTs = rs.getTimestamp("appointment_time");
                    if (oldTs == null) {
                        con.rollback();
                        return false;
                    }
                    oldTime = oldTs.toLocalDateTime();
                    currentStatus = rs.getString("status");
                    petId = rs.getInt("pet_id");
                }
            }

            boolean allowStatus = currentStatus != null
                    && ("Pending".equalsIgnoreCase(currentStatus)
                    || "Scheduled".equalsIgnoreCase(currentStatus)
                    || "Confirmed".equalsIgnoreCase(currentStatus));
            if (!allowStatus) {
                con.rollback();
                return false;
            }

            if ("Reschedule-Requested".equalsIgnoreCase(currentStatus)) {
                con.rollback();
                return false;
            }

            try (PreparedStatement updatePs = con.prepareStatement(updateStatusSql)) {
                updatePs.setInt(1, appointmentId);
                updatePs.setInt(2, customerId);
                if (updatePs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }

            String note = reason == null ? "" : reason.trim();
            if (note.length() > 600) {
                note = note.substring(0, 600);
            }

            String title = "Reschedule Request";
            String message = "appointmentId=" + appointmentId
                    + ";customerId=" + customerId
                    + ";petId=" + petId
                    + ";previousStatus=" + currentStatus
                    + ";oldTime=" + oldTime
                    + ";requestedSlot=" + normalizedRequestedSlot
                    + ";requestedTime=" + requestedAppointmentTime
                    + ";reason=" + note;

            try (PreparedStatement notifyPs = con.prepareStatement(notifySql)) {
                notifyPs.setString(1, title);
                notifyPs.setString(2, message);
                notifyPs.executeUpdate();
            }

            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean createDoctorChangeRequest(int appointmentId, int customerId, String preferredDoctor, String reason) {
        String findSql = """
            SELECT a.appointment_time, a.status, a.pet_id, a.veterinarian_id, vet_user.full_name AS veterinarian_name
            FROM appointments a
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            WHERE a.appointment_id = ? AND a.customer_id = ?
        """;

        String notifySql = """
            INSERT INTO Notifications (user_id, title, message)
            SELECT u.user_id, ?, ?
            FROM Receptionists r
            JOIN Users u ON r.user_id = u.user_id
            WHERE u.status = 'Active'
        """;

        String updateStatusSql = """
            UPDATE appointments
            SET status = 'Doctor-Change-Requested'
            WHERE appointment_id = ? AND customer_id = ?
        """;

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            LocalDateTime appointmentTime;
            String status;
            int petId;
            int currentVetId;
            String currentVetName;

            try (PreparedStatement findPs = con.prepareStatement(findSql)) {
                findPs.setInt(1, appointmentId);
                findPs.setInt(2, customerId);
                try (ResultSet rs = findPs.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    Timestamp ts = rs.getTimestamp("appointment_time");
                    if (ts == null) {
                        con.rollback();
                        return false;
                    }

                    appointmentTime = ts.toLocalDateTime();
                    status = rs.getString("status");
                    petId = rs.getInt("pet_id");
                    currentVetId = rs.getInt("veterinarian_id");
                    currentVetName = rs.getString("veterinarian_name");
                }
            }

            if (isPastDate(appointmentTime)) {
                con.rollback();
                return false;
            }

            boolean allowStatus = status != null
                    && ("Pending".equalsIgnoreCase(status)
                    || "Scheduled".equalsIgnoreCase(status)
                    || "Confirmed".equalsIgnoreCase(status)
                    || "Reschedule-Requested".equalsIgnoreCase(status));
            if (!allowStatus) {
                con.rollback();
                return false;
            }

            if ("Doctor-Change-Requested".equalsIgnoreCase(status)) {
                con.rollback();
                return false;
            }

            String preferred = preferredDoctor == null ? "" : preferredDoctor.trim();
            if (preferred.length() > 120) {
                preferred = preferred.substring(0, 120);
            }

            String note = reason == null ? "" : reason.trim();
            if (note.length() > 600) {
                note = note.substring(0, 600);
            }

            String title = "Doctor Change Request";
            String message = "appointmentId=" + appointmentId
                    + ";customerId=" + customerId
                    + ";petId=" + petId
                    + ";previousStatus=" + status
                    + ";currentVeterinarianId=" + currentVetId
                    + ";currentVeterinarianName=" + (currentVetName == null ? "" : currentVetName)
                    + ";preferredDoctor=" + preferred
                    + ";reason=" + note;

            try (PreparedStatement updatePs = con.prepareStatement(updateStatusSql)) {
                updatePs.setInt(1, appointmentId);
                updatePs.setInt(2, customerId);
                if (updatePs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }

            try (PreparedStatement notifyPs = con.prepareStatement(notifySql)) {
                notifyPs.setString(1, title);
                notifyPs.setString(2, message);
                if (notifyPs.executeUpdate() <= 0) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private Map<String, String> parseRequestPayload(String message) {
        Map<String, String> payload = new HashMap<>();
        if (message == null || message.isBlank()) {
            return payload;
        }

        String[] parts = message.split(";");
        for (String part : parts) {
            int idx = part.indexOf('=');
            if (idx <= 0) {
                continue;
            }
            String key = part.substring(0, idx).trim();
            String value = part.substring(idx + 1).trim();
            payload.put(key, value);
        }
        return payload;
    }

    public Map<String, String> getDoctorChangeRequestDetails(int appointmentId) {
        Map<String, String> details = new HashMap<>();
        try (Connection con = getConnection()) {
            String payloadRaw = getLatestRequestMessage(con, appointmentId, "Doctor Change Request");
            if (payloadRaw != null && !payloadRaw.isEmpty()) {
                details = parseRequestPayload(payloadRaw);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return details;
    }

    public Map<String, String> getRescheduleRequestDetails(int appointmentId) {
        Map<String, String> details = new HashMap<>();
        try (Connection con = getConnection()) {
            String payloadRaw = getLatestRequestMessage(con, appointmentId, "Reschedule Request");
            if (payloadRaw != null && !payloadRaw.isEmpty()) {
                details = parseRequestPayload(payloadRaw);
                String normalizedSlot = normalizeRequestedTimeSlot(details.get("requestedSlot"));
                if (normalizedSlot == null) {
                    String requestedTimeRaw = details.get("requestedTime");
                    if (requestedTimeRaw != null && !requestedTimeRaw.isBlank()) {
                        try {
                            LocalDateTime requestedTime = LocalDateTime.parse(requestedTimeRaw);
                            normalizedSlot = requestedTime.getHour() < 12 ? "morning" : "afternoon";
                        } catch (Exception ignored) {
                        }
                    }
                }
                if (normalizedSlot != null) {
                    details.put("requestedSlot", normalizedSlot);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return details;
    }

    public boolean createDoctorChangeRequest(int appointmentId, int customerId, int preferredVeterinarianId, String reason) {
        String findSql = """
            SELECT a.appointment_time, a.status, a.pet_id, a.veterinarian_id, vet_user.full_name AS veterinarian_name
            FROM appointments a
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            WHERE a.appointment_id = ? AND a.customer_id = ?
        """;

        String findVetSql = """
            SELECT u.full_name
            FROM veterinarians v
            JOIN users u ON v.user_id = u.user_id
            WHERE v.veterinarian_id = ?
        """;

        String notifySql = """
            INSERT INTO Notifications (user_id, title, message)
            SELECT u.user_id, ?, ?
            FROM Receptionists r
            JOIN Users u ON r.user_id = u.user_id
            WHERE u.status = 'Active'
        """;

        String updateStatusSql = """
            UPDATE appointments
            SET status = 'Doctor-Change-Requested'
            WHERE appointment_id = ? AND customer_id = ?
        """;

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            LocalDateTime appointmentTime;
            String status;
            int petId;
            int currentVetId;
            String currentVetName;

            try (PreparedStatement findPs = con.prepareStatement(findSql)) {
                findPs.setInt(1, appointmentId);
                findPs.setInt(2, customerId);
                try (ResultSet rs = findPs.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    Timestamp ts = rs.getTimestamp("appointment_time");
                    if (ts == null) {
                        con.rollback();
                        return false;
                    }

                    appointmentTime = ts.toLocalDateTime();
                    status = rs.getString("status");
                    petId = rs.getInt("pet_id");
                    currentVetId = rs.getInt("veterinarian_id");
                    currentVetName = rs.getString("veterinarian_name");
                }
            }

            if (isPastDate(appointmentTime)) {
                con.rollback();
                return false;
            }

            boolean allowStatus = status != null
                    && ("Pending".equalsIgnoreCase(status)
                    || "Scheduled".equalsIgnoreCase(status)
                    || "Confirmed".equalsIgnoreCase(status)
                    || "Reschedule-Requested".equalsIgnoreCase(status));
            if (!allowStatus) {
                con.rollback();
                return false;
            }

            if ("Doctor-Change-Requested".equalsIgnoreCase(status)) {
                con.rollback();
                return false;
            }

            String preferredVetName = "";
            try (PreparedStatement vetPs = con.prepareStatement(findVetSql)) {
                vetPs.setInt(1, preferredVeterinarianId);
                try (ResultSet rs = vetPs.executeQuery()) {
                    if (rs.next()) {
                        preferredVetName = rs.getString("full_name");
                    }
                }
            }

            String note = reason == null ? "" : reason.trim();
            if (note.length() > 600) {
                note = note.substring(0, 600);
            }

            String title = "Doctor Change Request";
            String message = "appointmentId=" + appointmentId
                    + ";customerId=" + customerId
                    + ";petId=" + petId
                    + ";previousStatus=" + status
                    + ";currentVeterinarianId=" + currentVetId
                    + ";currentVeterinarianName=" + (currentVetName == null ? "" : currentVetName)
                    + ";preferredVeterinarianId=" + preferredVeterinarianId
                    + ";preferredDoctor=" + (preferredVetName == null ? "" : preferredVetName)
                    + ";reason=" + note;

            try (PreparedStatement updatePs = con.prepareStatement(updateStatusSql)) {
                updatePs.setInt(1, appointmentId);
                updatePs.setInt(2, customerId);
                if (updatePs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }

            try (PreparedStatement notifyPs = con.prepareStatement(notifySql)) {
                notifyPs.setString(1, title);
                notifyPs.setString(2, message);
                if (notifyPs.executeUpdate() <= 0) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private String getLatestRequestMessage(Connection con, int appointmentId, String title) throws Exception {
        String sql = """
            SELECT TOP 1 message
            FROM Notifications
            WHERE title = ?
              AND message LIKE ?
                        ORDER BY created_at DESC, notification_id DESC
        """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, "%appointmentId=" + appointmentId + ";%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("message");
                }
            }
        }

        return null;
    }

    private String normalizePreviousStatus(String previousStatus) {
        if (previousStatus == null || previousStatus.isBlank()) {
            return "Scheduled";
        }
        return previousStatus;
    }

    private String normalizeRequestedTimeSlot(String requestedTimeSlot) {
        if (requestedTimeSlot == null || requestedTimeSlot.isBlank()) {
            return null;
        }
        String normalized = requestedTimeSlot.trim().toLowerCase();
        if ("morning".equals(normalized) || "am".equals(normalized)) {
            return "morning";
        }
        if ("afternoon".equals(normalized) || "pm".equals(normalized)) {
            return "afternoon";
        }
        return null;
    }

    private String toDisplayTimeSlot(String requestedTimeSlot) {
        String normalized = normalizeRequestedTimeSlot(requestedTimeSlot);
        if ("morning".equals(normalized)) {
            return "Morning";
        }
        if ("afternoon".equals(normalized)) {
            return "Afternoon";
        }
        return null;
    }

    private boolean isPastDate(LocalDateTime dateTime) {
        return dateTime != null && dateTime.toLocalDate().isBefore(LocalDate.now());
    }

    public boolean processRescheduleRequest(int appointmentId, boolean approve) {
        String findSql = """
            SELECT customer_id, status
            FROM appointments
            WHERE appointment_id = ?
        """;

        String updateApproveSql = """
            UPDATE appointments
            SET appointment_time = ?, status = 'Pending'
            WHERE appointment_id = ?
        """;

        String updateRejectSql = """
            UPDATE appointments
            SET status = ?
            WHERE appointment_id = ?
        """;

        String notifyCustomerSql = """
            INSERT INTO Notifications (user_id, title, message)
            SELECT u.user_id, ?, ?
            FROM appointments a
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            WHERE a.appointment_id = ?
        """;

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            String status;
            try (PreparedStatement findPs = con.prepareStatement(findSql)) {
                findPs.setInt(1, appointmentId);
                try (ResultSet rs = findPs.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                    status = rs.getString("status");
                }
            }

            if (!"Reschedule-Requested".equalsIgnoreCase(status)) {
                con.rollback();
                return false;
            }

            String payloadRaw = getLatestRequestMessage(con, appointmentId, "Reschedule Request");
            Map<String, String> payload = parseRequestPayload(payloadRaw);
            String previousStatus = normalizePreviousStatus(payload.get("previousStatus"));
            String requestedTimeRaw = payload.get("requestedTime");
            String requestedSlot = normalizeRequestedTimeSlot(payload.get("requestedSlot"));
            if (requestedSlot == null && requestedTimeRaw != null && !requestedTimeRaw.isBlank()) {
                try {
                    LocalDateTime requestedTime = LocalDateTime.parse(requestedTimeRaw);
                    requestedSlot = requestedTime.getHour() < 12 ? "morning" : "afternoon";
                } catch (Exception ignored) {
                }
            }

            boolean updated;
            if (approve) {
                if (requestedTimeRaw == null || requestedTimeRaw.isBlank()) {
                    con.rollback();
                    return false;
                }
                LocalDateTime requestedTime = LocalDateTime.parse(requestedTimeRaw);
                if (isPastDate(requestedTime)) {
                    con.rollback();
                    return false;
                }

                try (PreparedStatement updatePs = con.prepareStatement(updateApproveSql)) {
                    updatePs.setTimestamp(1, Timestamp.valueOf(requestedTime));
                    updatePs.setInt(2, appointmentId);
                    updated = updatePs.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement updatePs = con.prepareStatement(updateRejectSql)) {
                    updatePs.setString(1, previousStatus);
                    updatePs.setInt(2, appointmentId);
                    updated = updatePs.executeUpdate() > 0;
                }
            }

            if (!updated) {
                con.rollback();
                return false;
            }

            String title = approve ? "Reschedule Approved" : "Reschedule Rejected";
            String customerMessage;
            if (approve) {
                String displayDate = requestedTimeRaw;
                try {
                    LocalDateTime approvedTime = LocalDateTime.parse(requestedTimeRaw);
                    displayDate = approvedTime.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                } catch (Exception ignored) {
                }
                String displaySlot = toDisplayTimeSlot(requestedSlot);
                customerMessage = "Your reschedule request for appointment #" + appointmentId
                        + " has been approved. New slot: " + displayDate
                        + (displaySlot != null ? " (" + displaySlot + ")" : "") + ".";
            } else {
                customerMessage = "Your reschedule request for appointment #" + appointmentId
                        + " was rejected. Please keep your current schedule or submit a new request.";
            }
            try (PreparedStatement notifyPs = con.prepareStatement(notifyCustomerSql)) {
                notifyPs.setString(1, title);
                notifyPs.setString(2, customerMessage);
                notifyPs.setInt(3, appointmentId);
                if (notifyPs.executeUpdate() <= 0) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean processDoctorChangeRequest(int appointmentId, boolean approve) {
        return processDoctorChangeRequest(appointmentId, approve, null);
    }

    public boolean processDoctorChangeRequest(int appointmentId, boolean approve, Integer newVeterinarianId) {
        String findSql = """
            SELECT customer_id, status
            FROM appointments
            WHERE appointment_id = ?
        """;

        String updateSql = """
            UPDATE appointments
            SET status = ?
            WHERE appointment_id = ?
        """;

        String updateWithDoctorSql = """
            UPDATE appointments
            SET status = ?, veterinarian_id = ?
            WHERE appointment_id = ?
        """;

        String notifyCustomerSql = """
            INSERT INTO Notifications (user_id, title, message)
            SELECT u.user_id, ?, ?
            FROM appointments a
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            WHERE a.appointment_id = ?
        """;

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            String status;
            try (PreparedStatement findPs = con.prepareStatement(findSql)) {
                findPs.setInt(1, appointmentId);
                try (ResultSet rs = findPs.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                    status = rs.getString("status");
                }
            }

            if (!"Doctor-Change-Requested".equalsIgnoreCase(status)) {
                con.rollback();
                return false;
            }

            String payloadRaw = getLatestRequestMessage(con, appointmentId, "Doctor Change Request");
            Map<String, String> payload = parseRequestPayload(payloadRaw);
            String previousStatus = normalizePreviousStatus(payload.get("previousStatus"));

            // If newVeterinarianId is not provided and we're approving, try to extract from payload
            if (approve && (newVeterinarianId == null || newVeterinarianId <= 0)) {
                String preferredVetIdStr = payload.get("preferredVeterinarianId");
                if (preferredVetIdStr != null && !preferredVetIdStr.isEmpty()) {
                    try {
                        newVeterinarianId = Integer.parseInt(preferredVetIdStr);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            }

            if (approve && (newVeterinarianId == null || newVeterinarianId <= 0)) {
                con.rollback();
                return false;
            }

            if (approve) {
                try (PreparedStatement updatePs = con.prepareStatement(updateWithDoctorSql)) {
                    updatePs.setString(1, previousStatus);
                    updatePs.setInt(2, newVeterinarianId);
                    updatePs.setInt(3, appointmentId);
                    if (updatePs.executeUpdate() == 0) {
                        con.rollback();
                        return false;
                    }
                }
            } else {
                try (PreparedStatement updatePs = con.prepareStatement(updateSql)) {
                    updatePs.setString(1, previousStatus);
                    updatePs.setInt(2, appointmentId);
                    if (updatePs.executeUpdate() == 0) {
                        con.rollback();
                        return false;
                    }
                }
            }

            String title = approve ? "Doctor Change Approved" : "Doctor Change Rejected";
            String customerMessage = approve
                    ? "Your doctor change request for appointment #" + appointmentId + " has been approved."
                    : "Your doctor change request for appointment #" + appointmentId + " was rejected.";
            try (PreparedStatement notifyPs = con.prepareStatement(notifyCustomerSql)) {
                notifyPs.setString(1, title);
                notifyPs.setString(2, customerMessage);
                notifyPs.setInt(3, appointmentId);
                if (notifyPs.executeUpdate() <= 0) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
