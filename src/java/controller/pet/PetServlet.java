package controller.pet;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.file.Paths;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import model.Customer;
import model.Pet;
import model.User;
import service.PetService;
import service.impl.PetServiceImpl;
import dao.CustomerDAO;
import dao.impl.CustomerJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import static jakarta.servlet.http.HttpServletResponse.SC_FORBIDDEN;

/**
 * Servlet controller for Pet CRUD operations
 * Handles: list, create, edit, delete, details
 */
@WebServlet(name = "PetServlet", urlPatterns = {"/pets"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 15    // 15 MB
)
public class PetServlet extends HttpServlet {

    private PetService petService;
    private CustomerDAO customerDAO;

    @Override
    public void init() throws ServletException {
        System.out.println("=== PetServlet INITIALIZED ===");
        petService = new PetServiceImpl();
        customerDAO = new CustomerJdbcDAO();
        System.out.println("=== PetService created successfully ===");
    }

    private User getCurrentUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object currentUserObj = session.getAttribute("currentUser");
        return currentUserObj instanceof User ? (User) currentUserObj : null;
    }

    private Optional<Customer> resolveCurrentCustomer(HttpSession session) {
        User currentUser = getCurrentUser(session);
        if (currentUser == null || currentUser.getRole() == null
                || !"Customer".equalsIgnoreCase(currentUser.getRole().getRoleName())) {
            return Optional.empty();
        }
        Optional<Customer> customerOpt = customerDAO.findByUserId(currentUser.getUserId());
        if (customerOpt.isPresent()) {
            return customerOpt;
        }

        try {
            Customer autoCustomer = new Customer();
            autoCustomer.setUser(currentUser);
            customerDAO.create(autoCustomer);
            return customerDAO.findByUserId(currentUser.getUserId());
        } catch (Exception ex) {
            System.err.println("Could not auto-create customer profile for userId=" + currentUser.getUserId() + ": " + ex.getMessage());
            return Optional.empty();
        }
    }

    private boolean isCustomerUser(User user) {
        return user != null && user.getRole() != null
                && "Customer".equalsIgnoreCase(user.getRole().getRoleName());
    }

    private boolean isPetOwnedByCustomer(Pet pet, Customer customer) {
        return pet != null
                && customer != null
                && pet.getOwner() != null
                && pet.getOwner().getCustomerId() == customer.getCustomerId();
    }

    private void forwardAccessDenied(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("denyMessage", message);
        request.setAttribute("backUrl", request.getContextPath() + "/customer/dashboard");
        response.setStatus(SC_FORBIDDEN);
        request.getRequestDispatcher("/access-denied.jsp").forward(request, response);
    }

    private Optional<Pet> findDeletedPetById(int petId) {
        List<Pet> deletedPets = petService.getDeletedPets();
        if (deletedPets == null || deletedPets.isEmpty()) {
            return Optional.empty();
        }
        for (Pet pet : deletedPets) {
            if (pet != null && pet.getPetId() == petId) {
                return Optional.of(pet);
            }
        }
        return Optional.empty();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = getCurrentUser(session);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String searchQuery = request.getParameter("q");
        if ((action == null || action.trim().isEmpty())
                && searchQuery != null && !searchQuery.trim().isEmpty()) {
            action = "search";
        } else if (action == null) {
            action = "list";
        }

        System.out.println("doGet action: " + action);

        try {
            switch (action) {
                case "list":
                    listPets(request, response);
                    break;
                case "trash":
                    listDeletedPets(request, response);
                    break;
                case "create":
                    showCreateForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deletePet(request, response);
                    break;
                case "hardDelete":
                    hardDeletePet(request, response);
                    break;
                case "restore":
                    restorePet(request, response);
                    break;
                case "details":
                    showDetails(request, response);
                    break;
                case "search":
                    searchPets(request, response);
                    break;
                default:
                    listPets(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException("Error processing pet request", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = getCurrentUser(session);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "create";
        }

        try {
            switch (action) {
                case "create":
                    createPet(request, response);
                    break;
                case "update":
                    updatePet(request, response);
                    break;
                default:
                    response.sendRedirect("pets");
                    break;
            }
        } catch (Exception e) {
            throw new ServletException("Error processing pet request", e);
        }
    }

    private void listPets(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== PetServlet.listPets() called ===");
        
        HttpSession session = request.getSession(false);
        List<Pet> pets = java.util.Collections.emptyList();
        Customer displayCustomer = null;

        User currentUser = getCurrentUser(session);
        if (currentUser == null) {
            System.out.println("No authenticated user, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // If user is logged in as customer, show only their pets
        // Otherwise show all pets (for admin/staff)
        if (currentUser != null) {
            System.out.println("User logged in: " + currentUser.getFullName());
            
            // Check if user is a customer
            if (isCustomerUser(currentUser)) {
                Optional<Customer> customerOpt = resolveCurrentCustomer(session);
                if (customerOpt.isPresent()) {
                    Customer customer = customerOpt.get();
                    System.out.println("Loading pets for customer ID: " + customer.getCustomerId());
                    pets = petService.getPetsByCustomerId(customer.getCustomerId());
                    displayCustomer = customer;
                } else {
                    System.out.println("Customer role detected but no customer record found");
                    pets = java.util.Collections.emptyList();
                }
            } else {
                System.out.println("User is not a customer, loading all pets");
                pets = petService.getAllPets();
            }
        }

        System.out.println("Total pets retrieved: " + (pets != null ? pets.size() : "null"));
        if (pets != null && !pets.isEmpty()) {
            System.out.println("First pet: " + pets.get(0).getName());
        }
        
        request.setAttribute("pets", pets);
        
        // Set customer info for header display
        if (displayCustomer != null) {
            request.setAttribute("customer", displayCustomer);
        } else if (session != null) {
            resolveCurrentCustomer(session).ifPresent(customer -> request.setAttribute("customer", customer));
            request.setAttribute("user", currentUser);
        }
        
        request.getRequestDispatcher("/WEB-INF/views/pets/index.jsp").forward(request, response);
    }

    private void listDeletedPets(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("Loading deleted pets (trash)...");

        HttpSession session = request.getSession(false);
        User currentUser = getCurrentUser(session);
        Optional<Customer> currentCustomerOpt = resolveCurrentCustomer(session);

        List<Pet> deletedPets = petService.getDeletedPets();
        if (isCustomerUser(currentUser)) {
            if (!currentCustomerOpt.isPresent()) {
                response.sendRedirect("pets?error=Customer profile not found");
                return;
            }
            int currentCustomerId = currentCustomerOpt.get().getCustomerId();
            java.util.ArrayList<Pet> ownDeletedPets = new java.util.ArrayList<>();
            for (Pet pet : deletedPets) {
                if (pet != null && pet.getOwner() != null && pet.getOwner().getCustomerId() == currentCustomerId) {
                    ownDeletedPets.add(pet);
                }
            }
            deletedPets = ownDeletedPets;
            request.setAttribute("customer", currentCustomerOpt.get());
        }
        
        System.out.println("Total deleted pets retrieved: " + (deletedPets != null ? deletedPets.size() : "null"));
        
        request.setAttribute("deletedPets", deletedPets);
        request.getRequestDispatcher("/WEB-INF/views/pets/trash.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = getCurrentUser(session);
        request.setAttribute("user", currentUser);
        resolveCurrentCustomer(session).ifPresent(customer -> request.setAttribute("customer", customer));
        request.getRequestDispatcher("/WEB-INF/views/pets/create.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int petId = Integer.parseInt(request.getParameter("id"));
        Optional<Pet> pet = petService.getPetById(petId);

        if (pet.isPresent()) {
            HttpSession session = request.getSession(false);
            User currentUser = getCurrentUser(session);
            if (isCustomerUser(currentUser)) {
                Optional<Customer> customerOpt = resolveCurrentCustomer(session);
                if (!customerOpt.isPresent() || !isPetOwnedByCustomer(pet.get(), customerOpt.get())) {
                    forwardAccessDenied(request, response, "Bạn không có quyền chỉnh sửa thú cưng của khách hàng khác.");
                    return;
                }
            }
            request.setAttribute("pet", pet.get());
            request.getRequestDispatcher("/WEB-INF/views/pets/edit.jsp").forward(request, response);
        } else {
            response.sendRedirect("pets?error=Pet not found");
        }
    }

    private void showDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int petId = Integer.parseInt(request.getParameter("id"));
        Optional<Pet> pet = petService.getPetById(petId);

        if (pet.isPresent()) {
            HttpSession session = request.getSession(false);
            User currentUser = getCurrentUser(session);
            if (isCustomerUser(currentUser)) {
                Optional<Customer> customerOpt = resolveCurrentCustomer(session);
                if (!customerOpt.isPresent() || !isPetOwnedByCustomer(pet.get(), customerOpt.get())) {
                    forwardAccessDenied(request, response, "Bạn không có quyền xem thú cưng của khách hàng khác.");
                    return;
                }
            }
            request.setAttribute("pet", pet.get());
            request.getRequestDispatcher("/WEB-INF/views/pets/details.jsp").forward(request, response);
        } else {
            response.sendRedirect("pets?error=Pet not found");
        }
    }

    private void createPet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get customer ID from session or request
            HttpSession session = request.getSession(false);
            int customerId;
            User currentUser = getCurrentUser(session);

            Optional<Customer> sessionCustomerOpt = resolveCurrentCustomer(session);
            if (sessionCustomerOpt.isPresent()) {
                Customer customer = sessionCustomerOpt.get();
                customerId = customer.getCustomerId();
            } else {
                if (isCustomerUser(currentUser)) {
                    request.setAttribute("error", "Customer profile not found");
                    request.getRequestDispatcher("/WEB-INF/views/pets/create.jsp").forward(request, response);
                    return;
                }
                // For admin/staff creating pet for a customer
                String customerIdParam = request.getParameter("customerId");
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    customerId = Integer.parseInt(customerIdParam);
                } else {
                    request.setAttribute("error", "Customer ID is required");
                    request.getRequestDispatcher("/WEB-INF/views/pets/create.jsp").forward(request, response);
                    return;
                }
            }
            
            // Validate: Customer can only create pets for themselves (if not admin)
            if (sessionCustomerOpt.isPresent()) {
                Customer customer = sessionCustomerOpt.get();
                String customerIdParam = request.getParameter("customerId");
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    int paramCustomerId = Integer.parseInt(customerIdParam);
                    if (paramCustomerId != customer.getCustomerId()) {
                        System.err.println("❌ Access denied: Customer " + customer.getCustomerId() + 
                                         " trying to create pet for customer " + paramCustomerId);
                        request.setAttribute("error", "You can only create pets for your own account");
                        request.getRequestDispatcher("/WEB-INF/views/pets/create.jsp").forward(request, response);
                        return;
                    }
                }
            }

            String name = request.getParameter("name");
            String species = request.getParameter("species");
            String breed = request.getParameter("breed");
            String gender = request.getParameter("gender");

            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Pet name is required");
            }
            if (species == null || species.trim().isEmpty()) {
                throw new IllegalArgumentException("Pet species is required");
            }
            
            LocalDate birthDate = null;
            String birthDateStr = request.getParameter("birthDate");
            if (birthDateStr != null && !birthDateStr.trim().isEmpty()) {
                birthDate = LocalDate.parse(birthDateStr);
            }

            Double weight = null;
            String weightStr = request.getParameter("weight");
            if (weightStr != null && !weightStr.trim().isEmpty()) {
                weight = Double.parseDouble(weightStr);
            }
            
            // Handle file upload
            String photoUrl = handleFileUpload(request, "photo");
            System.out.println("Photo URL after upload: " + photoUrl);

            Pet newPet = petService.createPet(customerId, name, species, breed, gender, birthDate, weight);
            System.out.println("Pet created with ID: " + (newPet != null ? newPet.getPetId() : "null"));
            
            // Update photo if uploaded
            if (photoUrl != null && newPet != null) {
                System.out.println("Updating pet " + newPet.getPetId() + " with photo: " + photoUrl);
                petService.updatePetWithPhoto(newPet.getPetId(), name, species, breed, gender, birthDate, weight, photoUrl);
                System.out.println("✅ Photo updated successfully");
            }
            
            // Redirect with customer_id to maintain session context
            response.sendRedirect("pets?success=Pet created successfully");

        } catch (NumberFormatException | DateTimeParseException e) {
            System.err.println("❌ Format error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Invalid input format: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/pets/create.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            System.err.println("❌ Validation error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/pets/create.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ Unexpected error in createPet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error creating pet: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/pets/create.jsp").forward(request, response);
        }
    }

    private void updatePet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int petId = Integer.parseInt(request.getParameter("petId"));
            
            // Get customerId from session or parameter for redirect
            int customerId = 0;
            HttpSession session = request.getSession(false);
            User currentUser = getCurrentUser(session);
            Customer sessionCustomer = null;
            Optional<Customer> sessionCustomerOpt = resolveCurrentCustomer(session);
            if (sessionCustomerOpt.isPresent()) {
                sessionCustomer = sessionCustomerOpt.get();
                customerId = sessionCustomer.getCustomerId();
            } else {
                if (isCustomerUser(currentUser)) {
                    request.setAttribute("error", "Customer profile not found");
                    request.getRequestDispatcher("/WEB-INF/views/pets/edit.jsp").forward(request, response);
                    return;
                }
                String customerIdParam = request.getParameter("customer_id");
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    customerId = Integer.parseInt(customerIdParam);
                }
            }
            
            // Validate: Check if pet exists and belongs to customer
            Optional<Pet> petOpt = petService.getPetById(petId);
            if (!petOpt.isPresent()) {
                request.setAttribute("error", "Pet not found");
                request.getRequestDispatcher("/WEB-INF/views/pets/edit.jsp").forward(request, response);
                return;
            }
            
            Pet existingPet = petOpt.get();
            int petOwnerId = existingPet.getOwner().getCustomerId();
            
            // If customer is logged in, verify they own the pet
            if (sessionCustomer != null && petOwnerId != sessionCustomer.getCustomerId()) {
                System.err.println("❌ Access denied: Customer " + sessionCustomer.getCustomerId() + 
                                 " trying to edit pet of customer " + petOwnerId);
                forwardAccessDenied(request, response, "Bạn không có quyền chỉnh sửa thú cưng của khách hàng khác.");
                return;
            }
            
            String name = request.getParameter("name");
            String species = request.getParameter("species");
            String breed = request.getParameter("breed");
            String gender = request.getParameter("gender");

            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Pet name is required");
            }
            if (species == null || species.trim().isEmpty()) {
                throw new IllegalArgumentException("Pet species is required");
            }

            LocalDate birthDate = null;
            String birthDateStr = request.getParameter("birthDate");
            if (birthDateStr != null && !birthDateStr.trim().isEmpty()) {
                birthDate = LocalDate.parse(birthDateStr);
            }

            Double weight = null;
            String weightStr = request.getParameter("weight");
            if (weightStr != null && !weightStr.trim().isEmpty()) {
                weight = Double.parseDouble(weightStr);
            }
            
            // Handle file upload
            String photoUrl = handleFileUpload(request, "photo");
            System.out.println("Photo URL after upload: " + photoUrl);

            boolean success = petService.updatePet(petId, name, species, breed, gender, birthDate, weight);
            System.out.println("Pet " + petId + " updated: " + success);
            
            // Update photo if new file uploaded
            if (success && photoUrl != null) {
                System.out.println("Updating pet " + petId + " with new photo: " + photoUrl);
                petService.updatePetWithPhoto(petId, name, species, breed, gender, birthDate, weight, photoUrl);
                deleteUploadedFileIfExists(request, existingPet.getPhotoUrl());
                System.out.println("✅ Photo updated successfully");
            }

            if (success) {
                response.sendRedirect("pets?success=Pet updated successfully");
            } else {
                response.sendRedirect("pets?error=Failed to update pet");
            }

        } catch (NumberFormatException | DateTimeParseException e) {
            System.err.println("❌ Format error in updatePet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Invalid input format: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/pets/edit.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            System.err.println("❌ Validation error in updatePet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/pets/edit.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ Unexpected error in updatePet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error updating pet: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/pets/edit.jsp").forward(request, response);
        }
    }

    private void deletePet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int petId = Integer.parseInt(request.getParameter("id"));
            
            // Get customerId for redirect and validate ownership
            int customerId = 0;
            HttpSession session = request.getSession(false);
            User currentUser = getCurrentUser(session);
            Customer sessionCustomer = null;
            Optional<Customer> sessionCustomerOpt = resolveCurrentCustomer(session);
            if (sessionCustomerOpt.isPresent()) {
                sessionCustomer = sessionCustomerOpt.get();
                customerId = sessionCustomer.getCustomerId();
            } else {
                if (isCustomerUser(currentUser)) {
                    response.sendRedirect("pets?error=Customer profile not found");
                    return;
                }
                String customerIdParam = request.getParameter("customer_id");
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    customerId = Integer.parseInt(customerIdParam);
                }
            }
            
            // Validate: Check if pet exists and belongs to customer
            Optional<Pet> petOpt = petService.getPetById(petId);
            if (petOpt.isPresent()) {
                Pet pet = petOpt.get();
                int petOwnerId = pet.getOwner().getCustomerId();
                if (customerId == 0) {
                    customerId = petOwnerId;
                }
                
                // If customer is logged in, verify they own the pet
                if (sessionCustomer != null && petOwnerId != sessionCustomer.getCustomerId()) {
                    System.err.println("❌ Access denied: Customer " + sessionCustomer.getCustomerId() + 
                                     " trying to delete pet of customer " + petOwnerId);
                    forwardAccessDenied(request, response, "Bạn không có quyền xóa thú cưng của khách hàng khác.");
                    return;
                }
            } else {
                response.sendRedirect("pets?error=Pet not found");
                return;
            }
            
            boolean success = petService.deletePet(petId);

            if (success) {
                if (petOpt.isPresent()) {
                    deleteUploadedFileIfExists(request, petOpt.get().getPhotoUrl());
                }
                response.sendRedirect("pets?success=Pet deleted successfully");
            } else {
                response.sendRedirect("pets?error=Failed to delete pet");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("pets?error=Invalid pet ID");
        }
    }

    private void hardDeletePet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int petId = Integer.parseInt(request.getParameter("id"));
            
            int customerId = 0;
            HttpSession session = request.getSession(false);
            User currentUser = getCurrentUser(session);
            Customer sessionCustomer = null;
            Optional<Customer> sessionCustomerOpt = resolveCurrentCustomer(session);
            if (sessionCustomerOpt.isPresent()) {
                sessionCustomer = sessionCustomerOpt.get();
                customerId = sessionCustomer.getCustomerId();
            } else {
                if (isCustomerUser(currentUser)) {
                    response.sendRedirect("pets?error=Customer profile not found");
                    return;
                }
                String customerIdParam = request.getParameter("customer_id");
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    customerId = Integer.parseInt(customerIdParam);
                }
            }
            
            Optional<Pet> petOpt = petService.getPetById(petId);
            if (petOpt.isPresent()) {
                Pet pet = petOpt.get();
                int petOwnerId = pet.getOwner().getCustomerId();
                if (customerId == 0) {
                    customerId = petOwnerId;
                }
                
                if (sessionCustomer != null && petOwnerId != sessionCustomer.getCustomerId()) {
                    System.err.println("❌ Access denied: Customer " + sessionCustomer.getCustomerId() + 
                                     " trying to hard delete pet of customer " + petOwnerId);
                    forwardAccessDenied(request, response, "Bạn không có quyền xóa vĩnh viễn thú cưng của khách hàng khác.");
                    return;
                }
            } else {
                response.sendRedirect("pets?error=Pet not found in trash");
                return;
            }
            
            boolean success = petService.hardDeletePet(petId);

            if (success) {
                if (petOpt.isPresent()) {
                    deleteUploadedFileIfExists(request, petOpt.get().getPhotoUrl());
                }
                System.out.println("✅ Pet " + petId + " permanently deleted from database");
                String fallback = buildDefaultDashboardUrl(request, customerId);
                String target = appendQueryParam(resolveSafeReturnUrl(request, fallback), "success", "Pet permanently deleted");
                response.sendRedirect(target);
            } else {
                String fallback = buildDefaultDashboardUrl(request, customerId);
                String target = appendQueryParam(resolveSafeReturnUrl(request, fallback), "error", "Failed to delete pet");
                response.sendRedirect(target);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("pets?error=Invalid pet ID");
        }
    }

    private void restorePet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int petId = Integer.parseInt(request.getParameter("id"));

            HttpSession session = request.getSession(false);
            User currentUser = getCurrentUser(session);
            Optional<Customer> sessionCustomerOpt = resolveCurrentCustomer(session);
            Customer sessionCustomer = sessionCustomerOpt.orElse(null);

            int customerId = 0;
            Optional<Pet> petOpt = findDeletedPetById(petId);
            if (petOpt.isPresent()) {
                Pet pet = petOpt.get();
                int petOwnerId = pet.getOwner().getCustomerId();
                if (customerId == 0) {
                    customerId = petOwnerId;
                }

                if (isCustomerUser(currentUser) && (sessionCustomer == null || petOwnerId != sessionCustomer.getCustomerId())) {
                    forwardAccessDenied(request, response, "Bạn không có quyền khôi phục thú cưng của khách hàng khác.");
                    return;
                }
            } else {
                response.sendRedirect("pets?error=Pet not found in trash");
                return;
            }
            
            boolean success = petService.restorePet(petId);

            if (success) {
                System.out.println("✅ Pet " + petId + " restored successfully");
                String fallback = buildDefaultDashboardUrl(request, customerId);
                String target = appendQueryParam(resolveSafeReturnUrl(request, fallback), "success", "Pet restored successfully");
                response.sendRedirect(target);
            } else {
                String fallback = buildDefaultDashboardUrl(request, customerId);
                String target = appendQueryParam(resolveSafeReturnUrl(request, fallback), "error", "Failed to restore pet");
                response.sendRedirect(target);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("pets?error=Invalid pet ID");
        }
    }

    private String buildDefaultDashboardUrl(HttpServletRequest request, int customerId) {
        StringBuilder builder = new StringBuilder(request.getContextPath()).append("/customer/dashboard");
        if (customerId > 0) {
            builder.append("?customer_id=").append(customerId);
        }
        return builder.toString();
    }

    private String resolveSafeReturnUrl(HttpServletRequest request, String fallback) {
        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl == null || returnUrl.trim().isEmpty()) {
            return fallback;
        }

        String value = returnUrl.trim();
        String contextPath = request.getContextPath();

        if (value.startsWith("http://") || value.startsWith("https://")) {
            String host = request.getServerName();
            if (!(value.contains("://" + host + "/") || value.contains("://" + host + ":"))) {
                return fallback;
            }
            return value;
        }

        if (value.startsWith(contextPath + "/")) {
            return value;
        }

        if (value.startsWith("/")) {
            return contextPath + value;
        }

        return fallback;
    }

    private String appendQueryParam(String url, String key, String value) {
        String separator = url.contains("?") ? "&" : "?";
        return url + separator
            + URLEncoder.encode(key, StandardCharsets.UTF_8)
            + "=" + URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private void searchPets(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchQuery = request.getParameter("q");
        System.out.println("=== searchPets() called with query: " + searchQuery + " ===");

        List<Pet> pets;
        HttpSession session = request.getSession(false);
        User currentUser = getCurrentUser(session);
        Optional<Customer> currentCustomerOpt = resolveCurrentCustomer(session);

        if (currentCustomerOpt.isPresent()) {
            Customer currentCustomer = currentCustomerOpt.get();
            List<Pet> customerPets = petService.getPetsByCustomerId(currentCustomer.getCustomerId());
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                String keyword = searchQuery.trim().toLowerCase();
                java.util.ArrayList<Pet> filteredPets = new java.util.ArrayList<>();
                for (Pet pet : customerPets) {
                    String petName = pet.getName() == null ? "" : pet.getName().toLowerCase();
                    String petSpecies = pet.getSpecies() == null ? "" : pet.getSpecies().toLowerCase();
                    if (petName.contains(keyword) || petSpecies.contains(keyword)) {
                        filteredPets.add(pet);
                    }
                }
                pets = filteredPets;
            } else {
                pets = customerPets;
            }
            request.setAttribute("customer", currentCustomer);
        } else if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            pets = petService.searchPetsByName(searchQuery.trim());
            System.out.println("Search results: " + pets.size() + " pets found");
        } else {
            pets = petService.getAllPets();
        }

        request.setAttribute("pets", pets);
        request.setAttribute("searchQuery", searchQuery);
        request.setAttribute("user", currentUser);
        
        request.getRequestDispatcher("/WEB-INF/views/pets/index.jsp").forward(request, response);
    }
    
    /**
     * Helper method to handle file upload
     * @param request HTTP request
     * @param partName name of the file input in form
     * @return filename if uploaded, null if no file
     */
    private String handleFileUpload(HttpServletRequest request, String partName) {
        try {
            Part filePart = request.getPart(partName);
            
            if (filePart == null || filePart.getSize() == 0) {
                return null; // No file uploaded
            }
            
            // Get filename
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            if (!isAllowedImage(filePart, fileName)) {
                throw new IllegalArgumentException("Invalid image file. Only JPG, JPEG, PNG, GIF, WEBP are allowed.");
            }
            
            // Generate unique filename to avoid conflicts
            String fileExtension = "";
            int dotIndex = fileName.lastIndexOf('.');
            if (dotIndex > 0) {
                fileExtension = fileName.substring(dotIndex);
            }
            String uniqueFileName = UUID.randomUUID().toString().replace("-", "") + fileExtension;
            
            // Define upload directory (external, persistent across builds)
            String uploadPath = getUploadBaseDir() + File.separator + "pets";
            
            System.out.println("================================");
            System.out.println("📁 Upload Directory Configuration:");
            System.out.println("   Base Dir: " + getUploadBaseDir());
            System.out.println("   Full Path: " + uploadPath);
            System.out.println("================================");
            
            // Create directory if not exists
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Save file
            String filePath = uploadPath + File.separator + uniqueFileName;
            filePart.write(filePath);
            
            System.out.println("✅ File uploaded successfully!");
            System.out.println("   Filename: " + uniqueFileName);
            System.out.println("   Full Path: " + filePath);
            System.out.println("   File Size: " + filePart.getSize() + " bytes");
            
            // Return relative path for database
            return "uploads/pets/" + uniqueFileName;
        } catch (Exception e) {
            if (e instanceof IllegalArgumentException) {
                throw (IllegalArgumentException) e;
            }
            System.err.println("❌ Error uploading file: " + e.getMessage());
            e.printStackTrace();
            return null; // Return null on error
        }
    }

    private boolean isAllowedImage(Part filePart, String fileName) {
        String contentType = filePart.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
            return false;
        }

        String lower = fileName.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png")
            || lower.endsWith(".gif") || lower.endsWith(".webp");
    }

    private void deleteUploadedFileIfExists(HttpServletRequest request, String photoUrl) {
        if (photoUrl == null || photoUrl.trim().isEmpty()) {
            return;
        }

        String normalized = photoUrl.trim().replace("\\", "/");
        File file;

        File rawFile = new File(photoUrl.trim());
        if (rawFile.isAbsolute()) {
            file = rawFile;
        } else if (normalized.startsWith("uploads/")) {
            String relative = normalized.substring("uploads/".length());
            file = new File(getUploadBaseDir(), relative.replace("/", File.separator));
        } else if (normalized.startsWith("pets/")) {
            file = new File(getUploadBaseDir(), normalized.replace("/", File.separator));
        } else if (normalized.contains("/uploads/")) {
            int uploadsIndex = normalized.indexOf("/uploads/");
            String relative = normalized.substring(uploadsIndex + "/uploads/".length());
            file = new File(getUploadBaseDir(), relative.replace("/", File.separator));
        } else {
            return;
        }

        if (file.exists() && file.isFile()) {
            boolean deleted = file.delete();
            if (deleted) {
                System.out.println("✅ Deleted old file: " + file.getAbsolutePath());
            } else {
                System.out.println("⚠️ Failed to delete old file: " + file.getAbsolutePath());
            }
        }
    }

    private String getUploadBaseDir() {
        String configured = getServletContext().getInitParameter("uploadDir");
        if (configured != null && !configured.trim().isEmpty()) {
            String path = configured.trim();
            if (!new File(path).isAbsolute()) {
                File projectRoot = new File(System.getProperty("user.dir"));
                path = new File(projectRoot, path).getAbsolutePath();
            }
            System.out.println("📌 Using configured uploadDir: " + path);
            return path;
        }

        String userDir = System.getProperty("user.dir");
        String defaultPath = userDir + File.separator + "uploads";
        System.out.println("📌 Using default uploadDir: " + defaultPath);
        System.out.println("   (user.dir = " + userDir + ")");
        return defaultPath;
    }
}
