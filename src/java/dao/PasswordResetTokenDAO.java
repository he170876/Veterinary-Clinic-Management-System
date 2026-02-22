package dao;

import java.time.LocalDateTime;

/**
 * DAO for password reset tokens (forgot-password flow).
 */
public interface PasswordResetTokenDAO {

    /**
     * Store a reset token for the given email. Replaces any existing token for that email.
     */
    void create(String token, String email, LocalDateTime expiresAt);

    /**
     * Find email for a valid (non-expired) token. Returns null if not found or expired.
     */
    String findEmailByToken(String token);

    /**
     * Remove token after successful reset or to invalidate.
     */
    void deleteByToken(String token);

    /**
     * Remove expired tokens (optional cleanup).
     */
    void deleteExpired();
}
