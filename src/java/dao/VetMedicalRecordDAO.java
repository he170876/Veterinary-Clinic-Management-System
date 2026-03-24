package dao;

import model.MedicalRecord;
import model.MedicalRecordSummary;
import model.Prescription;
import model.RecordServiceLine;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.ResultSetMetaData;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Medical records, record services, and prescriptions for vet/customer record-detail flows.
 */
public class VetMedicalRecordDAO extends DBContext {

    private boolean hasClinicalConditionColumn(Connection con) {
        String sql = """
            SELECT 1
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = 'MedicalRecords' AND COLUMN_NAME = 'clinical_condition'
            """;
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next();
        } catch (Exception e) {
            return false;
        }
    }

    private boolean hasColumn(ResultSet rs, String columnName) {
        try {
            ResultSetMetaData meta = rs.getMetaData();
            int count = meta.getColumnCount();
            for (int i = 1; i <= count; i++) {
                if (columnName.equalsIgnoreCase(meta.getColumnLabel(i))
                        || columnName.equalsIgnoreCase(meta.getColumnName(i))) {
                    return true;
                }
            }
        } catch (SQLException ignored) {
        }
        return false;
    }

    public MedicalRecord getByVisitId(int visitId) {
        String sqlWithCondition = "SELECT record_id, visit_id, veterinarian_id, diagnosis, treatment, note, clinical_condition, created_at FROM MedicalRecords WHERE visit_id = ?";
        String sqlLegacy = "SELECT record_id, visit_id, veterinarian_id, diagnosis, treatment, note, created_at FROM MedicalRecords WHERE visit_id = ?";
        try (Connection con = getConnection()) {
            String sql = hasClinicalConditionColumn(con) ? sqlWithCondition : sqlLegacy;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, visitId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapRecord(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public MedicalRecord getByRecordId(int recordId) {
        String sqlWithCondition = "SELECT record_id, visit_id, veterinarian_id, diagnosis, treatment, note, clinical_condition, created_at FROM MedicalRecords WHERE record_id = ?";
        String sqlLegacy = "SELECT record_id, visit_id, veterinarian_id, diagnosis, treatment, note, created_at FROM MedicalRecords WHERE record_id = ?";
        try (Connection con = getConnection()) {
            String sql = hasClinicalConditionColumn(con) ? sqlWithCondition : sqlLegacy;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, recordId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapRecord(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public MedicalRecord create(int visitId, int veterinarianId, String diagnosis, String treatment, String note, String clinicalCondition) {
        String sqlWithCondition = "INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note, clinical_condition, created_at) OUTPUT INSERTED.record_id VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        String sqlLegacy = "INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note, created_at) OUTPUT INSERTED.record_id VALUES (?, ?, ?, ?, ?, GETDATE())";
        try (Connection con = getConnection()) {
            boolean hasCondition = hasClinicalConditionColumn(con);
            String sql = hasCondition ? sqlWithCondition : sqlLegacy;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, visitId);
                ps.setInt(2, veterinarianId);
                ps.setString(3, diagnosis);
                ps.setString(4, treatment);
                ps.setString(5, note);
                if (hasCondition) {
                    ps.setString(6, clinicalCondition);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        MedicalRecord r = new MedicalRecord();
                        r.setRecordId(rs.getInt(1));
                        r.setVisitId(visitId);
                        r.setVeterinarianId(veterinarianId);
                        r.setDiagnosis(diagnosis);
                        r.setTreatment(treatment);
                        r.setNote(note);
                        r.setClinicalCondition(clinicalCondition);
                        return r;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean update(int recordId, String diagnosis, String treatment, String note, String clinicalCondition) {
        String sqlWithCondition = "UPDATE MedicalRecords SET diagnosis = ?, treatment = ?, note = ?, clinical_condition = ? WHERE record_id = ?";
        String sqlLegacy = "UPDATE MedicalRecords SET diagnosis = ?, treatment = ?, note = ? WHERE record_id = ?";
        try (Connection con = getConnection()) {
            boolean hasCondition = hasClinicalConditionColumn(con);
            String sql = hasCondition ? sqlWithCondition : sqlLegacy;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, diagnosis);
                ps.setString(2, treatment);
                ps.setString(3, note);
                if (hasCondition) {
                    ps.setString(4, clinicalCondition);
                    ps.setInt(5, recordId);
                } else {
                    ps.setInt(4, recordId);
                }
                return ps.executeUpdate() > 0;
            }
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

    public List<MedicalRecordSummary> getEarliestRecordsByVeterinarian(int veterinarianId, int limit, String query) {
        List<MedicalRecordSummary> list = new ArrayList<>();
        if (limit <= 0) limit = 10;
        if (query == null) query = "";
        query = query.trim();

        String sql = """
            SELECT TOP (?) mr.record_id,
                           v.visit_id,
                           v.appointment_id,
                           v.pet_id,
                           p.name AS pet_name,
                           cu.full_name AS owner_name,
                           mr.created_at,
                           u.full_name AS veterinarian_name,
                           mr.diagnosis
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users cu ON c.user_id = cu.user_id
            JOIN Veterinarians vet ON mr.veterinarian_id = vet.veterinarian_id
            JOIN Users u ON vet.user_id = u.user_id
            WHERE mr.veterinarian_id = ?
              AND ( ? = ''
                    OR p.name LIKE ?
                    OR cu.full_name LIKE ?
                    OR CAST(mr.record_id AS NVARCHAR(20)) = ? )
            ORDER BY mr.created_at ASC, mr.record_id ASC
            """;

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, veterinarianId);
            ps.setString(3, query);
            String like = "%" + query + "%";
            ps.setString(4, like);
            ps.setString(5, like);
            ps.setString(6, query);
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

    public int countRecordsByVeterinarian(int veterinarianId, String query) {
        if (query == null) query = "";
        query = query.trim();

        String sql = """
            SELECT COUNT(*)
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users cu ON c.user_id = cu.user_id
            WHERE mr.veterinarian_id = ?
              AND ( ? = ''
                    OR p.name LIKE ?
                    OR cu.full_name LIKE ?
                    OR CAST(mr.record_id AS NVARCHAR(20)) = ? )
            """;

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, veterinarianId);
            ps.setString(2, query);
            String like = "%" + query + "%";
            ps.setString(3, like);
            ps.setString(4, like);
            ps.setString(5, query);
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

    public List<MedicalRecordSummary> getRecordsPageByVeterinarian(int veterinarianId, int offset, int pageSize, String query) {
        List<MedicalRecordSummary> list = new ArrayList<>();
        if (pageSize <= 0) pageSize = 10;
        if (offset < 0) offset = 0;
        if (query == null) query = "";
        query = query.trim();

        String sql = """
            SELECT mr.record_id,
                   v.visit_id,
                   v.appointment_id,
                   v.pet_id,
                   p.name AS pet_name,
                   cu.full_name AS owner_name,
                   mr.created_at,
                   u.full_name AS veterinarian_name,
                   mr.diagnosis
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users cu ON c.user_id = cu.user_id
            JOIN Veterinarians vet ON mr.veterinarian_id = vet.veterinarian_id
            JOIN Users u ON vet.user_id = u.user_id
            WHERE mr.veterinarian_id = ?
              AND ( ? = ''
                    OR p.name LIKE ?
                    OR cu.full_name LIKE ?
                    OR CAST(mr.record_id AS NVARCHAR(20)) = ? )
                        ORDER BY mr.created_at DESC, mr.record_id DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
            """;

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, veterinarianId);
            ps.setString(2, query);
            String like = "%" + query + "%";
            ps.setString(3, like);
            ps.setString(4, like);
            ps.setString(5, query);
            ps.setInt(6, offset);
            ps.setInt(7, pageSize);
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
                        -- Customer can view records after completion/payment confirmation.
                        -- Support both Done and Completed statuses.
                        WHERE v.customer_id = ?
                            AND LOWER(COALESCE(a.status, '')) IN ('done', 'completed')
            ORDER BY mr.created_at DESC, mr.record_id DESC
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

    private MedicalRecord mapRecord(ResultSet rs) throws SQLException {
        MedicalRecord r = new MedicalRecord();
        r.setRecordId(rs.getInt("record_id"));
        r.setVisitId(rs.getInt("visit_id"));
        r.setVeterinarianId(rs.getInt("veterinarian_id"));
        r.setDiagnosis(rs.getString("diagnosis"));
        r.setTreatment(rs.getString("treatment"));
        r.setNote(rs.getString("note"));
        if (hasColumn(rs, "clinical_condition")) {
            r.setClinicalCondition(rs.getString("clinical_condition"));
        }
        Timestamp t = rs.getTimestamp("created_at");
        if (t != null) r.setCreatedAt(t.toLocalDateTime());
        return r;
    }
}
