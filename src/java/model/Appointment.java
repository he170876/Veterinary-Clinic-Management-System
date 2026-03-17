package model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Domain model representing an Appointment, mapped to the Appointments table.
 */
public class Appointment {

    private int appointmentId;
    private Pet pet;
    private Customer customer;
    private Integer veterinarianId; // keep as id for now to avoid circular model explosion
    private String veterinarianName; // for display purposes
    private String customerPhone; // customer's phone for receptionist views
    private String service; // service name
    private Integer serviceId; // for saving record services
    private LocalDate appointmentDate; // new: date-only column
    private String timeSlot;           // new: "AM" or "PM"
    private LocalDateTime appointmentTime;
    private String status; // Pending, Confirmed, Completed, Cancelled...
    private LocalDateTime createdAt;
    private String notes;

    public Appointment() {
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    public Pet getPet() {
        return pet;
    }

    public void setPet(Pet pet) {
        this.pet = pet;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public Integer getVeterinarianId() {
        return veterinarianId;
    }

    public void setVeterinarianId(int veterinarianId) {
        this.veterinarianId = veterinarianId;
    }

    public String getVeterinarianName() {
        return veterinarianName;
    }

    public void setVeterinarianName(String veterinarianName) {
        this.veterinarianName = veterinarianName;
    }

    public String getService() {
        return service;
    }

    public void setService(String service) {
        this.service = service;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public Integer getServiceId() {
        return serviceId;
    }

    public void setServiceId(Integer serviceId) {
        this.serviceId = serviceId;
    }

    public LocalDateTime getAppointmentTime() {
        return appointmentTime;
    }

    public void setAppointmentTime(LocalDateTime appointmentTime) {
        this.appointmentTime = appointmentTime;
    }
    
    public String getFormattedTime() {
        if (appointmentTime == null) {
            return "N/A";
        }
        return appointmentTime.format(DateTimeFormatter.ofPattern("hh:mm a"));
    }
    
    public String getFormattedDate() {
        if (appointmentTime == null) {
            return "N/A";
        }
        return appointmentTime.format(DateTimeFormatter.ofPattern("MMM dd, yyyy"));
    }

    public LocalDate getAppointmentDate() {
        return appointmentDate;
    }

    public void setAppointmentDate(LocalDate appointmentDate) {
        this.appointmentDate = appointmentDate;
    }

    public String getTimeSlot() {
        return timeSlot;
    }

    public void setTimeSlot(String timeSlot) {
        this.timeSlot = timeSlot;
    }

    /**
     * Returns a compact representation of the appointment slot using the new
     * (appointment_date, time_slot) schema, for example "2026-03-16 AM".
     * Falls back to the legacy appointmentTime field if needed.
     */
    public String getFormattedDateWithSlot() {
        if (appointmentDate != null && timeSlot != null && !timeSlot.isBlank()) {
            return appointmentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " " + timeSlot.trim().toUpperCase();
        }
        if (appointmentTime != null) {
            return appointmentTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd a"));
        }
        return "N/A";
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
