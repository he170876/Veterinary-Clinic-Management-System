/*
    Reset Services category to GENERAL (single-run script)
    Includes:
    1) Drop Services.duration (if exists)
    2) Set all category = 'general'
    3) Add default/check constraint for category
    4) Overview queries for verification
*/

-- 1) Ensure category column exists
IF COL_LENGTH('dbo.Services', 'category') IS NULL
BEGIN
    ALTER TABLE dbo.Services ADD category NVARCHAR(100) NULL;
END
GO

-- 2) Drop duration column if still exists
IF COL_LENGTH('dbo.Services', 'duration') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Services DROP COLUMN duration;
END
GO

-- 3) Force all existing rows to general
UPDATE dbo.Services
SET category = 'general';
GO

-- 4) Recreate CHECK constraint
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
CHECK (LOWER(LTRIM(RTRIM(COALESCE(category, '')))) IN ('general', 'labtest'));
GO

-- 5) Recreate DEFAULT constraint for category
DECLARE @dfName NVARCHAR(128);
SELECT TOP 1 @dfName = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c
  ON c.object_id = dc.parent_object_id
 AND c.column_id = dc.parent_column_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.Services')
  AND c.name = 'category';

IF @dfName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.Services DROP CONSTRAINT ' + QUOTENAME(@dfName));
END
GO

ALTER TABLE dbo.Services
ADD CONSTRAINT DF_Services_Category DEFAULT ('general') FOR category;
GO

/* =========================
   Overview / verification
   ========================= */

-- A) Current Services table shape
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'Services'
ORDER BY c.ORDINAL_POSITION;
GO

-- B) Category summary
SELECT
    LOWER(LTRIM(RTRIM(COALESCE(category, 'general')))) AS category,
    COUNT(*) AS total_services,
    SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END) AS active_services
FROM dbo.Services
GROUP BY LOWER(LTRIM(RTRIM(COALESCE(category, 'general'))))
ORDER BY category;
GO

-- C) Active services listing
SELECT
    service_id,
    name,
    category,
    price,
    description,
    is_deleted
FROM dbo.Services
ORDER BY is_deleted, name;
GO

