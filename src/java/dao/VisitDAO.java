package dao;

import model.Visit;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Visit CRUD. Visits are created when a vet starts an examination (or when receptionist checks in).
 */
public class VisitDAO extends DBContext {

    /** Returns appointment_id values that have a visit (for staff queue to show Check-in vs Checked in). */
    public Set<Integer> getAppointmentIdsWithVisit(Set<Integer> appointmentIds) {
        Set<Integer> out = new HashSet<>();
        if (appointmentIds == null || appointmentIds.isEmpty()) return out;
        List<Integer> ids = new ArrayList<>(appointmentIds);
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < ids.size(); i++) placeholders.append(i > 0 ? ",?" : "?");
        String sql = "SELECT appointment_id FROM Visits WHERE appointment_id IN (" + placeholders.toString() + ")";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < ids.size(); i++) ps.setInt(i + 1, ids.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(rs.getInt("appointment_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }

    public Visit getByAppointmentId(int appointmentId) {
        String sql = "SELECT visit_id, appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, staff_id, veterinarian_id FROM Visits WHERE appointment_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Visit getByVisitId(int visitId) {
        String sql = "SELECT visit_id, appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, staff_id, veterinarian_id FROM Visits WHERE visit_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, visitId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Creates a visit when receptionist checks in: status Checked-in, staff_id set. */
    public Visit createForCheckIn(int appointmentId, int petId, int customerId, int veterinarianId, int staffId) {
        String sql = "INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, visit_status, staff_id, veterinarian_id) OUTPUT INSERTED.visit_id VALUES (?, ?, ?, GETDATE(), 'Checked-in', ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, petId);
            ps.setInt(3, customerId);
            ps.setInt(4, staffId);
            ps.setInt(5, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Visit v = new Visit();
                    v.setVisitId(rs.getInt(1));
                    v.setAppointmentId(appointmentId);
                    v.setPetId(petId);
                    v.setCustomerId(customerId);
                    v.setStaffId(staffId);
                    v.setVeterinarianId(veterinarianId);
                    v.setVisitStatus("Checked-in");
                    return v;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Updates visit status (e.g. to In-Examination when vet starts). */
    public boolean updateStatus(int visitId, String status) {
        String sql = "UPDATE Visits SET visit_status = ? WHERE visit_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, visitId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Marks visit as completed: sets check_out_time and visit_status = 'Completed'. */
    public boolean completeVisit(int visitId) {
        String sql = "UPDATE Visits SET check_out_time = GETDATE(), visit_status = 'Completed' WHERE visit_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, visitId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Visit mapRow(ResultSet rs) throws SQLException {
        Visit v = new Visit();
        v.setVisitId(rs.getInt("visit_id"));
        v.setAppointmentId(rs.getObject("appointment_id") != null ? rs.getInt("appointment_id") : null);
        v.setPetId(rs.getInt("pet_id"));
        v.setCustomerId(rs.getInt("customer_id"));
        Timestamp t = rs.getTimestamp("check_in_time");
        if (t != null) v.setCheckInTime(t.toLocalDateTime());
        t = rs.getTimestamp("check_out_time");
        if (t != null) v.setCheckOutTime(t.toLocalDateTime());
        v.setVisitStatus(rs.getString("visit_status"));
        v.setStaffId(rs.getObject("staff_id") != null ? rs.getInt("staff_id") : null);
        v.setVeterinarianId(rs.getObject("veterinarian_id") != null ? rs.getInt("veterinarian_id") : null);
        return v;
    }
}
