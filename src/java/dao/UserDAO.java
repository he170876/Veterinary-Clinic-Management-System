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

    Optional<User> findByPhone(String phone);

    Optional<User> findById(int userId);

    boolean existsByEmail(String email);

    /** Phone exists (normalized comparison) for any user. */
    boolean existsByPhone(String phone);

    /** Phone exists for any other user (excluding given userId). */
    boolean existsByPhoneExceptId(String phone, int userId);

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

    void updateUserStatus(int userId, String status);

    boolean updateUserByAdmin(int userId, String fullName, String email, String phone, String address, int roleId, String status);

    boolean existsByEmailExceptId(String email, int userId);

    boolean existsRoleById(int roleId);
    
    boolean existsById(int userId);
    
    public boolean create(User user);

    /**
     * Mark user as Google sign-in (no change password).
     *
     * @return true if one row was updated.
     */
    boolean setGoogleUser(int userId);
}
