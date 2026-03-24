-- Drop LabTestResults.result_value now that lab result uses only note + file.
IF COL_LENGTH('dbo.LabTestResults', 'result_value') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTestResults DROP COLUMN result_value;
END
GO

-- Quick verification
SELECT c.COLUMN_NAME, c.DATA_TYPE, c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'LabTestResults'
ORDER BY c.ORDINAL_POSITION;
GO

