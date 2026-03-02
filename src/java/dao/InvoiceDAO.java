package dao;

import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

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
}
