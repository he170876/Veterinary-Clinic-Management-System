package model;

import java.time.LocalDateTime;

/**
 * Domain model representing an image in the system.
 */
public class Image {
    private long id;
    private String title;
    private String url;
    private String altText;
    private String section;
    private int sortOrder;
    private LocalDateTime createdAt;

    public Image() {
    }

    public Image(String title, String url, String altText, String section, int sortOrder) {
        this.title = title;
        this.url = url;
        this.altText = altText;
        this.section = section;
        this.sortOrder = sortOrder;
    }

    // Getters & Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getAltText() {
        return altText;
    }

    public void setAltText(String altText) {
        this.altText = altText;
    }

    public String getSection() {
        return section;
    }

    public void setSection(String section) {
        this.section = section;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Image{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", url='" + url + '\'' +
                ", altText='" + altText + '\'' +
                ", section='" + section + '\'' +
                ", sortOrder=" + sortOrder +
                ", createdAt=" + createdAt +
                '}';
    }
}
