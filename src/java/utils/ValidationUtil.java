package utils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Shared validation rules for VCMS.
 * Rules: no leading/trailing spaces (trim); name 1-30 chars; password 6-128, 1 upper + 1 digit;
 * phone 10 digits starting 0; email @gmail.com, max 255; address max 500.
 */
public final class ValidationUtil {

    public static final int EMAIL_MAX_LENGTH = 255;
    public static final int PASSWORD_MIN_LENGTH = 6;
    public static final int PASSWORD_MAX_LENGTH = 128;
    public static final int ADDRESS_MAX_LENGTH = 500;
    public static final int OWNER_OR_PET_NAME_MAX_LENGTH = 100;
    public static final int NOTES_MAX_LENGTH = 1000;

    private ValidationUtil() {}

    /** Trim; return null if null or empty after trim. */
    public static String trim(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    /** Reject if string has leading/trailing spaces (after trim, compare length). */
    public static boolean hasLeadingOrTrailingSpaces(String s) {
        if (s == null) return false;
        return !s.equals(s.trim());
    }

    /**
     * Normalize name: trim leading/trailing spaces and collapse multiple spaces between words to one.
     * Use this before validating so "  Nguyễn   Văn   A  " becomes "Nguyễn Văn A".
     * Returns null if null or empty after normalize.
     */
    public static String normalizeFullName(String s) {
        if (s == null) return null;
        String t = s.trim().replaceAll("\\s+", " ");
        return t.isEmpty() ? null : t;
    }

    /**
     * Normalize address: trim and collapse multiple spaces. Returns null if null or empty after normalize.
     */
    public static String normalizeAddress(String s) {
        if (s == null) return null;
        String t = s.trim().replaceAll("\\s+", " ");
        return t.isEmpty() ? null : t;
    }

    /** Full name: 1-30 characters, letters and spaces only (Unicode letters allowed, e.g. Vietnamese). */
    public static boolean isValidFullName(String name) {
        if (name == null) return false;
        if (name.length() < 1 || name.length() > 30) return false;
        return name.matches("^[\\p{L}\\p{M}\\s]+$");
    }

    /** Password: 6-128 chars, at least 1 uppercase, at least 1 digit. */
    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < PASSWORD_MIN_LENGTH || password.length() > PASSWORD_MAX_LENGTH) return false;
        boolean hasUpper = false;
        boolean hasDigit = false;
        for (int i = 0; i < password.length(); i++) {
            char c = password.charAt(i);
            if (Character.isUpperCase(c)) hasUpper = true;
            if (Character.isDigit(c)) hasDigit = true;
        }
        return hasUpper && hasDigit;
    }

    /** Phone: exactly 10 digits, must start with 0. */
    public static boolean isValidPhone(String phone) {
        if (phone == null) return false;
        String digits = phone.trim().replaceAll("[^0-9]", "");
        return digits.length() == 10 && digits.startsWith("0");
    }

    /** Email: must contain @gmail.com (only Gmail allowed), max 255 chars. */
    public static boolean isValidGmail(String email) {
        if (email == null) return false;
        String e = email.trim().toLowerCase();
        return e.length() <= EMAIL_MAX_LENGTH && e.endsWith("@gmail.com") && e.indexOf("@gmail.com") > 0;
    }

    /** Address: optional; if present, max 500 chars. */
    public static boolean isValidAddress(String address) {
        if (address == null || address.trim().isEmpty()) return true;
        return address.trim().length() <= ADDRESS_MAX_LENGTH;
    }

    /** Owner or pet name (booking): 1-100 chars, letters and spaces. */
    public static boolean isValidOwnerOrPetName(String name) {
        if (name == null) return false;
        String t = name.trim();
        if (t.isEmpty() || t.length() > OWNER_OR_PET_NAME_MAX_LENGTH) return false;
        return t.matches("^[a-zA-Z\\s]+$");
    }

    /** Generic email format (for guest booking): has @ and dot, max 255. */
    public static boolean isValidEmailFormat(String email) {
        if (email == null) return false;
        String e = email.trim();
        return e.length() >= 5 && e.length() <= EMAIL_MAX_LENGTH && e.contains("@") && e.contains(".");
    }

    /** Date string (yyyy-MM-dd) not in the past. */
    public static boolean isDateNotInPast(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return false;
        try {
            java.time.LocalDate d = java.time.LocalDate.parse(dateStr.trim());
            return !d.isBefore(java.time.LocalDate.now());
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Normalize booking slot to canonical values used by validation rules.
     * Returns "morning", "afternoon" or null if invalid.
     */
    public static String normalizeBookingSlot(String slot) {
        if (slot == null) {
            return null;
        }
        String normalized = slot.trim().toLowerCase();
        if ("morning".equals(normalized) || "am".equals(normalized)) {
            return "morning";
        }
        if ("afternoon".equals(normalized) || "pm".equals(normalized)) {
            return "afternoon";
        }
        return null;
    }

    /**
     * Returns true when the provided date+slot can still be booked from now.
     * Rule:
     * - date in the past: false
     * - future date: true
     * - today: booking must happen before slot start time
     */
    public static boolean isBookableDateSlot(LocalDate date, String slot) {
        if (date == null) {
            return false;
        }

        String normalizedSlot = normalizeBookingSlot(slot);
        if (normalizedSlot == null) {
            return false;
        }

        LocalDate today = LocalDate.now();
        if (date.isBefore(today)) {
            return false;
        }
        if (date.isAfter(today)) {
            return true;
        }

        LocalTime slotStart = "morning".equals(normalizedSlot)
                ? LocalTime.of(8, 0)
                : LocalTime.of(14, 0);
        return LocalDateTime.now().isBefore(LocalDateTime.of(today, slotStart));
    }

    /** No spaces allowed anywhere in value (reject if contains space). */
    public static boolean containsSpace(String s) {
        return s != null && s.contains(" ");
    }

    /** For fields that must not contain any space (e.g. password, email local part). */
    public static boolean hasNoSpaces(String s) {
        if (s == null) return true;
        return !s.contains(" ");
    }
}
