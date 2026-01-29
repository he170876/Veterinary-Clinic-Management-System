package service.impl;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import java.util.Optional;
import model.Role;
import model.User;
import service.AuthService;
import utils.PasswordUtil;

/**
 * Default implementation of {@link AuthService}.
 */
public class AuthServiceImpl implements AuthService {

    private static volatile String lastRegistrationError;

    public static String getLastRegistrationError() {
        return lastRegistrationError;
    }

    private final UserDAO userDAO;

    public AuthServiceImpl() {
        this.userDAO = new UserJdbcDAO();
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

        return userDAO.createCustomerUser(user);
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

        // Update with new password hash
        user.setPasswordHash(PasswordUtil.hashPassword(newPassword));
        return userDAO.updateUser(user);
    }
}
