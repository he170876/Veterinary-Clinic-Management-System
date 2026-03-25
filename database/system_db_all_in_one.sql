/*
    FULL ONE-RUN migration for the whole current system.
    IMPORTANT:
    - Run this file in the target database context (select DB first).
    - Script is idempotent where possible (safe to rerun).
*/

/* ============================================================
   0) Safety check: must run inside a user database
   ============================================================ */
IF DB_NAME() IN ('master', 'model', 'msdb', 'tempdb')
BEGIN
    RAISERROR('Please select application database first, then run this script.', 16, 1);
    RETURN;
END
GO

/* ============================================================
   1) Users/Auth migrations
   ============================================================ */
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Users' AND COLUMN_NAME = 'profile_picture_url'
)
BEGIN
    ALTER TABLE dbo.Users ADD profile_picture_url NVARCHAR(500) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Users' AND COLUMN_NAME = 'is_google_user'
)
BEGIN
    ALTER TABLE dbo.Users ADD is_google_user BIT NOT NULL CONSTRAINT DF_Users_is_google_user DEFAULT 0;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Users') AND name = 'UQ_Users_Email'
)
BEGIN
    CREATE UNIQUE INDEX UQ_Users_Email ON dbo.Users(email);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PasswordResetTokens' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.PasswordResetTokens (
        token NVARCHAR(64) NOT NULL PRIMARY KEY,
        email NVARCHAR(255) NOT NULL,
        expires_at DATETIME2 NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.PasswordResetTokens') AND name = 'IX_PasswordResetTokens_email'
)
BEGIN
    CREATE INDEX IX_PasswordResetTokens_email ON dbo.PasswordResetTokens(email);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.PasswordResetTokens') AND name = 'IX_PasswordResetTokens_expires_at'
)
BEGIN
    CREATE INDEX IX_PasswordResetTokens_expires_at ON dbo.PasswordResetTokens(expires_at);
END
GO

/* ============================================================
   2) Appointment/check-in migrations
   ============================================================ */
IF COL_LENGTH('dbo.Appointments', 'arrival_time') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments ADD arrival_time DATETIME NULL;
END
GO

/* ============================================================
   3) Medical record migration
   ============================================================ */
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.MedicalRecords') AND name = N'clinical_condition'
)
BEGIN
    ALTER TABLE dbo.MedicalRecords ADD clinical_condition NVARCHAR(40) NULL;
END
GO

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.MedicalRecords') AND name = N'clinical_condition'
)
BEGIN
    UPDATE dbo.MedicalRecords
    SET clinical_condition = N'follow_up'
    WHERE clinical_condition IS NULL;
END
GO

/* ============================================================
   3.1) MedicalRecords treatment -> conclusion
   ============================================================ */
IF COL_LENGTH('dbo.MedicalRecords', 'conclusion') IS NULL
BEGIN
    ALTER TABLE dbo.MedicalRecords ADD conclusion NVARCHAR(500) NULL;
END
GO

IF COL_LENGTH('dbo.MedicalRecords', 'treatment') IS NOT NULL
BEGIN
    UPDATE dbo.MedicalRecords
    SET conclusion = CASE
        WHEN conclusion IS NULL OR LTRIM(RTRIM(conclusion)) = '' THEN treatment
        ELSE conclusion
    END;
END
GO

IF COL_LENGTH('dbo.MedicalRecords', 'treatment') IS NOT NULL
BEGIN
    ALTER TABLE dbo.MedicalRecords DROP COLUMN treatment;
END
GO

/* ============================================================
   4) Lab result migrations
   ============================================================ */
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LabTestResults' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    ALTER TABLE dbo.LabTestResults ALTER COLUMN result_note NVARCHAR(MAX) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.LabTestResults') AND name = N'result_file'
)
BEGIN
    ALTER TABLE dbo.LabTestResults ADD result_file NVARCHAR(500) NULL;
END
GO

IF COL_LENGTH('dbo.LabTestResults', 'result_value') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTestResults DROP COLUMN result_value;
END
GO

/* ============================================================
   5) Services category normalization
   ============================================================ */
IF COL_LENGTH('dbo.Services', 'category') IS NULL
BEGIN
    ALTER TABLE dbo.Services ADD category NVARCHAR(100) NULL;
END
GO

UPDATE s
SET s.category =
    CASE
        WHEN LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'labtest' THEN 'labtest'
        WHEN LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'general' THEN 'general'
        WHEN LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) IN (
            'diagnostics', 'diagnostic', 'laboratory', 'lab', 'test',
            'imaging', 'radiology', 'xray', 'x-ray', 'ultrasound', 'ct', 'mri'
        ) THEN 'labtest'
        ELSE 'general'
    END
FROM dbo.Services s;
GO

UPDATE s
SET s.category = 'labtest'
FROM dbo.Services s
JOIN dbo.LabTests lt
  ON LOWER(LTRIM(RTRIM(COALESCE(lt.test_name, ''))))
   = LOWER(LTRIM(RTRIM(COALESCE(s.name, ''))));
GO

