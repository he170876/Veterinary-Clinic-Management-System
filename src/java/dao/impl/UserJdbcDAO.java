package dao.impl;

import dao.BaseDAO;
import dao.UserDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.ResultSetMetaData;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.Optional;
import model.Role;
import model.User;

/**
 * JDBC implementation of {@link UserDAO} for SQL Server.
 */
public class UserJdbcDAO extends BaseDAO implements UserDAO {

    /** Last SQL error message when createCustomerUser fails (for UI). */
    private static volatile String lastInsertError;

    public static String getLastInsertError() {
        return lastInsertError;
    }

    @Override
    public Optional<User> findByEmail(String email) {
        String sql = "SELECT u.user_id, u.email, u.password, u.status, u.created_at, u.updated_at, "
                + "u.full_name, u.phone, u.address, u.profile_picture_url, r.role_id, r.role_name, u.is_google_user "
                + "FROM Users u "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.email = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToUser(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public Optional<User> findById(int userId) {
        String sql = "SELECT u.user_id, u.email, u.password, u.status, u.created_at, u.updated_at, "
                + "u.full_name, u.phone, u.address, u.profile_picture_url, r.role_id, r.role_name, u.is_google_user "
                + "FROM Users u "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.user_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToUser(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public boolean existsByEmail(String email) {
        String sql = "SELECT 1 FROM Users WHERE email = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    public Optional<Role> findRoleByName(String roleName) {
        String sql = "SELECT role_id, role_name FROM Roles WHERE LTRIM(RTRIM(role_name)) COLLATE SQL_Latin1_General_CP1_CI_AS = LTRIM(RTRIM(?))";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, roleName == null ? "" : roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    return Optional.of(role);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public User createCustomerUser(User user) {
        String sql = "INSERT INTO Users (email, password, role_id, status, created_at, updated_at, "
                + "full_name, phone, address) "
                + "OUTPUT INSERTED.user_id "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        LocalDateTime now = LocalDateTime.now();

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPasswordHash());
            ps.setInt(3, user.getRole().getRoleId());
            ps.setString(4, user.getStatus());
            ps.setTimestamp(5, Timestamp.valueOf(now));
            ps.setTimestamp(6, Timestamp.valueOf(now));
            ps.setString(7, user.getFullName());
            ps.setString(8, user.getPhone());
            ps.setString(9, user.getAddress());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user.setUserId(rs.getInt(1));
                }
            }
            user.setCreatedAt(now);
            user.setUpdatedAt(now);
            lastInsertError = null;
            return user;
        } catch (SQLException ex) {
            lastInsertError = ex.getMessage();
            System.err.println("[UserJdbcDAO] INSERT failed: " + lastInsertError);
            ex.printStackTrace();
            return null;
        }
    }

    @Override
    public boolean updateUser(User user) {
        String sql = "UPDATE Users SET full_name = ?, phone = ?, address = ?, profile_picture_url = ?, updated_at = ? WHERE user_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getAddress());
            if (user.getProfilePictureUrl() != null) {
                ps.setString(4, user.getProfilePictureUrl());
            } else {
                ps.setNull(4, Types.VARCHAR);
            }
            ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(6, user.getUserId());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updatePassword(int userId, String newPasswordHash) {
        String sql = "UPDATE Users SET password = ?, updated_at = ? WHERE user_id = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean setGoogleUser(int userId) {
        String sql = "UPDATE Users SET is_google_user = 1 WHERE user_id = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password"));
        user.setStatus(rs.getString("status"));

        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            user.setCreatedAt(created.toLocalDateTime());
        }
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) {
            user.setUpdatedAt(updated.toLocalDateTime());
        }

        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setAddress(rs.getString("address"));
        try {
            if (hasColumn(rs, "profile_picture_url")) {
                user.setProfilePictureUrl(rs.getString("profile_picture_url"));
            }
        } catch (SQLException ignored) { }
        try {
            if (hasColumn(rs, "is_google_user")) {
                user.setGoogleUser(rs.getBoolean("is_google_user"));
            }
        } catch (SQLException ignored) { }

        Role role = new Role();
        role.setRoleId(rs.getInt("role_id"));
        role.setRoleName(rs.getString("role_name"));
        user.setRole(role);

        return user;
    }

    private static boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData meta = rs.getMetaData();
        for (int i = 1; i <= meta.getColumnCount(); i++) {
            if (columnName.equalsIgnoreCase(meta.getColumnName(i))) {
                return true;
            }
        }
        return false;
    }
}
