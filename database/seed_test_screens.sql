/* ===============================
   TEST DATA FOR SCREENS
   Run after seed_data.sql
   Adds TODAY's appointments so Vet Queue, Receptionist, and Examination screens have data.
   Password for all: dev123
   =============================== */

USE VetClinicManagement1;
GO

/* ========= TODAY'S APPOINTMENTS (for Vet Queue & Receptionist list) ========= */
/* Dr. Sarah Smith (dr.smith@anipats.com) - 2 appointments today */
INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, c.customer_id, v.veterinarian_id,
       DATEADD(hour, 9, CAST(CAST(GETDATE() AS DATE) AS DATETIME)),  /* 09:00 today */
       'Confirmed'
FROM Pets p
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
CROSS JOIN (SELECT veterinarian_id FROM Veterinarians WHERE user_id = (SELECT user_id FROM Users WHERE email = 'dr.smith@anipats.com')) v
WHERE u.email = 'dev@anipats.com' AND p.name = 'Max';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, c.customer_id, v.veterinarian_id,
       DATEADD(hour, 10, DATEADD(minute, 30, CAST(CAST(GETDATE() AS DATE) AS DATETIME))),  /* 10:30 today */
       'Confirmed'
FROM Pets p
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
CROSS JOIN (SELECT veterinarian_id FROM Veterinarians WHERE user_id = (SELECT user_id FROM Users WHERE email = 'dr.smith@anipats.com')) v
WHERE u.email = 'dev@anipats.com' AND p.name = 'Luna';

/* Dr. James Lee (dr.james@anipats.com) - 2 appointments today */
INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, c.customer_id, v.veterinarian_id,
       DATEADD(hour, 11, CAST(CAST(GETDATE() AS DATE) AS DATETIME)),  /* 11:00 today */
       'Confirmed'
FROM Pets p
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
CROSS JOIN (SELECT veterinarian_id FROM Veterinarians WHERE user_id = (SELECT user_id FROM Users WHERE email = 'dr.james@anipats.com')) v
WHERE u.email = 'mary.wilson@email.com' AND p.name = 'Buddy';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, c.customer_id, v.veterinarian_id,
       DATEADD(hour, 14, CAST(CAST(GETDATE() AS DATE) AS DATETIME)),  /* 14:00 today */
       'Confirmed'
FROM Pets p
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
CROSS JOIN (SELECT veterinarian_id FROM Veterinarians WHERE user_id = (SELECT user_id FROM Users WHERE email = 'dr.james@anipats.com')) v
WHERE u.email = 'dev@anipats.com' AND p.name = 'Max';

/* ========= ONE CHECKED-IN VISIT (for Vet Queue + Lab Dashboard) ========= */
/* Vet queue shows only status = ''Checked-in''; receptionist creates visit with staff_id. */
/* This inserts one visit as if receptionist had already checked in the first appointment. */
INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, visit_status, staff_id, veterinarian_id)
SELECT TOP 1 a.appointment_id, a.pet_id, a.customer_id, GETDATE(), 'Checked-in',
       (SELECT TOP 1 receptionist_id FROM Receptionists),
       a.veterinarian_id
FROM Appointments a
WHERE a.status = 'Confirmed' AND CAST(a.appointment_time AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY a.appointment_time;

/* Update that appointment to Checked-in so it matches the visit */
UPDATE a SET a.status = 'Checked-in'
FROM Appointments a
WHERE a.appointment_id IN (SELECT TOP 1 appointment_id FROM Visits WHERE visit_status = 'Checked-in' ORDER BY visit_id DESC);

/* One Pending lab request for that visit (Lab Dashboard) */
INSERT INTO LabTestRequests (visit_id, test_id, veterinarian_id, status)
SELECT TOP 1 v.visit_id, (SELECT TOP 1 test_id FROM LabTests), v.veterinarian_id, 'Pending'
FROM Visits v
WHERE v.visit_status = 'Checked-in'
ORDER BY v.visit_id DESC;

GO

PRINT 'Test screen data inserted.';
PRINT 'Today''s appointments: 4 total (2 for Dr. Sarah Smith, 2 for Dr. James Lee).';
PRINT 'One appointment is pre-checked-in (appears in Vet Queue). Other 3: use Staff Queue as reception@anipats.com and click Check-in.';
PRINT 'Vet Queue: dr.smith@anipats.com or dr.james@anipats.com. Lab: lab@anipats.com.';
GO

/* ========= EXTRA UNIQUE COMPLETED VISITS & RECORDS (for history screens) ========= */
/* These create additional, varied medical records so vet/customer history pages have more realistic data. */

/* Completed visit #1: Max – Ear infection follow-up (Dr. Sarah Smith, Paid) */
DECLARE @maxPetId INT = (SELECT TOP 1 p.pet_id FROM Pets p JOIN Customers c ON p.customer_id = c.customer_id
                          JOIN Users u ON c.user_id = u.user_id
                          WHERE u.email = 'dev@anipats.com' AND p.name = 'Max');
DECLARE @maxCustomerId INT = (SELECT TOP 1 c.customer_id FROM Customers c JOIN Users u ON c.user_id = u.user_id
                               WHERE u.email = 'dev@anipats.com');
DECLARE @vetSarahId INT = (SELECT TOP 1 veterinarian_id FROM Veterinarians v
                            JOIN Users u ON v.user_id = u.user_id
                            WHERE u.email = 'dr.smith@anipats.com');
DECLARE @staffId INT = (SELECT TOP 1 receptionist_id FROM Receptionists);

IF @maxPetId IS NOT NULL AND @maxCustomerId IS NOT NULL AND @vetSarahId IS NOT NULL AND @staffId IS NOT NULL
BEGIN
    DECLARE @appt1 INT;
    INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
    VALUES (@maxPetId, @maxCustomerId, @vetSarahId, DATEADD(day, -3, GETDATE()), 'Completed');
    SET @appt1 = SCOPE_IDENTITY();

    DECLARE @visit1 INT;
    INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, staff_id, veterinarian_id)
    VALUES (@appt1, @maxPetId, @maxCustomerId,
            DATEADD(hour, -1, DATEADD(day, -3, GETDATE())),
            DATEADD(minute, -30, DATEADD(day, -3, GETDATE())),
            'Completed', @staffId, @vetSarahId);
    SET @visit1 = SCOPE_IDENTITY();

    DECLARE @record1 INT;
    INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, conclusion, note)
    VALUES (@visit1, @vetSarahId,
            'Chronic otitis externa (ear infection), mild flare-up',
            'Clean ear canal, prescribe topical antibiotic drops for 7 days',
            'Owner reports scratching and head shaking. Mild erythema in ear canal, no systemic signs.');
    SET @record1 = SCOPE_IDENTITY();

    /* Services: General Checkup + Blood Test */
    INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT @record1, service_id, 1, price FROM Services WHERE name = 'General Checkup';
    INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT @record1, service_id, 1, price FROM Services WHERE name = 'Blood Test';

    /* Invoice + items */
    DECLARE @total1 DECIMAL(10,2) =
        (SELECT SUM(price * quantity) FROM MedicalRecordServices WHERE record_id = @record1);
    DECLARE @inv1 INT;
    INSERT INTO Invoices (visit_id, total_amount, status)
    VALUES (@visit1, @total1, 'Paid');
    SET @inv1 = SCOPE_IDENTITY();

    INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
    SELECT @inv1, 'Service', NULL, s.name, s.price, mrs.quantity, mrs.price * mrs.quantity
    FROM MedicalRecordServices mrs
    JOIN Services s ON mrs.service_id = s.service_id
    WHERE mrs.record_id = @record1;
