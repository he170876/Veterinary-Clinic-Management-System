/* ===============================
   VET CLINIC MANAGEMENT SYSTEM
   SEED DATA (run after schema script)
   =============================== */

USE VetClinicManagement;
GO

/* ========= ROLES ========= */
INSERT INTO Roles (role_name) VALUES ('Customer');
INSERT INTO Roles (role_name) VALUES ('Veterinarian');
INSERT INTO Roles (role_name) VALUES ('Receptionist');
INSERT INTO Roles (role_name) VALUES ('LabStaff');
INSERT INTO Roles (role_name) VALUES ('Admin');
INSERT INTO Roles (role_name) VALUES ('ClinicOwner');
GO

/* ========= USERS (password dev123 = SHA-256 hex below) ========= */
-- Customer: dev@anipats.com / dev123
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'dev@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Customer'),
    'Active',
    'Alex Johnson',
    '+1 (555) 100-2001',
    '123 Pet Lane, New York, NY'
);

-- Customer 2
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'mary.wilson@email.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Customer'),
    'Active',
    'Mary Wilson',
    '+1 (555) 100-2002',
    '456 Oak St, Brooklyn, NY'
);

-- Veterinarian 1
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'dr.smith@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Veterinarian'),
    'Active',
    'Dr. Sarah Smith',
    '+1 (555) 200-3001',
    NULL
);

-- Veterinarian 2
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'dr.james@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Veterinarian'),
    'Active',
    'Dr. James Lee',
    '+1 (555) 200-3002',
    NULL
);

-- Receptionist
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'reception@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Receptionist'),
    'Active',
    'Emma Davis',
    '+1 (555) 300-4001',
    NULL
);

-- Lab staff
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'lab@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'LabStaff'),
    'Active',
    'Chris Brown',
    '+1 (555) 400-5001',
    NULL
);

-- Admin
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'admin@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Admin'),
    'Active',
    'Admin User',
    '+1 (555) 000-0001',
    NULL
);
GO

/* ========= USER SUB TYPES ========= */
INSERT INTO Customers (user_id)
SELECT user_id FROM Users WHERE email = 'dev@anipats.com';
INSERT INTO Customers (user_id)
SELECT user_id FROM Users WHERE email = 'mary.wilson@email.com';

INSERT INTO Veterinarians (user_id, specialization)
SELECT user_id, 'General Practice' FROM Users WHERE email = 'dr.smith@anipats.com';
INSERT INTO Veterinarians (user_id, specialization)
SELECT user_id, 'Surgery' FROM Users WHERE email = 'dr.james@anipats.com';

INSERT INTO Receptionists (user_id)
SELECT user_id FROM Users WHERE email = 'reception@anipats.com';

INSERT INTO LabStaff (user_id, position)
SELECT user_id, 'Lab Technician' FROM Users WHERE email = 'lab@anipats.com';
GO

/* ========= PETS ========= */
INSERT INTO Pets (customer_id, name, species, breed, gender, birth_date, weight)
SELECT c.customer_id, 'Max', 'Dog', 'Golden Retriever', 'M', '2020-03-15', 28.5
FROM Customers c JOIN Users u ON c.user_id = u.user_id WHERE u.email = 'dev@anipats.com';

INSERT INTO Pets (customer_id, name, species, breed, gender, birth_date, weight)
SELECT c.customer_id, 'Luna', 'Cat', 'Siamese', 'F', '2021-07-20', 4.2
FROM Customers c JOIN Users u ON c.user_id = u.user_id WHERE u.email = 'dev@anipats.com';

INSERT INTO Pets (customer_id, name, species, breed, gender, birth_date, weight)
SELECT c.customer_id, 'Buddy', 'Dog', 'Labrador', 'M', '2019-11-08', 32.0
FROM Customers c JOIN Users u ON c.user_id = u.user_id WHERE u.email = 'mary.wilson@email.com';
GO

/* ========= SERVICES ========= */
INSERT INTO Services (name, price, description) VALUES
('General Checkup', 50.00, 'Routine health examination'),
('Vaccination', 35.00, 'Core vaccination'),
('Dental Cleaning', 80.00, 'Teeth cleaning and examination'),
('Blood Test', 45.00, 'Basic blood panel'),
('X-Ray', 120.00, 'Radiology'),
('Surgery Consultation', 75.00, 'Pre-surgery assessment'),
('Emergency Visit', 150.00, 'Emergency care');
GO

/* ========= APPOINTMENTS ========= */
INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, p.customer_id, v.veterinarian_id, DATEADD(day, -7, GETDATE()), 'Completed'
FROM Pets p
CROSS JOIN (SELECT TOP 1 veterinarian_id FROM Veterinarians) v
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
WHERE u.email = 'dev@anipats.com' AND p.name = 'Max';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, p.customer_id, v.veterinarian_id, DATEADD(day, 3, GETDATE()), 'Scheduled'
FROM Pets p
CROSS JOIN (SELECT TOP 1 veterinarian_id FROM Veterinarians) v
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
WHERE u.email = 'dev@anipats.com' AND p.name = 'Luna';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, p.customer_id, v.veterinarian_id, DATEADD(day, 5, GETDATE()), 'Scheduled'
FROM Pets p
CROSS JOIN (SELECT TOP 1 veterinarian_id FROM Veterinarians ORDER BY veterinarian_id DESC) v
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
WHERE u.email = 'mary.wilson@email.com' AND p.name = 'Buddy';
GO

