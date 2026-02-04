package dao;

import java.util.List;
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

    /**
     * Update only the password hash for a user.
     *
     * @return true if one row was updated.
     */
    boolean updatePassword(int userId, String newPasswordHash);

    List<User> filterUsers(String keyword, Integer roleId, String status,
            String sort, int offset, int pageSize);

    int countUsers(String keyword, Integer roleId, String status);

}
