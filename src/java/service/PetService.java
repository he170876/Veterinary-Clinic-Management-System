package service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import model.Pet;

/**
 * Service interface for Pet-related business logic
 */
public interface PetService {

    /**
     * Get a pet by its ID
     */
    Optional<Pet> getPetById(int petId);

    /**
     * Get all pets for a specific customer
     */
    List<Pet> getPetsByCustomerId(int customerId);

    /**
     * Get all pets in the system
     */
    List<Pet> getAllPets();

    /**
     * Create a new pet
     */
    Pet createPet(int customerId, String name, String species, String breed, 
                  String gender, LocalDate birthDate, Double weight);

    /**
     * Update an existing pet (all fields)
     */
    boolean updatePet(int petId, String name, String species, String breed, 
                     String gender, LocalDate birthDate, Double weight);

    /**
     * Update pet with photo URL
     */
    boolean updatePetWithPhoto(int petId, String name, String species, String breed,
                              String gender, LocalDate birthDate, Double weight, String photoUrl);

    /**
     * Delete a pet
     */
    boolean deletePet(int petId);

    /**
     * Search pets by name
     */
    List<Pet> searchPetsByName(String name);
}
