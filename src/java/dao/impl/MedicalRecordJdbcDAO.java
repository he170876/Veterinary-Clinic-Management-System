package dao.impl;

import dao.BaseDAO;
import dao.MedicalRecordDAO;
import model.MedicalRecord;
import model.Pet;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * JDBC implementation of {@link MedicalRecordDAO} for SQL Server.
 * Handles retrieval of medical history for pets and customers.
 */
public class MedicalRecordJdbcDAO extends BaseDAO implements MedicalRecordDAO {

    @Override
    public List<MedicalRecord> getMedicalHistoryByPet(int petId) {
        List<MedicalRecord> records = new ArrayList<>();
        String sql = """
            SELECT 
                mr.record_id,
                mr.visit_id,
                mr.veterinarian_id,
                u.full_name AS veterinarian_name,
                mr.diagnosis,
                mr.treatment,
                mr.note,
                mr.clinical_condition,
                v.check_in_time AS visit_date,
                v.visit_status,
                p.pet_id,
                p.name AS pet_name,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            LEFT JOIN Users u ON mr.veterinarian_id = u.user_id
            WHERE p.pet_id = ?
            ORDER BY v.check_in_time DESC
            """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, petId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(mapRowToMedicalRecord(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return records;
    }

    @Override
    public List<MedicalRecord> getMedicalHistoryByCustomer(int customerId) {
        List<MedicalRecord> records = new ArrayList<>();
        String sql = """
            SELECT 
                mr.record_id,
                mr.visit_id,
                mr.veterinarian_id,
                u.full_name AS veterinarian_name,
                mr.diagnosis,
                mr.treatment,
                mr.note,
                mr.clinical_condition,
                v.check_in_time AS visit_date,
                v.visit_status,
                p.pet_id,
                p.name AS pet_name,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            LEFT JOIN Users u ON mr.veterinarian_id = u.user_id
            WHERE v.customer_id = ?
            ORDER BY v.check_in_time DESC
            """;

        System.out.println("[MedicalRecordDAO] Getting medical history for customer_id: " + customerId);
        System.out.println("[MedicalRecordDAO] SQL Query: " + sql);
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(mapRowToMedicalRecord(rs));
                }
            }
            System.out.println("[MedicalRecordDAO] Found " + records.size() + " records for customer_id: " + customerId);
        } catch (SQLException ex) {
            System.err.println("[MedicalRecordDAO] ERROR getting medical history for customer_id " + customerId + ": " + ex.getMessage());
            ex.printStackTrace();
        }
        return records;
    }

    @Override
    public Optional<MedicalRecord> getMedicalRecordById(int recordId) {
        String sql = """
            SELECT 
                mr.record_id,
                mr.visit_id,
                mr.veterinarian_id,
                u.full_name AS veterinarian_name,
                mr.diagnosis,
                mr.treatment,
                mr.note,
                mr.clinical_condition,
                v.check_in_time AS visit_date,
                v.visit_status,
                p.pet_id,
                p.name AS pet_name,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            LEFT JOIN Users u ON mr.veterinarian_id = u.user_id
            WHERE mr.record_id = ?
            """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToMedicalRecord(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public Optional<MedicalRecord> getMedicalRecordByIdAndCustomer(int recordId, int customerId) {
        String sql = """
            SELECT 
                mr.record_id,
                mr.visit_id,
                mr.veterinarian_id,
                u.full_name AS veterinarian_name,
                mr.diagnosis,
                mr.treatment,
                mr.note,
                mr.clinical_condition,
                v.check_in_time AS visit_date,
                v.visit_status,
                p.pet_id,
                p.name AS pet_name,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            LEFT JOIN Users u ON mr.veterinarian_id = u.user_id
            WHERE mr.record_id = ?
              AND v.customer_id = ?
            """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToMedicalRecord(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public List<MedicalRecord> getRecentMedicalHistory(int petId, int limit) {
        List<MedicalRecord> records = new ArrayList<>();
        String sql = """
            SELECT TOP (?)
                mr.record_id,
                mr.visit_id,
                mr.veterinarian_id,
                u.full_name AS veterinarian_name,
                mr.diagnosis,
                mr.treatment,
                mr.note,
                mr.clinical_condition,
                v.check_in_time AS visit_date,
                v.visit_status,
                p.pet_id,
                p.name AS pet_name,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            LEFT JOIN Users u ON mr.veterinarian_id = u.user_id
            WHERE p.pet_id = ?
            ORDER BY v.check_in_time DESC
            """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, petId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(mapRowToMedicalRecord(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return records;
    }

    @Override
    public List<MedicalRecord> getRecentMedicalHistoryByCustomer(int customerId, int limit) {
        List<MedicalRecord> records = new ArrayList<>();
        String sql = """
            SELECT TOP (?)
                mr.record_id,
                mr.visit_id,
                mr.veterinarian_id,
                u.full_name AS veterinarian_name,
                mr.diagnosis,
                mr.treatment,
                mr.note,
                mr.clinical_condition,
                v.check_in_time AS visit_date,
                v.visit_status,
                p.pet_id,
                p.name AS pet_name,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            LEFT JOIN Users u ON mr.veterinarian_id = u.user_id
            WHERE v.customer_id = ?
            ORDER BY v.check_in_time DESC
            """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(mapRowToMedicalRecord(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return records;
    }

    /**
     * Map a ResultSet row to a MedicalRecord object.
     */
    private MedicalRecord mapRowToMedicalRecord(ResultSet rs) throws SQLException {
        MedicalRecord record = new MedicalRecord();
        record.setRecordId(rs.getInt("record_id"));
        record.setVisitId(rs.getInt("visit_id"));
        record.setVeterinarianId(rs.getInt("veterinarian_id"));
        record.setVeterinarianName(rs.getString("veterinarian_name"));
        record.setDiagnosis(rs.getString("diagnosis"));
        record.setTreatment(rs.getString("treatment"));
        record.setNote(rs.getString("note"));
        record.setClinicalCondition(rs.getString("clinical_condition"));
        
        Timestamp visitDate = rs.getTimestamp("visit_date");
        if (visitDate != null) {
            record.setVisitDate(visitDate.toLocalDateTime());
        }
        record.setVisitStatus(rs.getString("visit_status"));

        // Map Pet object
        Pet pet = new Pet();
        pet.setPetId(rs.getInt("pet_id"));
        pet.setName(rs.getString("pet_name"));
        pet.setSpecies(rs.getString("species"));
        pet.setBreed(rs.getString("breed"));
        pet.setGender(rs.getString("gender"));
        
        java.sql.Date birthDate = rs.getDate("birth_date");
        if (birthDate != null) {
            pet.setBirthDate(birthDate.toLocalDate());
        }
        pet.setWeight(rs.getDouble("weight"));
        record.setPet(pet);

        return record;
    }
    
    @Override
    public List<MedicalRecord> getMedicalRecordsWithFilter(int customerId, Integer petId, 
            LocalDateTime startDate, LocalDateTime endDate, int offset, int limit) {
        List<MedicalRecord> records = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT 
                mr.record_id,
                mr.visit_id,
                mr.veterinarian_id,
                u.full_name AS veterinarian_name,
                mr.diagnosis,
                mr.treatment,
                mr.note,
                mr.clinical_condition,
                v.check_in_time AS visit_date,
                v.visit_status,
                p.pet_id,
                p.name AS pet_name,
                p.species,
                p.breed,
                p.gender,
                p.birth_date,
                p.weight
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Appointments a ON v.appointment_id = a.appointment_id
            JOIN Pets p ON v.pet_id = p.pet_id
            LEFT JOIN Users u ON mr.veterinarian_id = u.user_id
                        -- Only show to customer after completion/payment confirmation.
                        -- Support both legacy and current status values.
                        WHERE v.customer_id = ?
                            AND LOWER(COALESCE(a.status, '')) IN ('done', 'completed')
            """);
        
        if (petId != null) {
            sql.append(" AND p.pet_id = ?");
        }
        if (startDate != null) {
            sql.append(" AND v.check_in_time >= ?");
        }
        if (endDate != null) {
            sql.append(" AND v.check_in_time <= ?");
        }
        
        sql.append(" ORDER BY v.check_in_time DESC");
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, customerId);
            
            if (petId != null) {
                ps.setInt(paramIndex++, petId);
            }
            if (startDate != null) {
                ps.setTimestamp(paramIndex++, Timestamp.valueOf(startDate));
            }
            if (endDate != null) {
                ps.setTimestamp(paramIndex++, Timestamp.valueOf(endDate));
            }
            
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex++, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(mapRowToMedicalRecord(rs));
                }
            }
        } catch (SQLException ex) {
            System.err.println("[MedicalRecordDAO] ERROR in getMedicalRecordsWithFilter: " + ex.getMessage());
            ex.printStackTrace();
        }
        return records;
    }
    
    @Override
    public int countMedicalRecordsWithFilter(int customerId, Integer petId, 
            LocalDateTime startDate, LocalDateTime endDate) {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) as total
            FROM MedicalRecords mr
            JOIN Visits v ON mr.visit_id = v.visit_id
            JOIN Appointments a ON v.appointment_id = a.appointment_id
            JOIN Pets p ON v.pet_id = p.pet_id
                        -- Only show to customer after completion/payment confirmation.
                        -- Support both legacy and current status values.
                        WHERE v.customer_id = ?
                            AND LOWER(COALESCE(a.status, '')) IN ('done', 'completed')
            """);
        
        if (petId != null) {
            sql.append(" AND p.pet_id = ?");
        }
        if (startDate != null) {
            sql.append(" AND v.check_in_time >= ?");
        }
        if (endDate != null) {
            sql.append(" AND v.check_in_time <= ?");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, customerId);
            
            if (petId != null) {
                ps.setInt(paramIndex++, petId);
            }
            if (startDate != null) {
                ps.setTimestamp(paramIndex++, Timestamp.valueOf(startDate));
            }
            if (endDate != null) {
                ps.setTimestamp(paramIndex++, Timestamp.valueOf(endDate));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException ex) {
            System.err.println("[MedicalRecordDAO] ERROR in countMedicalRecordsWithFilter: " + ex.getMessage());
            ex.printStackTrace();
        }
        return 0;
    }
}
