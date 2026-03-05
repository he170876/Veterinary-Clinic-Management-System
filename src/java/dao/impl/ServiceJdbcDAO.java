package dao.impl;

import dao.BaseDAO;
import dao.ServiceDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import model.Service;

/**
 * JDBC implementation of {@link ServiceDAO} for SQL Server.
 * Handles CRUD operations for veterinary services with support for nullable fields
 * (category, duration) and soft delete functionality (is_deleted flag).
 */
public class ServiceJdbcDAO extends BaseDAO implements ServiceDAO {

    @Override
    public List<Service> findAll() {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT service_id, name, category, duration, price, description, is_deleted "
                + "FROM Services WHERE is_deleted = 0 ORDER BY name ASC";

        try (Connection conn = getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                services.add(mapRowToService(rs));
            }
            System.out.println("[ServiceJdbcDAO] findAll() found " + services.size() + " services");
        } catch (SQLException ex) {
            System.err.println("[ServiceJdbcDAO] findAll() ERROR: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("ErrorCode: " + ex.getErrorCode());
            System.err.println("SQL: " + sql);
            ex.printStackTrace();
        } catch (Exception ex) {
            System.err.println("[ServiceJdbcDAO] findAll() UNEXPECTED ERROR: " + ex.getMessage());
            ex.printStackTrace();
        }
        return services;
    }

    @Override
    public List<Service> findByCategory(String category) {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT service_id, name, category, duration, price, description, is_deleted "
                + "FROM Services WHERE is_deleted = 0 AND category = ? ORDER BY name ASC";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    services.add(mapRowToService(rs));
                }
            }
        } catch (SQLException ex) {
            System.err.println("[ServiceJdbcDAO] findByCategory() error: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("ErrorCode: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        return services;
    }

    @Override
    public Optional<Service> findById(int serviceId) {
        String sql = "SELECT service_id, name, category, duration, price, description, is_deleted "
                + "FROM Services WHERE service_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToService(rs));
                }
            }
        } catch (SQLException ex) {
            System.err.println("[ServiceJdbcDAO] findById() error: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("ErrorCode: " + ex.getErrorCode());
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public boolean existsByName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT COUNT(1) FROM Services "
                + "WHERE is_deleted = 0 AND LOWER(LTRIM(RTRIM(name))) = LOWER(LTRIM(RTRIM(?)))";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }

        } catch (SQLException ex) {
            System.err.println("[ServiceJdbcDAO] existsByName() error: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("ErrorCode: " + ex.getErrorCode());
            ex.printStackTrace();
        }

        return false;
    }

    @Override
    public Service create(Service service) {
        String sql = "INSERT INTO Services (name, category, duration, price, description, is_deleted) "
                + "OUTPUT INSERTED.service_id "
                + "VALUES (?, ?, ?, ?, ?, 0)";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            System.out.println("[ServiceJdbcDAO] Creating service: " + service.getName());
            ps.setString(1, service.getName());

            // Handle nullable category
            if (service.getCategory() != null && !service.getCategory().isEmpty()) {
                ps.setString(2, service.getCategory());
            } else {
                ps.setNull(2, Types.VARCHAR);
            }

            // Handle nullable duration - 0 means NULL in database
            if (service.getDuration() > 0) {
                ps.setInt(3, service.getDuration());
            } else {
                ps.setNull(3, Types.INTEGER);
            }

            ps.setDouble(4, service.getPrice());
            ps.setString(5, service.getDescription());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    service.setServiceId(rs.getInt(1));
                }
            }

            System.out.println("[ServiceJdbcDAO] Service created successfully with ID: " + service.getServiceId());
            return service;

        } catch (SQLException ex) {
            System.err.println("[ServiceJdbcDAO] create() ERROR: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("ErrorCode: " + ex.getErrorCode());
            System.err.println("SQL: " + sql);
            System.err.println("Service Name: " + service.getName());
            System.err.println("Price: " + service.getPrice());
            ex.printStackTrace();
            return null;
        } catch (Exception ex) {
            System.err.println("[ServiceJdbcDAO] create() UNEXPECTED ERROR: " + ex.getMessage());
            ex.printStackTrace();
            return null;
        }
    }

    @Override
    public boolean update(Service service) {
        String sql = "UPDATE Services SET name = ?, category = ?, duration = ?, price = ?, description = ? "
                + "WHERE service_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, service.getName());

            // Handle nullable category
            if (service.getCategory() != null && !service.getCategory().isEmpty()) {
                ps.setString(2, service.getCategory());
            } else {
                ps.setNull(2, Types.VARCHAR);
            }

            // Handle nullable duration - 0 means NULL in database
            if (service.getDuration() > 0) {
                ps.setInt(3, service.getDuration());
            } else {
                ps.setNull(3, Types.INTEGER);
            }

            ps.setDouble(4, service.getPrice());
            ps.setString(5, service.getDescription());
            ps.setInt(6, service.getServiceId());

            boolean result = ps.executeUpdate() > 0;
            if (result) {
                System.out.println("[ServiceJdbcDAO] Service updated successfully: " + service.getServiceId());
            }
            return result;

        } catch (SQLException ex) {
            System.err.println("[ServiceJdbcDAO] update() error: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("ErrorCode: " + ex.getErrorCode());
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int serviceId) {
        // Soft delete - set is_deleted = 1
        String sql = "UPDATE Services SET is_deleted = 1 WHERE service_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            boolean result = ps.executeUpdate() > 0;
            if (result) {
                System.out.println("[ServiceJdbcDAO] Service deleted (soft): " + serviceId);
            }
            return result;

        } catch (SQLException ex) {
            System.err.println("[ServiceJdbcDAO] delete() error: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("ErrorCode: " + ex.getErrorCode());
            ex.printStackTrace();
            return false;
        }
    }

    /**
     * Maps a ResultSet row to a Service object.
     * Handles NULL values for optional fields (category, duration).
     */
    private Service mapRowToService(ResultSet rs) throws SQLException {
        Service service = new Service();

        service.setServiceId(rs.getInt("service_id"));
        service.setName(rs.getString("name"));

        // Handle nullable category
        String category = rs.getString("category");
        service.setCategory(category == null ? "" : category);

        // Handle nullable duration - NULL returns 0
        Integer duration = rs.getObject("duration", Integer.class);
        service.setDuration(duration == null ? 0 : duration);

        service.setPrice(rs.getDouble("price"));
        service.setDescription(rs.getString("description"));
        service.setDeleted(rs.getBoolean("is_deleted"));

        return service;
    }
}
