## Examination flow – Technical walkthrough

File này tóm tắt **luồng khám bệnh đầy đủ** theo từng role + từng function/endpoint chính trong code, để bạn dễ đọc/ôn lại.

Các vai trò chính:
- **Customer** (khách hàng)
- **Receptionist** (staff)
- **Veterinarian** (bác sĩ)
- **Lab Staff** (kỹ thuật viên phòng lab)

---

### 1. Receptionist – Appointment & Check‑in

#### 1.1 Xem danh sách lịch hẹn
- **Servlet**: `controller.receptionist.ViewListAppointmentServlet`
- **URL**: `/Receptionist/ViewListAppointment`
- **View**: `web/WEB-INF/views/Receptionist/ViewListAppointment.jsp`
- **Chức năng:**
  - Load danh sách `Appointment` theo bộ lọc:
    - `statusFilter` (All / Pending / Confirmed / Checked-in / In-Examination / Waiting-for-Payment / Done / Canceled)
    - khoảng ngày (`fromDate`, `toDate`)
  - Tính các số lượng: `totalCount`, `pendingCount`, `confirmedCount`, `checkedInCount`, `inExaminationCount`, `waitingForPaymentCount`, `doneCount`, `canceledCount`.
  - Phân trang (pageSize = 4).
  - Giao diện tab phía trên dùng các biến này để hiển thị số lượng và highlight tab hiện tại.

#### 1.2 Chi tiết appointment (panel bên phải)
- **URL nội bộ**: AJAX gọi `GetAppointmentDetail` (servlet `controller.receptionist.GetAppointmentDetailServlet`) trả JSON.
- **Mục đích:**
  - Hiển thị chi tiết pet, owner, status, dịch vụ, bác sĩ hiện tại.
  - Cho phép receptionist đổi bác sĩ (thông qua `UpdateAppointmentDoctorServlet`).

#### 1.3 Check‑in – tạo Visit
- **Servlet**: `controller.staff.StaffCheckInServlet`
- **URL**: `/staff/check-in` (POST)
- **Luồng:**
  1. Lấy `currentUser` từ session → map sang `receptionist_id` bằng `AppointmentDAO.getReceptionistIdByUserId`.
  2. Nhận `appointmentId` từ form.
  3. Kiểm tra: nếu appointment đã có `Visit` trước đó thì redirect `/staff/queue?already=1`.
  4. Gọi:
     - `VisitDAO.createForCheckIn(appointmentId, petId, customerId, veterinarianId, receptionistId)` → tạo bản ghi `Visits` với:
       - `visit_status = 'Checked-in'`
       - `staff_id = receptionistId`
     - `AppointmentDAO.updateAppointmentStatus(appointmentId, "Checked-in")`.
  5. Redirect về `/staff/queue?checkedin=1`.

#### 1.4 Staff Queue
- **Servlet**: `controller.staff.StaffPatientsQueueServlet`
- **URL**: `/staff/queue`
- **View**: `web/WEB-INF/views/staff/patients-queue.jsp`
- **Chức năng:**
  - Hiển thị danh sách appointment hôm nay chưa check‑in hoặc đã check‑in (tùy thiết kế).
  - Show nút **Check-in** hoặc badge **Checked in** dựa trên `VisitDAO.getAppointmentIdsWithVisit`.

---

### 2. Veterinarian – Queue & Examination

#### 2.1 Vet Dashboard
- **Servlet**: `controller.vet.VetDashboardServlet` (không trích chi tiết ở đây, nhưng endpoint là `/vet/dashboard`).
- **View**: `web/WEB-INF/views/vet/dashboard.jsp`
- **Dùng các DAO:**
  - `AppointmentDAO` – lấy appointment hôm nay + các thống kê.
  - `LabTestRequestDAO` – đếm pending lab.
- **Chức năng:**
  - Thẻ thống kê (Total Appointments, Surgeries Today, Pending Lab Results, Follow-ups).
  - Bảng “Today’s Appointments”: nút **Start** dẫn tới `/vet/examination?id={appointmentId}`.

#### 2.2 Vet Patients Queue
- **Servlet**: `controller.vet.VetPatientsQueueServlet` (hoặc tương đương nếu bạn đã có).
- **URL**: `/vet/queue`
- **View**: `web/WEB-INF/views/vet/patients-queue.jsp`
- **Luồng:**
  - Lấy danh sách appointment hôm nay `status = 'Checked-in'` cho vet đang đăng nhập bằng `AppointmentDAO.getAppointmentsForDateByVeterinarian`.
  - Hiển thị queue với nút **Start Examination** → `/vet/examination?id={appointmentId}`.

