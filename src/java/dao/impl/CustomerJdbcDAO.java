package dao.impl;

import dao.BaseDAO;
import dao.CustomerDAO;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import model.Customer;
import model.Role;
import model.User;

/**
 * JDBC implementation of CustomerDAO
 */
public class CustomerJdbcDAO extends BaseDAO implements CustomerDAO {

    @Override
    public Optional<Customer> findById(int customerId) {
        String sql = "SELECT c.customer_id, c.user_id, "
                + "u.email, u.password, u.status, u.created_at, u.updated_at, "
                + "u.full_name, u.phone, u.address, r.role_id, r.role_name "
                + "FROM Customers c "
                + "JOIN Users u ON c.user_id = u.user_id "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE c.customer_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToCustomer(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public Optional<Customer> findByUserId(int userId) {
        String sql = "SELECT c.customer_id, c.user_id, "
                + "u.email, u.password, u.status, u.created_at, u.updated_at, "
                + "u.full_name, u.phone, u.address, r.role_id, r.role_name "
                + "FROM Customers c "
                + "JOIN Users u ON c.user_id = u.user_id "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE c.user_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToCustomer(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public List<Customer> findAll() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT c.customer_id, c.user_id, "
                + "u.email, u.password, u.status, u.created_at, u.updated_at, "
                + "u.full_name, u.phone, u.address, r.role_id, r.role_name "
                + "FROM Customers c "
                + "JOIN Users u ON c.user_id = u.user_id "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "ORDER BY c.customer_id DESC";

        try (Connection conn = getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                customers.add(mapRowToCustomer(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return customers;
    }

    @Override
    public Customer create(Customer customer) {
        String sql = "INSERT INTO Customers (user_id) VALUES (?)";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, customer.getUser().getUserId());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new SQLException("Creating customer failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    customer.setCustomerId(generatedKeys.getInt(1));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return customer;
    }

    @Override
    public boolean update(Customer customer) {
        // Customer table only has customer_id and user_id
        // Updates to user info should go through UserDAO
        return true;
    }

    @Override
    public boolean delete(int customerId) {
        String sql = "DELETE FROM Customers WHERE customer_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            int affected = ps.executeUpdate();
            return affected > 0;

        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    private Customer mapRowToCustomer(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setCustomerId(rs.getInt("customer_id"));

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

        Role role = new Role();
        role.setRoleId(rs.getInt("role_id"));
        role.setRoleName(rs.getString("role_name"));
        user.setRole(role);

        customer.setUser(user);
        return customer;
    }
}
