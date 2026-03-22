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
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Role;
import model.User;

/**
 * JDBC implementation of {@link UserDAO} for SQL Server.
 */
public class UserJdbcDAO extends BaseDAO implements UserDAO {

    private static final Logger LOG = Logger.getLogger(UserJdbcDAO.class.getName());

    /**
     * Last SQL error message when createCustomerUser fails (for UI).
     */
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

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
    public Optional<User> findByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return Optional.empty();
        }
        String normalized = phone.trim().replaceAll("[^0-9+]", "");
        if (normalized.isEmpty()) {
            return Optional.empty();
        }
        String sql = "SELECT u.user_id, u.email, u.password, u.status, u.created_at, u.updated_at, "
                + "u.full_name, u.phone, u.address, u.profile_picture_url, r.role_id, r.role_name, u.is_google_user "
                + "FROM Users u "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE (LTRIM(RTRIM(ISNULL(u.phone, ''))) = ? OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(u.phone,''))), ' ', ''), '-', ''), '(', ''), ')', ''), '+', '') = ?)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            ps.setString(2, normalized);
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

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
        String insertUserSql = "INSERT INTO Users (email, password, role_id, status, created_at, updated_at, "
                + "full_name, phone, address) "
                + "OUTPUT INSERTED.user_id "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertCustomerSql = "INSERT INTO Customers (user_id) VALUES (?)";

        LocalDateTime now = LocalDateTime.now();

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(insertUserSql)) {

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
                        } else {
                            throw new SQLException("Creating user failed, no user_id returned.");
                        }
                    }
                }

                try (PreparedStatement customerPs = conn.prepareStatement(insertCustomerSql)) {
                    customerPs.setInt(1, user.getUserId());
                    customerPs.executeUpdate();
                }

                conn.commit();
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
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

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

            int rows = ps.executeUpdate();
            if (rows == 0) {
                LOG.warning("[PFP] updateUser: 0 rows affected user_id=" + user.getUserId()
                        + " profile_picture_url=" + user.getProfilePictureUrl());
            }
            return rows > 0;
        } catch (SQLException ex) {
            LOG.log(Level.WARNING, "[PFP] updateUser SQL error user_id=" + user.getUserId()
                    + " profile_picture_url=" + user.getProfilePictureUrl(), ex);
        }
        return false;
    }

    @Override
    public boolean updatePassword(int userId, String newPasswordHash) {
        String sql = "UPDATE Users SET password = ?, updated_at = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
    public List<User> filterUsers(String keyword, Integer roleId, String status,
            String sort, int offset, int pageSize) {

        List<User> users = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
        SELECT u.user_id, u.email, u.password, u.status, u.created_at, u.updated_at,
               u.full_name, u.phone, u.address, u.profile_picture_url,
               r.role_id, r.role_name
        FROM Users u
        JOIN Roles r ON u.role_id = r.role_id
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        /* ===== KEYWORD ===== */
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? ESCAPE '\\' OR u.email LIKE ? ESCAPE '\\')");

            String kw = "%" + escapeLike(keyword.trim()) + "%";
            params.add(kw);
            params.add(kw);
        }

        /* ===== ROLE ===== */
        if (roleId != null) {
            sql.append(" AND u.role_id = ?");
            params.add(roleId);
        }

        /* ===== STATUS ===== */
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND u.status = ?");
            params.add(status);
        }

        /* ===== SORT ===== */
        if ("id_asc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY u.user_id ASC ");
        } else {
            // mặc định
            sql.append(" ORDER BY u.user_id DESC ");
        }

        /* ===== PAGINATION (SQL SERVER) ===== */
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");

        params.add(offset);
        params.add(pageSize);

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRowToUser(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

    private String escapeLike(String input) {
        return input
                .replace("\\", "\\\\")
                .replace("%", "\\%")
                .replace("_", "\\_");
    }

    @Override
    public int countUsers(String keyword, Integer roleId, String status) {

        StringBuilder sql = new StringBuilder("""
        SELECT COUNT(*)
        FROM Users u
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.email LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (roleId != null) {
            sql.append(" AND u.role_id = ?");
            params.add(roleId);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND u.status = ?");
            params.add(status);
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public void updateUserStatus(int userId, String status) {
        String sql = "UPDATE Users SET status = ?, updated_at = GETDATE() WHERE user_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, userId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean updateUserByAdmin(
            int userId,
            String fullName,
            String email,
            String phone,
            String address,
            int roleId,
            String status
    ) {
        String sql = """
        UPDATE Users
        SET full_name = ?,
            email = ?,
            phone = ?,
            address = ?,
            role_id = ?,
            status = ?,
            updated_at = ?
        WHERE user_id = ?
    """;

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, address);
            ps.setInt(5, roleId);
            ps.setString(6, status);
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(8, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[UserJdbcDAO] updateUserByAdmin failed");
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean setGoogleUser(int userId) {
        String sql = "UPDATE Users SET is_google_user = 1 WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    private String resolveProfilePictureUrl(ResultSet rs) throws SQLException {
        String pfp = null;
        if (hasColumn(rs, "profile_picture_url")) {
            pfp = rs.getString("profile_picture_url");
        }
        if (pfp == null || pfp.trim().isEmpty()) {
            return null;
        }
        return pfp.trim();
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
        user.setProfilePictureUrl(resolveProfilePictureUrl(rs));
        try {
            if (hasColumn(rs, "is_google_user")) {
                user.setGoogleUser(rs.getBoolean("is_google_user"));
            }
        } catch (SQLException ignored) {
            // optional column
        }

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

    @Override
    public boolean existsByEmailExceptId(String email, int userId) {
        String sql = "SELECT 1 FROM Users WHERE email = ? AND user_id <> ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setInt(2, userId);

            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean existsRoleById(int roleId) {
        String sql = "SELECT 1 FROM Roles WHERE role_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);
            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean existsById(int userId) {

        String sql = "SELECT 1 FROM Users WHERE user_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // true nếu tồn tại
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean create(User user) {

        String sql = """
        INSERT INTO Users
        (email, password, role_id, status,
         created_at, updated_at,
         full_name, phone, address,
         profile_picture_url, is_google_user)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """;

        LocalDateTime now = LocalDateTime.now();

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPasswordHash());
            ps.setInt(3, user.getRole().getRoleId());
            ps.setString(4, user.getStatus());

            ps.setTimestamp(5, Timestamp.valueOf(now));
            ps.setTimestamp(6, Timestamp.valueOf(now));

            ps.setString(7, user.getFullName());
            ps.setString(8, user.getPhone());
            ps.setString(9, user.getAddress());

            if (user.getProfilePictureUrl() != null) {
                ps.setString(10, user.getProfilePictureUrl());
            } else {
                ps.setNull(10, Types.VARCHAR);
            }

            ps.setBoolean(11, user.isGoogleUser());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
}
