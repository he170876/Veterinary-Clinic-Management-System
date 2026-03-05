package dao;

import utils.DBContext;
import model.Notification;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Notifications DAO for creating and reading user notifications.
 */
public class NotificationDAO extends DBContext {

    public boolean create(int userId, String title, String message) {
        if (userId <= 0) return false;
        if (title == null) title = "";
        if (message == null) message = "";
        String sql = "INSERT INTO Notifications (user_id, title, message) VALUES (?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, message);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int createForRole(String roleName, String title, String message) {
        List<Integer> ids = getUserIdsByRoleName(roleName);
        int count = 0;
        for (Integer id : ids) {
            if (id != null && create(id, title, message)) count++;
        }
        return count;
    }

    public List<Integer> getUserIdsByRoleName(String roleName) {
        List<Integer> out = new ArrayList<>();
        if (roleName == null || roleName.trim().isEmpty()) return out;
        String sql = """
            SELECT u.user_id
            FROM Users u
            JOIN Roles r ON u.role_id = r.role_id
            WHERE r.role_name = ?
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, roleName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(rs.getInt("user_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }

    public List<Notification> getRecentForUser(int userId, int limit) {
        if (userId <= 0) return new ArrayList<>();
        if (limit <= 0) limit = 10;

        if (!isReceptionistUser(userId)) {
            return getRecentStoredForUser(userId, limit, false);
        }

        List<Notification> merged = new ArrayList<>();
        List<Notification> customerRequestNotifications = getPendingCustomerRequestNotifications(limit);
        merged.addAll(customerRequestNotifications);

        List<Notification> storedNotifications = getRecentStoredForUser(userId, limit, true);
        if (!storedNotifications.isEmpty()) {
            Map<String, Notification> uniqueByContent = new LinkedHashMap<>();
            for (Notification n : merged) {
                uniqueByContent.put(buildKey(n), n);
            }
            for (Notification n : storedNotifications) {
                uniqueByContent.putIfAbsent(buildKey(n), n);
            }
            merged = new ArrayList<>(uniqueByContent.values());
        }

        if (merged.size() > limit) {
            return new ArrayList<>(merged.subList(0, limit));
        }
        return merged;
    }

    private List<Notification> getRecentStoredForUser(int userId, int limit, boolean excludeCustomerRequestTitles) {
        List<Notification> list = new ArrayList<>();
        String sql;
        if (excludeCustomerRequestTitles) {
            sql = """
                SELECT TOP (%d) notification_id, user_id, title, message, created_at
                FROM Notifications
                WHERE user_id = ?
                  AND (title IS NULL OR title NOT IN ('Reschedule Request', 'Doctor Change Request'))
                ORDER BY created_at DESC, notification_id DESC
                """.formatted(limit);
        } else {
            sql = """
                SELECT TOP (%d) notification_id, user_id, title, message, created_at
                FROM Notifications
                WHERE user_id = ?
                ORDER BY created_at DESC, notification_id DESC
                """.formatted(limit);
        }

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setNotificationId(rs.getInt("notification_id"));
                    n.setUserId(rs.getInt("user_id"));
                    n.setTitle(rs.getString("title"));
                    n.setMessage(rs.getString("message"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    n.setCreatedAt(ts != null ? ts.toLocalDateTime() : (LocalDateTime) null);
                    n.setRead(false);
                    list.add(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private boolean isReceptionistUser(int userId) {
        String sql = """
            SELECT 1
            FROM Users u
            JOIN Roles r ON u.role_id = r.role_id
            WHERE u.user_id = ?
              AND r.role_name = 'Receptionist'
            """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private List<Notification> getPendingCustomerRequestNotifications(int limit) {
        List<Notification> list = new ArrayList<>();
        String sql = """
            SELECT TOP (%d)
                a.appointment_id,
                a.status,
                a.appointment_time,
                p.name AS pet_name,
                u.full_name AS customer_name
            FROM Appointments a
            JOIN Pets p ON a.pet_id = p.pet_id
            JOIN Customers c ON a.customer_id = c.customer_id
            JOIN Users u ON c.user_id = u.user_id
            WHERE p.isDeleted = 0
              AND (a.status = 'Reschedule-Requested' OR a.status = 'Doctor-Change-Requested')
            ORDER BY a.appointment_time ASC, a.appointment_id DESC
            """.formatted(limit);

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("status");
                int appointmentId = rs.getInt("appointment_id");
                String petName = rs.getString("pet_name");
                String customerName = rs.getString("customer_name");

                Notification n = new Notification();
                n.setNotificationId(-appointmentId);
                n.setUserId(0);
                if ("Reschedule-Requested".equalsIgnoreCase(status)) {
                    n.setTitle("Reschedule Request");
                    n.setMessage("Customer " + safe(customerName) + " requested reschedule for pet " + safe(petName) + " (Appointment #" + appointmentId + ").");
                } else {
                    n.setTitle("Doctor Change Request");
                    n.setMessage("Customer " + safe(customerName) + " requested doctor change for pet " + safe(petName) + " (Appointment #" + appointmentId + ").");
                }
                Timestamp ts = rs.getTimestamp("appointment_time");
                n.setCreatedAt(ts != null ? ts.toLocalDateTime() : (LocalDateTime) null);
                n.setRead(false);
                list.add(n);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private String safe(String value) {
        if (value == null) return "N/A";
        String trimmed = value.trim();
        return trimmed.isEmpty() ? "N/A" : trimmed;
    }

    private String buildKey(Notification n) {
        String title = n.getTitle() == null ? "" : n.getTitle().trim();
        String message = n.getMessage() == null ? "" : n.getMessage().trim();
        return title + "|" + message;
    }
}

