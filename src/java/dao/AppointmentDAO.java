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
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO extends DBContext {

    public List<Appointment> getAllAppointments() {
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
                ap.setAppointmentTime(
                        rs.getTimestamp("appointment_time").toLocalDateTime()
                );
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
                cus.setUser(customerUser);
                ap.setCustomer(cus);
                
                String vetName = rs.getString("veterinarian_name");
                if (vetName != null) {
                    ap.setVeterinarianName(vetName);
                }

                list.add(ap);
            }

        }catch (Exception e) {
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

    private List<Appointment> getAppointmentsForDateByVeterinarianAllStatuses(LocalDate date, int veterinarianId) {
        if (veterinarianId <= 0) return new ArrayList<>();
        List<Appointment> list = new ArrayList<>();
        String sql = """
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
            WHERE p.isDeleted = 0 AND CAST(a.appointment_time AS DATE) = ? AND a.veterinarian_id = ?
              AND a.status IN ('Confirmed', 'Checked-in', 'Scheduled')
            ORDER BY a.appointment_time
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, date);
            ps.setInt(2, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment ap = mapAppointmentFromRs(rs);
                    list.add(ap);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private Appointment mapAppointmentFromRs(ResultSet rs) throws SQLException {
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
        return ap;
    }

    /** Count today's appointments for a vet. */
    public int countTodayAppointmentsByVet(int veterinarianId) {
        if (veterinarianId <= 0) return 0;
        String sql = "SELECT COUNT(*) FROM appointments a JOIN pets p ON a.pet_id = p.pet_id WHERE p.isDeleted = 0 AND CAST(a.appointment_time AS DATE) = CAST(GETDATE() AS DATE) AND a.veterinarian_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /** Count today's appointments with service containing 'Surgery' for a vet. */
    public int countSurgeriesTodayByVet(int veterinarianId) {
        if (veterinarianId <= 0) return 0;
        String sql = """
            SELECT COUNT(*) FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0 AND CAST(a.appointment_time AS DATE) = CAST(GETDATE() AS DATE)
              AND a.veterinarian_id = ? AND (s.name LIKE '%Surgery%' OR s.name LIKE '%surgery%')
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /** Count follow-up appointments this week (today through +7 days) for a vet. */
    public int countFollowUpsThisWeek(int veterinarianId) {
        if (veterinarianId <= 0) return 0;
        String sql = """
            SELECT COUNT(*) FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            WHERE p.isDeleted = 0 AND a.veterinarian_id = ?
              AND CAST(a.appointment_time AS DATE) > CAST(GETDATE() AS DATE)
              AND CAST(a.appointment_time AS DATE) <= DATEADD(day, 7, CAST(GETDATE() AS DATE))
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public Appointment getAppointmentDetail(int appointmentId) {
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
                    ap.setAppointmentTime(rs.getTimestamp("appointment_time").toLocalDateTime());
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
        }catch (Exception e) {
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

    public boolean updateAppointmentDoctor(int appointmentId, int veterinarianId) {
        String sql = "UPDATE appointments SET veterinarian_id = ? WHERE appointment_id = ?";
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, veterinarianId);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Updates the status of an appointment (e.g. Completed, Cancelled). */
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
}