#### 2.3 Mở trang Examination
- **Servlet**: `controller.vet.VetExaminationServlet`
- **URL**: `/vet/examination` (GET)
- **Chức năng chính trong `doGet`:**
  1. Bảo vệ đăng nhập (`currentUser` trong session, role Vet).
  2. Đọc `id` (appointmentId) từ query.
  3. Lấy `Appointment` chi tiết: `AppointmentDAO.getAppointmentDetail`.
  4. Kiểm tra appointment thuộc về vet hiện tại (so sánh veterinarianId).
  5. Lấy `Visit` theo appointment:
     - `VisitDAO.getByAppointmentId`.
     - Nếu **chưa có Visit** → redirect `/vet/queue?error=notcheckedin` (bắt buộc receptionist phải check‑in).
     - Nếu `visit_status = 'Checked-in'` → update sang `'In-Examination'`.
  6. Load `MedicalRecord` nếu có (`MedicalRecordDAO.getByVisitId`) + danh sách:
     - `RecordServiceLine` (dịch vụ trong record)
     - `Prescriptions`
  7. Load dữ liệu lab:
     - `LabTestRequestDAO.getByVisitId(visitId)` → list lab request theo visit.
     - `LabTestRequestDAO.getRecentResultsByPetId(petId, 14)` → lab results gần đây của pet.
  8. Load list `Service` và `LabTests` cho UI.
  9. Set các attribute (`user`, `appointment`, `visit`, `medicalRecord`, `recordServices`, `prescriptions`, `labRequests`, `recentLabResults`, `clinicServices`, `labTests`) rồi forward sang `vet/examination.jsp`.

#### 2.4 Lưu Examination (POST)
- **Servlet**: `VetExaminationServlet.doPost`
- **Nhận input:**
  - `appointmentId`
  - Form nội dung:
    - `diagnosis`
    - `treatment`
    - `note`
    - `serviceIds` (chuỗi id dịch vụ, được JS build từ UI)
    - `medication_name[]`, `dosage[]`, `duration[]` (prescriptions)
  - `action` = `"save"` hoặc `"complete"`.

- **Bước xử lý chính:**
  1. Lấy `Appointment` + `Visit` (giống GET, kèm kiểm tra quyền vet).
  2. Lấy hoặc tạo `MedicalRecord`:
     - Nếu chưa có: `MedicalRecordDAO.create(visitId, veterinarianId, diagnosis, treatment, note)`.
     - Nếu đã có: `MedicalRecordDAO.update(recordId, diagnosis, treatment, note)`.
  3. Ghi lại dịch vụ:
     - `deleteRecordServices(recordId)`.
     - Parse `serviceIds`, tra trong `ServiceService` để lấy `price`, rồi `addService(recordId, serviceId, quantity, price)`.
  4. Ghi lại prescriptions:
     - `deletePrescriptionsByRecordId(recordId)`.
     - Lặp qua mảng thuốc, thêm mới từng prescription bằng `addPrescription`.

- **Nếu `action = "complete"`:**
  1. `VisitDAO.completeVisit(visitId)` → `visit_status = 'Completed'`, set `check_out_time = GETDATE()`.
  2. `AppointmentDAO.updateAppointmentStatus(appointmentId, "Completed")` *(bạn có thể đổi thành `"Waiting-for-Payment"` nếu muốn)*.
  3. Lấy lại toàn bộ `RecordServiceLine` cho record.
  4. Tính tổng tiền:
     - `total += line.getPrice() * line.getQuantity()`.
  5. Nếu `total > 0`:
     - Tạo `Invoice`:
       - `InvoiceDAO.create(visitId, total, "Recorded")` (hoặc `"Paid"` cho data seed).
     - Thêm `InvoiceItems`:
       - `InvoiceDAO.addItem(invoiceId, "Service", serviceName, unitPrice, quantity, totalPrice)`.
  6. Redirect về `/vet/queue?completed=1`.

---

### 3. Lab – Nhận request & trả kết quả

#### 3.1 Gửi Lab Request từ phía Vet
- **(Trong `vet/examination.jsp` + một servlet `VetLabRequestServlet`):**
  - Form Lab Request gửi `visitId`, `testId`, `veterinarianId`.
  - Servlet gọi `LabTestRequestDAO.createRequest(visitId, testId, veterinarianId)` → tạo bản ghi `LabTestRequests` status `'Pending'`.

#### 3.2 Lab Dashboard – hàng đợi
- **Servlet**: `controller.lab.LabDashboardServlet`
- **URL**: `/lab/dashboard`
- **View**: `web/WEB-INF/views/lab/dashboard.jsp`
- **Chức năng:**
  - Gọi `LabTestRequestDAO.getPendingRequests()` → list request gồm:
    - `pet_name`, `owner_name`, `veterinarian_name`, `test_name`, `request_time`, `status`.
  - JSP loop qua `pendingRequests` để hiển thị queue, mỗi hàng có nút **Upload Results**.
  - Khi chọn hàng, form bên phải được điền `requestId`, tên test, bác sĩ, vv.

#### 3.3 Gửi kết quả từ Lab
- **Servlet**: `controller.lab.LabUploadResultServlet`
- **URL**: `/lab/result` (POST)
- **Nhận:**
  - `requestId`
  - `resultValue`
  - `resultNote`
  - `techNotes` (append vào note nếu có, với prefix `[Tech notes]`).
