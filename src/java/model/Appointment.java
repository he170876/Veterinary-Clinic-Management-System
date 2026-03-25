package model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

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
    private LocalDateTime arrivalTime; // receptionist check-in time
    private String status; // Pending, Confirmed, Completed, Cancelled...
    private String type;   // Normal, Emergency, etc.
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

    public LocalDateTime getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(LocalDateTime arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public String getFormattedArrivalTime() {
        if (arrivalTime == null) {
            return "—";
        }
        return arrivalTime.format(DateTimeFormatter.ofPattern("HH:mm"));
    }
    
    /**
     * Human-readable period for booking slots (not a specific clock time).
     */
    public String getDisplayTimePeriodEnglish() {
        if (timeSlot != null && !timeSlot.isBlank()) {
            String t = timeSlot.trim().toLowerCase(Locale.ROOT);
            if ("am".equals(t) || "morning".equals(t)) {
                return "in the Morning";
            }
            if ("pm".equals(t) || "afternoon".equals(t)) {
                return "in the Afternoon";
            }
        }
        if (appointmentTime != null) {
            return appointmentTime.getHour() < 12 ? "in the Morning" : "in the Afternoon";
        }
        return "N/A";
    }

    public String getFormattedTime() {
        return getDisplayTimePeriodEnglish();
    }
    
    public String getFormattedDate() {
        if (appointmentDate != null) {
            return appointmentDate.format(DateTimeFormatter.ofPattern("MMM dd, yyyy"));
        }
        if (appointmentTime != null) {
            return appointmentTime.format(DateTimeFormatter.ofPattern("MMM dd, yyyy"));
        }
        return "N/A";
    }

    /** e.g. {@code February 26, 2026 in the Morning} */
    public String getFormattedDateAndPeriod() {
        LocalDate date = appointmentDate != null ? appointmentDate
                : (appointmentTime != null ? appointmentTime.toLocalDate() : null);
        if (date == null) {
            return "N/A";
        }
        String period = getDisplayTimePeriodEnglish();
        String datePart = date.format(DateTimeFormatter.ofPattern("MMMM dd, yyyy"));
        if ("N/A".equals(period)) {
            return datePart;
        }
        return datePart + " " + period;
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
        LocalDate date = appointmentDate != null ? appointmentDate
                : (appointmentTime != null ? appointmentTime.toLocalDate() : null);
        if (date == null) {
            return "N/A";
        }
        String period = getDisplayTimePeriodEnglish();
        String datePart = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        if ("N/A".equals(period)) {
            return datePart;
        }
        return datePart + " " + period;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
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