UPDATE s
SET s.category = 'labtest'
FROM dbo.Services s
WHERE LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xét nghiệm%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xet nghiem%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%chẩn đoán%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%chan doan%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%cbc%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%sinh hóa máu%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%sinh hoa mau%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%blood chemistry%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xét nghiệm máu%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xet nghiem mau%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xét nghiệm nước tiểu%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xet nghiem nuoc tieu%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xét nghiệm phân%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xet nghiem phan%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%parvo%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%felv%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%fiv%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%care%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%pcr%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%nuôi cấy%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%nuoi cay%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%vi khuẩn%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%vi khuan%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%kháng sinh đồ%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%khang sinh do%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%hormone%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%dị ứng%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%di ung%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%di truyền%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%di truyen%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%x-quang%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xquang%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%x-ray%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%xray%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%siêu âm%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%sieu am%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%ct scan%'
   OR LOWER(COALESCE(s.name, '') + ' ' + COALESCE(s.description, '')) LIKE '%mri%';
GO

UPDATE dbo.Services
SET category = 'general'
WHERE category IS NULL OR LTRIM(RTRIM(category)) = '';
GO

IF EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_Services_Category'
      AND parent_object_id = OBJECT_ID('dbo.Services')
)
BEGIN
    ALTER TABLE dbo.Services DROP CONSTRAINT CK_Services_Category;
END
GO

ALTER TABLE dbo.Services
ADD CONSTRAINT CK_Services_Category
CHECK (LOWER(LTRIM(RTRIM(category))) IN ('general', 'labtest'));
GO

IF EXISTS (
    SELECT 1
    FROM sys.default_constraints dc
    JOIN sys.columns c
      ON c.object_id = dc.parent_object_id
     AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID('dbo.Services')
      AND c.name = 'category'
      AND dc.name = 'DF_Services_Category'
)
BEGIN
    ALTER TABLE dbo.Services DROP CONSTRAINT DF_Services_Category;
END
GO

ALTER TABLE dbo.Services
ADD CONSTRAINT DF_Services_Category DEFAULT ('general') FOR category;
GO

IF COL_LENGTH('dbo.Services', 'duration') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Services DROP COLUMN duration;
END
GO

/* ============================================================
   6) LabTests simplify + sync from Services(category='labtest')
   ============================================================ */
IF COL_LENGTH('dbo.LabTests', 'test_name') IS NULL
BEGIN
    ALTER TABLE dbo.LabTests ADD test_name NVARCHAR(255) NULL;
END
GO

IF COL_LENGTH('dbo.LabTests', 'status') IS NULL
BEGIN
    ALTER TABLE dbo.LabTests ADD status NVARCHAR(20) NULL;
END
GO

IF COL_LENGTH('dbo.LabTests', 'description') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTests DROP COLUMN description;
END
GO

IF COL_LENGTH('dbo.LabTests', 'normal_range') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTests DROP COLUMN normal_range;
END
GO

IF COL_LENGTH('dbo.LabTests', 'unit') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTests DROP COLUMN unit;
END
GO

UPDATE dbo.LabTests
SET status = 'Active'
WHERE status IS NULL OR LTRIM(RTRIM(status)) = '';
GO

UPDATE dbo.LabTests
SET test_name = LTRIM(RTRIM(test_name))
WHERE test_name IS NOT NULL;
GO

INSERT INTO dbo.LabTests (test_name, status)
SELECT
    src.service_name,
    'Active' AS status
FROM (
    SELECT DISTINCT LTRIM(RTRIM(s.name)) AS service_name
    FROM dbo.Services s
    WHERE ISNULL(s.is_deleted, 0) = 0
      AND LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'labtest'
      AND LTRIM(RTRIM(COALESCE(s.name, ''))) <> ''
) src
LEFT JOIN dbo.LabTests lt
  ON LOWER(LTRIM(RTRIM(COALESCE(lt.test_name, '')))) = LOWER(src.service_name)
WHERE lt.test_id IS NULL;
GO

UPDATE lt
SET lt.status = 'Active'
FROM dbo.LabTests lt
JOIN dbo.Services s
  ON LOWER(LTRIM(RTRIM(COALESCE(lt.test_name, '')))) = LOWER(LTRIM(RTRIM(COALESCE(s.name, ''))))
WHERE ISNULL(s.is_deleted, 0) = 0
  AND LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'labtest'
  AND LOWER(LTRIM(RTRIM(COALESCE(lt.status, '')))) <> 'active';
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_LabTests_TestName_Active'
      AND object_id = OBJECT_ID('dbo.LabTests')
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_LabTests_TestName_Active
    ON dbo.LabTests(test_name)
    WHERE status = 'Active' AND test_name IS NOT NULL;
END
GO

/* ============================================================
   7) Verification (quick overview)
   ============================================================ */
SELECT DB_NAME() AS running_database;
GO

SELECT c.COLUMN_NAME, c.DATA_TYPE, c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'Users'
  AND c.COLUMN_NAME IN ('profile_picture_url', 'is_google_user')
ORDER BY c.COLUMN_NAME;
GO

SELECT c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH, c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'Services'
ORDER BY c.ORDINAL_POSITION;
GO

SELECT LOWER(LTRIM(RTRIM(COALESCE(category, 'general')))) AS category, COUNT(*) AS total_services
FROM dbo.Services
GROUP BY LOWER(LTRIM(RTRIM(COALESCE(category, 'general'))))
ORDER BY category;
GO

SELECT c.COLUMN_NAME, c.DATA_TYPE, c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'LabTests'
ORDER BY c.ORDINAL_POSITION;
GO

SELECT c.COLUMN_NAME, c.DATA_TYPE, c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'LabTestResults'
ORDER BY c.ORDINAL_POSITION;
GO

SELECT c.COLUMN_NAME, c.DATA_TYPE, c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'MedicalRecords'
  AND c.COLUMN_NAME = 'clinical_condition';
GO
