package dao;

import model.MedicalRecord;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * DAO interface for Medical Records.
 * Provides methods to retrieve medical history for pets.
 */
public interface MedicalRecordDAO {

    /**
     * Get all medical records for a specific pet.
     * @param petId The pet ID
     * @return List of medical records sorted by visit date (most recent first)
     */
    List<MedicalRecord> getMedicalHistoryByPet(int petId);

    /**
     * Get all medical records for a customer's pets.
     * @param customerId The customer ID
     * @return List of medical records for all customer's pets sorted by visit date (most recent first)
     */
    List<MedicalRecord> getMedicalHistoryByCustomer(int customerId);

    /**
     * Get a single medical record by ID.
     * @param recordId The medical record ID
     * @return Optional containing the medical record if found
     */
    Optional<MedicalRecord> getMedicalRecordById(int recordId);

        /**
         * Get a single medical record by ID and customer ownership.
         * @param recordId The medical record ID
         * @param customerId The owner customer ID
         * @return Optional containing the medical record if found and owned by customer
         */
        Optional<MedicalRecord> getMedicalRecordByIdAndCustomer(int recordId, int customerId);

    /**
     * Get recent medical records for a specific pet (limited to N records).
     * @param petId The pet ID
     * @param limit The maximum number of records to retrieve
     * @return List of recent medical records
     */
    List<MedicalRecord> getRecentMedicalHistory(int petId, int limit);

    /**
     * Get recent medical records for all customer's pets (limited to N records).
     * @param customerId The customer ID
     * @param limit The maximum number of records to retrieve
     * @return List of recent medical records
     */
    List<MedicalRecord> getRecentMedicalHistoryByCustomer(int customerId, int limit);
    
    /**
     * Get medical records for a customer with pagination and date filtering.
     * @param customerId The customer ID
     * @param petId Optional pet ID filter (null for all pets)
     * @param startDate Optional start date filter
     * @param endDate Optional end date filter
     * @param offset Starting record (for pagination)
     * @param limit Number of records per page
     * @return List of medical records
     */
    List<MedicalRecord> getMedicalRecordsWithFilter(int customerId, Integer petId, 
            LocalDateTime startDate, LocalDateTime endDate, int offset, int limit);
    
    /**
     * Count total medical records for a customer with filters.
     * @param customerId The customer ID
     * @param petId Optional pet ID filter
     * @param startDate Optional start date filter
     * @param endDate Optional end date filter
     * @return Total count of records
     */
    int countMedicalRecordsWithFilter(int customerId, Integer petId, 
            LocalDateTime startDate, LocalDateTime endDate);
}
