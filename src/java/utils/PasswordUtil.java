package utils;

import org.mindrot.jbcrypt.BCrypt;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Simple password hashing utility.
 * In a production system you would use a stronger algorithm (e.g. BCrypt),
 * but this provides a clear starting point for the VCMS base code.
 */
public class PasswordUtil {

    /**
     * bcrypt hashes typically look like:
     * $2a$..., $2b$..., $2y$...
     */
    private static boolean looksLikeBcryptHash(String hashedPassword) {
        if (hashedPassword == null) return false;
        String h = hashedPassword.trim();
        return h.startsWith("$2a$") || h.startsWith("$2b$") || h.startsWith("$2y$") || h.startsWith("$2x$");
    }

    public static String hashPassword(String rawPassword) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedHash = digest.digest(rawPassword.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(encodedHash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Failed to hash password", e);
        }
    }

    public static boolean matches(String rawPassword, String hashedPassword) {
        if (rawPassword == null || hashedPassword == null) return false;

        // Support both legacy SHA-256 and accounts created with BCrypt.
        if (looksLikeBcryptHash(hashedPassword)) {
            try {
                return BCrypt.checkpw(rawPassword, hashedPassword);
            } catch (Exception ignored) {
                return false;
            }
        }

        return hashPassword(rawPassword).equals(hashedPassword.trim());
    }

    private static String bytesToHex(byte[] hash) {
        StringBuilder hexString = new StringBuilder(2 * hash.length);
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString();
    }
}

