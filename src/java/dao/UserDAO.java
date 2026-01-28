package dao;

import java.util.Optional;
import model.User;

/**
 * DAO interface for accessing Users.
 */
public interface UserDAO {

    Optional<User> findByEmail(String email);

    User createCustomerUser(User user);
}

