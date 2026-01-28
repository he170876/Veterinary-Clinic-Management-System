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

    private final UserDAO userDAO;

    // In a more advanced setup, this would be injected.
    public AuthServiceImpl() {
        this.userDAO = new UserJdbcDAO();
    }

    @Override
    public Optional<User> login(String email, String passwordPlaintext) {
        Optional<User> userOpt = userDAO.findByEmail(email);
        if (!userOpt.isPresent()) {
            return Optional.empty();
        }

        User user = userOpt.get();
        if (!"Active".equalsIgnoreCase(user.getStatus())) {
            return Optional.empty();
        }

        boolean matches = PasswordUtil.matches(passwordPlaintext, user.getPasswordHash());
        return matches ? Optional.of(user) : Optional.empty();
    }

    @Override
    public User registerCustomer(String fullName, String email, String phone, String passwordPlaintext) {
        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setPasswordHash(PasswordUtil.hashPassword(passwordPlaintext));
        user.setStatus("Active");

        // For base code, we assume Customer role has ID = 5.
        // Adjust this to match your actual Roles table once initialized.
        Role customerRole = new Role();
        customerRole.setRoleId(5);
        customerRole.setRoleName("Customer");
        user.setRole(customerRole);

        return userDAO.createCustomerUser(user);
    }
}

