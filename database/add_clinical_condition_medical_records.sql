-- Thêm trạng thái lâm sàng (Condition) cho bản ghi khám — chạy một lần trên SQL Server.
-- Lưu ý: SQL Server không cho UPDATE cột mới trong cùng batch với ALTER; phải tách bằng GO.

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.MedicalRecords') AND name = N'clinical_condition'
)
BEGIN
    ALTER TABLE dbo.MedicalRecords ADD clinical_condition NVARCHAR(40) NULL;
END
GO

-- Batch riêng: sau GO, cột đã tồn tại mới parse được UPDATE.
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.MedicalRecords') AND name = N'clinical_condition'
)
BEGIN
    UPDATE dbo.MedicalRecords SET clinical_condition = N'follow_up' WHERE clinical_condition IS NULL;
END
GO

/* ============================================================
   treatment -> conclusion (idempotent)
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
