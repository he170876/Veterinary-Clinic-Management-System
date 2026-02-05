-- Add profile picture URL column to Users (run once)
-- Use your VCMS database (change name if different)
USE VetClinicManagement;
GO

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'profile_picture_url'
)
BEGIN
    ALTER TABLE Users ADD profile_picture_url NVARCHAR(500) NULL;
END
GO
