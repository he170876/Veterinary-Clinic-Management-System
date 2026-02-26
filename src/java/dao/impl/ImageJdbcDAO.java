package dao.impl;

import dao.BaseDAO;
import dao.ImageDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import model.Image;

/**
 * JDBC implementation of {@link ImageDAO} for SQL Server.
 */
public class ImageJdbcDAO extends BaseDAO implements ImageDAO {

    @Override
    public List<Image> findAll() {
        String sql = "SELECT id, title, url, alt_text, section, sort_order, created_at "
                + "FROM Images ORDER BY created_at DESC";
        List<Image> images = new ArrayList<>();

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    images.add(mapRowToImage(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return images;
    }

    @Override
    public List<Image> findBySection(String section) {
        String sql = "SELECT id, title, url, alt_text, section, sort_order, created_at "
                + "FROM Images WHERE section = ? ORDER BY sort_order ASC";
        List<Image> images = new ArrayList<>();

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, section);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    images.add(mapRowToImage(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return images;
    }

    @Override
    public Optional<Image> findById(long id) {
        String sql = "SELECT id, title, url, alt_text, section, sort_order, created_at "
                + "FROM Images WHERE id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRowToImage(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public Image create(Image image) {
        String sql = "INSERT INTO Images (title, url, alt_text, section, sort_order, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, image.getTitle());
            ps.setString(2, image.getUrl());
            ps.setString(3, image.getAltText());
            ps.setString(4, image.getSection());
            ps.setInt(5, image.getSortOrder());
            ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));

            int rowsInserted = ps.executeUpdate();
            if (rowsInserted > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        image.setId(generatedKeys.getLong(1));
                        image.setCreatedAt(LocalDateTime.now());
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return image;
    }

    @Override
    public boolean update(Image image) {
        String sql = "UPDATE Images SET title = ?, url = ?, alt_text = ?, section = ?, sort_order = ? "
                + "WHERE id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, image.getTitle());
            ps.setString(2, image.getUrl());
            ps.setString(3, image.getAltText());
            ps.setString(4, image.getSection());
            ps.setInt(5, image.getSortOrder());
            ps.setLong(6, image.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean delete(long id) {
        String sql = "DELETE FROM Images WHERE id = ?";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    public List<Image> findAllOrderBySort() {
        String sql = "SELECT id, title, url, alt_text, section, sort_order, created_at "
                + "FROM Images ORDER BY section ASC, sort_order ASC";
        List<Image> images = new ArrayList<>();

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    images.add(mapRowToImage(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return images;
    }

    private Image mapRowToImage(ResultSet rs) throws SQLException {
        Image image = new Image();
        image.setId(rs.getLong("id"));
        image.setTitle(rs.getString("title"));
        image.setUrl(rs.getString("url"));
        image.setAltText(rs.getString("alt_text"));
        image.setSection(rs.getString("section"));
        image.setSortOrder(rs.getInt("sort_order"));

        Timestamp createdTs = rs.getTimestamp("created_at");
        if (createdTs != null) {
            image.setCreatedAt(createdTs.toLocalDateTime());
        }
        return image;
    }
}
