package model;

/**
 * Domain model representing a system role, aligned with the Roles table
 * defined in the VCMS RDS.
 */
public class Role {

    private int roleId;
    private String roleName; // Admin, ClinicOwner, Veterinarian, Receptionist, Customer, LabStaff, etc.

    public Role() {
    }

    public Role(int roleId, String roleName) {
        this.roleId = roleId;
        this.roleName = roleName;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
}

