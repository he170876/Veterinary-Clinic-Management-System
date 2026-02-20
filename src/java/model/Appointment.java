package model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Domain model representing an Appointment, mapped to the Appointments table.
 */
public class Appointment {

    private int appointmentId;
    private Pet pet;
    private Customer customer;
    private int veterinarianId; // keep as id for now to avoid circular model explosion
    private String veterinarianName; // for display purposes
    private String service; // service name
    private LocalDateTime appointmentTime;
    private String status; // Pending, Confirmed, Completed, Cancelled...
    private LocalDateTime createdAt;

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

    public int getVeterinarianId() {
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
}

