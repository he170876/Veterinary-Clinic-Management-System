package dao;

import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Records amount spent per visit (no full billing UI). Creates Invoice and optional InvoiceItems from record services.
 */
public class InvoiceDAO extends DBContext {

    private static final String STATUS_RECORDED = "Recorded";

    /**
     * Creates an invoice for the visit with the given total amount. Returns the new invoice_id, or 0 on failure.
     */
    public int create(int visitId, double totalAmount, String status) {
        if (status == null || status.isEmpty()) status = STATUS_RECORDED;
        String sql = "INSERT INTO Invoices (visit_id, total_amount, status) OUTPUT INSERTED.invoice_id VALUES (?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, visitId);
            ps.setDouble(2, totalAmount);
            ps.setString(3, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Marks an invoice as Paid. */
    public boolean markAsPaid(int invoiceId) {
        String sql = "UPDATE Invoices SET status = 'Paid' WHERE invoice_id = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Adds an invoice item line (e.g. from MedicalRecordServices).
     */
    public void addItem(int invoiceId, String itemType, String nameSnapshot, double unitPrice, int quantity, double totalPrice) {
        String sql = "INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price) VALUES (?, ?, NULL, ?, ?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ps.setString(2, itemType != null ? itemType : "Service");
            ps.setString(3, nameSnapshot != null ? nameSnapshot : "");
            ps.setDouble(4, unitPrice);
            ps.setInt(5, quantity);
            ps.setDouble(6, totalPrice);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Returns the latest invoice_id for a given appointment.
     * Used by receptionist UI when it doesn't have invoiceId on the page.
     */
    public int getLatestInvoiceIdByAppointmentId(int appointmentId) {
        String sql = """
            SELECT TOP 1 i.invoice_id
            FROM Invoices i
            JOIN Visits v ON i.visit_id = v.visit_id
            WHERE v.appointment_id = ?
            ORDER BY i.invoice_id DESC
        """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("invoice_id") : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static class InvoiceLine {
        private String serviceName;
        private double unitPrice;
        private int quantity;

        public String getServiceName() {
            return serviceName;
        }

        public void setServiceName(String serviceName) {
            this.serviceName = serviceName;
        }

        public double getUnitPrice() {
            return unitPrice;
        }

        public void setUnitPrice(double unitPrice) {
            this.unitPrice = unitPrice;
        }

        public int getQuantity() {
            return quantity;
        }

        public void setQuantity(int quantity) {
            this.quantity = quantity;
        }

        public double getLineTotal() {
            return unitPrice * quantity;
        }
    }

    public static class AppointmentInvoiceView {
        private int appointmentId;
        private int invoiceId;
        private double totalAmount;
        private String invoiceStatus;
        private LocalDateTime bookedAt;
        private LocalDate appointmentDate;
        private String timeSlot;
        private LocalDateTime appointmentTimeLegacy;
        private LocalDateTime checkInAt;
        private String petName;
        private String petSpecies;
        private String customerPhone;
        private String customerEmail;
        private String veterinarianName;
        private String receptionistName;
        private final List<InvoiceLine> serviceLines = new ArrayList<>();

        public int getAppointmentId() { return appointmentId; }
        public void setAppointmentId(int appointmentId) { this.appointmentId = appointmentId; }
        public int getInvoiceId() { return invoiceId; }
        public void setInvoiceId(int invoiceId) { this.invoiceId = invoiceId; }
        public double getTotalAmount() { return totalAmount; }
        public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
        public String getInvoiceStatus() { return invoiceStatus; }
        public void setInvoiceStatus(String invoiceStatus) { this.invoiceStatus = invoiceStatus; }
        public LocalDateTime getBookedAt() { return bookedAt; }
        public void setBookedAt(LocalDateTime bookedAt) { this.bookedAt = bookedAt; }
        public LocalDate getAppointmentDate() { return appointmentDate; }
        public void setAppointmentDate(LocalDate appointmentDate) { this.appointmentDate = appointmentDate; }
        public String getTimeSlot() { return timeSlot; }
        public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }
        public LocalDateTime getAppointmentTimeLegacy() { return appointmentTimeLegacy; }
        public void setAppointmentTimeLegacy(LocalDateTime appointmentTimeLegacy) { this.appointmentTimeLegacy = appointmentTimeLegacy; }
        public LocalDateTime getCheckInAt() { return checkInAt; }
        public void setCheckInAt(LocalDateTime checkInAt) { this.checkInAt = checkInAt; }
        public String getPetName() { return petName; }
        public void setPetName(String petName) { this.petName = petName; }
        public String getPetSpecies() { return petSpecies; }
        public void setPetSpecies(String petSpecies) { this.petSpecies = petSpecies; }
        public String getCustomerPhone() { return customerPhone; }
        public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }
        public String getCustomerEmail() { return customerEmail; }
        public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }
        public String getVeterinarianName() { return veterinarianName; }
        public void setVeterinarianName(String veterinarianName) { this.veterinarianName = veterinarianName; }
        public String getReceptionistName() { return receptionistName; }
        public void setReceptionistName(String receptionistName) { this.receptionistName = receptionistName; }
        public List<InvoiceLine> getServiceLines() { return serviceLines; }
    }

    public AppointmentInvoiceView getAppointmentInvoiceView(int appointmentId) {
        String headerSql = """
            SELECT TOP 1
                a.appointment_id,
                ISNULL(i.invoice_id, 0) AS invoice_id,
                ISNULL(i.total_amount, 0) AS total_amount,
                i.status AS invoice_status,
                a.created_at AS booked_at,
                a.appointment_date,
                a.time_slot,
                v.check_in_time AS check_in_at,
                p.name AS pet_name,
                p.species AS pet_species,
                cu.phone AS customer_phone,
                cu.email AS customer_email,
                vetu.full_name AS veterinarian_name,
                ru.full_name AS receptionist_name
            FROM appointments a
            LEFT JOIN visits v ON v.appointment_id = a.appointment_id
            LEFT JOIN invoices i ON i.visit_id = v.visit_id
            LEFT JOIN pets p ON p.pet_id = a.pet_id
            LEFT JOIN customers c ON c.customer_id = a.customer_id
            LEFT JOIN users cu ON cu.user_id = c.user_id
            LEFT JOIN veterinarians vv ON vv.veterinarian_id = a.veterinarian_id
            LEFT JOIN users vetu ON vetu.user_id = vv.user_id
            LEFT JOIN receptionists rr ON rr.receptionist_id = v.staff_id
            LEFT JOIN users ru ON ru.user_id = rr.user_id
            WHERE a.appointment_id = ?
            ORDER BY i.invoice_id DESC
        """;

        AppointmentInvoiceView data = null;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(headerSql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    data = new AppointmentInvoiceView();
                    data.setAppointmentId(rs.getInt("appointment_id"));
                    data.setInvoiceId(rs.getInt("invoice_id"));
                    data.setTotalAmount(rs.getDouble("total_amount"));
                    data.setInvoiceStatus(rs.getString("invoice_status"));

                    java.sql.Timestamp bookedTs = rs.getTimestamp("booked_at");
                    if (bookedTs != null) data.setBookedAt(bookedTs.toLocalDateTime());

                    java.sql.Date apDate = rs.getDate("appointment_date");
                    if (apDate != null) data.setAppointmentDate(apDate.toLocalDate());

                    data.setTimeSlot(rs.getString("time_slot"));

                    java.sql.Timestamp checkInTs = rs.getTimestamp("check_in_at");
                    if (checkInTs != null) data.setCheckInAt(checkInTs.toLocalDateTime());

                    data.setPetName(rs.getString("pet_name"));
                    data.setPetSpecies(rs.getString("pet_species"));
                    data.setCustomerPhone(rs.getString("customer_phone"));
                    data.setCustomerEmail(rs.getString("customer_email"));
                    data.setVeterinarianName(rs.getString("veterinarian_name"));
                    data.setReceptionistName(rs.getString("receptionist_name"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        if (data == null) {
            return null;
        }

        // Priority 1: read from InvoiceItems if invoice exists.
        if (data.getInvoiceId() > 0) {
            String itemsSql = """
                SELECT
                    ii.name_snapshot,
                    ii.unit_price,
                    ii.quantity
                FROM InvoiceItems ii
                WHERE ii.invoice_id = ?
                ORDER BY ii.item_id
            """;
            try (Connection con = getConnection();
                 PreparedStatement ps = con.prepareStatement(itemsSql)) {
                ps.setInt(1, data.getInvoiceId());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        InvoiceLine line = new InvoiceLine();
                        line.setServiceName(rs.getString("name_snapshot"));
                        line.setUnitPrice(rs.getDouble("unit_price"));
                        line.setQuantity(rs.getInt("quantity"));
                        data.getServiceLines().add(line);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Fallback: aggregate from appointment_service when invoice items are unavailable.
        if (data.getServiceLines().isEmpty()) {
            String serviceSql = """
                SELECT
                    s.name AS service_name,
                    ISNULL(s.price, 0) AS unit_price,
                    COUNT(*) AS qty
                FROM appointment_service aps
                JOIN services s ON s.service_id = aps.service_id
                WHERE aps.appointment_id = ?
                GROUP BY s.name, s.price
                ORDER BY s.name
            """;
            try (Connection con = getConnection();
                 PreparedStatement ps = con.prepareStatement(serviceSql)) {
                ps.setInt(1, appointmentId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        InvoiceLine line = new InvoiceLine();
                        line.setServiceName(rs.getString("service_name"));
                        line.setUnitPrice(rs.getDouble("unit_price"));
                        line.setQuantity(rs.getInt("qty"));
                        data.getServiceLines().add(line);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Final fallback total if invoice amount is missing.
        if (data.getTotalAmount() <= 0 && !data.getServiceLines().isEmpty()) {
            double sum = 0;
            for (InvoiceLine line : data.getServiceLines()) {
                sum += line.getLineTotal();
            }
            data.setTotalAmount(sum);
        }

        return data;
    }
}
