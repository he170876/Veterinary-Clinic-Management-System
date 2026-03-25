package dao.impl;

import dao.BaseDAO;
import dao.ContentDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import model.ContentItem;

public class ContentJdbcDAO extends BaseDAO implements ContentDAO {

    @Override
    public Optional<ContentItem> findLatestByKey(String keyName, String locale, boolean includeDraft) {
        String sql = includeDraft
                ? "SELECT TOP 1 content_id, key_name, value_type, value_text, image_id, locale, status, version, updated_by, updated_at "
                    + "FROM dbo.content_items WHERE key_name = ? AND locale = ? ORDER BY version DESC, content_id DESC"
                : "SELECT TOP 1 content_id, key_name, value_type, value_text, image_id, locale, status, version, updated_by, updated_at "
                    + "FROM dbo.content_items WHERE key_name = ? AND locale = ? AND status = 'published' ORDER BY version DESC, content_id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, keyName);
            ps.setString(2, locale);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public List<ContentItem> findLatestByLocale(String locale, boolean includeDraft) {
        String sql = includeDraft
                ? "WITH ranked AS ("
                    + " SELECT content_id, key_name, value_type, value_text, image_id, locale, status, version, updated_by, updated_at,"
                    + " ROW_NUMBER() OVER (PARTITION BY key_name, locale ORDER BY version DESC, content_id DESC) rn"
                    + " FROM dbo.content_items WHERE locale = ?"
                    + ")"
                    + " SELECT content_id, key_name, value_type, value_text, image_id, locale, status, version, updated_by, updated_at"
                    + " FROM ranked WHERE rn = 1 ORDER BY key_name ASC"
                : "WITH ranked AS ("
                    + " SELECT content_id, key_name, value_type, value_text, image_id, locale, status, version, updated_by, updated_at,"
                    + " ROW_NUMBER() OVER (PARTITION BY key_name, locale ORDER BY version DESC, content_id DESC) rn"
                    + " FROM dbo.content_items WHERE locale = ? AND status = 'published'"
                    + ")"
                    + " SELECT content_id, key_name, value_type, value_text, image_id, locale, status, version, updated_by, updated_at"
                    + " FROM ranked WHERE rn = 1 ORDER BY key_name ASC";

        List<ContentItem> items = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, locale);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapRow(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return items;
    }

    @Override
    public Optional<ContentItem> findLatestDraftByKey(String keyName, String locale) {
        String sql = "SELECT TOP 1 content_id, key_name, value_type, value_text, image_id, locale, status, version, updated_by, updated_at "
                + "FROM dbo.content_items WHERE key_name = ? AND locale = ? AND status = 'draft' ORDER BY version DESC, content_id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, keyName);
            ps.setString(2, locale);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public int findMaxVersion(String keyName, String locale) {
        String sql = "SELECT ISNULL(MAX(version), 0) max_version FROM dbo.content_items WHERE key_name = ? AND locale = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, keyName);
            ps.setString(2, locale);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("max_version");
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    @Override
    public long create(ContentItem item) {
        String sql = "INSERT INTO dbo.content_items (key_name, value_type, value_text, image_id, locale, status, version, updated_by, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, item.getKeyName());
            ps.setString(2, item.getValueType());
            ps.setString(3, item.getValueText());
            if (item.getImageId() == null) {
                ps.setNull(4, java.sql.Types.BIGINT);
            } else {
                ps.setLong(4, item.getImageId());
            }
            ps.setString(5, item.getLocale());
            ps.setString(6, item.getStatus());
            ps.setInt(7, item.getVersion());
            if (item.getUpdatedBy() == null) {
                ps.setNull(8, java.sql.Types.INTEGER);
            } else {
                ps.setInt(8, item.getUpdatedBy());
            }

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return -1;
    }

    @Override
    public boolean update(ContentItem item) {
        String sql = "UPDATE dbo.content_items "
                + "SET value_type = ?, value_text = ?, image_id = ?, updated_by = ?, updated_at = GETDATE() "
                + "WHERE content_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getValueType());
            ps.setString(2, item.getValueText());
            if (item.getImageId() == null) {
                ps.setNull(3, java.sql.Types.BIGINT);
            } else {
                ps.setLong(3, item.getImageId());
            }
            if (item.getUpdatedBy() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, item.getUpdatedBy());
            }
            ps.setLong(5, item.getContentId());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean publishKey(String keyName, String locale, Integer updatedBy) {
        String selectDraftSql = "SELECT TOP 1 content_id FROM dbo.content_items WHERE key_name = ? AND locale = ? AND status = 'draft' ORDER BY version DESC, content_id DESC";
        String demotePublishedSql = "UPDATE dbo.content_items SET status = 'draft', updated_by = ?, updated_at = GETDATE() WHERE key_name = ? AND locale = ? AND status = 'published'";
        String promoteDraftSql = "UPDATE dbo.content_items SET status = 'published', updated_by = ?, updated_at = GETDATE() WHERE content_id = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                Long draftId = null;
                try (PreparedStatement ps = conn.prepareStatement(selectDraftSql)) {
                    ps.setString(1, keyName);
                    ps.setString(2, locale);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            draftId = rs.getLong("content_id");
                        }
                    }
                }

                if (draftId == null) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(demotePublishedSql)) {
                    if (updatedBy == null) {
                        ps.setNull(1, java.sql.Types.INTEGER);
                    } else {
                        ps.setInt(1, updatedBy);
                    }
                    ps.setString(2, keyName);
                    ps.setString(3, locale);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(promoteDraftSql)) {
                    if (updatedBy == null) {
                        ps.setNull(1, java.sql.Types.INTEGER);
                    } else {
                        ps.setInt(1, updatedBy);
                    }
                    ps.setLong(2, draftId);
                    int updated = ps.executeUpdate();
                    if (updated == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                ex.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    private ContentItem mapRow(ResultSet rs) throws SQLException {
        ContentItem item = new ContentItem();
        item.setContentId(rs.getLong("content_id"));
        item.setKeyName(rs.getString("key_name"));
        item.setValueType(rs.getString("value_type"));
        item.setValueText(rs.getString("value_text"));
        long imageId = rs.getLong("image_id");
        if (!rs.wasNull()) {
            item.setImageId(imageId);
        }
        item.setLocale(rs.getString("locale"));
        item.setStatus(rs.getString("status"));
        item.setVersion(rs.getInt("version"));

        int updatedBy = rs.getInt("updated_by");
        if (!rs.wasNull()) {
            item.setUpdatedBy(updatedBy);
        }

        Timestamp ts = rs.getTimestamp("updated_at");
        if (ts != null) {
            item.setUpdatedAt(ts.toLocalDateTime());
        }
        return item;
    }
}
