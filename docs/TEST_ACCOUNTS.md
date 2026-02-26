# Test Accounts & Screen Data

Use these accounts to test each role’s screens. **Password for all:** `dev123`.

---

## 1. Load test data

1. Run **`database/seed_data.sql`** (if not already done) to create roles, users, customers, vets, pets, services, and sample appointments.
2. Run **`database/seed_test_screens.sql`** to add **today’s** appointments so the Vet Queue, Receptionist list, and Examination flow have data.

---

## 2. Test accounts

| Role          | Email                 | What to test |
|---------------|------------------------|--------------|
| **Customer**  | `dev@anipats.com`      | Customer dashboard, My Pets (Max, Luna), profile, edit profile. |
| **Customer**  | `mary.wilson@email.com`| Customer dashboard, pet Buddy. |
| **Veterinarian** | `dr.smith@anipats.com` | Vet dashboard → **Patients Queue** (`/vet/queue`): 2 today (Max 09:00, Luna 10:30). **Start Examination** → Current Examination page. |
| **Veterinarian** | `dr.james@anipats.com` | Vet dashboard → **Patients Queue**: 2 today (Buddy 11:00, Max 14:00). |
| **Receptionist** | `reception@anipats.com` | Appointments list (`/Receptionist/ViewListAppointment`), assign doctor, filters. |
| **Lab staff** | `lab@anipats.com`       | Lab dashboard (`/lab/dashboard`), FIFO queue (placeholder rows). |
| **Admin**     | `admin@anipats.com`    | Owner/Admin area (e.g. user management, services). |

---

## 3. Today’s appointments (after `seed_test_screens.sql`)

- **Dr. Sarah Smith:** Max (09:00), Luna (10:30).
- **Dr. James Lee:** Buddy (11:00), Max (14:00).

So each vet sees only their own appointments in **Patients Queue**, and the receptionist sees all in the appointment list.

---

## 4. Quick checks

- **Customer:** Login → `dev@anipats.com` / `dev123` → Dashboard shows pet count; click **Pets** or **Add Pet**.
- **Vet:** Login → `dr.smith@anipats.com` / `dev123` → **Patients Queue** → 2 rows → **Start Examination** on one → Examination page with pet/owner and Lab Request modal.
- **Receptionist:** Login → `reception@anipats.com` / `dev123` → open appointment list URL (or link from your app) → filter by date/status, assign vet.
- **Lab:** Login → `lab@anipats.com` / `dev123` → Lab Queue dashboard with sample queue and result entry panel.
