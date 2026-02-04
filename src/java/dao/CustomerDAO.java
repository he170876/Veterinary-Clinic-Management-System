package dao;

import java.util.List;
import java.util.Optional;
import model.Customer;

/**
 * DAO interface for accessing Customer entities.
 */
public interface CustomerDAO {

    /**
     * Find a customer by their ID
     */
    Optional<Customer> findById(int customerId);

    /**
     * Find a customer by their user ID
     */
    Optional<Customer> findByUserId(int userId);

    /**
     * Get all customers
     */
    List<Customer> findAll();

    /**
     * Create a new customer record
     */
    Customer create(Customer customer);

    /**
     * Update an existing customer
     */
    boolean update(Customer customer);

    /**
     * Delete a customer by ID
     */
    boolean delete(int customerId);
}
