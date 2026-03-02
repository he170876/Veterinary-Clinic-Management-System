/* ===============================
   TEST DATA FOR SCREENS
   Run after seed_data.sql
   Adds TODAY's appointments so Vet Queue, Receptionist, and Examination screens have data.
   Password for all: dev123
   =============================== */

USE VetClinicManagement;
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
