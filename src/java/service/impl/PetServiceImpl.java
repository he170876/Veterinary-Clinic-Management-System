package service.impl;

import dao.PetDAO;
import dao.impl.PetJdbcDAO;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import model.Customer;
import model.Pet;
import service.PetService;

/**
 * Implementation of PetService
 */
public class PetServiceImpl implements PetService {

    private final PetDAO petDAO;

    public PetServiceImpl() {
        this.petDAO = new PetJdbcDAO();
    }

    // Constructor for testing with dependency injection
    public PetServiceImpl(PetDAO petDAO) {
        this.petDAO = petDAO;
    }

    @Override
    public Optional<Pet> getPetById(int petId) {
        return petDAO.findById(petId);
    }

    @Override
    public List<Pet> getPetsByCustomerId(int customerId) {
        return petDAO.findByCustomerId(customerId);
    }

    @Override
    public List<Pet> getAllPets() {
        return petDAO.findAll();
    }

    @Override
    public Pet createPet(int customerId, String name, String species, String breed,
            String gender, LocalDate birthDate, Double weight) {

        // Validate input
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Pet name is required");
        }
        if (species == null || species.trim().isEmpty()) {
            throw new IllegalArgumentException("Pet species is required");
        }
        if (birthDate != null && birthDate.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Birth date cannot be in the future");
        }

        Pet pet = new Pet();
        Customer owner = new Customer();
        owner.setCustomerId(customerId);
        pet.setOwner(owner);
        pet.setName(name.trim());
        pet.setSpecies(species.trim());
        pet.setBreed(breed != null ? breed.trim() : null);
        pet.setGender(gender);
        pet.setBirthDate(birthDate);
        pet.setWeight(weight);

        return petDAO.create(pet);
    }

    @Override
    public boolean updatePet(int petId, String name, String species, String breed,
            String gender, LocalDate birthDate, Double weight) {

        // Validate input
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Pet name is required");
        }
        if (species == null || species.trim().isEmpty()) {
            throw new IllegalArgumentException("Pet species is required");
        }
        if (birthDate != null && birthDate.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Birth date cannot be in the future");
        }

        Optional<Pet> existingPet = petDAO.findById(petId);
        if (!existingPet.isPresent()) {
            return false;
        }

        Pet pet = existingPet.get();
        pet.setName(name.trim());
        pet.setSpecies(species.trim());
        pet.setBreed(breed != null ? breed.trim() : null);
        pet.setGender(gender);
        pet.setBirthDate(birthDate);
        pet.setWeight(weight);

        return petDAO.update(pet);
    }

    @Override
    public boolean updatePetWithPhoto(int petId, String name, String species, String breed,
            String gender, LocalDate birthDate, Double weight, String photoUrl) {

        // Validate input
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Pet name is required");
        }
        if (species == null || species.trim().isEmpty()) {
            throw new IllegalArgumentException("Pet species is required");
        }
        if (birthDate != null && birthDate.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Birth date cannot be in the future");
        }

        Optional<Pet> existingPet = petDAO.findById(petId);
        if (!existingPet.isPresent()) {
            return false;
        }

        Pet pet = existingPet.get();
        pet.setName(name.trim());
        pet.setSpecies(species.trim());
        pet.setBreed(breed != null ? breed.trim() : null);
        pet.setGender(gender);
        pet.setBirthDate(birthDate);
        pet.setWeight(weight);
        pet.setPhotoUrl(photoUrl);

        return petDAO.update(pet);
    }

    @Override
    public boolean deletePet(int petId) {
        return petDAO.delete(petId);
    }

    @Override
    public List<Pet> searchPetsByName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return getAllPets();
        }
        return petDAO.searchByName(name.trim());
    }

    /**
     * Main method to test PetService CRUD operations
     * Run this to test without web server
     */
  public static void main(String[] args) {
    PetService petService = new PetServiceImpl();

    try {
        // 1. Get all pets
        List<Pet> pets = petService.getAllPets();
        System.out.println("All pets: " + pets.size());

        // 2. Get pets by customer
        int customerId = 1;
        List<Pet> customerPets = petService.getPetsByCustomerId(customerId);
        System.out.println("Pets of customer " + customerId + ": " + customerPets.size());

        // 3. Create new pet
        Pet pet = petService.createPet(
                customerId,
                "TestPet" + System.currentTimeMillis(),
                "Dog",
                "Labrador",
                "Male",
                LocalDate.of(2023, 6, 15),
                25.5
        );

        System.out.println("Created pet id = " + pet.getPetId());

        int petId = pet.getPetId();

        // 4. Find pet by id
        Optional<Pet> found = petService.getPetById(petId);
        if (found.isPresent()) {
            System.out.println("Found pet: " + found.get().getName());
        } else {
            System.out.println("Pet not found");
        }

        // 5. Update pet
        boolean updated = petService.updatePet(
                petId,
                "UpdatedPet",
                "Cat",
                "Persian",
                "Female",
                LocalDate.of(2022, 3, 20),
                5.5
        );

        System.out.println("Update result: " + updated);

        // 6. Search pet by name
        List<Pet> searchResult = petService.searchPetsByName("Max");
        System.out.println("Search result for 'Max': " + searchResult.size());

        // 7. Delete pet
        boolean deleted = petService.deletePet(petId);
        System.out.println("Delete result: " + deleted);

        // Verify delete
        if (!petService.getPetById(petId).isPresent()) {
            System.out.println("Pet removed successfully");
        }

    } catch (Exception e) {
        System.out.println("Error while testing PetService");
        e.printStackTrace();
    }
}

}