- **Xử lý:**
  - Lấy `LabStaff` theo user hiện tại: `LabTestRequestDAO.getLabStaffIdByUserId(userId)`.
  - `LabTestRequestDAO.saveResult(requestId, resultValue, fullNote, labStaffId)`:
    - Insert vào `LabTestResults`.
    - Update `LabTestRequests.status = 'Completed'`.
  - Redirect về `/lab/dashboard`.

#### 3.4 Vet xem kết quả lab
- Trên `vet/examination.jsp`:
  - Block **Lab Requests Status** hiển thị từng request với button:
    - `View Result` nếu status `'Completed'`.
  - Khi click `View Result`:
    - Gửi GET `/vet/examination?id=...&viewLabRequestId={requestId}`.
    - `VetExaminationServlet` gọi `LabTestRequestDAO.getResultDetailByRequestId(requestId)` → `LabResultDetail`.
    - Set `labResultDetail` → JSP mở modal **Lab Result Viewer** (read‑only).

---

### 4. Medical Records – lịch sử & xem lại

#### 4.1 Lịch sử Medical Record cho Vet
- **Servlet**: `controller.vet.VetMedicalRecordsServlet`
- **URL**: `/vet/records`
- **DAO**: `MedicalRecordDAO.getRecentRecordsByVeterinarian(vetId, limit)`
  - Join `MedicalRecords` + `Visits` + `Pets` + `Veterinarians` + `Users` để lấy:
    - `record_id`, `pet_id`, `appointment_id`, `pet_name`, `created_at`, `veterinarian_name`, `diagnosis`.
- **View**: `vet/medical-records.jsp`
  - Bảng “Medical Records History” với Record ID, Patient ID, Pet, Date, Doctor, Diagnosis, nút **View Record**.

#### 4.2 Chi tiết Medical Record (vet)
- **Servlet**: `controller.vet.VetMedicalRecordDetailServlet`
- **URL**: `/vet/record?id={recordId}`
- **Luồng:**
  1. Kiểm tra đăng nhập và đảm bảo bác sĩ hiện tại là chủ của record (`record.veterinarianId`).
  2. Lấy:
     - `MedicalRecord` theo `recordId`.
     - `Visit` theo `visitId` (`VisitDAO.getByVisitId`).
     - `Pet` (qua `PetJdbcDAO.findById`).
     - `Customer` (qua `CustomerJdbcDAO.findById`).
     - `RecordServiceLine` + `Prescriptions`.
  3. Tính:
     - `durationLabel` từ `check_in_time` & `check_out_time`.
     - `concludedAt` (chuỗi ngày/giờ).
     - `totalAmount` từ tất cả services.
  4. Forward tới `vet/medical-record-view.jsp` (bản report read‑only).

#### 4.3 Customer xem Medical Records sau khi thanh toán
- **Servlet**: `controller.customer.CustomerMedicalRecordsServlet`
- **URL**: `/customer/records`
- **DAO**: `MedicalRecordDAO.getRecordsForCustomer(customerId)`
  - Lọc `WHERE v.customer_id = ? AND (a.status = 'Done' OR a.status = 'Completed')`.
- **View**: `customer/records.jsp`
  - Bảng “My Medical Records” – mỗi dòng là 1 record hoàn tất + đã thanh toán (hoặc Completed).

---

### 5. Hồ sơ & đổi mật khẩu

Phần này tái sử dụng logic của customer cho vet:

- **Customer side:**
  - `CustomerProfileServlet` (`/customer/profile`) + `profile.jsp`
  - `CustomerEditProfileServlet` (`/customer/edit-profile`) + `edit-profile.jsp`
  - `ChangePasswordServlet` (`/customer/change-password`)

- **Vet side (song song):**
  - `VetProfileServlet` (`/vet/profile`) + `vet/profile.jsp`
  - `VetEditProfileServlet` (`/vet/edit-profile`) + `vet/edit-profile.jsp`
  - `VetChangePasswordServlet` (`/vet/change-password`)

Các rule validate (tên, phone, address, password) đều dùng chung `ValidationUtil`.

---

### 6. Test data – xem nhanh

- **`database/seed_data.sql`**:
  - Tạo roles, users (customers, vets, receptionist, lab), pets, services, 1 số appointments cũ, 1 completed visit + medical record + invoice, lab tests & kết quả.

- **`database/seed_test_screens.sql`**:
  - Thêm **4 appointments ngày hôm nay** cho 2 bác sĩ.
  - Tự tạo **1 visit đã Checked-in** + **1 lab request Pending** (để vet queue & lab dashboard có data).
  - Tạo thêm **2 visits completed + medical records + invoices**:
    - Max – ear infection (đã `Paid`).
    - Luna – gastroenteritis (`Waiting-for-Payment` với invoice `Recorded`).

Bạn có thể đọc file này từ trên xuống để **hiểu luồng đầy đủ**, hoặc dùng nó làm tài liệu khi viết test case / user story chi tiết. 
