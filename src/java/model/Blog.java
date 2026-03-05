package model;

import java.time.LocalDateTime;

public class Blog {

    private int blogId;
    private String title;
    private String content;
    private LocalDateTime createdAt;
    private String status;
    private int authorUserId;
    private LocalDateTime updatedAt;
    private String thumbnailUrl;
    private String slug;
    private String category;
    private String metaDescription;

    // ===== Constructor rỗng =====
    public Blog() {
    }

    // ===== Constructor đầy đủ =====
    public Blog(int blogId, String title, String content, LocalDateTime createdAt,
                String status, int authorUserId, LocalDateTime updatedAt,
                String thumbnailUrl, String slug, String category,
                String metaDescription) {
        this.blogId = blogId;
        this.title = title;
        this.content = content;
        this.createdAt = createdAt;
        this.status = status;
        this.authorUserId = authorUserId;
        this.updatedAt = updatedAt;
        this.thumbnailUrl = thumbnailUrl;
        this.slug = slug;
        this.category = category;
        this.metaDescription = metaDescription;
    }

    // ===== Getter & Setter =====

    public int getBlogId() {
        return blogId;
    }

    public void setBlogId(int blogId) {
        this.blogId = blogId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getAuthorUserId() {
        return authorUserId;
    }

    public void setAuthorUserId(int authorUserId) {
        this.authorUserId = authorUserId;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getMetaDescription() {
        return metaDescription;
    }

    public void setMetaDescription(String metaDescription) {
        this.metaDescription = metaDescription;
    }
}