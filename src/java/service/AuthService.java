package service;

import java.util.Optional;
import model.User;

/**
 * Service interface for authentication-related use cases (login, register),
 * corresponding to AL-01, AL-02, AL-03, and registration requirements in the RDS.
 */
public interface AuthService {

    Optional<User> login(String email, String passwordPlaintext);

    User registerCustomer(String fullName, String email, String phone, String passwordPlaintext);
}

