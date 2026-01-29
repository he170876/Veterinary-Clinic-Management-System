package dao;

import java.util.Optional;
import model.Role;
import model.User;

/**
 * DAO interface for accessing Users.
 */
public interface UserDAO {

    Optional<User> findByEmail(String email);
    
    Optional<User> findById(int userId);

    boolean existsByEmail(String email);
    
    Optional<Role> findRoleByName(String roleName);

    User createCustomerUser(User user);
    
    boolean updateUser(User user);
}
