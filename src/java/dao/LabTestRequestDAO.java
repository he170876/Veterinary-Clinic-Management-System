package dao;

import model.LabResultDetail;
import model.LabResultSummary;
import model.LabTest;
import model.LabTestRequest;
import utils.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * LabTestRequests, LabTests, LabTestResults. Create requests (vet), list pending (lab), save results (lab).
 */
public class LabTestRequestDAO extends DBContext {

    public List<LabTest> getAllLabTests() {
        List<LabTest> list = new ArrayList<>();
        String sql = "SELECT test_id, test_name, description, normal_range, unit, status FROM LabTests WHERE status = 'Active' ORDER BY test_name";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LabTest t = new LabTest();
                t.setTestId(rs.getInt("test_id"));
                t.setTestName(rs.getString("test_name"));
                t.setDescription(rs.getString("description"));
                t.setNormalRange(rs.getString("normal_range"));
                t.setUnit(rs.getString("unit"));
                t.setStatus(rs.getString("status"));
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Create a lab test request (status Pending). */
    public LabTestRequest createRequest(int visitId, int testId, int veterinarianId) {
        return createRequest(visitId, testId, veterinarianId, null);
    }

    /**
     * Create a lab test request (status Pending) with optional clinical notes.
     * Works with both schemas:
     * - If column clinical_notes exists: store it.
     * - If not: falls back to legacy insert.
     */
    public LabTestRequest createRequest(int visitId, int testId, int veterinarianId, String clinicalNotes) {
        String sqlWithNotes = "INSERT INTO LabTestRequests (visit_id, test_id, veterinarian_id, request_time, status, clinical_notes) OUTPUT INSERTED.request_id VALUES (?, ?, ?, GETDATE(), 'Pending', ?)";
        String sqlLegacy = "INSERT INTO LabTestRequests (visit_id, test_id, veterinarian_id, request_time, status) OUTPUT INSERTED.request_id VALUES (?, ?, ?, GETDATE(), 'Pending')";
        try (Connection con = getConnection()) {
            // Try insert with clinical_notes first
            try (PreparedStatement ps = con.prepareStatement(sqlWithNotes)) {
                ps.setInt(1, visitId);
                ps.setInt(2, testId);
                ps.setInt(3, veterinarianId);
                ps.setString(4, clinicalNotes);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        LabTestRequest r = new LabTestRequest();
                        r.setRequestId(rs.getInt(1));
                        r.setVisitId(visitId);
                        r.setTestId(testId);
                        r.setVeterinarianId(veterinarianId);
                        r.setStatus("Pending");
                        r.setClinicalNotes(clinicalNotes);
                        return r;
                    }
                }
            } catch (SQLException ignored) {
                // Fallback to legacy schema
                try (PreparedStatement ps = con.prepareStatement(sqlLegacy)) {
                    ps.setInt(1, visitId);
                    ps.setInt(2, testId);
                    ps.setInt(3, veterinarianId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            LabTestRequest r = new LabTestRequest();
                            r.setRequestId(rs.getInt(1));
                            r.setVisitId(visitId);
                            r.setTestId(testId);
                            r.setVeterinarianId(veterinarianId);
                            r.setStatus("Pending");
                            return r;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Pending requests for lab queue (FIFO by request_time), with pet, owner, vet, test name. */
    public List<LabTestRequest> getPendingRequests() {
        List<LabTestRequest> list = new ArrayList<>();
        String sqlWithNotes = """
            SELECT ltr.request_id, ltr.visit_id, ltr.test_id, ltr.veterinarian_id, ltr.request_time, ltr.status,
                   ltr.clinical_notes,
                   p.name AS pet_name, p.species, p.breed,
                   u.full_name AS owner_name,
                   vet_u.full_name AS veterinarian_name,
                   lt.test_name
            FROM LabTestRequests ltr
            JOIN Visits v ON ltr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users u ON c.user_id = u.user_id
            JOIN Veterinarians vet ON ltr.veterinarian_id = vet.veterinarian_id
            JOIN Users vet_u ON vet.user_id = vet_u.user_id
            JOIN LabTests lt ON ltr.test_id = lt.test_id
            WHERE ltr.status = 'Pending'
            ORDER BY ltr.request_time ASC, ltr.request_id ASC
            """;
        String sqlLegacy = """
            SELECT ltr.request_id, ltr.visit_id, ltr.test_id, ltr.veterinarian_id, ltr.request_time, ltr.status,
                   p.name AS pet_name, p.species, p.breed,
                   u.full_name AS owner_name,
                   vet_u.full_name AS veterinarian_name,
                   lt.test_name
            FROM LabTestRequests ltr
            JOIN Visits v ON ltr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users u ON c.user_id = u.user_id
            JOIN Veterinarians vet ON ltr.veterinarian_id = vet.veterinarian_id
            JOIN Users vet_u ON vet.user_id = vet_u.user_id
            JOIN LabTests lt ON ltr.test_id = lt.test_id
            WHERE ltr.status = 'Pending'
            ORDER BY ltr.request_time ASC, ltr.request_id ASC
            """;
        try (Connection con = getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sqlWithNotes); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LabTestRequest r = new LabTestRequest();
                    r.setRequestId(rs.getInt("request_id"));
                    r.setVisitId(rs.getInt("visit_id"));
                    r.setTestId(rs.getInt("test_id"));
                    r.setVeterinarianId(rs.getInt("veterinarian_id"));
                    Timestamp t = rs.getTimestamp("request_time");
                    if (t != null) r.setRequestTime(t.toLocalDateTime());
                    r.setStatus(rs.getString("status"));
                    r.setPetName(rs.getString("pet_name"));
                    r.setSpecies(rs.getString("species"));
                    r.setBreed(rs.getString("breed"));
                    r.setOwnerName(rs.getString("owner_name"));
                    r.setVeterinarianName(rs.getString("veterinarian_name"));
                    r.setTestName(rs.getString("test_name"));
                    r.setClinicalNotes(rs.getString("clinical_notes"));
                    list.add(r);
                }
                return list;
            } catch (SQLException ignored) {
                try (PreparedStatement ps = con.prepareStatement(sqlLegacy); ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LabTestRequest r = new LabTestRequest();
                        r.setRequestId(rs.getInt("request_id"));
                        r.setVisitId(rs.getInt("visit_id"));
                        r.setTestId(rs.getInt("test_id"));
                        r.setVeterinarianId(rs.getInt("veterinarian_id"));
                        Timestamp t = rs.getTimestamp("request_time");
                        if (t != null) r.setRequestTime(t.toLocalDateTime());
                        r.setStatus(rs.getString("status"));
                        r.setPetName(rs.getString("pet_name"));
                        r.setSpecies(rs.getString("species"));
                        r.setBreed(rs.getString("breed"));
                        r.setOwnerName(rs.getString("owner_name"));
                        r.setVeterinarianName(rs.getString("veterinarian_name"));
                        r.setTestName(rs.getString("test_name"));
                        list.add(r);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Count pending lab requests for lab queue with optional search.
     * Search matches pet name OR owner name (LIKE) OR request_id/visit_id (exact numeric).
     */
    public int countPendingRequests(String query) {
        String q = query == null ? "" : query.trim();
        boolean hasQ = !q.isEmpty();
        String sql = """
            SELECT COUNT(*)
            FROM LabTestRequests ltr
            JOIN Visits v ON ltr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users u ON c.user_id = u.user_id
            WHERE ltr.status = 'Pending'
            """ + (hasQ ? " AND (p.name LIKE ? OR u.full_name LIKE ? OR CAST(ltr.request_id AS NVARCHAR(20)) = ? OR CAST(ltr.visit_id AS NVARCHAR(20)) = ?)" : "");

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            if (hasQ) {
                ps.setString(1, "%" + q + "%");
                ps.setString(2, "%" + q + "%");
                ps.setString(3, q);
                ps.setString(4, q);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Page pending requests for lab queue (FIFO), with optional search.
     * Order is stable: request_time ASC, request_id ASC.
     */
    public List<LabTestRequest> getPendingRequestsPage(int offset, int pageSize, String query) {
        List<LabTestRequest> list = new ArrayList<>();
        if (offset < 0) offset = 0;
        if (pageSize <= 0) pageSize = 10;
        String q = query == null ? "" : query.trim();
        boolean hasQ = !q.isEmpty();

        String baseSelectWithNotes = """
            SELECT ltr.request_id, ltr.visit_id, ltr.test_id, ltr.veterinarian_id, ltr.request_time, ltr.status,
                   ltr.clinical_notes,
                   p.name AS pet_name, p.species, p.breed,
                   u.full_name AS owner_name,
                   vet_u.full_name AS veterinarian_name,
                   lt.test_name
            FROM LabTestRequests ltr
            JOIN Visits v ON ltr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users u ON c.user_id = u.user_id
            JOIN Veterinarians vet ON ltr.veterinarian_id = vet.veterinarian_id
            JOIN Users vet_u ON vet.user_id = vet_u.user_id
            JOIN LabTests lt ON ltr.test_id = lt.test_id
            WHERE ltr.status = 'Pending'
            """;
        String baseSelectLegacy = """
            SELECT ltr.request_id, ltr.visit_id, ltr.test_id, ltr.veterinarian_id, ltr.request_time, ltr.status,
                   p.name AS pet_name, p.species, p.breed,
                   u.full_name AS owner_name,
                   vet_u.full_name AS veterinarian_name,
                   lt.test_name
            FROM LabTestRequests ltr
            JOIN Visits v ON ltr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users u ON c.user_id = u.user_id
            JOIN Veterinarians vet ON ltr.veterinarian_id = vet.veterinarian_id
            JOIN Users vet_u ON vet.user_id = vet_u.user_id
            JOIN LabTests lt ON ltr.test_id = lt.test_id
            WHERE ltr.status = 'Pending'
            """;

        String filter = hasQ ? " AND (p.name LIKE ? OR u.full_name LIKE ? OR CAST(ltr.request_id AS NVARCHAR(20)) = ? OR CAST(ltr.visit_id AS NVARCHAR(20)) = ?)" : "";
        String paging = " ORDER BY ltr.request_time ASC, ltr.request_id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = getConnection()) {
            String sqlWithNotes = baseSelectWithNotes + filter + paging;
            try (PreparedStatement ps = con.prepareStatement(sqlWithNotes)) {
                int idx = 1;
                if (hasQ) {
                    ps.setString(idx++, "%" + q + "%");
                    ps.setString(idx++, "%" + q + "%");
                    ps.setString(idx++, q);
                    ps.setString(idx++, q);
                }
                ps.setInt(idx++, offset);
                ps.setInt(idx, pageSize);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LabTestRequest r = new LabTestRequest();
                        r.setRequestId(rs.getInt("request_id"));
                        r.setVisitId(rs.getInt("visit_id"));
                        r.setTestId(rs.getInt("test_id"));
                        r.setVeterinarianId(rs.getInt("veterinarian_id"));
                        Timestamp t = rs.getTimestamp("request_time");
                        if (t != null) r.setRequestTime(t.toLocalDateTime());
                        r.setStatus(rs.getString("status"));
                        r.setPetName(rs.getString("pet_name"));
                        r.setSpecies(rs.getString("species"));
                        r.setBreed(rs.getString("breed"));
                        r.setOwnerName(rs.getString("owner_name"));
                        r.setVeterinarianName(rs.getString("veterinarian_name"));
                        r.setTestName(rs.getString("test_name"));
                        r.setClinicalNotes(rs.getString("clinical_notes"));
                        list.add(r);
                    }
                    return list;
                }
            } catch (SQLException ignored) {
                String sqlLegacy = baseSelectLegacy + filter + paging;
                try (PreparedStatement ps = con.prepareStatement(sqlLegacy)) {
                    int idx = 1;
                    if (hasQ) {
                        ps.setString(idx++, "%" + q + "%");
                        ps.setString(idx++, "%" + q + "%");
                        ps.setString(idx++, q);
                        ps.setString(idx++, q);
                    }
                    ps.setInt(idx++, offset);
                    ps.setInt(idx, pageSize);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            LabTestRequest r = new LabTestRequest();
                            r.setRequestId(rs.getInt("request_id"));
                            r.setVisitId(rs.getInt("visit_id"));
                            r.setTestId(rs.getInt("test_id"));
                            r.setVeterinarianId(rs.getInt("veterinarian_id"));
                            Timestamp t = rs.getTimestamp("request_time");
                            if (t != null) r.setRequestTime(t.toLocalDateTime());
                            r.setStatus(rs.getString("status"));
                            r.setPetName(rs.getString("pet_name"));
                            r.setSpecies(rs.getString("species"));
                            r.setBreed(rs.getString("breed"));
                            r.setOwnerName(rs.getString("owner_name"));
                            r.setVeterinarianName(rs.getString("veterinarian_name"));
                            r.setTestName(rs.getString("test_name"));
                            list.add(r);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lab requests for a specific visit (for vet examination page). */
    public List<LabTestRequest> getByVisitId(int visitId) {
        List<LabTestRequest> list = new ArrayList<>();
        String sql = """
            SELECT ltr.request_id, ltr.visit_id, ltr.test_id, ltr.veterinarian_id, ltr.request_time, ltr.status,
                   p.name AS pet_name, p.species,
                   u.full_name AS owner_name,
                   vet_u.full_name AS veterinarian_name,
                 lt.test_name,
                 res.result_note,
                 res.result_file
            FROM LabTestRequests ltr
            JOIN Visits v ON ltr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users u ON c.user_id = u.user_id
            JOIN Veterinarians vet ON ltr.veterinarian_id = vet.veterinarian_id
            JOIN Users vet_u ON vet.user_id = vet_u.user_id
            JOIN LabTests lt ON ltr.test_id = lt.test_id
             LEFT JOIN LabTestResults res ON res.request_id = ltr.request_id
            WHERE ltr.visit_id = ?
            ORDER BY ltr.request_time DESC
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, visitId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LabTestRequest r = new LabTestRequest();
                    r.setRequestId(rs.getInt("request_id"));
                    r.setVisitId(rs.getInt("visit_id"));
                    r.setTestId(rs.getInt("test_id"));
                    r.setVeterinarianId(rs.getInt("veterinarian_id"));
                    Timestamp t = rs.getTimestamp("request_time");
                    if (t != null) r.setRequestTime(t.toLocalDateTime());
                    r.setStatus(rs.getString("status"));
                    r.setPetName(rs.getString("pet_name"));
                    r.setSpecies(rs.getString("species"));
                    r.setOwnerName(rs.getString("owner_name"));
                    r.setVeterinarianName(rs.getString("veterinarian_name"));
                    r.setTestName(rs.getString("test_name"));
                    r.setResultNote(rs.getString("result_note"));
                    r.setResultFileUrl(rs.getString("result_file"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public LabTestRequest getById(int requestId) {
        String sql = """
            SELECT ltr.request_id, ltr.visit_id, ltr.test_id, ltr.veterinarian_id, ltr.request_time, ltr.status,
                   p.name AS pet_name, p.species, u.full_name AS owner_name, vet_u.full_name AS veterinarian_name, lt.test_name
            FROM LabTestRequests ltr
            JOIN Visits v ON ltr.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Customers c ON v.customer_id = c.customer_id
            JOIN Users u ON c.user_id = u.user_id
            JOIN Veterinarians vet ON ltr.veterinarian_id = vet.veterinarian_id
            JOIN Users vet_u ON vet.user_id = vet_u.user_id
            JOIN LabTests lt ON ltr.test_id = lt.test_id
            WHERE ltr.request_id = ?
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LabTestRequest r = new LabTestRequest();
                    r.setRequestId(rs.getInt("request_id"));
                    r.setVisitId(rs.getInt("visit_id"));
                    r.setTestId(rs.getInt("test_id"));
                    r.setVeterinarianId(rs.getInt("veterinarian_id"));
                    Timestamp t = rs.getTimestamp("request_time");
                    if (t != null) r.setRequestTime(t.toLocalDateTime());
                    r.setStatus(rs.getString("status"));
                    r.setPetName(rs.getString("pet_name"));
                    r.setSpecies(rs.getString("species"));
                    r.setOwnerName(rs.getString("owner_name"));
                    r.setVeterinarianName(rs.getString("veterinarian_name"));
                    r.setTestName(rs.getString("test_name"));
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Get lab staff_id for current user (LabStaff.user_id). Returns 0 if not lab staff. */
    public int getLabStaffIdByUserId(int userId) {
        String sql = "SELECT staff_id FROM LabStaff WHERE user_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("staff_id") : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Insert LabTestResults and set LabTestRequests.status = 'Completed'. {@code resultFile} = relative URL (e.g. /uploads/lab-results/...). */
    public boolean saveResult(int requestId, String resultValue, String resultNote, String resultFile, int labStaffId) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);
            String insertResult = "INSERT INTO LabTestResults (request_id, result_value, result_note, result_file, result_date, lab_staff_id) VALUES (?, ?, ?, ?, GETDATE(), ?)";
            try (PreparedStatement ps = con.prepareStatement(insertResult)) {
                ps.setInt(1, requestId);
                ps.setString(2, resultValue);
                ps.setString(3, resultNote);
                ps.setString(4, resultFile != null ? resultFile : "");
                ps.setInt(5, labStaffId);
                ps.executeUpdate();
            }
            String updateStatus = "UPDATE LabTestRequests SET status = 'Completed' WHERE request_id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateStatus)) {
                ps.setInt(1, requestId);
                ps.executeUpdate();
            }
            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignored) {}
            }
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    /** Number of lab requests still in Pending status for this visit (blocks completing examination). */
    public int countPendingByVisitId(int visitId) {
        if (visitId <= 0) return 0;
        String sql = "SELECT COUNT(*) FROM LabTestRequests WHERE visit_id = ? AND status = 'Pending'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, visitId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Count pending lab requests for a veterinarian. */
    public int countPendingByVeterinarian(int veterinarianId) {
        if (veterinarianId <= 0) return 0;
        String sql = "SELECT COUNT(*) FROM LabTestRequests WHERE veterinarian_id = ? AND status = 'Pending'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /** Recent lab results for a vet's requests (for dashboard). Includes pet name, test name, status, date. */
    public List<LabResultSummary> getRecentResultsForVeterinarian(int veterinarianId, int limit) {
        List<LabResultSummary> list = new ArrayList<>();
        String sql = """
            SELECT TOP (?) p.name AS pet_name, lt.test_name, ltr.result_value, ltr.result_note, ltr.result_date
            FROM LabTestResults ltr
            JOIN LabTestRequests req ON ltr.request_id = req.request_id
            JOIN Visits v ON req.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN LabTests lt ON req.test_id = lt.test_id
            WHERE req.veterinarian_id = ?
            ORDER BY ltr.result_date DESC
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, veterinarianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LabResultSummary s = new LabResultSummary();
                    s.setPetName(rs.getString("pet_name"));
                    s.setTestName(rs.getString("test_name"));
                    s.setResultValue(rs.getString("result_value"));
                    s.setResultNote(rs.getString("result_note"));
                    Timestamp t = rs.getTimestamp("result_date");
                    if (t != null) s.setResultDate(t.toLocalDateTime());
                    String note = rs.getString("result_note");
                    s.setStatus((note != null && note.toLowerCase().contains("critical")) ? "Critical" : "Normal");
                    list.add(s);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Recent lab results for a pet (within the last {@code days} days), for display on examination page. */
    public List<LabResultSummary> getRecentResultsByPetId(int petId, int days) {
        List<LabResultSummary> list = new ArrayList<>();
        String sql = """
            SELECT lt.test_name, ltr.result_value, ltr.result_note, ltr.result_date
            FROM LabTestResults ltr
            JOIN LabTestRequests req ON ltr.request_id = req.request_id
            JOIN Visits v ON req.visit_id = v.visit_id
            JOIN LabTests lt ON req.test_id = lt.test_id
            WHERE v.pet_id = ? AND ltr.result_date >= DATEADD(day, -?, GETDATE())
            ORDER BY ltr.result_date DESC
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, petId);
            ps.setInt(2, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LabResultSummary s = new LabResultSummary();
                    s.setTestName(rs.getString("test_name"));
                    s.setResultValue(rs.getString("result_value"));
                    s.setResultNote(rs.getString("result_note"));
                    Timestamp t = rs.getTimestamp("result_date");
                    if (t != null) s.setResultDate(t.toLocalDateTime());
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Set all pending lab requests for a visit to Cancelled (optional cleanup; vet cannot complete exam while Pending). */
    public int cancelPendingByVisitId(int visitId) {
        if (visitId <= 0) return 0;
        String sql = "UPDATE LabTestRequests SET status = 'Cancelled' WHERE visit_id = ? AND status = 'Pending'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, visitId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Detailed result for a specific lab request, used by vet viewer modal. */
    public LabResultDetail getResultDetailByRequestId(int requestId) {
        String sql = """
            SELECT req.request_id,
                   lt.test_name,
                   v.pet_id,
                   p.name               AS pet_name,
                   vet_u.full_name      AS veterinarian_name,
                   tech_u.full_name     AS technician_name,
                   res.result_value,
                   res.result_note,
                   res.result_file,
                   res.result_date
            FROM LabTestRequests req
            JOIN Visits v ON req.visit_id = v.visit_id
            JOIN Pets p ON v.pet_id = p.pet_id
            JOIN Veterinarians vet ON req.veterinarian_id = vet.veterinarian_id
            JOIN Users vet_u ON vet.user_id = vet_u.user_id
            JOIN LabTests lt ON req.test_id = lt.test_id
            JOIN LabTestResults res ON res.request_id = req.request_id
            LEFT JOIN LabStaff ls ON res.lab_staff_id = ls.staff_id
            LEFT JOIN Users tech_u ON ls.user_id = tech_u.user_id
            WHERE req.request_id = ?
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LabResultDetail d = new LabResultDetail();
                    d.setRequestId(rs.getInt("request_id"));
                    d.setTestName(rs.getString("test_name"));
                    int petId = rs.getInt("pet_id");
                    d.setPatientCode("PAT-" + petId);
                    d.setPetName(rs.getString("pet_name"));
                    d.setVeterinarianName(rs.getString("veterinarian_name"));
                    d.setTechnicianName(rs.getString("technician_name"));
                    d.setResultValue(rs.getString("result_value"));
                    d.setResultNote(rs.getString("result_note"));
                    d.setResultFileUrl(rs.getString("result_file"));
                    Timestamp t = rs.getTimestamp("result_date");
                    if (t != null) d.setResultDate(t.toLocalDateTime());
                    return d;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
