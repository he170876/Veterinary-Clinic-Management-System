package dao.impl;

import dao.BaseDAO;
import dao.PetDAO;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import model.Customer;
import model.Pet;

/**
 * JDBC implementation of PetDAO
 */
public class PetJdbcDAO extends BaseDAO implements PetDAO {

    @Override
    public Optional<Pet> findById(int petId) {
        String sql = "SELECT pet_id, customer_id, name, species, breed, gender, "
            + "birth_date, weight, photoUrl, created_at FROM dbo.Pets "
            + "WHERE pet_id = ? AND (isDeleted = 0 OR isDeleted IS NULL)";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, petId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToPet(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public List<Pet> findByCustomerId(int customerId) {
        List<Pet> pets = new ArrayList<>();
        String sql = "SELECT pet_id, customer_id, name, species, breed, gender, "
            + "birth_date, weight, photoUrl, created_at FROM dbo.Pets "
            + "WHERE customer_id = ? AND (isDeleted = 0 OR isDeleted IS NULL) "
            + "ORDER BY created_at DESC";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    pets.add(mapRowToPet(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return pets;
    }

    @Override
    public List<Pet> findAll() {
        List<Pet> pets = new ArrayList<>();
        String sql = "SELECT pet_id, customer_id, name, species, breed, gender, "
            + "birth_date, weight, photoUrl, created_at FROM dbo.Pets "
            + "WHERE (isDeleted = 0 OR isDeleted IS NULL) ORDER BY created_at DESC";

        System.out.println("=== PetJdbcDAO.findAll() ===");
        System.out.println("SQL: " + sql);
        
        try (Connection conn = getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            int count = 0;
            while (rs.next()) {
                pets.add(mapRowToPet(rs));
                count++;
            }
            System.out.println("Rows fetched from database: " + count);
        } catch (SQLException ex) {
            System.err.println("ERROR in findAll(): " + ex.getMessage());
            ex.printStackTrace();
        }
        System.out.println("Returning " + pets.size() + " pets");
        return pets;
    }

    @Override
    public Pet create(Pet pet) {
        String sql = "INSERT INTO dbo.Pets (customer_id, name, species, breed, gender, "
            + "birth_date, weight, photoUrl, created_at, isDeleted) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, pet.getOwner().getCustomerId());
            ps.setString(2, pet.getName());
            ps.setString(3, pet.getSpecies());
            ps.setString(4, pet.getBreed());
            ps.setString(5, pet.getGender());

            if (pet.getBirthDate() != null) {
                ps.setDate(6, Date.valueOf(pet.getBirthDate()));
            } else {
                ps.setNull(6, Types.DATE);
            }

            if (pet.getWeight() != null) {
                ps.setDouble(7, pet.getWeight());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }

            ps.setString(8, pet.getPhotoUrl());
            ps.setTimestamp(9, Timestamp.valueOf(LocalDateTime.now()));

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new SQLException("Creating pet failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    pet.setPetId(generatedKeys.getInt(1));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return pet;
    }

    @Override
    public boolean update(Pet pet) {
        String sql = "UPDATE dbo.Pets SET name = ?, species = ?, breed = ?, gender = ?, "
                + "birth_date = ?, weight = ?, photoUrl = ? WHERE pet_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, pet.getName());
            ps.setString(2, pet.getSpecies());
            ps.setString(3, pet.getBreed());
            ps.setString(4, pet.getGender());

            if (pet.getBirthDate() != null) {
                ps.setDate(5, Date.valueOf(pet.getBirthDate()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            if (pet.getWeight() != null) {
                ps.setDouble(6, pet.getWeight());
            } else {
                ps.setNull(6, Types.DECIMAL);
            }

            ps.setString(7, pet.getPhotoUrl());
            ps.setInt(8, pet.getPetId());

            int affected = ps.executeUpdate();
            return affected > 0;

        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int petId) {
        String sql = "UPDATE dbo.Pets SET isDeleted = 1, deleted_at = ? "
            + "WHERE pet_id = ? AND (isDeleted = 0 OR isDeleted IS NULL)";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(2, petId);
            int affected = ps.executeUpdate();
            return affected > 0;

        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean hardDelete(int petId) {
        String sql = "DELETE FROM dbo.Pets WHERE pet_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, petId);
            int affected = ps.executeUpdate();
            return affected > 0;

        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean restore(int petId) {
        String sql = "UPDATE dbo.Pets SET isDeleted = 0, deleted_at = NULL WHERE pet_id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, petId);
            int affected = ps.executeUpdate();
            return affected > 0;

        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Pet> findAllDeleted() {
        List<Pet> pets = new ArrayList<>();
        String sql = "SELECT pet_id, customer_id, name, species, breed, gender, "
            + "birth_date, weight, photoUrl, created_at FROM dbo.Pets "
            + "WHERE isDeleted = 1 ORDER BY deleted_at DESC";

        try (Connection conn = getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                pets.add(mapRowToPet(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return pets;
    }

    @Override
    public List<Pet> searchByName(String name) {
        List<Pet> pets = new ArrayList<>();
        String sql = "SELECT pet_id, customer_id, name, species, breed, gender, "
            + "birth_date, weight, photoUrl, created_at FROM dbo.Pets "
                + "WHERE name LIKE ? AND (isDeleted = 0 OR isDeleted IS NULL) ORDER BY name";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + name + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    pets.add(mapRowToPet(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return pets;
    }

    private Pet mapRowToPet(ResultSet rs) throws SQLException {
        Pet pet = new Pet();
        pet.setPetId(rs.getInt("pet_id"));

        // Set owner (customer)
        Customer owner = new Customer();
        owner.setCustomerId(rs.getInt("customer_id"));
        pet.setOwner(owner);

        pet.setName(rs.getString("name"));
        pet.setSpecies(rs.getString("species"));
        pet.setBreed(rs.getString("breed"));
        pet.setGender(rs.getString("gender"));

        Date birthDate = rs.getDate("birth_date");
        if (birthDate != null) {
            pet.setBirthDate(birthDate.toLocalDate());
        }

        Double weight = rs.getDouble("weight");
        if (!rs.wasNull()) {
            pet.setWeight(weight);
        }

        String photoUrl = rs.getString("photoUrl");
        if (photoUrl != null) {
            pet.setPhotoUrl(photoUrl);
        }

        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            pet.setCreatedAt(created.toLocalDateTime());
        }

        return pet;
    }
}
