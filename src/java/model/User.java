package model;

import java.time.LocalDateTime;

/**
 * Domain model representing a system user, mapped to the Users table
 * in the VCMS database design.
 */
public class User {

    private int userId;
    private String email;
    private String passwordHash;
    private Role role;
    private String status; // Active, Inactive, Blocked, etc.
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String fullName;
    private String phone;
    private String address;
    /** Relative URL path e.g. /uploads/avatars/5.jpg */
    private String profilePictureUrl;
    /** True if user was created via Google login (no change password). */
    private boolean googleUser;

    public User() {
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getProfilePictureUrl() {
        return profilePictureUrl;
    }

    /**
     * Stores a web-relative path (e.g. {@code /uploads/avatars/vet-1.jpg}).
     * Rejects Windows-style absolute paths; normalizes backslashes to slashes.
     */
    public void setProfilePictureUrl(String profilePictureUrl) {
        this.profilePictureUrl = normalizeProfilePictureUrl(profilePictureUrl);
    }

    private static String normalizeProfilePictureUrl(String url) {
        if (url == null) {
            return null;
        }
        String s = url.trim();
        if (s.isEmpty()) {
            return null;
        }
        // Reject Windows file paths pasted into DB (e.g. Admin\AppData\Local\... or C:\...)
        if (s.indexOf('\\') >= 0 && !s.startsWith("/") && !s.contains("://")) {
            return null;
        }
        s = s.replace('\\', '/');
        if (s.length() >= 2 && Character.isLetter(s.charAt(0)) && s.charAt(1) == ':') {
            return null;
        }
        if (s.startsWith("http://") || s.startsWith("https://")) {
            return s;
        }
        if (!s.startsWith("/")) {
            s = "/" + s;
        }
        return s;
    }

    public boolean isGoogleUser() {
        return googleUser;
    }

    public void setGoogleUser(boolean googleUser) {
        this.googleUser = googleUser;
    }
}

