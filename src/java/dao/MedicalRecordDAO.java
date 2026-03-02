package dao;

import model.MedicalRecord;
import model.MedicalRecordSummary;
import model.Prescription;
import model.RecordServiceLine;
import utils.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Medical records, record services, and prescriptions. Maps to MedicalRecords, MedicalRecordServices, Prescriptions.
 */
public class MedicalRecordDAO extends DBContext {

    public MedicalRecord getByVisitId(int visitId) {
        String sql = "SELECT record_id, visit_id, veterinarian_id, diagnosis, treatment, note, created_at FROM MedicalRecords WHERE visit_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, visitId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRecord(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Get a medical record by its primary key. */
    public MedicalRecord getByRecordId(int recordId) {
        String sql = "SELECT record_id, visit_id, veterinarian_id, diagnosis, treatment, note, created_at FROM MedicalRecords WHERE record_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRecord(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Creates a medical record and returns it with recordId set. */
    public MedicalRecord create(int visitId, int veterinarianId, String diagnosis, String treatment, String note) {
        String sql = "INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note, created_at) OUTPUT INSERTED.record_id VALUES (?, ?, ?, ?, ?, GETDATE())";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, visitId);
            ps.setInt(2, veterinarianId);
            ps.setString(3, diagnosis);
            ps.setString(4, treatment);
            ps.setString(5, note);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MedicalRecord r = new MedicalRecord();
                    r.setRecordId(rs.getInt(1));
                    r.setVisitId(visitId);
                    r.setVeterinarianId(veterinarianId);
                    r.setDiagnosis(diagnosis);
                    r.setTreatment(treatment);
                    r.setNote(note);
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Updates existing record (diagnosis, treatment, note). */
    public boolean update(int recordId, String diagnosis, String treatment, String note) {
        String sql = "UPDATE MedicalRecords SET diagnosis = ?, treatment = ?, note = ? WHERE record_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, diagnosis);
            ps.setString(2, treatment);
            ps.setString(3, note);
            ps.setInt(4, recordId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void addService(int recordId, int serviceId, int quantity, double price) {
        String sql = "INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price) VALUES (?, ?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ps.setInt(2, serviceId);
            ps.setInt(3, quantity);
            ps.setDouble(4, price);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void addPrescription(int recordId, String medicineName, String dosage, String duration) {
        String sql = "INSERT INTO Prescriptions (record_id, medicine_name, dosage, duration) VALUES (?, ?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ps.setString(2, medicineName);
            ps.setString(3, dosage);
            ps.setString(4, duration);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Prescription> getPrescriptionsByRecordId(int recordId) {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT prescription_id, record_id, medicine_name, dosage, duration FROM Prescriptions WHERE record_id = ? ORDER BY prescription_id";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Prescription p = new Prescription();
                    p.setPrescriptionId(rs.getInt("prescription_id"));
                    p.setRecordId(rs.getInt("record_id"));
                    p.setMedicineName(rs.getString("medicine_name"));
                    p.setDosage(rs.getString("dosage"));
                    p.setDuration(rs.getString("duration"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void deletePrescriptionsByRecordId(int recordId) {
        String sql = "DELETE FROM Prescriptions WHERE record_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<RecordServiceLine> getServicesForRecord(int recordId) {
        List<RecordServiceLine> list = new ArrayList<>();
        String sql = "SELECT mrs.record_service_id, mrs.record_id, mrs.service_id, s.name AS service_name, mrs.quantity, mrs.price FROM MedicalRecordServices mrs JOIN Services s ON mrs.service_id = s.service_id WHERE mrs.record_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RecordServiceLine line = new RecordServiceLine();
                    line.setRecordServiceId(rs.getInt("record_service_id"));
                    line.setRecordId(rs.getInt("record_id"));
                    line.setServiceId(rs.getInt("service_id"));
                    line.setServiceName(rs.getString("service_name"));
                    line.setQuantity(rs.getInt("quantity"));
                    line.setPrice(rs.getObject("price") != null ? rs.getDouble("price") : null);
                    list.add(line);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void deleteRecordServices(int recordId) {
        String sql = "DELETE FROM MedicalRecordServices WHERE record_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Recent medical records for a veterinarian, joined with pet and appointment info. */
    public List<MedicalRecordSummary> getRecentRecordsByVeterinarian(int veterinarianId, int limit) {
        List<MedicalRecordSummary> list = new ArrayList<>();
        String sql = """
            SELECT TOP (?) mr.record_id,
                           v.visit_id,
                           v.appointment_id,
                           v.pet_id,
                           p.name AS pet_name,
                           mr.created_at,
                           u.full_name AS veterinarian_name,
                           mr.diagnosis
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Veterinarians vet ON mr.veterinarian_id = vet.veterinarian_id
            JOIN Users u ON vet.user_id = u.user_id
            WHERE mr.veterinarian_id = ?
            ORDER BY mr.created_at DESC
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MedicalRecordSummary s = new MedicalRecordSummary();
                    s.setRecordId(rs.getInt("record_id"));
                    int petId = rs.getInt("pet_id");
                    s.setPetId(petId);
                    s.setAppointmentId(rs.getInt("appointment_id"));
                    s.setPatientCode("PA-" + petId);
                    s.setPetName(rs.getString("pet_name"));
                    Timestamp t = rs.getTimestamp("created_at");
                    if (t != null) s.setExaminationDate(t.toLocalDateTime());
                    s.setVeterinarianName(rs.getString("veterinarian_name"));
                    s.setPrimaryDiagnosis(rs.getString("diagnosis"));
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private MedicalRecord mapRecord(ResultSet rs) throws SQLException {
        MedicalRecord r = new MedicalRecord();
        r.setRecordId(rs.getInt("record_id"));
        r.setVisitId(rs.getInt("visit_id"));
        r.setVeterinarianId(rs.getInt("veterinarian_id"));
        r.setDiagnosis(rs.getString("diagnosis"));
        r.setTreatment(rs.getString("treatment"));
        r.setNote(rs.getString("note"));
        Timestamp t = rs.getTimestamp("created_at");
        if (t != null) r.setCreatedAt(t.toLocalDateTime());
        return r;
    }

    /**
     * Medical records for a given customer (owner), only for visits whose appointment is Done/Paid.
     */
    public List<MedicalRecordSummary> getRecordsForCustomer(int customerId) {
        List<MedicalRecordSummary> list = new ArrayList<>();
        String sql = """
            SELECT mr.record_id,
                   v.visit_id,
                   v.appointment_id,
                   v.pet_id,
                   p.name AS pet_name,
                   mr.created_at,
                   u.full_name AS veterinarian_name,
                   mr.diagnosis
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Appointments a ON v.appointment_id = a.appointment_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Veterinarians vet ON mr.veterinarian_id = vet.veterinarian_id
            JOIN Users u ON vet.user_id = u.user_id
            WHERE v.customer_id = ? AND (a.status = 'Done' OR a.status = 'Completed')
            ORDER BY mr.created_at DESC
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MedicalRecordSummary s = new MedicalRecordSummary();
                    s.setRecordId(rs.getInt("record_id"));
                    int petId = rs.getInt("pet_id");
                    s.setPetId(petId);
                    s.setAppointmentId(rs.getInt("appointment_id"));
                    s.setPatientCode("PA-" + petId);
                    s.setPetName(rs.getString("pet_name"));
                    Timestamp t = rs.getTimestamp("created_at");
                    if (t != null) s.setExaminationDate(t.toLocalDateTime());
                    s.setVeterinarianName(rs.getString("veterinarian_name"));
                    s.setPrimaryDiagnosis(rs.getString("diagnosis"));
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
