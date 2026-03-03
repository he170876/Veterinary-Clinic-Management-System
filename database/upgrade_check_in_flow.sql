-- ============================================================
-- UPGRADE: Check-in flow & amount recorded (no schema change)
-- Run only if you already have VetClinicManagement from script.sql
-- Purpose: Ensures DB is ready for receptionist check-in and
--          vet examination (visit required, invoice on complete).
-- ============================================================

USE VetClinicManagement;
GO

-- Verify required objects exist (no ALTERs needed; schema already has everything)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Visits')
    RAISERROR('Table Visits missing. Run script.sql first.', 16, 1);
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Visits') AND name = 'staff_id')
    RAISERROR('Visits.staff_id missing. Use full script.sql.', 16, 1);
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Invoices')
    RAISERROR('Table Invoices missing. Run script.sql first.', 16, 1);
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'InvoiceItems')
    RAISERROR('Table InvoiceItems missing. Run script.sql first.', 16, 1);
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Receptionists')
    RAISERROR('Table Receptionists missing. Run script.sql first.', 16, 1);
GO

PRINT 'Upgrade check complete. No schema changes required for check-in flow.';
PRINT 'Visits.staff_id, Invoices, InvoiceItems, Receptionists are present.';
GO
