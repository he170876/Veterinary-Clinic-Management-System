package dao;

import model.Blog;
import java.util.List;

public interface BlogDAO {

    // ===== Create =====
    boolean insert(Blog blog);

    // ===== Read =====
    Blog findById(int blogId);

    List<Blog> findAll();

    // ===== Update =====
    boolean update(Blog blog);

    boolean updateStatus(int blogId, String status);

    // Toggle nhanh giữa DRAFT <-> PUBLISHED
    boolean toggleStatus(int blogId);

    // ===== Delete =====
    boolean delete(int blogId);

    // ===== Pagination + Sorting =====
    List<Blog> findAllWithPaging(int offset, int limit,
            String sort, String order);

    int countAll();

    // ===== Search + Filter + Paging + Sorting =====
    List<Blog> search(String keyword, String status, String sort, int offset, int limit);

    int countSearch(String keyword, String status);
}
