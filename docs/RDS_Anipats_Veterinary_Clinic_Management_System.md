# Requirements Design Specification (RDS)

**Hệ thống:** Anipats – Veterinary Clinic Management System  
**Loại tài liệu:** RDS / Đặc tả thiết kế yêu cầu (bản chi tiết màn hình, luồng, ràng buộc dữ liệu)  
**Phiên bản tài liệu:** 1.0  
**Ngày:** 05/03/2026  

---

## Mục lục

1. [Giới thiệu & phạm vi](#1-giới-thiệu--phạm-vi)
2. [Tác nhân & vai trò](#2-tác-nhân--vai-trò)
3. [Ma trận chức năng – User story & trạng thái](#3-ma-trận-chức-năng--user-story--trạng-thái)
4. [Yêu cầu chức năng theo module](#4-yêu-cầu-chức-năng-theo-module)
5. [Đặc tả chi tiết màn hình: Khám bệnh (Examination)](#5-đặc-tả-chi-tiết-màn-hình-khám-bệnh-examination)
6. [Phòng xét nghiệm: tải kết quả (PDF)](#6-phòng-xét-nghiệm-tải-kết-quả-pdf)
7. [Thông báo (Notifications)](#7-thông-báo-notifications)
8. [Bảng ràng buộc dữ liệu mẫu (cấu hình / tham số)](#8-bảng-ràng-buộc-dữ-liệu-mẫu-cấu-hình--tham-số)
9. [Yêu cầu phi chức năng (tóm tắt)](#9-yêu-cầu-phi-chức-năng-tóm-tắt)
10. [Phụ lục: URL servlet chính (tham chiếu triển khai)](#10-phụ-lục-url-servlet-chính-tham-chiếu-triển-khai)

---

## 1. Giới thiệu & phạm vi

### 1.1 Mục đích

Tài liệu mô tả **thiết kế yêu cầu** đủ chi tiết để:

- Đồng bộ giữa SRS (mockup), backlog spreadsheet và mã nguồn.
- Làm cơ sở cho kiểm thử hệ thống (system test / UAT).
- Ghi nhận luồng nghiệp vụ: đặt lịch → check-in → khám → xét nghiệm → thanh toán (theo trạng thái đã triển khai).

### 1.2 Phạm vi sản phẩm

Ứng dụng **Web (JSP/Servlet)**, đa vai trò: Khách hàng, Lễ tân, Bác sĩ thú y, Nhân viên lab, Quản trị, Chủ phòng khám (dashboard thống kê).

### 1.3 Thuật ngữ

| Thuật ngữ | Ý nghĩa |
|-----------|---------|
| Visit | Lượt khám gắn với lịch hẹn sau khi check-in |
| Medical record | Bệnh án / bản ghi khám trong visit |
| Lab request | Yêu cầu xét nghiệm gắn visit, trạng thái Pending → Completed |

---

## 2. Tác nhân & vai trò

| Vai trò | Mô tả ngắn |
|---------|------------|
| **Customer** | Đăng ký/đăng nhập, quản lý thú cưng, đặt/hủy/hẹn lại lịch, xem hồ sơ khám |
| **Receptionist** | Lịch hẹn, check-in, hàng chờ, xác nhận thanh toán, đặt hộ |
| **Veterinarian** | Hàng chờ bác sĩ, khám, yêu cầu xét nghiệm, xem kết quả lab, hồ sơ bệnh án |
| **LabStaff** | Hàng chờ xét nghiệm, tải kết quả (PDF + ghi chú) |
| **Admin** | Người dùng, dịch vụ, blog, thư viện ảnh |
| **ClinicOwner** | Thống kê dashboard (owner) |

---

## 3. Ma trận chức năng – User story & trạng thái

Bảng dưới mở rộng backlog dạng spreadsheet (Iteration / Status). Có thể copy vào Excel.

| Nhóm | Screen / Function | Actor | User story (As a … I want … so that …) | Iteration | Status (gợi ý) |
|------|-------------------|-------|----------------------------------------|-----------|----------------|
| **Authentication** | Login / Logout | User | As a user I want to log in with email/password or Google so that I access features by role. | 1 | Done |
| | Google Login | User | As a user I want to sign in with Google without manual registration. | 1 | Done |
| | Register | Guest | As a guest I want to register to use customer features. | 1 | Done |
| | Forgot password | User | As a user I want to reset password via email to regain access. | 1 | Done |
| | Change password | User | As a user I want to change password to keep account secure. | 1 | Done |
| **Notification** | Notification center | Lab, Vet, … | As staff I want to see notifications for new lab requests / completed results / billing. | 3 | Doing / Done |
| **Profile** | View / update profile | User | As a customer I want to view and update personal information. | 1 | Done |
| **Medical records** | Create / update record | Vet | As a vet I want diagnosis, treatment, services, prescriptions saved on examination. | 2 | Done |
| | Revisit note | Vet | As a vet I want to add revisit / follow-up notes for continuity of care. | 3 | To do (nếu chưa có trong UI) |
| **Examination** | Start / update session | Vet | As a vet I want to open examination from queue and save or complete the visit. | 1–2 | Done |
| **Laboratory** | Lab queue list | Lab | As lab staff I want to see pending test requests FIFO / search. | 3 | Done |
| | Request lab test | Vet | As a vet I want to request tests from examination to support diagnosis. | 3 | Done |
| | Upload results | Lab | As lab staff I want to upload **PDF** result + text note for the vet. | 3 | Done |
| | View results | Vet | As a vet I want to view lab results (PDF viewer / modal) before finalizing. | 2–3 | Done |
| **Receptionist** | Check-in, queue | Receptionist | As receptionist I want to check in patients and manage appointment flow. | 2 | Done |
| **Admin** | Users, services, blog | Admin | As admin I want to manage users, service catalog, content. | 2–3 | Done |
| **Owner** | Dashboard stats | Owner | As owner I want aggregated statistics. | 2 | Done |

---

## 4. Yêu cầu chức năng theo module

### 4.1 Khách hàng (Customer)

- Đăng ký, đăng nhập (email/password, Google).
- CRUD thú cưng (tên, loài, giống, cân nặng, ảnh đại diện thú – định dạng ảnh theo cấu hình upload).
- Đặt lịch, xem chi tiết lịch, yêu cầu đổi lịch (reschedule) nếu được phép.
- Xem danh sách / chi tiết hồ sơ khám (read-only).

### 4.2 Lễ tân (Receptionist)

- Danh sách lịch, tạo lịch hộ, lịch khẩn cấp (theo màn hình triển khai).
- Check-in → tạo visit; cập nhật trạng thái lịch hẹn.
- Hàng chờ bệnh nhân (staff queue).
- Xác nhận thanh toán / hóa đơn (theo luồng invoice).

### 4.3 Bác sĩ (Veterinarian)

- Dashboard: lịch trong ngày, chỉ số tóm tắt (theo dashboard).
- Hàng chờ: bắt đầu khám (start examination) với kiểm soát trạng thái (busy / locked / not checked-in).
- **Examination:** nhập chẩn đoán, dịch vụ, đơn thuốc, kế hoạch điều trị; lưu nháp; hoàn tất khám.
- Yêu cầu xét nghiệm từ màn khám; xem danh sách lab request và **xem kết quả** (file PDF).
- Hồ sơ bệnh án / chi tiết bản ghi.
- Lên lịch tái khám (revisit) nếu servlet `VetScheduleRevisitServlet` được dùng trong UI.

### 4.4 Phòng xét nghiệm (Laboratory)

- Hàng chờ request Pending.
- Gửi kết quả: **ghi chú bắt buộc** + **file PDF bắt buộc** (không chấp nhận JPG/PNG… cho file gửi bác sĩ).
- Thông báo tới bác sĩ khi hoàn tất upload.

### 4.5 Quản trị (Admin)

- Quản lý người dùng (tạo, khóa, đổi vai trò tùy policy).
- Dịch vụ (service catalog).
- Blog: tạo/sửa, trạng thái.
- Thư viện ảnh (image servlet / management).

---

## 5. Đặc tả chi tiết màn hình: Khám bệnh (Examination)

### 5.1 Mã màn hình

- **Tên màn:** Patient Examination (Vet Examination)
- **JSP:** `web/WEB-INF/views/vet/examination.jsp`
- **Servlet:** `VetExaminationServlet` (`GET/POST /vet/examination`)
- **Điều kiện vào:** Đăng nhập vai trò Veterinarian; lịch hẹn thuộc bác sĩ; visit đã tồn tại (sau check-in); trạng thái hợp lệ theo logic start examination.

### 5.2 Bố cục UI (overview)

| Khu vực | Thành phần | Mô tả |
|---------|------------|--------|
| Header | Breadcrumb | Dashboard → Appointments → Patient Examination (hoặc tương đương) |
| | Tiêu đề bệnh nhân | Tên thú (species), mã bệnh nhân / owner |
| | Trạng thái | Ví dụ trạng thái lịch / visit (OPEN / In-Examination – theo dữ liệu) |
| | Nút **Save Progress** | Lưu nháp (POST không `action=complete`) |
| Thanh info | Giống / tuổi, cân nặng, lần khám gần nhất, cờ điều kiện (ví dụ follow-up) | Đọc từ pet / appointment / visit |
| Cột trái | **Diagnosis & Observation** | Textarea |
| | **Services** | Danh sách dịch vụ đã chọn; thêm từ dropdown; xóa dòng |
| | **Prescription** | Nhiều dòng: tên thuốc, liều (dosage), tần suất / ghi chú (duration) |
| | **Treatment plan** | Textarea (note / treatment) |
| Cột phải | **Request Lab Test** | Chọn loại xét nghiệm, submit lab request |
| | **Complete Examination** | Hoàn tất khám |
| | **Lab Requests Status** | Danh sách request: Pending / Completed; nút **View Result** khi Completed |

### 5.3 Dữ liệu hiển thị & nguồn

| Thông tin | Nguồn (logic) |
|-----------|----------------|
| Pet, owner | `Appointment` / `Pet` / `Customer` |
| Medical record | `MedicalRecord` theo `visit_id` |
| Services đã gắn | `RecordServiceLine` |
| Prescription | `Prescription` |
| Lab requests | `LabTestRequest` theo `visit_id` |
| Kết quả xem chi tiết | `LabResultDetail` khi có `viewLabRequestId` |

### 5.4 Luồng nút **Save Progress**

- **POST** form examination: lưu diagnosis, treatment, note; cập nhật/tạo medical record; ghi lại services và prescriptions theo tham số form.
- **Không** chuyển visit sang completed; **không** bắt buộc đủ điều kiện complete (cho phép lưu nháp).

### 5.5 Luồng nút **Complete Examination**

**Điều kiện nghiệp vụ (server):**

- Không cho complete nếu còn **LabTestRequest** trạng thái **Pending** cho visit → redirect `error=pendingLab` và banner.

**Điều kiện kiểm tra form (client – examination.jsp):**

1. **Diagnosis:** không được để trống (trim).
2. **Services:** ít nhất **một** dịch vụ trong `#examination-services-list`.
3. **Prescription:** Nếu nhập **tên thuốc** thì:
   - **Dosage** bắt buộc và chỉ chấp nhận **số** (số nguyên hoặc thập phân), regex kiểu `^\d+(\.\d+)?$`.
   - **Duration / frequency** bắt buộc (trường duration).
4. **Lab pending:** biến `PENDING_LAB_COUNT` > 0 → chặn complete, thông báo hoàn thành lab trước.

**Hậu quả khi complete thành công:**

- `visit` completed; appointment chuyển **Waiting-for-Payment** (theo code hiện tại).
- Tạo invoice (Recorded) từ tổng dịch vụ nếu total > 0.
- Thông báo role **Receptionist** xác nhận thanh toán.

### 5.6 Luồng **Request Lab Test**

- POST tới servlet lab request (ví dụ `/vet/lab-request`) với `appointmentId`, `testId`.
- Sau khi tạo request: thông báo lab; có thể tự gắn dịch vụ tương ứng (logic JS gọi API lab-service nếu có).

### 5.7 Luồng **View Result** (lab đã Completed)

- Link kèm `viewLabRequestId` → modal / overlay đọc `LabResultDetail`.
- File kết quả: **PDF** → hiển thị bằng `iframe` + link mở tab mới; file ảnh cũ (legacy) vẫn có thể hiển thị `<img>` nếu URL không kết thúc `.pdf`.

---

## 6. Phòng xét nghiệm: tải kết quả (PDF)

| Mục | Đặc tả |
|-----|--------|
| Màn hình | `lab/labqueue.jsp` – panel **Result Entry** |
| Input | `resultNote` (bắt buộc), file part `labPdf` |
| Định dạng | **Chỉ PDF** (`application/pdf` hoặc tên `.pdf`); từ chối ảnh |
| Lưu trữ | `/uploads/lab-results/lab-{requestId}-{timestamp}.pdf` |
| Phục vụ file | `UploadsLabResultsServlet` – `Content-Type: application/pdf` cho `.pdf` |
| Thông báo | Notify veterinarian khi upload thành công |

---

## 7. Thông báo (Notifications)

- Trung tâm thông báo / dropdown / poll servlet (theo triển khai).
- Sự kiện tiêu biểu: lab mới, lab xong, billing cần xác nhận, v.v.

---

## 8. Bảng ràng buộc dữ liệu mẫu (cấu hình / tham số)

Dùng cho bảng cấu hình generic (ví dụ settings key-value). **Điều chỉnh theo DB thực tế** nếu bảng khác tên.

| Field | Mô tả / kiểu & độ dài |
|-------|------------------------|
| **Name** | Chuỗi **không chứa chữ số** (non-digit string), tối đa **20** ký tự |
| **Type** | Giá trị khởi tạo: tên các setting đang active; cho phép null/blank |
| **Value** | Chuỗi bất kỳ, tối đa **100** ký tự |
| **Priority** | Số nguyên **dương** |
| **Description** | Chuỗi bất kỳ, tối đa **200** ký tự |

> Ghi chú: Nếu hệ thống không có bảng settings riêng, phần này là **chuẩn thiết kế** cho module cấu hình tương lai.

---

## 9. Yêu cầu phi chức năng (tóm tắt)

| Hạng mục | Nội dung |
|----------|----------|
| Xác thực | Session; phân quyền theo role; HTTPS khuyến nghị production |
| Upload | Giới hạn kích thước multipart (ví dụ lab PDF max ~10MB theo `@MultipartConfig`) |
| Bảo mật | Không truy cập file ngoài thư mục upload (path traversal) – servlet lab results kiểm tra path |
| Log / debug | Một số util ghi log tùy JVM flag (ví dụ profile picture debug) |

---

## 10. Phụ lục: URL servlet chính (tham chiếu triển khai)

| Module | URL patterns (một phần) |
|--------|-------------------------|
| Auth | `/login`, `/logout`, `/register`, `/auth/google`, forgot/reset password |
| Customer | `/customer/*`, pets, appointments, medical records |
| Receptionist | `/receptionist/*`, staff queue, check-in |
| Vet | `/vet/queue`, `/vet/examination`, `/vet/lab-request`, medical records |
| Lab | `/lab/labqueue`, `/lab/result` |
| Admin | `/admin/*` users, services, blog |
| Common | `/notifications/*`, `/uploads/*` |

---

**Hết tài liệu RDS (Markdown).**  
Để có file **Word (.docx)**: mở file `.md` bằng Microsoft Word (*Open* → chọn file) và *Save As* → **Word Document (.docx)**, hoặc dùng Pandoc:  
`pandoc RDS_Anipats_Veterinary_Clinic_Management_System.md -o RDS_Anipats.docx`
