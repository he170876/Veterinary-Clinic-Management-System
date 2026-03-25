package service.impl;

import dao.PasswordResetTokenDAO;
import dao.UserDAO;
import dao.impl.PasswordResetTokenJdbcDAO;
import dao.impl.UserJdbcDAO;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;
import model.Role;
import model.User;
import service.AuthService;
import utils.PasswordUtil;
import utils.ValidationUtil;

/**
 * Default implementation of {@link AuthService}.
 */
public class AuthServiceImpl implements AuthService {

    private static final Logger LOG = Logger.getLogger(AuthServiceImpl.class.getName());

    private static volatile String lastRegistrationError;

    public static String getLastRegistrationError() {
        return lastRegistrationError;
    }

    private static final int RESET_TOKEN_EXPIRE_HOURS = 1;

    private final UserDAO userDAO;
    private final PasswordResetTokenDAO resetTokenDAO;

    public AuthServiceImpl() {
        this.userDAO = new UserJdbcDAO();
        this.resetTokenDAO = new PasswordResetTokenJdbcDAO();
    }

    @Override
    public Optional<User> login(String email, String passwordPlaintext) {
        if (email == null || passwordPlaintext == null) {
            return Optional.empty();
        }

        Optional<User> userOpt = userDAO.findByEmail(email.trim().toLowerCase());
        if (!userOpt.isPresent()) {
            return Optional.empty();
        }

        User user = userOpt.get();
        
        // Check if account is active
        if (!"Active".equalsIgnoreCase(user.getStatus())) {
            return Optional.empty();
        }

        // Verify password
        boolean matches = PasswordUtil.matches(passwordPlaintext, user.getPasswordHash());
        return matches ? Optional.of(user) : Optional.empty();
    }

    @Override
    public User registerCustomer(String fullName, String email, String phone, String passwordPlaintext) {
        lastRegistrationError = null;
        // Check if email already exists
        if (userDAO.existsByEmail(email.trim().toLowerCase())) {
            return null; // Email taken
        }
        if (phone != null && !phone.trim().isEmpty() && userDAO.existsByPhone(phone)) {
            lastRegistrationError = "Phone number is already in use. Please use a different phone number.";
            return null;
        }

        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setPhone(phone != null ? phone.trim() : null);
        user.setPasswordHash(PasswordUtil.hashPassword(passwordPlaintext));
        user.setStatus("Active");

        Optional<Role> customerRole = userDAO.findRoleByName("Customer");
        if (!customerRole.isPresent()) {
            lastRegistrationError = "Role 'Customer' not found in Roles table. Run the SQL below in SSMS.";
            return null;
        }
        user.setRole(customerRole.get());

        User created = userDAO.createCustomerUser(user);
        if (created == null) {
            // Handle unique constraint race-condition (email/phone)
            String dbErr = dao.impl.UserJdbcDAO.getLastInsertError();
            if (dbErr != null && (dbErr.contains("UQ_Users_Phone") || dbErr.contains("UQ_Users_Phone".toLowerCase()))) {
                lastRegistrationError = "Phone number is already in use. Please use a different phone number.";
            }
        }
        return created;
    }

    @Override
    public boolean isEmailTaken(String email) {
        return userDAO.existsByEmail(email.trim().toLowerCase());
    }

    @Override
    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        Optional<User> userOpt = userDAO.findById(userId);
        if (!userOpt.isPresent()) {
            return false;
        }

        User user = userOpt.get();
        
        // Verify old password
        if (!PasswordUtil.matches(oldPassword, user.getPasswordHash())) {
            return false;
        }

        // Update password in database
        return userDAO.updatePassword(userId, PasswordUtil.hashPassword(newPassword));
    }

    @Override
    public Optional<String> createPasswordResetToken(String email) {
        if (email == null || email.isEmpty()) {
            LOG.log(Level.FINE, "Password reset: skipped (empty email)");
            return Optional.empty();
        }
        String normalized = email.trim().toLowerCase();
        Optional<User> userOpt = userDAO.findByEmail(normalized);
        if (!userOpt.isPresent()) {
            LOG.log(Level.INFO, "Password reset: no token created for ''{0}'' (user not found or Roles JOIN failed)", normalized);
            return Optional.empty();
        }
        User user = userOpt.get();
        if (user.isGoogleUser()) {
            LOG.log(Level.INFO, "Password reset: no token created for ''{0}'' (Google user)", normalized);
            return Optional.empty();
        }
        if (!"Active".equalsIgnoreCase(user.getStatus())) {
            LOG.log(Level.INFO, "Password reset: no token created for ''{0}'' (status not Active: {1})", new Object[]{normalized, user.getStatus()});
            return Optional.empty();
        }

        String token = UUID.randomUUID().toString().replace("-", "");
        LocalDateTime expiresAt = LocalDateTime.now().plusHours(RESET_TOKEN_EXPIRE_HOURS);
        resetTokenDAO.create(token, normalized, expiresAt);
        LOG.log(Level.INFO, "Password reset: token created for ''{0}''", normalized);
        return Optional.of(token);
    }

    @Override
    public boolean resetPasswordWithToken(String token, String newPasswordPlaintext) {
        if (token == null || token.isEmpty() || newPasswordPlaintext == null) return false;
        if (!ValidationUtil.isValidPassword(newPasswordPlaintext)) return false;

        String email = resetTokenDAO.findEmailByToken(token);
        if (email == null) return false;

        Optional<User> userOpt = userDAO.findByEmail(email);
        if (!userOpt.isPresent()) return false;

        User user = userOpt.get();
        boolean ok = userDAO.updatePassword(user.getUserId(), PasswordUtil.hashPassword(newPasswordPlaintext));
        if (ok) resetTokenDAO.deleteByToken(token);
        return ok;
    }
}
