## Notifications flow – Technical walkthrough

File này giải thích chi tiết **luồng notification** mới (assign vet, lab request, lab result, billing) + cách dropdown / notification center hoạt động.

Các vai trò chính:
- **Receptionist**
- **Veterinarian (Vet)**
- **Lab Staff**

---

### 1. Cấu trúc dữ liệu & DAO

#### 1.1 Bảng `Notifications`

- **Cột chính** (theo `seed_data.sql`):
  - `notification_id` (PK, identity)
  - `user_id` – khóa ngoại tới `Users.user_id` (ai là người nhận)
  - `title` – tiêu đề ngắn (vd: `"Lab result completed"`)
  - `message` – nội dung chi tiết
  - `created_at` – thời gian tạo (mặc định `GETDATE()` trong DB)

> Hiện chưa dùng cột `is_read`. Trong model có field `read` nhưng luôn `false`.

#### 1.2 Model `Notification`

- **File**: `src/java/model/Notification.java`
- Trường:
  - `notificationId`, `userId`, `title`, `message`, `createdAt`, `read`.
- Dùng cho cả dropdown và notification center.

#### 1.3 `NotificationDAO`

- **File**: `src/java/dao/NotificationDAO.java`

- **Tạo notification cho 1 user:**
  - **Method**: `public boolean create(int userId, String title, String message)`
  - SQL:
    - `INSERT INTO Notifications (user_id, title, message) VALUES (?, ?, ?)`
  - Dùng khi đã biết chính xác `user_id` (ví dụ vet cụ thể).

- **Tạo notification cho cả 1 role:**
  - **Method**: `public int createForRole(String roleName, String title, String message)`
  - Bước:
    1. Gọi `getUserIdsByRoleName(roleName)`:
       - `SELECT u.user_id FROM Users u JOIN Roles r ON u.role_id = r.role_id WHERE r.role_name = ?`
    2. Lặp qua tất cả `user_id` → gọi `create(userId, title, message)`.
  - Trả về số bản ghi insert thành công.
  - Dùng cho các thông báo broadcast: notify tất cả `LabStaff`, tất cả `Receptionist`.

- **Đọc notification cho 1 user (top N):**
  - **Method**: `public List<Notification> getRecentForUser(int userId, int limit)`
  - SQL (SQL Server):
    ```sql
    SELECT TOP (limit) notification_id, user_id, title, message, created_at
    FROM Notifications
    WHERE user_id = ?
    ORDER BY created_at DESC, notification_id DESC
    ```
  - Map sang `Notification`:
    - `created_at` → `LocalDateTime` qua `Timestamp.toLocalDateTime()`.
    - `read` luôn `false` (chưa tracking read/unread).
  - Được dùng bởi:
    - Dropdown (poll API `/notifications/poll`)
    - `NotificationCenterServlet` (`/notifications`)
    - Một số servlet vet/lab/receptionist để preload khi render JSP (fallback nếu JS chưa chạy).

---

### 2. Trigger notification theo flow

#### 2.1 Assign Veterinarian – **Notify Assigned Vet**

- **Servlet**: `controller.receptionist.UpdateAppointmentDoctorServlet`
- **URL**: `POST /Receptionist/UpdateAppointmentDoctor` (AJAX từ ViewListAppointment).
- **Luồng:**
  1. Nhận `appointmentId`, `veterinarianId`.
  2. Gọi `AppointmentDAO.updateAppointmentDoctor(appointmentId, veterinarianId)`.
  3. Nếu update thành công:
     - Map `veterinarian_id -> user_id`:
       - `vetUserId = AppointmentDAO.getUserIdByVeterinarianId(veterinarianId)`.
     - Tạo notification:
       ```java
       ndao.create(
           vetUserId,
           "Appointment assigned",
           "You have been assigned to appointment #" + appointmentId + "."
       );
       ```
  4. Trả JSON `{ success: true/false, message: ... }` cho front-end.

- **Ai nhận?**
  - Vet có `user_id = vetUserId` tương ứng với `veterinarian_id` vừa được gán.
  - Khi vet login (Dr Sarah Smithe, …), dropdown sẽ load đúng các bản ghi có `user_id` của vet đó.

#### 2.2 Vet tạo Lab Request – **Notify Lab Technician**

