-- Enforce unique email on Users (run once)
USE VetClinicManagement;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('Users') AND name = 'UQ_Users_Email'
)
BEGIN
    CREATE UNIQUE INDEX UQ_Users_Email ON Users (email);
END
GO
