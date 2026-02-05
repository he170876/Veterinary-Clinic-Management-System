-- Add is_google_user flag to Users (run once)
USE VetClinicManagement;
GO

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'is_google_user'
)
BEGIN
    ALTER TABLE Users ADD is_google_user BIT NOT NULL DEFAULT 0;
END
GO
