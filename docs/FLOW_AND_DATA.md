# Flow, Script & Seed Data – VCMS

## 1. script.sql (schema)

**Purpose:** Creates the database and all tables. Run this first (or use an existing `VetClinicManagement` DB).

**Main tables:**

| Table | Purpose |
|-------|--------|
| **Roles** | role_id, role_name (Customer, Veterinarian, Receptionist, LabStaff, Admin, ClinicOwner) |
| **Users** | user_id, email, password, role_id, status, full_name, phone, address, profile_picture_url, is_google_user |
| **Customers** | customer_id, user_id |
| **Veterinarians** | veterinarian_id, user_id, specialization |
| **Receptionists** | receptionist_id, user_id |
| **LabStaff** | staff_id, user_id, position |
| **Pets** | pet_id, customer_id, name, species, breed, gender, birth_date, weight, photoUrl, isDeleted |
| **Services** | service_id, name, price, description, category, duration, is_deleted |
| **Appointments** | appointment_id, pet_id, customer_id, veterinarian_id, appointment_time, status, service_id |
| **Visits** | visit_id, appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, **staff_id**, veterinarian_id |
| **MedicalRecords** | record_id, visit_id, veterinarian_id, diagnosis, treatment, note |
| **MedicalRecordServices** | record_service_id, record_id, service_id, quantity, price |
| **Prescriptions** | prescription_id, record_id, medicine_name, dosage, duration |
| **LabTests** | test_id, test_name, description, normal_range, unit, status |
| **LabTestRequests** | request_id, visit_id, test_id, veterinarian_id, request_time, status |
| **LabTestResults** | result_id, request_id, result_value, result_note, result_file, result_date, lab_staff_id |
| **Invoices** | invoice_id, visit_id, total_amount, status |
| **InvoiceItems** | item_id, invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price |
| **Notifications** | notification_id, user_id, title, message |
| **Blogs**, **Images**, **PasswordResetTokens** | Supporting content and auth |

**Note:** `Visits` uses column **staff_id** (FK to Receptionists.receptionist_id). seed_data.sql inserts using `staff_id`.

---

## 2. seed_data.sql (sample data for testing)

**Purpose:** Inserts roles, users, and one full visit so you can test the flow. Run after script.sql.

**Data inserted:**

- **Roles:** Customer, Veterinarian, Receptionist, LabStaff, Admin, ClinicOwner (role_id 1–6 in insert order).
- **Users (password for all: dev123):**
  - Customers: dev@anipats.com (Alex Johnson), mary.wilson@email.com (Mary Wilson)
  - Vets: dr.smith@anipats.com (Dr. Sarah Smith), dr.james@anipats.com (Dr. James Lee)
  - Receptionist: reception@anipats.com (Emma Davis)
  - Lab: lab@anipats.com (Chris Brown)
  - Admin: admin@anipats.com
- **Customers, Veterinarians, Receptionists, LabStaff** rows linked to those users.
- **Pets:** Max, Luna (dev@anipats.com), Buddy (mary.wilson@email.com).
- **Services:** General Checkup, Vaccination, Dental Cleaning, Blood Test, X-Ray, Surgery Consultation, Emergency Visit.
- **Appointments:** One completed (Max, -7 days), two scheduled (Luna +3 days, Buddy +5 days).
- **Visits:** One completed visit for the completed appointment (check_in/check_out, receptionist, vet).
- **MedicalRecords:** One record for that visit (diagnosis, treatment, note).
- **MedicalRecordServices:** General Checkup + Vaccination on that record.
- **Prescriptions:** One prescription (flea prevention).
- **LabTests:** Complete Blood Count, Blood Glucose, Kidney Panel.
- **LabTestRequests / LabTestResults:** One completed lab request and result for that visit.
- **Invoices / InvoiceItems:** One paid invoice (85.00) for that visit.
- **Notifications:** Two sample notifications.
- **Blogs:** Three sample posts.

**For “today” appointments (vet queue, receptionist list):** run **seed_test_screens.sql** after seed_data.sql to add today’s appointments for both vets.

---

## 3. Activity diagram flow (Veterinary Clinic Management System Flow)

