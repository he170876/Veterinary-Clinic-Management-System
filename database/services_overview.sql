-- Quick overview for service/lab structure after migration.
-- Run after services_category_migration.sql

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

-- B) Service categories summary
SELECT
    LOWER(LTRIM(RTRIM(COALESCE(category, 'general')))) AS category,
    COUNT(*) AS total_services,
    SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END) AS active_services
FROM dbo.Services
GROUP BY LOWER(LTRIM(RTRIM(COALESCE(category, 'general'))))
ORDER BY category;
GO

-- C) Active services visible in Examination "Services" list
SELECT
    service_id,
    name,
    category,
    price,
    description
FROM dbo.Services
WHERE is_deleted = 0
ORDER BY category, name;
GO

-- D) Services that should appear in Lab Request dropdown
SELECT
    service_id,
    name,
    price
FROM dbo.Services
WHERE is_deleted = 0
  AND LOWER(LTRIM(RTRIM(COALESCE(category, '')))) = 'labtest'
ORDER BY name;
GO

-- E) Mapping visibility check between Services(category=labtest) and LabTests
SELECT
    s.service_id,
    s.name AS service_name,
    lt.test_id,
    lt.test_name
FROM dbo.Services s
LEFT JOIN dbo.LabTests lt
  ON LOWER(LTRIM(RTRIM(COALESCE(lt.test_name, ''))))
   = LOWER(LTRIM(RTRIM(COALESCE(s.name, ''))))
WHERE s.is_deleted = 0
  AND LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'labtest'
ORDER BY s.name;
GO

