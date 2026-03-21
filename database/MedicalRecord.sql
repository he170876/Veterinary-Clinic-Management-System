USE VetClinicManagement1;
GO

-- =====================================================================
-- TẠO MEDICAL RECORDS CHO TẤT CẢ CUSTOMER (để history không trống)
-- Chạy script này sau khi đã có seed data đầy đủ
-- =====================================================================

DECLARE @DefaultVetId     INT = (SELECT TOP 1 veterinarian_id FROM dbo.Veterinarians ORDER BY NEWID());
DECLARE @DefaultStaffId   INT = (SELECT TOP 1 receptionist_id   FROM dbo.Receptionists   ORDER BY NEWID());
DECLARE @DefaultLabId     INT = (SELECT TOP 1 staff_id          FROM dbo.LabStaff        ORDER BY NEWID());

DECLARE @Today DATE = CAST(GETDATE() AS DATE);

-- Các dịch vụ sẽ random gắn vào record
DECLARE @Services TABLE (service_id INT, price DECIMAL(10,2));
INSERT INTO @Services (service_id, price)
SELECT service_id, ISNULL(price, 45.00)
FROM dbo.Services
WHERE is_deleted = 0;

-- Các xét nghiệm (nếu muốn gắn thêm lab request/result)
DECLARE @LabTests TABLE (test_id INT);
INSERT INTO @LabTests (test_id)
SELECT TOP 3 test_id FROM dbo.LabTests ORDER BY NEWID();

-- =====================================================================
-- Duyệt qua từng customer
-- =====================================================================
DECLARE @customer_id INT, @user_id INT, @pet_id INT;

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT c.customer_id, c.user_id
    FROM dbo.Customers c
    INNER JOIN dbo.Users u ON u.user_id = c.user_id
    WHERE u.isDeleted = 0
      AND u.status = 'Active'
      AND u.role_id = (SELECT role_id FROM dbo.Roles WHERE role_name = 'Customer');