High-level flow from the diagram:

1. **Receptionist**  
   - Confirm appointment → **Assign Veterinarian** (optional if default) → **Mark as Checked-in**.

2. **System**  
   - After check-in: **Notify Assigned Veterinarian**.  
   - After vet creates lab request: **Notify Lab Technician**.  
   - After lab uploads result: **Notify Veterinarian**.  
   - After vet records services: **Notify Receptionist for Billing**.

3. **Veterinarian**  
   - **View Assigned Appointment** → **Enter Diagnosis** → **Create Medical Records**.  
   - **Need Lab examinations?**  
     - **No** → **Create Treatment Plan** → **Record Services Used**.  
     - **Yes** → **Create Lab Examination Request** → (after lab result) **Create Treatment Plan** → **Record Services Used**.

4. **Lab Technician**  
   - **View Lab Examination Request** → **Upload Lab Examination Result**.

5. **Receptionist**  
   - **Mark as Paid** (after billing is ready).

---

## 4. Does the project do the same?

| Diagram step | In project? | Where |
|--------------|-------------|--------|
| **Receptionist: Confirm appointment** | Yes | ViewListAppointment (list, filters, date range). |
| **Receptionist: Assign Veterinarian** | Yes | UpdateAppointmentDoctor (dropdown, assign vet to appointment). |
| **Receptionist: Mark as Checked-in** | Partial | Status “Checked-in” exists in filters; no dedicated “Check-in” button that sets status and triggers notify. |
| **System: Notify Assigned Veterinarian** | No | No in-app or email notification when appointment is checked in. |
| **Veterinarian: View Assigned Appointment** | Yes | Vet queue (/vet/queue) shows only that vet’s appointments; Start Examination opens examination page. |
| **Veterinarian: Enter Diagnosis** | Yes | Examination page: Diagnosis & Observation textarea; Save Progress / Complete saves to MedicalRecords (diagnosis, treatment, note). |
| **Veterinarian: Create Medical Records** | Yes | Same page; persistence to MedicalRecords, Prescriptions. Visit must exist (created at receptionist check-in); vet cannot open examination until patient is checked in. |
| **Veterinarian: Need Lab? → Create Lab Examination Request** | Yes | “Request Lab Test” modal: test type from LabTests; POST /vet/lab-request saves to LabTestRequests (status Pending). |
| **System: Notify Lab Technician** | No | No notification when lab request is created. |
| **Lab Technician: View Lab Examination Request** | Yes | Lab dashboard (/lab/dashboard) loads pending requests from LabTestRequests (FIFO by request_time). |
| **Lab Technician: Upload Lab Examination Result** | Yes | Result Entry form POSTs to /lab/result; saves to LabTestResults and sets LabTestRequests.status = Completed. |
| **System: Notify Veterinarian** | No | No notification when lab result is uploaded. |
| **Veterinarian: Create Treatment Plan** | Yes | Treatment Plan textarea saved in MedicalRecords.treatment; “Schedule Revisit” modal POSTs to /vet/schedule-revisit and creates a new appointment. |
| **Veterinarian: Record Services Used** | Yes | Services section: saved to MedicalRecordServices (record_id, service_id, quantity, price); list from DB on load. |
| **System: Notify Receptionist for Billing** | No | No notification when services are recorded. |
| **Receptionist: Mark as Paid** | No | No billing/invoice UI or “Mark as Paid” tied to this flow. |

**Summary:**  
- The **schema** (script.sql) and **seed** (seed_data.sql) support the full flow (Visits, MedicalRecords, LabTestRequests/Results, Invoices).  
- The **app** implements: receptionist list + assign vet, vet queue + examination (with **persistence**), lab request creation (saved to DB), services used (MedicalRecordServices), lab dashboard with **real pending requests**, and lab result upload (LabTestResults + request completed).  
- **Implemented:** Receptionist check-in (creates Visit with staff_id, sets Checked-in); vet queue shows only Checked-in patients; vet can open examination only when visit exists; amount spent saved to Invoices on complete. **Not yet implemented:** notifications. Run seed_data.sql then seed_test_screens.sql; have receptionist check in today's appointments so they appear in the vet queue.
