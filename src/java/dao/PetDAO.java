package dao;

import java.util.List;
import java.util.Optional;
import model.Pet;

/**
 * DAO interface for accessing Pet entities.
 */
public interface PetDAO {

    /**
     * Find a pet by its ID
     */
    Optional<Pet> findById(int petId);

    /**
     * Get all pets owned by a specific customer
     */
    List<Pet> findByCustomerId(int customerId);

    /**
     * Get all pets in the system
     */
    List<Pet> findAll();

    /**
     * Create a new pet record
     */
    Pet create(Pet pet);

    /**
     * Update an existing pet
     */
    boolean update(Pet pet);

    /**
     * Delete a pet by ID (soft delete)
     */
    boolean delete(int petId);

    /**
     * Permanently delete a pet (hard delete - remove from DB)
     */
    boolean hardDelete(int petId);

    /**
     * Restore a soft-deleted pet
     */
    boolean restore(int petId);

    /**
     * Get all soft-deleted pets
     */
    List<Pet> findAllDeleted();

    /**
     * Search pets by name
     */
    List<Pet> searchByName(String name);
}
