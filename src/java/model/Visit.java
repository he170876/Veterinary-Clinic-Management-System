package model;

import java.time.LocalDateTime;

/**
 * Represents a clinic visit (one per appointment when vet starts examination or receptionist checks in).
 * Maps to Visits table.
 */
public class Visit {

    private int visitId;
    private Integer appointmentId;
    private int petId;
    private int customerId;
    private LocalDateTime checkInTime;
    private LocalDateTime checkOutTime;
    private String visitStatus;
    private Integer staffId;       // receptionist_id
    private Integer veterinarianId;

    public int getVisitId() { return visitId; }
    public void setVisitId(int visitId) { this.visitId = visitId; }
    public Integer getAppointmentId() { return appointmentId; }
    public void setAppointmentId(Integer appointmentId) { this.appointmentId = appointmentId; }
    public int getPetId() { return petId; }
    public void setPetId(int petId) { this.petId = petId; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    public LocalDateTime getCheckInTime() { return checkInTime; }
    public void setCheckInTime(LocalDateTime checkInTime) { this.checkInTime = checkInTime; }
    public LocalDateTime getCheckOutTime() { return checkOutTime; }
    public void setCheckOutTime(LocalDateTime checkOutTime) { this.checkOutTime = checkOutTime; }
    public String getVisitStatus() { return visitStatus; }
    public void setVisitStatus(String visitStatus) { this.visitStatus = visitStatus; }
    public Integer getStaffId() { return staffId; }
    public void setStaffId(Integer staffId) { this.staffId = staffId; }
    public Integer getVeterinarianId() { return veterinarianId; }
    public void setVeterinarianId(Integer veterinarianId) { this.veterinarianId = veterinarianId; }
}
