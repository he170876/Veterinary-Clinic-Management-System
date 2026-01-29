package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * RBAC: allows access to role-scoped paths only when the current user has the required role.
 * - /customer/*  → Customer (and Admin/ClinicOwner for future)
 * - /owner/*     → Admin, ClinicOwner
 * - /vet/*       → Veterinarian
 * - /staff/*     → Receptionist
 * - /lab/*       → LabStaff
 * Unauthenticated → redirect to /login. Wrong role → redirect to homepage with ?forbidden=1.
 */
@WebFilter(
    filterName = "RoleBasedAccessFilter",
    urlPatterns = { "/customer/*", "/owner/*", "/vet/*", "/staff/*", "/lab/*" }
)
public class RoleBasedAccessFilter implements Filter {

    private static final Set<String> CUSTOMER_ROLES = set("Customer", "Admin", "ClinicOwner");
    private static final Set<String> OWNER_ROLES = set("Admin", "ClinicOwner");
    private static final Set<String> VET_ROLES = set("Veterinarian");
    private static final Set<String> STAFF_ROLES = set("Receptionist");
    private static final Set<String> LAB_ROLES = set("LabStaff");

    private static Set<String> set(String... roles) {
        return Collections.unmodifiableSet(new HashSet<>(Arrays.asList(roles)));
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String path = req.getServletPath();
        if (path == null) path = "";

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        String roleName = (user.getRole() != null && user.getRole().getRoleName() != null)
                ? user.getRole().getRoleName().trim() : "";

        Set<String> allowed = allowedRolesForPath(path);
        if (allowed != null && !allowed.contains(roleName)) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp?forbidden=1");
            return;
        }

        chain.doFilter(request, response);
    }

    private Set<String> allowedRolesForPath(String path) {
        if (path.startsWith("/customer/")) return CUSTOMER_ROLES;
        if (path.startsWith("/owner/")) return OWNER_ROLES;
        if (path.startsWith("/vet/")) return VET_ROLES;
        if (path.startsWith("/staff/")) return STAFF_ROLES;
        if (path.startsWith("/lab/")) return LAB_ROLES;
        return null;
    }
}
