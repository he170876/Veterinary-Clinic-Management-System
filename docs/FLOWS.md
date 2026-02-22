# VCMS – Luồng ứng dụng (Application Flows)

Tài liệu mô tả các luồng chính và quy tắc validate (frontend + backend).

---

## 1. Đăng ký (Register)

- **URL:** `GET/POST /register`
- **Luồng:**
  1. User mở form đăng ký.
  2. Nhập: Họ tên, Email, Số điện thoại (optional), Mật khẩu, Xác nhận mật khẩu.
  3. Frontend validate (pattern, length) → gửi form.
  4. Backend validate lại (ValidationUtil), trim toàn bộ field.
  5. Nếu lỗi: trả về form + thông báo lỗi, giữ lại dữ liệu đã nhập.
  6. Nếu OK: tạo user (Customer), auto login, redirect `/customer/dashboard`.

- **Quy tắc validate:**
  - **Họ tên:** 1–30 ký tự, chỉ chữ cái và dấu cách; trim; không để trống.
  - **Email:** Bắt buộc có `@gmail.com`; trim; không chứa khoảng trắng thừa.
  - **Số điện thoại:** **Bắt buộc**; 10 số, bắt đầu bằng `0`; trim.
  - **Mật khẩu:** Tối thiểu 6 ký tự, ít nhất 1 chữ hoa và 1 chữ số; không khoảng trắng.
  - Mọi trường không được có khoảng trắng đầu/cuối (backend trim và kiểm tra).

---

## 2. Đăng nhập (Login)

- **URL:** `GET/POST /login`
- **Luồng:**
  1. User nhập email + mật khẩu.
  2. Frontend validate format (email @gmail.com, password không trống).
  3. Backend trim, validate email @gmail.com, gọi `AuthService.login`.
  4. Thành công: tạo session, redirect theo role (customer → `/customer/dashboard`, …).
  5. Thất bại: trả về form + "Invalid email or password."

- **Validate:** Email phải @gmail.com; trim; không để trống email/password.

---

## 3. Đăng nhập Google

- **URL:** `GET /google-login` (redirect OAuth hoặc callback)
- **Luồng:**
  1. User bấm "Sign in with Google" → redirect Google.
  2. Google trả code + state → servlet đổi code lấy token, lấy email/name.
  3. Tìm user theo email: có thì login; chưa có thì tạo user mới (Customer) với `is_google_user = 1`, mật khẩu random.
  4. Tạo session, redirect theo role.

- **Lưu ý:** Tài khoản đăng nhập bằng Google **không được đổi mật khẩu** (ẩn chức năng "Change Password" trên giao diện).
- **Số điện thoại bắt buộc:** Nếu user Google chưa có SĐT (tạo mới hoặc cũ nhưng trống), sau khi đăng nhập sẽ bị chuyển tới **Edit Profile** với thông báo "You must add your phone number to continue." và không vào được Dashboard/Profile cho đến khi thêm SĐT hợp lệ (10 số bắt đầu 0). Sau khi lưu SĐT thành công, redirect về Dashboard.

---

## 4. Chỉnh sửa hồ sơ (Edit Profile)

- **URL:** `GET/POST /customer/edit-profile`
- **Luồng:**
  1. Chỉ user đã đăng nhập; GET hiển thị form (Họ tên, SĐT, Email readonly, Địa chỉ, Ảnh đại diện).
  2. User sửa và gửi form (multipart nếu có ảnh).
  3. Backend trim, validate:
     - **Họ tên:** 1–30 ký tự, chỉ chữ và dấu cách.
     - **Số điện thoại:** Nếu nhập thì 10 số, bắt đầu bằng `0`.
  4. Cập nhật DB, cập nhật session, redirect `/customer/profile?updated=1`.

- **Validate:** Giống register cho name/phone; mọi giá trị trim trước khi lưu.

---

## 5. Đổi mật khẩu (Change Password)

- **URL:** `POST /customer/change-password`
- **Luồng:**
  1. Chỉ hiển thị khi user **không** phải tài khoản Google (`is_google_user = 0`).
  2. User nhập mật khẩu hiện tại, mật khẩu mới, xác nhận mật khẩu mới.
  3. Backend validate mật khẩu mới (1 chữ hoa + 1 số, min 6 ký tự), kiểm tra mật khẩu hiện tại, cập nhật DB.

- **Tài khoản Google:** Không hiện nút/ form "Change Password".

---

## 6. Xác thực tài khoản (Account Verification)

- **Ý tưởng:** Sau khi đăng ký, gửi email chứa link xác thực; user bấm link → đánh dấu `email_verified = 1`.
- **Hiện trạng:** Có thể mở rộng sau (thêm cột `email_verified`, bảng token, gửi mail). Luồng đăng ký hiện tại vẫn cho phép đăng nhập ngay.

---

## 7. Thông báo (Notifications)

- **Ý tưởng:** User xem danh sách thông báo, có thể **chỉnh sửa** (đánh dấu đã đọc, xóa, hoặc cập nhật nội dung tùy thiết kế).
- **Hiện trạng:** Có bảng `Notifications` trong DB; phần "notification can edit them" có thể triển khai bằng trang quản lý thông báo (edit/delete/mark read) và dùng chung header/sidebar. Notification có thể edit (nội dung, trạng thái đọc) từ giao diện.

---

## 8. Header / Sidebar chung (Customer)

- **Mục tiêu:** Mọi trang customer (Dashboard, Profile, Edit Profile, v.v.) dùng **cùng một** header và sidebar.
- **Cách làm:** Tạo file include (ví dụ `WEB-INF/includes/customer-sidebar.jsp`) chứa toàn bộ sidebar (và header nếu dùng); các trang customer chỉ cần `<jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>` để giao diện giống hệt nhau.

---

## Tóm tắt quy tắc validate (Frontend + Backend)

| Trường      | Quy tắc |
|------------|---------|
| Mọi trường | Trim; không chấp nhận khoảng trắng đầu/cuối thừa. |
| Họ tên     | 1–30 ký tự, chỉ chữ cái và dấu cách. |
| Mật khẩu   | Min 6 ký tự; ít nhất 1 chữ hoa và 1 chữ số. |
| Số điện thoại | **Bắt buộc** khi đăng ký; 10 chữ số, bắt đầu bằng `0`. Google user chưa có SĐT bắt buộc thêm tại Edit Profile. |
| Email      | Bắt buộc có `@gmail.com` (chỉ Gmail). |

Validate luôn thực hiện cả **frontend** (HTML5/JS) và **backend** (ValidationUtil + servlet).

---

## Cơ sở dữ liệu (Migration)

- **Profile picture:** Chạy `database/add_profile_picture.sql` (thêm cột `profile_picture_url` vào `Users`).
- **Google user:** Chạy `database/add_is_google_user.sql` (thêm cột `is_google_user` vào `Users`) để ẩn "Change Password" cho tài khoản đăng nhập bằng Google.