END
GO

/* Completed visit #2: Luna – Gastrointestinal upset (Dr. James Lee, waiting for payment) */
DECLARE @lunaPetId INT = (SELECT TOP 1 p.pet_id FROM Pets p JOIN Customers c ON p.customer_id = c.customer_id
                           JOIN Users u ON c.user_id = u.user_id
                           WHERE u.email = 'dev@anipats.com' AND p.name = 'Luna');
DECLARE @customerDevId INT = (SELECT TOP 1 c.customer_id FROM Customers c JOIN Users u ON c.user_id = u.user_id
                               WHERE u.email = 'dev@anipats.com');
DECLARE @vetJamesId INT = (SELECT TOP 1 veterinarian_id FROM Veterinarians v
                            JOIN Users u ON v.user_id = u.user_id
                            WHERE u.email = 'dr.james@anipats.com');
DECLARE @staffId INT = (SELECT TOP 1 receptionist_id FROM Receptionists);

IF @lunaPetId IS NOT NULL AND @customerDevId IS NOT NULL AND @vetJamesId IS NOT NULL AND @staffId IS NOT NULL
BEGIN
    DECLARE @appt2 INT;
    INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
    VALUES (@lunaPetId, @customerDevId, @vetJamesId, DATEADD(day, -1, GETDATE()), 'Waiting-for-Payment');
    SET @appt2 = SCOPE_IDENTITY();

    DECLARE @visit2 INT;
    INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, staff_id, veterinarian_id)
    VALUES (@appt2, @lunaPetId, @customerDevId,
            DATEADD(hour, -2, DATEADD(day, -1, GETDATE())),
            DATEADD(hour, -1, DATEADD(day, -1, GETDATE())),
            'Completed', @staffId, @vetJamesId);
    SET @visit2 = SCOPE_IDENTITY();

    DECLARE @record2 INT;
    INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, conclusion, note)
    VALUES (@visit2, @vetJamesId,
            'Acute gastroenteritis, likely dietary indiscretion',
            'Prescribe bland diet and antiemetic for 3 days; recheck if no improvement.',
            'Vomiting x2 days, soft stool, mild dehydration. No foreign body on palpation.');
    SET @record2 = SCOPE_IDENTITY();

    /* Services: General Checkup + X-Ray */
    INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT @record2, service_id, 1, price FROM Services WHERE name = 'General Checkup';
    INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT @record2, service_id, 1, price FROM Services WHERE name = 'X-Ray';

    /* Invoice with status Recorded (to appear in Waiting for Payment) */
    DECLARE @total2 DECIMAL(10,2) =
        (SELECT SUM(price * quantity) FROM MedicalRecordServices WHERE record_id = @record2);
    DECLARE @inv2 INT;
    INSERT INTO Invoices (visit_id, total_amount, status)
    VALUES (@visit2, @total2, 'Recorded');
    SET @inv2 = SCOPE_IDENTITY();

    INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
    SELECT @inv2, 'Service', NULL, s.name, s.price, mrs.quantity, mrs.price * mrs.quantity
    FROM MedicalRecordServices mrs
    JOIN Services s ON mrs.service_id = s.service_id
    WHERE mrs.record_id = @record2;
END
GO