- **Servlet**: `controller.vet.VetLabRequestServlet`
- **URL**: `POST /vet/lab-request`
- **Luồng (phần liên quan notification):**
  1. Vet đang trong màn `examination.jsp` gửi form với `appointmentId`, `testId`.
  2. Servlet validate:
     - Session, `currentUser` là Vet.
     - `appointmentId` thuộc đúng vet (`AppointmentDAO.getVeterinarianIdByUserId(user.getUserId())`).
     - `Visit` đã tồn tại (đã check-in).
  3. Tạo lab request:
     - `labDao.createRequest(visit.getVisitId(), testId, visit.getVeterinarianId())`.
  4. Tạo notification cho tất cả lab staff:
     ```java
     NotificationDAO ndao = new NotificationDAO();
     ndao.createForRole(
         "LabStaff",
         "New lab request",
         "A new lab request was created for visit #" + visit.getVisitId() + " (testId=" + testId + ")."
     );
     ```

- **Ai nhận?**
  - Tất cả user có `Roles.role_name = 'LabStaff'`.
  - Khi login lab (`lab@anipats.com`), dropdown ở `/lab/dashboard` tự động poll và hiển thị các request mới.

#### 2.3 Lab upload result – **Notify Veterinarian (Lab Result Completed)**

- **Servlet**: `controller.lab.LabUploadResultServlet`
- **URL**: `POST /lab/result` (form Submit trên `lab/dashboard.jsp`).
- **Luồng:**
  1. Lab staff login, gửi form với `requestId`, `resultValue`, `resultNote`, `techNotes`.
  2. Validate:
     - Session, `currentUser` là LabStaff, map qua `LabTestRequestDAO.getLabStaffIdByUserId(user.getUserId())`.
  3. Ghi kết quả:
     - `dao.saveResult(requestId, resultValue, resultNote, labStaffId)`:
       - Insert `LabTestResults`.
       - Đổi `LabTestRequests.status = 'Completed'`.
  4. Tạo notification cho vet:
     ```java
     LabTestRequest req = dao.getById(requestId);
     if (req != null && req.getVeterinarianId() > 0) {
         AppointmentDAO appDao = new AppointmentDAO();
         int vetUserId = appDao.getUserIdByVeterinarianId(req.getVeterinarianId());
         if (vetUserId > 0) {
             NotificationDAO ndao = new NotificationDAO();
             String testName = req.getTestName() != null ? req.getTestName() : "Lab test";
             ndao.create(
                 vetUserId,
                 "Lab result completed",
                 testName + " result has been uploaded for request #" + requestId + "."
             );
         }
     }
     ```

- **Ai nhận?**
  - Vet gắn với `LabTestRequests.veterinarian_id` của request đó.
  - Trên UI vet (`/vet/dashboard`, `/vet/queue`, `/vet/examination`), dropdown poll `/notifications/poll` nên sẽ thấy dòng “Lab result completed” nhảy vào **mà không cần reload trang** (tối đa delay ~10s tùy interval).

#### 2.4 Vet hoàn tất khám – **Notify Receptionist for Billing**

- **Servlet**: `controller.vet.VetExaminationServlet`
- **URL**: `POST /vet/examination` với `action=complete`.
- **Luồng liên quan billing & notification:**
  1. Sau khi vet điền diagnosis, services, prescriptions:
  2. Khi `action = "complete"`:
     - `visitDao.completeVisit(visit.getVisitId());`
     - `appDao.updateAppointmentStatus(appointmentId, "Completed");`
     - Tính tổng tiền từ `RecordServiceLine` và tạo invoice (`InvoiceDAO.create` + `addItem`).
  3. Gửi notification cho tất cả receptionist:
     ```java
     NotificationDAO ndao = new NotificationDAO();
     ndao.createForRole(
         "Receptionist",
         "Billing confirmation needed",
         "Appointment #" + appointmentId + " has been completed by the veterinarian. Please confirm payment."
     );
     ```
  4. Redirect vet về `/vet/queue?completed=1`.

- **Ai nhận?**
  - Tất cả `Users` có `Roles.role_name = 'Receptionist'`.
  - Khi receptionist mở `/Receptionist/ViewListAppointment`, dropdown load/poll sẽ hiển thị notif billing.

---

### 3. Dropdown notifications (realtime nhẹ, không reload trang)

#### 3.1 Fragment JSP `notifications-dropdown.jsp`

