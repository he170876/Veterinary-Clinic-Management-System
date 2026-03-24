-- Services normalization migration
-- Goal:
-- 1) Only two categories: 'labtest' and 'general'
-- 2) Drop Services.duration column (if exists)
-- 3) Keep Service list as single source

-- 1) Ensure category column exists
IF COL_LENGTH('dbo.Services', 'category') IS NULL
BEGIN
    ALTER TABLE dbo.Services ADD category NVARCHAR(100) NULL;
END
GO

-- 2) Normalize category values to lowercase canonical values.
-- Existing values mapped by known keywords; anything else => general.
UPDATE s
SET s.category =
    CASE
        WHEN LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'labtest' THEN 'labtest'
        WHEN LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) = 'general' THEN 'general'
        WHEN LOWER(LTRIM(RTRIM(COALESCE(s.category, '')))) IN (
            'diagnostics', 'diagnostic', 'laboratory', 'lab', 'test',
            'imaging', 'radiology', 'xray', 'x-ray', 'ultrasound', 'ct', 'mri'
        )
             THEN 'labtest'
        ELSE 'general'
    END
FROM dbo.Services s;
GO

-- 3) Promote services whose names are used as LabTests into labtest category.
UPDATE s
SET s.category = 'labtest'
FROM dbo.Services s
JOIN dbo.LabTests lt
  ON LOWER(LTRIM(RTRIM(COALESCE(lt.test_name, ''))))
   = LOWER(LTRIM(RTRIM(COALESCE(s.name, ''))));
GO

-- 3.1) Promote services by lab/diagnostic keyword list from business rules.
--      Anything matching these patterns is considered labtest.
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

-- 4) Ensure category not null and has default.
UPDATE dbo.Services
SET category = 'general'
WHERE category IS NULL OR LTRIM(RTRIM(category)) = '';
GO

-- Drop and recreate check constraint safely.
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

-- 5) Remove duration column from Services if it still exists.
IF COL_LENGTH('dbo.Services', 'duration') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Services DROP COLUMN duration;
END
GO

