/*
    Direction 1: Keep LabTests, simplify + sync with Services(category='labtest')
    - Keep current FK flow: LabTestRequests.test_id -> LabTests.test_id
    - LabTests acts as stable test catalog for lab module/reporting
*/

/* ============================================================
   A) Simplify LabTests (without breaking existing data/FK)
   ============================================================ */

-- 1) Ensure core columns exist.
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

-- 2) Drop non-core columns because lab result detail is now stored in LabTestResults (note/file).
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

-- 3) Normalize status/test_name.
UPDATE dbo.LabTests
SET status = 'Active'
WHERE status IS NULL OR LTRIM(RTRIM(status)) = '';
GO

UPDATE dbo.LabTests
SET test_name = LTRIM(RTRIM(test_name))
WHERE test_name IS NOT NULL;
GO

/* ============================================================
   B) Sync from Services(category='labtest') -> LabTests
   ============================================================ */

-- Insert missing LabTests from active labtest services (by normalized name).
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

-- If a matching LabTest exists but not Active, activate it.
UPDATE lt
SET lt.status = 'Active'
FROM dbo.LabTests lt
JOIN dbo.Services s
  ON LOWER(LTRIM(RTRIM(COALESCE(lt.test_name, '')))) = LOWER(LTRIM(RTRIM(COALESCE(s.name, ''))))
WHERE ISNULL(s.is_deleted, 0) = 0
  AND LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'labtest'
  AND LOWER(LTRIM(RTRIM(COALESCE(lt.status, '')))) <> 'active';
GO

/* ============================================================
   C) Optional guardrails
   ============================================================ */

-- Add filtered unique index on normalized active test_name to reduce duplicates.
-- (Case/space-insensitive approximate via persisted computed column approach is heavier;
-- this keeps it simple with direct test_name uniqueness for active rows.)
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
   D) Overview checks
   ============================================================ */

-- 1) Current LabTests shape
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'LabTests'
ORDER BY c.ORDINAL_POSITION;
GO

-- 2) LabTests summary
SELECT
    status,
    COUNT(*) AS total_tests
FROM dbo.LabTests
GROUP BY status
ORDER BY status;
GO

-- 3) Active LabTests catalog
SELECT
    test_id,
    test_name,
    status
FROM dbo.LabTests
WHERE status = 'Active'
ORDER BY test_name;
GO

-- 4) Mapping check: active labtest services <-> LabTests
SELECT
    s.service_id,
    s.name AS service_name,
    lt.test_id,
    lt.test_name,
    lt.status
FROM dbo.Services s
LEFT JOIN dbo.LabTests lt
  ON LOWER(LTRIM(RTRIM(COALESCE(lt.test_name, ''))))
   = LOWER(LTRIM(RTRIM(COALESCE(s.name, ''))))
WHERE ISNULL(s.is_deleted, 0) = 0
  AND LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'labtest'
ORDER BY s.name;
GO

