package model;

import java.time.LocalDateTime;

/**
 * Lab test request from vet. Maps to LabTestRequests table.
 * Display fields (pet name, owner, vet name, test name) are populated by DAO for list view.
 */
public class LabTestRequest {

    private int requestId;
    private int visitId;
    private int testId;
    private int veterinarianId;
    private LocalDateTime requestTime;
    private String status;

    // Display (from JOINs)
    private String petName;
    private String species;
    private String breed;
    private String ownerName;
    private String veterinarianName;
    private String testName;
    private String clinicalNotes;

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }
    public int getVisitId() { return visitId; }
    public void setVisitId(int visitId) { this.visitId = visitId; }
    public int getTestId() { return testId; }
    public void setTestId(int testId) { this.testId = testId; }
    public int getVeterinarianId() { return veterinarianId; }
    public void setVeterinarianId(int veterinarianId) { this.veterinarianId = veterinarianId; }
    public LocalDateTime getRequestTime() { return requestTime; }
    public void setRequestTime(LocalDateTime requestTime) { this.requestTime = requestTime; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPetName() { return petName; }
    public void setPetName(String petName) { this.petName = petName; }
    public String getSpecies() { return species; }
    public void setSpecies(String species) { this.species = species; }
    public String getBreed() { return breed; }
    public void setBreed(String breed) { this.breed = breed; }
    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }
    public String getVeterinarianName() { return veterinarianName; }
    public void setVeterinarianName(String veterinarianName) { this.veterinarianName = veterinarianName; }
    public String getTestName() { return testName; }
    public void setTestName(String testName) { this.testName = testName; }
    public String getClinicalNotes() { return clinicalNotes; }
    public void setClinicalNotes(String clinicalNotes) { this.clinicalNotes = clinicalNotes; }
}
