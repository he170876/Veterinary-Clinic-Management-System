package controller.pet;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Optional;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        System.out.println("doGet action: " + action);

        try {
            switch (action) {
                case "list":
                    listPets(request, response);
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
        List<Pet> pets;
        Customer displayCustomer = null;

        // Check for customer_id in URL parameter (for testing)
        String customerIdParam = request.getParameter("customer_id");
        
        // If no session and no customer_id parameter, redirect to login
        if ((session == null || session.getAttribute("user") == null) && 
            (customerIdParam == null || customerIdParam.isEmpty())) {
            System.out.println("No authenticated user and no customer_id parameter, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // If user is logged in as customer, show only their pets
        // Otherwise show all pets (for admin/staff)
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            System.out.println("User logged in: " + user.getFullName());
            
            // Check if user is a customer
            if ("Customer".equals(user.getRole().getRoleName())) {
                Customer customer = (Customer) session.getAttribute("customer");
                if (customer != null) {
                    System.out.println("Loading pets for customer ID: " + customer.getCustomerId());
                    pets = petService.getPetsByCustomerId(customer.getCustomerId());
                    displayCustomer = customer;
                } else {
                    System.out.println("Customer object is null, loading all pets");
                    pets = petService.getAllPets();
                }
            } else {
                System.out.println("User is not a customer, loading all pets");
                pets = petService.getAllPets();
            }
        } else if (customerIdParam != null && !customerIdParam.isEmpty()) {
            // Test mode: load pets by customer_id parameter
            try {
                int customerId = Integer.parseInt(customerIdParam);
                System.out.println("Test mode: Loading pets for customer ID: " + customerId);
                pets = petService.getPetsByCustomerId(customerId);
                
                // Load customer from database
                Optional<Customer> customerOpt = customerDAO.findById(customerId);
                if (customerOpt.isPresent()) {
                    displayCustomer = customerOpt.get();
                    System.out.println("Customer found: " + displayCustomer.getName());
                } else {
                    System.out.println("Customer not found");
                }
            } catch (NumberFormatException e) {
                System.out.println("Invalid customer_id parameter, loading all pets");
                pets = petService.getAllPets();
            }
        } else {
            System.out.println("No session or user, loading all pets");
            pets = petService.getAllPets();
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
            Customer customer = (Customer) session.getAttribute("customer");
            User user = (User) session.getAttribute("user");
            request.setAttribute("customer", customer);
            request.setAttribute("user", user);
        }
        
        request.getRequestDispatcher("/pets/index.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/pets/create.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int petId = Integer.parseInt(request.getParameter("id"));
        Optional<Pet> pet = petService.getPetById(petId);

        if (pet.isPresent()) {
            request.setAttribute("pet", pet.get());
            request.getRequestDispatcher("/pets/edit.jsp").forward(request, response);
        } else {
            response.sendRedirect("pets?error=Pet not found");
        }
    }

    private void showDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int petId = Integer.parseInt(request.getParameter("id"));
        Optional<Pet> pet = petService.getPetById(petId);

        if (pet.isPresent()) {
            request.setAttribute("pet", pet.get());
            request.getRequestDispatcher("/pets/details.jsp").forward(request, response);
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

            if (session != null && session.getAttribute("customer") != null) {
                Customer customer = (Customer) session.getAttribute("customer");
                customerId = customer.getCustomerId();
            } else {
                // For admin/staff creating pet for a customer
                String customerIdParam = request.getParameter("customerId");
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    customerId = Integer.parseInt(customerIdParam);
                } else {
                    request.setAttribute("error", "Customer ID is required");
                    request.getRequestDispatcher("/pets/create.jsp").forward(request, response);
                    return;
                }
            }
            
            // Validate: Customer can only create pets for themselves (if not admin)
            if (session != null && session.getAttribute("customer") != null) {
                Customer customer = (Customer) session.getAttribute("customer");
                String customerIdParam = request.getParameter("customerId");
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    int paramCustomerId = Integer.parseInt(customerIdParam);
                    if (paramCustomerId != customer.getCustomerId()) {
                        System.err.println("❌ Access denied: Customer " + customer.getCustomerId() + 
                                         " trying to create pet for customer " + paramCustomerId);
                        request.setAttribute("error", "You can only create pets for your own account");
                        request.getRequestDispatcher("/pets/create.jsp").forward(request, response);
                        return;
                    }
                }
            }

            String name = request.getParameter("name");
            String species = request.getParameter("species");
            String breed = request.getParameter("breed");
            String gender = request.getParameter("gender");
            
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
            response.sendRedirect("pets?customer_id=" + customerId + "&success=Pet created successfully");

        } catch (NumberFormatException | DateTimeParseException e) {
            System.err.println("❌ Format error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Invalid input format: " + e.getMessage());
            request.getRequestDispatcher("/pets/create.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            System.err.println("❌ Validation error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/pets/create.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ Unexpected error in createPet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error creating pet: " + e.getMessage());
            request.getRequestDispatcher("/pets/create.jsp").forward(request, response);
        }
    }

    private void updatePet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int petId = Integer.parseInt(request.getParameter("petId"));
            
            // Get customerId from session or parameter for redirect
            int customerId = 0;
            HttpSession session = request.getSession(false);
            Customer sessionCustomer = null;
            if (session != null && session.getAttribute("customer") != null) {
                sessionCustomer = (Customer) session.getAttribute("customer");
                customerId = sessionCustomer.getCustomerId();
            } else {
                String customerIdParam = request.getParameter("customer_id");
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    customerId = Integer.parseInt(customerIdParam);
                }
            }
            
            // Validate: Check if pet exists and belongs to customer
            Optional<Pet> petOpt = petService.getPetById(petId);
            if (!petOpt.isPresent()) {
                request.setAttribute("error", "Pet not found");
                request.getRequestDispatcher("/pets/edit.jsp").forward(request, response);
                return;
            }
            
            Pet existingPet = petOpt.get();
            int petOwnerId = existingPet.getOwner().getCustomerId();
            
            // If customer is logged in, verify they own the pet
            if (sessionCustomer != null && petOwnerId != sessionCustomer.getCustomerId()) {
                System.err.println("❌ Access denied: Customer " + sessionCustomer.getCustomerId() + 
                                 " trying to edit pet of customer " + petOwnerId);
                request.setAttribute("error", "You can only edit your own pets");
                request.getRequestDispatcher("/pets/edit.jsp").forward(request, response);
                return;
            }
            
            String name = request.getParameter("name");
            String species = request.getParameter("species");
            String breed = request.getParameter("breed");
            String gender = request.getParameter("gender");

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
                System.out.println("✅ Photo updated successfully");
            }

            if (success) {
                response.sendRedirect("pets?customer_id=" + customerId + "&success=Pet updated successfully");
            } else {
                response.sendRedirect("pets?customer_id=" + customerId + "&error=Failed to update pet");
            }

        } catch (NumberFormatException | DateTimeParseException e) {
            System.err.println("❌ Format error in updatePet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Invalid input format: " + e.getMessage());
            request.getRequestDispatcher("/pets/edit.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ Unexpected error in updatePet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error updating pet: " + e.getMessage());
            request.getRequestDispatcher("/pets/edit.jsp").forward(request, response);
        }
    }

    private void deletePet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int petId = Integer.parseInt(request.getParameter("id"));
            
            // Get customerId for redirect and validate ownership
            int customerId = 0;
            HttpSession session = request.getSession(false);
            Customer sessionCustomer = null;
            if (session != null && session.getAttribute("customer") != null) {
                sessionCustomer = (Customer) session.getAttribute("customer");
                customerId = sessionCustomer.getCustomerId();
            } else {
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
                
                // If customer is logged in, verify they own the pet
                if (sessionCustomer != null && petOwnerId != sessionCustomer.getCustomerId()) {
                    System.err.println("❌ Access denied: Customer " + sessionCustomer.getCustomerId() + 
                                     " trying to delete pet of customer " + petOwnerId);
                    response.sendRedirect("pets?customer_id=" + customerId + "&error=You can only delete your own pets");
                    return;
                }
            }
            
            boolean success = petService.deletePet(petId);

            if (success) {
                response.sendRedirect("pets?customer_id=" + customerId + "&success=Pet deleted successfully");
            } else {
                response.sendRedirect("pets?customer_id=" + customerId + "&error=Failed to delete pet");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("pets?error=Invalid pet ID");
        }
    }

    private void searchPets(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchQuery = request.getParameter("q");
        System.out.println("=== searchPets() called with query: " + searchQuery + " ===");

        List<Pet> pets;
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            pets = petService.searchPetsByName(searchQuery.trim());
            System.out.println("Search results: " + pets.size() + " pets found");
        } else {
            pets = petService.getAllPets();
        }

        request.setAttribute("pets", pets);
        request.setAttribute("searchQuery", searchQuery);
        
        // Set customer info for header display
        HttpSession session = request.getSession(false);
        if (session != null) {
            Customer customer = (Customer) session.getAttribute("customer");
            request.setAttribute("customer", customer);
        }
        
        request.getRequestDispatcher("/pets/index.jsp").forward(request, response);
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
            
            // Generate unique filename to avoid conflicts
            String fileExtension = "";
            int dotIndex = fileName.lastIndexOf('.');
            if (dotIndex > 0) {
                fileExtension = fileName.substring(dotIndex);
            }
            String uniqueFileName = System.currentTimeMillis() + fileExtension;
            
            // Define upload directory (relative to web application)
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            
            // Create directory if not exists
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            
            // Save file
            String filePath = uploadPath + File.separator + uniqueFileName;
            filePart.write(filePath);
            
            System.out.println("✅ File uploaded: " + uniqueFileName + " to " + uploadPath);
            
            // Return relative path for database
            return "uploads/" + uniqueFileName;
        } catch (Exception e) {
            System.err.println("❌ Error uploading file: " + e.getMessage());
            e.printStackTrace();
            return null; // Return null on error
        }
    }
}
