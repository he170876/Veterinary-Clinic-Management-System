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

GO

PRINT 'Test screen data inserted.';
PRINT 'Today''s appointments: 2 for Dr. Sarah Smith (Max 09:00, Luna 10:30), 2 for Dr. James Lee (Buddy 11:00, Max 14:00).';
PRINT 'Log in as dr.smith@anipats.com or dr.james@anipats.com and open Vet Queue to see them.';
GO
