/* ================================================================
   NEW PET TEST DATA — EXAMINATION SCREEN
   Run after seed_data.sql + seed_test_screens.sql
   Creates a brand-new customer + pet with a TODAY appointment
   already in Checked-in state so it appears immediately in
   the Vet Queue / Examination page.

   New account:  sam.parker@email.com / dev123
   New pet:      Rex (German Shepherd, Male, 3 yrs, 25 kg)
   Assigned vet: dr.smith@anipats.com (Dr. Sarah Smith)
   ================================================================ */

USE VetClinicManagement;
GO

/* ── 1. New customer user ── */
IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'sam.parker@email.com')
BEGIN
    INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
    VALUES (
        'sam.parker@email.com',
        '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', /* dev123 */
        (SELECT role_id FROM Roles WHERE role_name = 'Customer'),
        'Active',
        'Sam Parker',
        '+1 (555) 100-3001',
        '789 Maple Ave, Queens, NY'
    );

    INSERT INTO Customers (user_id)
    SELECT user_id FROM Users WHERE email = 'sam.parker@email.com';
END
GO

/* ── 2. New pet ── */
IF NOT EXISTS (
    SELECT 1 FROM Pets p
    JOIN Customers c ON p.customer_id = c.customer_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE u.email = 'sam.parker@email.com' AND p.name = 'Rex'
)
BEGIN
    INSERT INTO Pets (customer_id, name, species, breed, gender, birth_date, weight)
    SELECT c.customer_id,
           'Rex',
           'Dog',
           'German Shepherd',
           'M',
           DATEADD(year, -3, CAST(GETDATE() AS DATE)),  /* 3 years old today */
           25.00
    FROM Customers c
    JOIN Users u ON c.user_id = u.user_id
    WHERE u.email = 'sam.parker@email.com';
END
GO

/* ── 3. Appointment for TODAY (Checked-in) ── */
DECLARE @rexPetId       INT = (
    SELECT TOP 1 p.pet_id
    FROM Pets p
    JOIN Customers c ON p.customer_id = c.customer_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE u.email = 'sam.parker@email.com' AND p.name = 'Rex'
);
DECLARE @samCustomerId  INT = (
    SELECT TOP 1 c.customer_id
    FROM Customers c
    JOIN Users u ON c.user_id = u.user_id
    WHERE u.email = 'sam.parker@email.com'
);
DECLARE @vetSarahId     INT = (
    SELECT TOP 1 veterinarian_id
    FROM Veterinarians v
    JOIN Users u ON v.user_id = u.user_id
    WHERE u.email = 'dr.smith@anipats.com'
);
DECLARE @staffId        INT = (SELECT TOP 1 receptionist_id FROM Receptionists);
DECLARE @generalCheckup INT = (SELECT TOP 1 service_id FROM Services WHERE name = 'General Checkup');

IF @rexPetId IS NOT NULL AND @samCustomerId IS NOT NULL AND @vetSarahId IS NOT NULL
BEGIN
    /* Appointment at current time, status Checked-in */
    DECLARE @apptId INT;
    INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status, service_id)
    VALUES (
        @rexPetId,
        @samCustomerId,
        @vetSarahId,
        DATEADD(minute, 30, CAST(CAST(GETDATE() AS DATE) AS DATETIME)), /* 00:30 today — always "today" */
        'Checked-in',
        @generalCheckup
    );
    SET @apptId = SCOPE_IDENTITY();

    /* Visit — already checked in, open for examination */
    INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, visit_status, staff_id, veterinarian_id)
    VALUES (
        @apptId,
        @rexPetId,
        @samCustomerId,
        GETDATE(),
        'Checked-in',
        @staffId,
        @vetSarahId
    );

    PRINT '========================================================';
    PRINT 'New pet data inserted successfully.';
    PRINT '';
    PRINT '  Customer:  Sam Parker (sam.parker@email.com / dev123)';
    PRINT '  Pet:       Rex — German Shepherd, Male, 3 yrs, 25 kg';
    PRINT '  Vet:       Dr. Sarah Smith (dr.smith@anipats.com)';
    PRINT '  Status:    Checked-in — ready for examination';
    PRINT '';
    PRINT 'Open examination:';
    PRINT '  Login as dr.smith@anipats.com, go to Vet Queue,';
    PRINT '  click "Start Examination" for Rex.';
    PRINT '========================================================';
END
ELSE
BEGIN
    PRINT 'ERROR: Could not find required records (pet/customer/vet). Make sure seed_data.sql was run first.';
END
GO
