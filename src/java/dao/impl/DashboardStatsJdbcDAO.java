
package dao.impl;

import dao.DashboardStatsDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import utils.DBContext;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;

public class DashboardStatsJdbcDAO implements DashboardStatsDAO {
    @Override
    public int countTotalPatients() {
        String sql = "SELECT COUNT(*) FROM Pets WHERE (isDeleted = 0 OR isDeleted IS NULL)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    @Override
    public int countNewRegistrationsLast7Days() {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDateTime from = weekStart.atStartOfDay();
        LocalDateTime toExclusive = weekStart.plusDays(7).atStartOfDay();

        String sql = "SELECT COUNT(*) FROM Users WHERE role_id = 1 AND created_at >= ? AND created_at < ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(from));
            ps.setTimestamp(2, Timestamp.valueOf(toExclusive));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    @Override
    public int countTotalAppointments() {
        LocalDate today = LocalDate.now();
        LocalDate monthStart = today.withDayOfMonth(1);
        LocalDate nextMonthStart = monthStart.plusMonths(1);

        String dateSlotSql = "SELECT COUNT(*) FROM appointments WHERE appointment_date >= ? AND appointment_date < ?";
        String legacySql = "SELECT COUNT(*) FROM appointments WHERE appointment_time >= ? AND appointment_time < ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(dateSlotSql)) {
            ps.setDate(1, java.sql.Date.valueOf(monthStart));
            ps.setDate(2, java.sql.Date.valueOf(nextMonthStart));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(legacySql)) {
                ps.setTimestamp(1, Timestamp.valueOf(monthStart.atStartOfDay()));
                ps.setTimestamp(2, Timestamp.valueOf(nextMonthStart.atStartOfDay()));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }
    
    @Override
    public int countNewCustomersThisMonth() {
        LocalDate today = LocalDate.now();
        LocalDate monthStart = today.withDayOfMonth(1);
        LocalDate nextMonthStart = monthStart.plusMonths(1);

        String sql = "SELECT COUNT(*) FROM Users WHERE role_id = 1 AND created_at >= ? AND created_at < ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(monthStart.atStartOfDay()));
            ps.setTimestamp(2, Timestamp.valueOf(nextMonthStart.atStartOfDay()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    @Override
    public int countNewAppointmentsThisMonth() {
        LocalDate today = LocalDate.now();
        LocalDate monthStart = today.withDayOfMonth(1);
        LocalDate nextMonthStart = monthStart.plusMonths(1);

        String dateSlotSql = "SELECT COUNT(*) FROM appointments WHERE created_at >= ? AND created_at < ?";
        String legacySql = "SELECT COUNT(*) FROM appointments WHERE appointment_time >= ? AND appointment_time < ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(dateSlotSql)) {
            ps.setTimestamp(1, Timestamp.valueOf(monthStart.atStartOfDay()));
            ps.setTimestamp(2, Timestamp.valueOf(nextMonthStart.atStartOfDay()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(legacySql)) {
                ps.setTimestamp(1, Timestamp.valueOf(monthStart.atStartOfDay()));
                ps.setTimestamp(2, Timestamp.valueOf(nextMonthStart.atStartOfDay()));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    @Override
    public int countTotalUsers() {
        String sql = "SELECT COUNT(*) FROM Users";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
}