/* ========= VISITS ========= */
INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, staff_id, veterinarian_id)
SELECT a.appointment_id, a.pet_id, a.customer_id,
       DATEADD(hour, -2, a.appointment_time),
       DATEADD(hour, -1, a.appointment_time),
       'Completed',
       (SELECT TOP 1 receptionist_id FROM Receptionists),
       a.veterinarian_id
FROM Appointments a
WHERE a.status = 'Completed';
GO

/* ========= MEDICAL RECORDS ========= */
INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note)
SELECT v.visit_id, v.veterinarian_id,
       'Routine checkup - healthy',
       'Vaccination booster administered',
       'Pet in good condition. Next checkup in 1 year.'
FROM Visits v
WHERE v.visit_status = 'Completed';
GO

/* ========= MEDICAL RECORD SERVICES ========= */
INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
SELECT mr.record_id, s.service_id, 1, s.price
FROM MedicalRecords mr
CROSS JOIN (SELECT service_id FROM Services WHERE name = 'General Checkup') s;

INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
SELECT mr.record_id, s.service_id, 1, s.price
FROM MedicalRecords mr
CROSS JOIN (SELECT service_id FROM Services WHERE name = 'Vaccination') s;
GO

/* ========= PRESCRIPTIONS ========= */
INSERT INTO Prescriptions (record_id, medicine_name, dosage, duration)
SELECT record_id, 'Flea prevention (monthly)', '1 tablet per month', '12 months'
FROM MedicalRecords;
GO

/* ========= LAB TESTS ========= */
INSERT INTO LabTests (test_name, description, normal_range, unit, status) VALUES
('Complete Blood Count', 'CBC panel', 'Varies by species', 'N/A', 'Active'),
('Blood Glucose', 'Glucose level', '70-120', 'mg/dL', 'Active'),
('Kidney Panel', 'BUN, Creatinine', 'Varies', 'mg/dL', 'Active');
GO

/* ========= LAB TEST REQUESTS & RESULTS ========= */
INSERT INTO LabTestRequests (visit_id, test_id, veterinarian_id, status)
SELECT v.visit_id, (SELECT TOP 1 test_id FROM LabTests), v.veterinarian_id, 'Completed'
FROM Visits v
WHERE v.visit_status = 'Completed';

INSERT INTO LabTestResults (request_id, result_value, result_note, lab_staff_id)
SELECT ltr.request_id, 'Within normal range', 'No abnormalities', (SELECT TOP 1 staff_id FROM LabStaff)
FROM LabTestRequests ltr
WHERE ltr.status = 'Completed';
GO

/* ========= INVOICES ========= */
INSERT INTO Invoices (visit_id, total_amount, status)
SELECT v.visit_id, 85.00, 'Paid'
FROM Visits v
WHERE v.visit_status = 'Completed';

INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
SELECT i.invoice_id, 'Service', NULL, 'General Checkup', 50.00, 1, 50.00
FROM Invoices i;

INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
SELECT i.invoice_id, 'Service', NULL, 'Vaccination', 35.00, 1, 35.00
FROM Invoices i;
GO

/* ========= NOTIFICATIONS ========= */
INSERT INTO Notifications (user_id, title, message)
SELECT u.user_id, 'Appointment Reminder', 'Your appointment for Luna is in 3 days.'
FROM Users u WHERE u.email = 'dev@anipats.com';

INSERT INTO Notifications (user_id, title, message)
SELECT u.user_id, 'Welcome', 'Thank you for choosing Anipats. We care for your pets.'
FROM Users u WHERE u.email = 'mary.wilson@email.com';
GO

/* ========= BLOGS ========= */
INSERT INTO Blogs (title, content) VALUES
('5 Signs Your Pet Needs a Checkup', 'Regular vet visits are essential. Here are five signs that indicate it might be time for a checkup: changes in appetite, lethargy, unusual behavior, vomiting or diarrhea, and difficulty breathing.'),
('Vaccination Schedule for Dogs', 'Core vaccines for dogs include rabies, distemper, parvovirus, and adenovirus. Your veterinarian can tailor a schedule based on your dog''s age and lifestyle.'),
('Dental Care for Cats', 'Dental disease is common in cats. Brushing teeth, dental treats, and annual cleanings can help keep your cat''s mouth healthy.');
GO

PRINT 'Seed data inserted successfully.';
PRINT 'Login (password for all): dev123';
PRINT '  Customer:    dev@anipats.com, mary.wilson@email.com';
PRINT '  Vet:         dr.smith@anipats.com, dr.james@anipats.com';
PRINT '  Reception:   reception@anipats.com';
PRINT '  Lab:         lab@anipats.com';
PRINT '  Admin:       admin@anipats.com';
GO
