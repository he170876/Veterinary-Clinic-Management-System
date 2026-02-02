package service;

import java.util.Optional;
import model.User;

/**
 * Service interface for authentication-related use cases.
 */
public interface AuthService {

    /**
     * Authenticate a user by email and password.
     * @return User if credentials are valid and account is active, empty otherwise.
     */
    Optional<User> login(String email, String passwordPlaintext);

    /**
     * Register a new customer account.
     * @return The created user, or null if email already exists.
     */
    User registerCustomer(String fullName, String email, String phone, String passwordPlaintext);
    
    /**
     * Check if an email is already registered.
     */
    boolean isEmailTaken(String email);
    
    /**
     * Change a user's password.
     * @return true if successful.
     */
    boolean changePassword(int userId, String oldPassword, String newPassword);
}
