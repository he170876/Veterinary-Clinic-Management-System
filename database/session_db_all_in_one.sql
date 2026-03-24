/*
    ONE-RUN script for this session
    Includes:
    1) add_clinical_condition_medical_records.sql
    2) services_category_migration.sql
    3) services_overview.sql (verification queries)
*/

/* ============================================================
   1) MedicalRecords: add clinical_condition
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
   2) Services normalization
   - Only categories: labtest/general
   - Drop Services.duration
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
   3) Overview / verification
   ============================================================ */
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

SELECT
    LOWER(LTRIM(RTRIM(COALESCE(category, 'general')))) AS category,
    COUNT(*) AS total_services,
    SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END) AS active_services
FROM dbo.Services
GROUP BY LOWER(LTRIM(RTRIM(COALESCE(category, 'general'))))
ORDER BY category;
GO

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

SELECT
    service_id,
    name,
    price
FROM dbo.Services
WHERE is_deleted = 0
  AND LOWER(LTRIM(RTRIM(COALESCE(category, '')))) = 'labtest'
ORDER BY name;
GO

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

