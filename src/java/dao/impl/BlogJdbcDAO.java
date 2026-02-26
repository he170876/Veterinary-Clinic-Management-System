package dao.impl;

import dao.BaseDAO;
import dao.BlogDAO;
import model.Blog;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BlogJdbcDAO extends BaseDAO implements BlogDAO {

    private static final String TABLE = "Blogs";

    // ================= INSERT =================
    @Override
    public boolean insert(Blog blog) {
        String sql = "INSERT INTO " + TABLE + " (title, content, created_at, status, "
                + "author_user_id, updated_at, thumbnail_url, slug, category, meta_description) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, blog.getTitle());
            ps.setString(2, blog.getContent());
            ps.setTimestamp(3, Timestamp.valueOf(blog.getCreatedAt()));
            ps.setString(4, blog.getStatus());
            ps.setInt(5, blog.getAuthorUserId());
            ps.setTimestamp(6, Timestamp.valueOf(blog.getUpdatedAt()));
            ps.setString(7, blog.getThumbnailUrl());
            ps.setString(8, blog.getSlug());
            ps.setString(9, blog.getCategory());
            ps.setString(10, blog.getMetaDescription());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================= FIND BY ID =================
    @Override
    public Blog findById(int blogId) {
        String sql = "SELECT * FROM " + TABLE + " WHERE blog_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, blogId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return map(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ================= FIND ALL =================
    @Override
    public List<Blog> findAll() {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT * FROM " + TABLE + " ORDER BY created_at DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================= UPDATE =================
    @Override
    public boolean update(Blog blog) {
        String sql = "UPDATE " + TABLE + " SET title=?, content=?, status=?, author_user_id=?, "
                + "updated_at=?, thumbnail_url=?, slug=?, category=?, meta_description=? "
                + "WHERE blog_id=?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, blog.getTitle());
            ps.setString(2, blog.getContent());
            ps.setString(3, blog.getStatus());
            ps.setInt(4, blog.getAuthorUserId());
            ps.setTimestamp(5, Timestamp.valueOf(blog.getUpdatedAt()));
            ps.setString(6, blog.getThumbnailUrl());
            ps.setString(7, blog.getSlug());
            ps.setString(8, blog.getCategory());
            ps.setString(9, blog.getMetaDescription());
            ps.setInt(10, blog.getBlogId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================= UPDATE STATUS =================
    @Override
    public boolean updateStatus(int blogId, String status) {
        String sql = "UPDATE " + TABLE + " SET status=?, updated_at=GETDATE() WHERE blog_id=?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, blogId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================= TOGGLE STATUS =================
    @Override
    public boolean toggleStatus(int blogId) {
        Blog blog = findById(blogId);
        if (blog == null) {
            return false;
        }

        String newStatus = "DRAFT".equalsIgnoreCase(blog.getStatus())
                ? "PUBLISHED"
                : "DRAFT";

        return updateStatus(blogId, newStatus);
    }

    // ================= DELETE =================
    @Override
    public boolean delete(int blogId) {
        String sql = "DELETE FROM " + TABLE + " WHERE blog_id=?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, blogId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================= PAGING =================
    @Override
    public List<Blog> findAllWithPaging(int offset, int limit) {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT * FROM " + TABLE + " ORDER BY created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, limit);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================= COUNT ALL =================
    @Override
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM " + TABLE;

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ================= SEARCH + FILTER + PAGING =================
    @Override
    public List<Blog> search(String keyword, String status, int offset, int limit) {

        List<Blog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT * FROM " + TABLE + " WHERE 1=1 "
        );

        boolean hasKeyword = keyword != null && !keyword.isBlank();
        boolean hasStatus = status != null && !status.isBlank();

        if (hasKeyword) {
            sql.append("AND title LIKE ? ESCAPE '\\' ");
        }

        if (hasStatus) {
            sql.append("AND status = ? ");
        }

        sql.append("ORDER BY created_at DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int index = 1;

            // ===== KEYWORD =====
            if (hasKeyword) {
                keyword = keyword.trim();

                // limit length to avoid abuse
                if (keyword.length() > 100) {
                    keyword = keyword.substring(0, 100);
                }

                String safeKeyword = escapeLikeKeyword(keyword);
                ps.setString(index++, "%" + safeKeyword + "%");
            }

            // ===== STATUS =====
            if (hasStatus) {
                ps.setString(index++, status.trim());
            }

            // ===== PAGING =====
            ps.setInt(index++, offset);
            ps.setInt(index, limit);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // ================= COUNT SEARCH =================
    @Override
    public int countSearch(String keyword, String status) {

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM " + TABLE + " WHERE 1=1 "
        );

        boolean hasKeyword = keyword != null && !keyword.isBlank();
        boolean hasStatus = status != null && !status.isBlank();

        if (hasKeyword) {
            sql.append("AND title LIKE ? ESCAPE '\\' ");
        }

        if (hasStatus) {
            sql.append("AND status = ? ");
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int index = 1;

            // ===== KEYWORD =====
            if (hasKeyword) {
                keyword = keyword.trim();

                if (keyword.length() > 100) {
                    keyword = keyword.substring(0, 100);
                }

                String safeKeyword = escapeLikeKeyword(keyword);
                ps.setString(index++, "%" + safeKeyword + "%");
            }

            // ===== STATUS =====
            if (hasStatus) {
                ps.setString(index++, status.trim());
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    // ================= ESCAPE HELPER =================
    private String escapeLikeKeyword(String keyword) {
        if (keyword == null) {
            return null;
        }

        return keyword
                .replace("\\", "\\\\") // escape backslash
                .replace("%", "\\%") // escape %
                .replace("_", "\\_");    // escape _
    }

    // ================= MAPPER =================
    private Blog map(ResultSet rs) throws SQLException {
        Blog blog = new Blog();

        blog.setBlogId(rs.getInt("blog_id"));
        blog.setTitle(rs.getString("title"));
        blog.setContent(rs.getString("content"));
        blog.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        blog.setStatus(rs.getString("status"));
        blog.setAuthorUserId(rs.getInt("author_user_id"));
        blog.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        blog.setThumbnailUrl(rs.getString("thumbnail_url"));
        blog.setSlug(rs.getString("slug"));
        blog.setCategory(rs.getString("category"));
        blog.setMetaDescription(rs.getString("meta_description"));

        return blog;
    }
}
