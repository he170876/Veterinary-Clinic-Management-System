-- Password reset tokens for forgot-password flow (run once)
USE VetClinicManagement;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PasswordResetTokens')
BEGIN
    CREATE TABLE PasswordResetTokens (
        token      NVARCHAR(64) NOT NULL PRIMARY KEY,
        email      NVARCHAR(255) NOT NULL,
        expires_at DATETIME2 NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_PasswordResetTokens_email ON PasswordResetTokens (email);
    CREATE INDEX IX_PasswordResetTokens_expires_at ON PasswordResetTokens (expires_at);
END
GO
