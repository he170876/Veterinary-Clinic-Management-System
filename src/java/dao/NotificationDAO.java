package dao;

import utils.DBContext;
import model.Notification;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Minimal Notifications writer. Current UI does not render notifications yet;
 * this DAO only inserts notification rows so they can be displayed later.
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
        List<Notification> list = new ArrayList<>();
        if (userId <= 0) return list;
        if (limit <= 0) limit = 10;
        // SQL Server does not allow binding TOP with a parameter placeholder,
        // so we inject the small limit directly into the query string.
        String sql = """
            SELECT TOP (%d) notification_id, user_id, title, message, created_at
            FROM Notifications
            WHERE user_id = ?
            ORDER BY created_at DESC, notification_id DESC
            """.formatted(limit);
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
                    // is_read column is optional; default to false for now
                    n.setRead(false);
                    list.add(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}

