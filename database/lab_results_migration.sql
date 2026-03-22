/*
  Lab results: đảm bảo cột ảnh + ghi chú đủ dài cho upload + text note.
  Chạy trên SQL Server — đổi USE sang đúng tên database của bạn (nếu cần).
*/
-- USE [VetClinicManagement1];
-- GO

-- Mở rộng ghi chú (trước đây có thể chỉ NVARCHAR(500))
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LabTestResults')
BEGIN
    ALTER TABLE dbo.LabTestResults ALTER COLUMN result_note NVARCHAR(MAX) NULL;
END
GO

-- Đảm bảo có cột lưu đường dẫn file ảnh (relative URL, ví dụ /uploads/lab-results/...)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.LabTestResults') AND name = N'result_file'
)
BEGIN
    ALTER TABLE dbo.LabTestResults ADD result_file NVARCHAR(500) NULL;
END
GO
