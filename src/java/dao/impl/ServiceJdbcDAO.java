package dao.impl;

import dao.BaseDAO;
import dao.ServiceDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import model.Service;

/**
 * JDBC implementation of {@link ServiceDAO} for SQL Server.
 */
public class ServiceJdbcDAO extends BaseDAO implements ServiceDAO {

    @Override
    public List<Service> findAll() {
        String sql = "SELECT service_id, name, category, duration, price, description, is_deleted FROM Services WHERE is_deleted = 0 ORDER BY name";
        List<Service> services = new ArrayList<>();

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                services.add(mapRowToService(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return services;
    }

    @Override
    public List<Service> findByCategory(String category) {
        String sql = "SELECT service_id, name, category, duration, price, description, is_deleted FROM Services WHERE category = ? AND is_deleted = 0 ORDER BY name";
        List<Service> services = new ArrayList<>();

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    services.add(mapRowToService(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return services;
    }

    @Override
    public Optional<Service> findById(int serviceId) {
        String sql = "SELECT service_id, name, category, duration, price, description, is_deleted FROM Services WHERE service_id = ? AND is_deleted = 0";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToService(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public Service create(Service service) {
        String sql = "INSERT INTO Services (name, category, duration, price, description, is_deleted) VALUES (?, ?, ?, ?, ?, 0)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, service.getName());
            ps.setString(2, service.getCategory());
            ps.setInt(3, service.getDuration());
            ps.setDouble(4, service.getPrice());
            ps.setString(5, service.getDescription());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        service.setServiceId(rs.getInt(1));
                        service.setDeleted(false);
                        return service;
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean update(Service service) {
        String sql = "UPDATE Services SET name = ?, category = ?, duration = ?, price = ?, description = ? WHERE service_id = ? AND is_deleted = 0";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, service.getName());
            ps.setString(2, service.getCategory());
            ps.setInt(3, service.getDuration());
            ps.setDouble(4, service.getPrice());
            ps.setString(5, service.getDescription());
            ps.setInt(6, service.getServiceId());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean delete(int serviceId) {
        String sql = "UPDATE Services SET is_deleted = 1 WHERE service_id = ? AND is_deleted = 0";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    private Service mapRowToService(ResultSet rs) throws SQLException {
        Service service = new Service();
        service.setServiceId(rs.getInt("service_id"));
        service.setName(rs.getString("name"));
        service.setCategory(rs.getString("category"));
        service.setDuration(rs.getInt("duration"));
        service.setPrice(rs.getDouble("price"));
        service.setDescription(rs.getString("description"));
        service.setDeleted(rs.getBoolean("is_deleted"));
        return service;
    }
}