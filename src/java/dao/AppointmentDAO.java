package dao;

import model.Appointment;
import model.Customer;
import model.Pet;
import model.User;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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

    public Appointment getAppointmentDetail(int appointmentId) {
        String sql = """
            SELECT
                a.appointment_id,
                a.appointment_time,
                a.status,
                a.veterinarian_id,
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

    public List<Appointment> getAppointmentsByCustomerId(int customerId) {
        List<Appointment> list = new ArrayList<>();

        String sql = """
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

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
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
        if (requestedAppointmentTime == null || requestedAppointmentTime.isBefore(LocalDateTime.now())) {
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
                    || "Confirmed".equalsIgnoreCase(currentStatus)
                    || "Re-Scheduled".equalsIgnoreCase(currentStatus)
                    || "Rescheduled".equalsIgnoreCase(currentStatus));
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
                    + ";oldTime=" + oldTime
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

        try (Connection con = getConnection()) {
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
                        return false;
                    }

                    Timestamp ts = rs.getTimestamp("appointment_time");
                    if (ts == null) {
                        return false;
                    }

                    appointmentTime = ts.toLocalDateTime();
                    status = rs.getString("status");
                    petId = rs.getInt("pet_id");
                    currentVetId = rs.getInt("veterinarian_id");
                    currentVetName = rs.getString("veterinarian_name");
                }
            }

            if (appointmentTime.isBefore(LocalDateTime.now())) {
                return false;
            }

            boolean allowStatus = status != null
                    && ("Pending".equalsIgnoreCase(status)
                    || "Scheduled".equalsIgnoreCase(status)
                    || "Confirmed".equalsIgnoreCase(status)
                    || "Re-Scheduled".equalsIgnoreCase(status)
                    || "Rescheduled".equalsIgnoreCase(status)
                    || "Reschedule-Requested".equalsIgnoreCase(status));
            if (!allowStatus) {
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
                    + ";currentVeterinarianId=" + currentVetId
                    + ";currentVeterinarianName=" + (currentVetName == null ? "" : currentVetName)
                    + ";preferredDoctor=" + preferred
                    + ";reason=" + note;

            try (PreparedStatement notifyPs = con.prepareStatement(notifySql)) {
                notifyPs.setString(1, title);
                notifyPs.setString(2, message);
                return notifyPs.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