- **File**: `web/WEB-INF/includes/notifications-dropdown.jsp`
- Được include vào các header:
  - Vet: `vet/dashboard.jsp`, `vet/patients-queue.jsp`, `vet/examination.jsp`
  - Lab: `lab/dashboard.jsp`
  - Receptionist: `Receptionist/ViewListAppointment.jsp`
- Biến đầu vào:
  - `notifications` – list từ server (thường được set sẵn ở servlet, nhưng không bắt buộc vì JS sẽ poll).
  - `notificationTimeFmt` – `DateTimeFormatter` dùng cho render ban đầu.

- HTML chính:
  - Nút chuông:
    - Badge đỏ nếu `hasUnread` (hiện tại = tồn tại bất kỳ `Notification` nào – chưa phân read/unread thật).
  - Dropdown panel:
    - Header: “Notifications”, `X items`.
    - Body: list các item trong `#notif-items`.
    - Footer: link `View notification center` → `/notifications`.

- JS trong fragment:
  - Toggle show/hide dropdown khi click chuông.
  - Hàm `renderNotifications(data)`:
    - Render danh sách JSON `{ id, title, message, time }` vào `#notif-items`.
    - Cập nhật `#notif-count`.

#### 3.2 Poll API `/notifications/poll`

- **Servlet**: `controller.common.NotificationPollServlet`
- **URL**: `GET /notifications/poll`
- **Luồng:**
  1. Lấy `currentUser` từ session; nếu không có, trả `[]`.
  2. `dao.getRecentForUser(user.getUserId(), 3)` – luôn chỉ lấy **3 notification gần nhất** cho dropdown.
  3. Serialize JSON array:
     ```json
     [
       { "id": 12, "title": "Lab result completed", "message": "...", "time": "Mar 05, 11:10" },
       ...
     ]
     ```

- **JS ở dropdown**:
  - Lấy `baseUrl` từ `data-base-url="<%= notifCtx %>"`.
  - Tạo `pollUrl = base + "/notifications/poll"`.
  - Gọi:
    ```javascript
    async function poll() {
      const res = await fetch(pollUrl, { headers: { 'Accept': 'application/json' } });
      const data = await res.json();
      renderNotifications(data);
    }
    poll();
    setInterval(poll, 10000); // 10s
    ```
  - Kết quả: **không cần F5 trang**, khi backend tạo mới 1 notification (assign vet, lab request, lab result, billing), sau tối đa ~10s dropdown sẽ tự sync 3 bản ghi mới nhất.

---

### 4. Notification Center (full lịch sử)

#### 4.1 Servlet `NotificationCenterServlet`

- **File**: `src/java/controller/common/NotificationCenterServlet.java`
- **URL**: `GET /notifications`
- **Luồng:**
  1. Check `currentUser` trong session.
  2. Lấy `notifications = dao.getRecentForUser(user.getUserId(), 50)` (nhiều hơn dropdown).
  3. Set:
     - `user`, `notifications`
     - `notificationTimeFmt` (`MMM dd, HH:mm`)
  4. Forward tới view: `web/WEB-INF/views/common/notifications.jsp`.

#### 4.2 View `notifications.jsp`

- **File**: `web/WEB-INF/views/common/notifications.jsp`
- Dùng HTML bạn cung cấp cho Notification Center:
  - Header với logo Anipats, topbar, search.
  - Content: list các notification của user hiện tại, chỉ khác là **data lấy từ DB**, không phải mock cứng.
  - Nếu không có thông báo:
    - Hiển thị card “You have no notifications yet.”

---

### 5. Ghi chú & cách debug nhanh

- **Kiểm tra dữ liệu thô trong DB:**
  ```sql
  SELECT TOP 50 notification_id, user_id, title, message, created_at
  FROM Notifications
  ORDER BY notification_id DESC;
  ```
- **Xem notification cho 1 user cụ thể (vd Dr Sarah Smithe – `user_id = 3`):**
  ```sql
  SELECT TOP 20 notification_id, title, message, created_at
  FROM Notifications
  WHERE user_id = 3
  ORDER BY created_at DESC, notification_id DESC;
  ```
- Nếu DB đã có dòng đúng `user_id` mà dropdown không hiện:
  - Kiểm tra session: `currentUser.userId` có đúng với `user_id` đó không.
  - Check JS `fetch('/notifications/poll')` trong DevTools → xem JSON trả về.

