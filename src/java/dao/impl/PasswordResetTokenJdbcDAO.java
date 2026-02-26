package dao.impl;

import dao.BaseDAO;
import dao.PasswordResetTokenDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * JDBC implementation of {@link PasswordResetTokenDAO} for SQL Server.
 */
public class PasswordResetTokenJdbcDAO extends BaseDAO implements PasswordResetTokenDAO {

    @Override
    public void create(String token, String email, LocalDateTime expiresAt) {
        String deleteSql = "DELETE FROM PasswordResetTokens WHERE email = ?";
        String insertSql = "INSERT INTO PasswordResetTokens (token, email, expires_at, created_at) VALUES (?, ?, ?, SYSUTCDATETIME())";
        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setString(1, email);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, token);
                ps.setString(2, email);
                ps.setTimestamp(3, Timestamp.valueOf(expiresAt));
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to create password reset token", e);
        }
    }

    @Override
    public String findEmailByToken(String token) {
        if (token == null || token.isEmpty()) return null;
        String sql = "SELECT email FROM PasswordResetTokens WHERE token = ? AND expires_at > SYSUTCDATETIME()";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("email");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void deleteByToken(String token) {
        if (token == null || token.isEmpty()) return;
        String sql = "DELETE FROM PasswordResetTokens WHERE token = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteExpired() {
        String sql = "DELETE FROM PasswordResetTokens WHERE expires_at <= SYSUTCDATETIME()";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
