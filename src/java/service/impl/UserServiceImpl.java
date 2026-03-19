package service.impl;

import dao.UserDAO;
import dao.impl.UserJdbcDAO;
import service.UserService;

public class UserServiceImpl implements UserService {
    private final UserDAO userDAO;
    public UserServiceImpl() {
        this.userDAO = new UserJdbcDAO();
    }
    @Override
    public boolean changeUserRole(int userId, int newRoleId) {
        // Sử dụng updateUserByAdmin để đổi role (các trường khác giữ nguyên)
        // Lấy user hiện tại
        return userDAO.findById(userId).map(user ->
            userDAO.updateUserByAdmin(
                userId,
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getAddress(),
                newRoleId,
                user.getStatus()
            )
        ).orElse(false);
    }
}