OPEN cur;
FETCH NEXT FROM cur INTO @customer_id, @user_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Với mỗi customer, tạo 1–4 medical record (ngẫu nhiên số lượng)
    DECLARE @recordCount INT = 1 + (ABS(CHECKSUM(NEWID())) % 4);  -- 1 đến 4 record

    DECLARE @i INT = 1;
    WHILE @i <= @recordCount
    BEGIN
        -- Chọn random 1 pet của customer này
        SELECT TOP 1 @pet_id = pet_id
        FROM dbo.Pets
        WHERE customer_id = @customer_id
          AND isDeleted = 0
        ORDER BY NEWID();

        IF @pet_id IS NULL
        BEGIN
            -- Nếu customer không có pet → bỏ qua customer này
            BREAK;
        END

        DECLARE @days_ago INT = 30 + (ABS(CHECKSUM(NEWID())) % 700);   -- từ 1 tháng đến ~2 năm trước
        DECLARE @visit_date DATE = DATEADD(DAY, -@days_ago, @Today);

        -- Tạo Appointment (đã hoàn thành)
        DECLARE @new_appt_id INT;
        INSERT INTO dbo.Appointments
        (
            pet_id, customer_id, veterinarian_id,
            appointment_date, time_slot, [type], phone,
            status, created_at, notes
        )
        VALUES
        (
            @pet_id, @customer_id, @DefaultVetId,
            @visit_date,
            CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'AM' ELSE 'PM' END,
            'Normal',
            '0000000000',           -- hoặc lấy từ Users nếu muốn
            'Completed',
            GETDATE(),
            'Auto-generated history record #' + CAST(@i AS VARCHAR(10))
        );
        SET @new_appt_id = SCOPE_IDENTITY();

        -- Tạo Visit (đã hoàn thành)
        DECLARE @new_visit_id INT;
        INSERT INTO dbo.Visits
        (
            appointment_id, pet_id, customer_id,
            check_in_time, check_out_time, visit_status,
            staff_id, veterinarian_id
        )
        VALUES
        (
            @new_appt_id, @pet_id, @customer_id,
            DATEADD(HOUR, 9 + (ABS(CHECKSUM(NEWID())) % 6), CAST(@visit_date AS DATETIME)),
            DATEADD(HOUR, 10 + (ABS(CHECKSUM(NEWID())) % 5), CAST(@visit_date AS DATETIME)),
            'Completed',
            @DefaultStaffId,
            @DefaultVetId
        );
        SET @new_visit_id = SCOPE_IDENTITY();

        -- Tạo Medical Record
        DECLARE @new_record_id INT;
        INSERT INTO dbo.MedicalRecords
        (
            visit_id, veterinarian_id,
            diagnosis, treatment, note, created_at
        )
        VALUES
        (
            @new_visit_id, @DefaultVetId,
            CASE ABS(CHECKSUM(NEWID())) % 6
                WHEN 0 THEN N'Viêm da dị ứng mùa'
                WHEN 1 THEN N'Viêm tai ngoài'
                WHEN 2 THEN N'Rối loạn tiêu hóa cấp'
                WHEN 3 THEN N'Kiểm tra sức khỏe định kỳ'
                WHEN 4 THEN N'Nhiễm khuẩn đường hô hấp'
                ELSE N'Theo dõi sau tiêm phòng'
            END,
            N'Kháng sinh / Chăm sóc tại nhà / Thuốc nhỏ tai / ...',
            N'Hồ sơ tự động tạo để hiển thị lịch sử khám cho khách hàng. Pet khỏe mạnh hơn sau điều trị.',
            DATEADD(DAY, -@days_ago + 1, GETDATE())   -- created_at gần với visit
        );
        SET @new_record_id = SCOPE_IDENTITY();

        -- Gắn 1–3 dịch vụ ngẫu nhiên
        DECLARE @svc_count INT = 1 + (ABS(CHECKSUM(NEWID())) % 3);
        INSERT INTO dbo.MedicalRecordServices (record_id, service_id, quantity, price)
        SELECT TOP (@svc_count)
            @new_record_id,
            s.service_id,
            1,
            s.price
        FROM @Services s
        ORDER BY NEWID();

        -- Gắn đơn thuốc (ít nhất 1 loại)
        INSERT INTO dbo.Prescriptions (record_id, medicine_name, dosage, duration)
        VALUES
        (
            @new_record_id,
            CASE ABS(CHECKSUM(NEWID())) % 5
                WHEN 0 THEN N'Amoxicillin/Clavulanate'
                WHEN 1 THEN N'Prednisolone'
                WHEN 2 THEN N'Metronidazole'
                WHEN 3 THEN N'Fenbendazole'
                ELSE N'Vitamin bổ sung'
            END,
            N'Theo chỉ định bác sĩ',
            N'5–14 ngày'
        );

        -- (Tùy chọn) Gắn hóa đơn đã thanh toán
        DECLARE @total DECIMAL(12,2) = (
            SELECT ISNULL(SUM(price * quantity), 65.00)
            FROM dbo.MedicalRecordServices
            WHERE record_id = @new_record_id
        );

        DECLARE @inv_id INT;
        INSERT INTO dbo.Invoices (visit_id, total_amount, status, created_at)
        VALUES (@new_visit_id, @total, 'Paid', DATEADD(DAY, -@days_ago + 2, GETDATE()));
        SET @inv_id = SCOPE_IDENTITY();

        INSERT INTO dbo.InvoiceItems (invoice_id, item_type, name_snapshot, unit_price, quantity, total_price)
        SELECT
            @inv_id,
            'Service',
            s.name,
            mrs.price,
            mrs.quantity,
            mrs.price * mrs.quantity
        FROM dbo.MedicalRecordServices mrs
        INNER JOIN dbo.Services s ON s.service_id = mrs.service_id
        WHERE mrs.record_id = @new_record_id;

        -- (Tùy chọn) Gắn lab test nếu muốn
        IF ABS(CHECKSUM(NEWID())) % 3 = 0
        BEGIN
            DECLARE @test_id INT = (SELECT TOP 1 test_id FROM @LabTests ORDER BY NEWID());

            DECLARE @req_id INT;
            INSERT INTO dbo.LabTestRequests (visit_id, test_id, veterinarian_id, request_time, status)
            VALUES (@new_visit_id, @test_id, @DefaultVetId, DATEADD(HOUR, 1, CAST(@visit_date AS DATETIME)), 'Completed');
            SET @req_id = SCOPE_IDENTITY();

            INSERT INTO dbo.LabTestResults (request_id, result_value, result_note, result_date, lab_staff_id)
            VALUES (@req_id, N'Trong giới hạn bình thường', N'Kết quả mẫu tự động', DATEADD(HOUR, 4, CAST(@visit_date AS DATETIME)), @DefaultLabId);
        END

        SET @i = @i + 1;
    END

    FETCH NEXT FROM cur INTO @customer_id, @user_id;
END

CLOSE cur;
DEALLOCATE cur;

PRINT 'Đã tạo thêm medical records cho hầu hết khách hàng.';
PRINT 'Mỗi khách hàng hiện có khoảng 1–4 hồ sơ khám bệnh trong lịch sử.';
GO