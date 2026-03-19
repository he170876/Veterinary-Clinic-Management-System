-- Adds arrival_time to Appointments.
-- Purpose: store real check-in time (NOW) when receptionist clicks Check-in.
-- Default: NULL when appointment is created.

USE VetClinicManagement;
GO

IF COL_LENGTH('dbo.Appointments', 'arrival_time') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments
    ADD arrival_time DATETIME NULL;
END
GO

