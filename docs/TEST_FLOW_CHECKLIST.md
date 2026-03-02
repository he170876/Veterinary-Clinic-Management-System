# VCMS Flow – Self-Testing Checklist

Use this checklist to verify the **receptionist check-in → vet examination → amount recorded** flow.  
Run **script.sql**, then **seed_data.sql**, then **seed_test_screens.sql**.  
Password for all seed users: **dev123**.

---

## 1. Database readiness

| Step | Action | Expected |
|------|--------|----------|
| 1.1 | Run `database/upgrade_check_in_flow.sql` (optional) | No errors; message "No schema changes required". |
| 1.2 | Confirm tables exist: Visits (with staff_id), Invoices, InvoiceItems, Receptionists | All present (script.sql already includes them). |

---

## 2. Receptionist – Staff queue & check-in

| Step | Action | Expected |
|------|--------|----------|
| 2.1 | Log in as **reception@anipats.com** / dev123 | Redirect to staff dashboard or queue. |
| 2.2 | Go to **Patients Queue** (`/staff/queue`) | List of today’s appointments. |
| 2.3 | Check one row has **"Checked in"** (pre-checked-in from seed_test_screens) | One appointment shows "Checked in", others show **"Check-in"** button. |
| 2.4 | Click **Check-in** on an appointment that is not checked in | POST to `/staff/check-in`; redirect back to queue with green message "Patient checked in successfully." |
| 2.5 | Same row now shows **"Checked in"** (no button) | No Check-in button; status or badge shows checked in. |
| 2.6 | Click Check-in again on already checked-in (e.g. open in new tab and resubmit) | Redirect with "This patient is already checked in." (or similar). |

---

## 3. Veterinarian – Queue (only checked-in)

| Step | Action | Expected |
|------|--------|----------|
| 3.1 | Log in as **dr.smith@anipats.com** / dev123 | Vet portal. |
| 3.2 | Go to **Appointments** / **Patients Queue** (`/vet/queue`) | Only appointments with status **Checked-in** for this vet. |
| 3.3 | Without any check-in: if seed_test_screens ran | At least one patient (e.g. Max 09:00) in the list. |
| 3.4 | After 2.4, refresh vet queue | Newly checked-in patient appears for the assigned vet. |
| 3.5 | Empty state | If no checked-in patients: message like "No checked-in patients for today. Patients appear here after receptionist checks them in." |

---

## 4. Veterinarian – Examination (only when visit exists)

| Step | Action | Expected |
|------|--------|----------|
| 4.1 | From vet queue, click **Start Examination** on a checked-in patient | GET `/vet/examination?id=<appointmentId>`; examination page loads. |
| 4.2 | Visit status | Visit status becomes **In-Examination** (backend). |
| 4.3 | Open `/vet/examination?id=<id>` for an appointment that has **no** visit (e.g. not checked in) | Redirect to `/vet/queue?error=notcheckedin` and message "Patient must be checked in by receptionist first." |
| 4.4 | On examination page: edit diagnosis, services, prescription; click **Save Progress** | POST with action=save; redirect back to same examination; data persisted. |
| 4.5 | Click **Complete Examination** | POST with action=complete; redirect to `/vet/queue?completed=1`; success message. |

---

## 5. Amount recorded (invoice on complete)

| Step | Action | Expected |
|------|--------|----------|
| 5.1 | After **Complete Examination** (4.5), check DB: `SELECT * FROM Invoices WHERE visit_id = ?` | One new row: visit_id, total_amount (sum of record services), status e.g. **Recorded**. |
| 5.2 | Check `SELECT * FROM InvoiceItems WHERE invoice_id = ?` | Rows for each service line (name_snapshot, unit_price, quantity, total_price). |
| 5.3 | Complete exam with no services recorded | Invoice may still be created with total 0, or skipped if logic requires total > 0 (current code creates only when total > 0). |

---

## 6. Schedule revisit

| Step | Action | Expected |
|------|--------|----------|
| 6.1 | On examination page, open **Schedule Revisit** modal; set date and time; **Confirm Appointment** | POST to `/vet/schedule-revisit`; redirect to vet queue with success (e.g. revisit=ok). |
| 6.2 | Check DB: new row in **Appointments** | pet_id, customer_id, veterinarian_id, appointment_time, status e.g. Confirmed. |

---

## 7. Lab request (from examination)

| Step | Action | Expected |
|------|--------|----------|
| 7.1 | On examination page, open **Request Lab Test**; select test, submit | POST to `/vet/lab-request`; new row in **LabTestRequests** (status Pending). |
| 7.2 | Log in as **lab@anipats.com**; open Lab dashboard | Pending request(s) listed; can upload result. |

---

## 8. Quick reference – URLs & users

| Role | Login | Main URLs |
|------|--------|-----------|
| Receptionist | reception@anipats.com | /staff/queue |
| Veterinarian | dr.smith@anipats.com, dr.james@anipats.com | /vet/queue, /vet/examination?id= |
| Lab | lab@anipats.com | /lab/dashboard |

---

## 9. Flow summary (in order)

1. **Receptionist** checks in patient → Visit created (staff_id set), appointment status = Checked-in.  
2. **Vet** sees only Checked-in patients in queue; opens examination only when visit exists.  
3. **Vet** completes examination → Visit and appointment completed; **Invoice** (and items) created with amount from record services.  
4. Revisit and lab request work from examination page as above.

If any step fails, check: DB (script + seed + seed_test_screens), app server logs, and that the correct user role is logged in for each step.
