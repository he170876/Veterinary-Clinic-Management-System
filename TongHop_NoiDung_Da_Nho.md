# Anipats — Danh sách kiểm thử hệ thống

Tài liệu bám **bố cục sheet kiểm thử** (Workflow, yêu cầu, số lượng case, tổng hợp theo vòng, nhóm **Scenario**, bảng chi tiết).  
**Toàn bộ nội dung diễn đạt bằng tiếng Việt** theo phong cách mô tả nghiệp vụ (không nhúng mã lệnh, tên lớp hay đường dẫn kỹ thuật).

---

## Phần đầu (thông tin chung & tổng hợp theo vòng)

| Hạng mục | Nội dung |
|----------|----------|
| **Workflow** | Quy trình nghiệp vụ Anipats: hồ sơ & ảnh đại diện, lễ tân, chủ phòng khám, đổi mật khẩu, phân quyền, đồng bộ dữ liệu, **khám bệnh — xét nghiệm — hàng đợi bác sĩ**. |
| **Yêu cầu kiểm thử** | Xác minh đúng luồng nghiệp vụ và trải nghiệm người dùng trên ứng dụng quản lý phòng khám thú y; bao gồm các tình huống thành công, từ chối hợp lệ, và phân quyền. |
| **Số lượng test case** | **43** |

### Tổng hợp theo vòng kiểm thử

| Vòng | Đạt | Không đạt | Chưa chạy | Không áp dụng |
|------|-----|-----------|-----------|----------------|
| Vòng 1 | 0 | 0 | 43 | 0 |
| Vòng 2 | 0 | 0 | 43 | 0 |
| Vòng 3 | 0 | 0 | 43 | 0 |

*Khi thực hiện test: cập nhật số liệu Đạt / Không đạt / Chưa chạy; ở bảng chi tiết điền ngày và người thực hiện từng vòng.*

---

## Chi tiết test case theo Scenario

### Scenario A — Ảnh đại diện & cập nhật hồ sơ

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-PFP-01</td>
<td>Bác sĩ tải ảnh đại diện định dạng JPG hợp lệ và lưu hồ sơ thành công.</td>
<td>1. Đăng nhập bằng tài khoản Bác sĩ thú y.<br/>2. Vào mục Hồ sơ của tôi, chọn Chỉnh sửa hồ sơ.<br/>3. Chọn ảnh JPG có dung lượng trong giới hạn cho phép (không vượt quá mức tối đa), dùng nút chọn ảnh.<br/>4. Bấm Lưu thay đổi.</td>
<td>Hệ thống lưu thành công; ảnh đại diện hiển thị đúng trên trang hồ sơ; thông tin lưu trữ ảnh trên hệ thống được cập nhật tương ứng.</td>
<td>Tài khoản bác sĩ đang hoạt động; file ảnh đúng định dạng và trong giới hạn dung lượng.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-PFP-02</td>
<td>Người dùng các vai trò (khách, quản trị, xét nghiệm, lễ tân) tải ảnh PNG / GIF / WebP hợp lệ khi chỉnh sửa hồ sơ.</td>
<td>1. Đăng nhập theo từng vai trò được hỗ trợ chỉnh sửa hồ sơ.<br/>2. Mở màn hình Chỉnh sửa hồ sơ.<br/>3. Chọn ảnh PNG, GIF hoặc WebP trong giới hạn dung lượng.<br/>4. Lưu thay đổi.</td>
<td>Ảnh được lưu; hồ sơ cập nhật đường dẫn ảnh; ảnh hiển thị trên trang hồ sơ và (nếu có) khu vực đầu trang.</td>
<td>Tài khoản có quyền truy cập trang chỉnh sửa hồ sơ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-PFP-03</td>
<td>Từ chối tải lên khi file ảnh vượt quá dung lượng cho phép.</td>
<td>1. Mở Chỉnh sửa hồ sơ.<br/>2. Chọn một file ảnh có dung lượng lớn hơn mức tối đa cho phép.<br/>3. Thử lưu.</td>
<td>Hệ thống báo lỗi hoặc không chấp nhận tải lên; đường dẫn ảnh trên hồ sơ không đổi (hoặc không tạo file lưu trữ mới không hợp lệ).</td>
<td>Đã cấu hình giới hạn dung lượng tải lên theo quy định hệ thống.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-PFP-04</td>
<td>Từ chối file không phải ảnh hoặc định dạng không được hỗ trợ.</td>
<td>1. Mở Chỉnh sửa hồ sơ.<br/>2. Chọn file không phải ảnh hoặc loại không nằm trong danh sách cho phép.<br/>3. Lưu.</td>
<td>Không lưu đường dẫn ảnh hợp lệ; hệ thống có thể ghi nhận từ chối theo quy tắc kiểm tra loại file.</td>
<td>—</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-PFP-05</td>
<td>Chỉ cập nhật họ tên / số điện thoại / địa chỉ mà không chọn ảnh mới.</td>
<td>1. Mở Chỉnh sửa hồ sơ.<br/>2. Sửa các trường thông tin chữ; không thay đổi ô chọn ảnh.<br/>3. Lưu.</td>
<td>Các trường thông tin được cập nhật; ảnh đại diện hiện tại giữ nguyên.</td>
<td>Người dùng đã tồn tại trên hệ thống.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Hồi quy</td>
</tr>
<tr>
<td>TC-PFP-06</td>
<td>Tải ảnh mới thay thế ảnh đại diện cũ.</td>
<td>1. Người dùng đã có ảnh đại diện.<br/>2. Chọn ảnh mới và lưu.</td>
<td>Ảnh mới được lưu; ảnh cũ được xử lý theo quy tắc (ví dụ thay thế); hồ sơ hiển thị ảnh mới.</td>
<td>Đã có ảnh đại diện trước đó.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-PFP-07</td>
<td>Khi trong hệ thống lưu sẵn đường dẫn ảnh không hợp lệ (ví dụ định dạng đường dẫn máy trạm), giao diện không hiển thị sai.</td>
<td>1. (Thiết lập kiểm thử) Gán giá trị đường dẫn ảnh không hợp lệ cho hồ sơ.<br/>2. Đăng nhập và tải lại trang hồ sơ / đầu trang.</td>
<td>Hệ thống bỏ qua đường dẫn không hợp lệ; hiển thị chữ cái đầu hoặc trạng thái mặc định, không hiện chuỗi đường dẫn lỗi.</td>
<td>Môi trường cho phép thiết lập dữ liệu thử.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Biên / an toàn</td>
</tr>
<tr>
<td>TC-PFP-08</td>
<td>Trình duyệt mở được ảnh đại diện đã lưu qua đường dẫn công khai hợp lệ.</td>
<td>1. Sau khi tải ảnh thành công, ghi nhận đường dẫn hiển thị ảnh.<br/>2. Mở đường dẫn đó trên trình duyệt (cùng ứng dụng).</td>
<td>Trình duyệt nhận được nội dung ảnh; loại nội dung phù hợp với ảnh.</td>
<td>File ảnh tồn tại trên máy chủ theo cấu hình lưu trữ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-PFP-09</td>
<td>Sau khi đổi ảnh, phiên làm việc hiển thị ảnh mới không cần đăng nhập lại.</td>
<td>1. Lưu ảnh đại diện mới.<br/>2. Chuyển sang trang hồ sơ hoặc khu vực hiển thị avatar mà không đăng xuất.</td>
<td>Thông tin người dùng trong phiên phản ánh ảnh và thời gian cập nhật mới.</td>
<td>Đang đăng nhập.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
</tbody></table>

### Scenario B — Chỉnh sửa thông tin cá nhân

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-EP-01</td>
<td>Kiểm tra ràng buộc họ tên (bắt buộc, ký tự hợp lệ).</td>
<td>1. Mở Chỉnh sửa hồ sơ.<br/>2. Xóa họ tên hoặc nhập ký tự không cho phép.<br/>3. Lưu.</td>
<td>Hệ thống báo lỗi xác thực; không lưu dữ liệu sai.</td>
<td>—</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EP-02</td>
<td>Kiểm tra định dạng số điện thoại (10 số, bắt đầu bằng 0).</td>
<td>1. Nhập số điện thoại không đúng quy tắc.<br/>2. Lưu.</td>
<td>Thông báo lỗi định dạng số điện thoại.</td>
<td>—</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EP-03</td>
<td>Giới hạn độ dài địa chỉ.</td>
<td>1. Nhập địa chỉ vượt quá giới hạn ký tự cho phép.<br/>2. Lưu.</td>
<td>Hệ thống báo lỗi; không lưu vượt quá.</td>
<td>—</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EP-04</td>
<td>Email chỉ đọc, không đổi được qua biểu mẫu (nếu thiết kế như vậy).</td>
<td>1. Mở Chỉnh sửa hồ sơ.<br/>2. Thử thay đổi email (nếu ô bị khóa hoặc không gửi được).</td>
<td>Email trong cơ sở dữ liệu không đổi theo thao tác không được phép.</td>
<td>—</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
</tbody></table>

### Scenario C — Lễ tân: giao diện hồ sơ

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-RS-01</td>
<td>Giao diện chỉnh sửa hồ sơ của Lễ tân thống nhất với Bác sĩ (menu, thẻ nội dung, nút chọn ảnh).</td>
<td>1. Đăng nhập vai trò Lễ tân.<br/>2. Mở Chỉnh sửa hồ sơ.</td>
<td>Hiển thị bố cục thương hiệu thống nhất; đường dẫn điều hướng rõ ràng; có điều khiển chọn ảnh thân thiện (không chỉ ô tải file thô).</td>
<td>Tài khoản lễ tân hoạt động.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Giao diện / hồi quy</td>
</tr>
<tr>
<td>TC-RS-02</td>
<td>Khi hệ thống yêu cầu bổ sung số điện thoại, lễ tân thấy thông báo và phải nhập đủ trước khi tiếp tục.</td>
<td>1. Phiên làm việc đang trong trạng thái cần bổ sung số điện thoại (theo luồng nghiệp vụ).<br/>2. Mở trang chỉnh sửa hồ sơ với tham số yêu cầu số điện thoại (nếu có).<br/>3. Nhập số hợp lệ và lưu.</td>
<td>Có thông báo/banner hướng dẫn; sau khi lưu thành công, trạng thái chờ số điện thoại được xử lý và chuyển trang theo quy tắc.</td>
<td>Luồng bắt buộc số điện thoại được bật trong phiên.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Nghiệp vụ</td>
</tr>
</tbody></table>

### Scenario D — Chủ phòng khám / Quản trị: thanh điều hướng

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-OW-01</td>
<td>Khu vực chủ phòng khám / quản trị hiển thị ảnh đại diện đã cập nhật trên thanh điều hướng.</td>
<td>1. Đăng nhập vai trò chủ phòng khám hoặc quản trị tại các màn hình có thanh đầu trang.<br/>2. Cập nhật ảnh hồ sơ trong phần quản lý tài khoản.<br/>3. Quay lại trang có thanh điều hướng.</td>
<td>Vòng tròn avatar hiển thị ảnh người dùng đã tải, không cố định ảnh mặc định ngoài thiết kế.</td>
<td>Đã đặt ảnh đại diện cho tài khoản.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-OW-02</td>
<td>Khi chưa có ảnh đại diện, thanh điều hướng hiển thị chữ cái đầu tên.</td>
<td>1. Tài khoản không có ảnh đại diện trong hồ sơ.<br/>2. Mở trang có thanh điều hướng.</td>
<td>Hiển thị avatar dạng chữ cái đầu (hoặc ký hiệu mặc định an toàn).</td>
<td>Hồ sơ không có ảnh.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
</tbody></table>

### Scenario E — Đổi mật khẩu

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-PW-01</td>
<td>Đổi mật khẩu thành công khi nhập đúng mật khẩu hiện tại và mật khẩu mới đạt quy tắc.</td>
<td>1. Vào Hồ sơ &gt; Đổi mật khẩu.<br/>2. Nhập đúng mật khẩu hiện tại.<br/>3. Mật khẩu mới và xác nhận giống nhau, có chữ hoa và số, độ dài trong khoảng cho phép (ví dụ dạng hợp lệ: mật khẩu có chữ hoa và số).<br/>4. Gửi biểu mẫu.</td>
<td>Hệ thống xác nhận đổi thành công; đăng nhập lại bằng mật khẩu mới được.</td>
<td>Tài khoản đăng nhập bằng mật khẩu cục bộ (không phải tài khoản chỉ đăng nhập mạng xã hội).</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-PW-02</td>
<td>Từ chối mật khẩu mới không có chữ in hoa.</td>
<td>1. Nhập mật khẩu mới toàn chữ thường và số, thiếu chữ hoa.<br/>2. Gửi.</td>
<td>Báo lỗi theo quy tắc: độ dài cho phép, có ít nhất một chữ hoa và một chữ số.</td>
<td>—</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-PW-03</td>
<td>Từ chối khi mật khẩu hiện tại nhập sai.</td>
<td>1. Nhập sai mật khẩu hiện tại.<br/>2. Nhập mật khẩu mới hợp lệ và gửi.</td>
<td>Thông báo mật khẩu hiện tại không đúng.</td>
<td>Biết mật khẩu thật để đối chiếu.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-PW-04</td>
<td>Từ chối khi mật khẩu mới và xác nhận không khớp.</td>
<td>1. Hai ô mật khẩu mới và xác nhận khác nhau.<br/>2. Gửi.</td>
<td>Báo lỗi hai mật khẩu không trùng.</td>
<td>—</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-PW-05</td>
<td>Tài khoản chỉ đăng nhập qua nhà cung cấp bên ngoài không đổi mật khẩu cục bộ.</td>
<td>1. Đăng nhập bằng tài khoản liên kết bên ngoài.<br/>2. Thử mở đổi mật khẩu (nếu có).</td>
<td>Không cho phép hoặc thông báo không áp dụng đổi mật khẩu cục bộ.</td>
<td>Tài khoản được đánh dấu đăng nhập qua nhà cung cấp bên ngoài.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
</tbody></table>

### Scenario F — Đồng bộ dữ liệu ảnh trên hồ sơ người dùng

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-DB-01</td>
<td>Sau khi đổi ảnh, bản ghi người dùng trong cơ sở dữ liệu lưu đúng đường dẫn ảnh.</td>
<td>1. Thực hiện đổi ảnh đại diện thành công trên giao diện.<br/>2. Kiểm tra trên cơ sở dữ liệu giá trị đường dẫn ảnh của người dùng.</td>
<td>Cột đường dẫn ảnh khớp với đường dẫn lưu trữ hợp lệ trên hệ thống.</td>
<td>Quyền truy vấn cơ sở dữ liệu kiểm thử.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích hợp</td>
</tr>
</tbody></table>

### Scenario G — Phân quyền theo vai trò

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-AC-01</td>
<td>Người dùng sai vai trò không truy cập được khu vực dành cho Bác sĩ.</td>
<td>1. Đăng nhập vai trò Khách hàng.<br/>2. Thử mở trang bảng điều khiển hoặc đường dẫn dành cho bác sĩ bằng tay (nhập địa chỉ trực tiếp).</td>
<td>Hệ thống từ chối hoặc chuyển về trang đăng nhập / thông báo không có quyền theo thiết kế.</td>
<td>—</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>An toàn</td>
</tr>
<tr>
<td>TC-AC-02</td>
<td>Bác sĩ truy cập bình thường các màn hình thuộc phần dành cho bác sĩ.</td>
<td>1. Đăng nhập tài khoản Bác sĩ thú y.<br/>2. Mở các trang nghiệp vụ bác sĩ.</td>
<td>Trang tải thành công, hiển thị nội dung đúng vai trò.</td>
<td>Tài khoản có vai trò bác sĩ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
</tbody></table>

### Scenario H — Quy trình tài liệu kiểm thử

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-REG-01</td>
<td>Nhập danh sách test case từ bảng tính vào mẫu tài liệu kiểm thử hệ thống.</td>
<td>1. Mở file danh sách test case dạng bảng.<br/>2. Sao chép các dòng vào đúng sheet quy trình trong mẫu tài liệu kiểm thử.</td>
<td>Dữ liệu khớp phạm vi dự án; cột và số lượng test case nhất quán.</td>
<td>Có file mẫu tài liệu kiểm thử hệ thống.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Quy trình</td>
</tr>
</tbody></table>

### Scenario I — Khám bệnh, xét nghiệm & hàng đợi bác sĩ

<table>
<thead>
<tr>
<th>Mã test case</th>
<th>Mô tả test case</th>
<th>Các bước thực hiện</th>
<th>Kết quả mong đợi</th>
<th>Điều kiện trước khi test</th>
<th>Minh chứng</th>
<th>Round 1</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 2</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Round 3</th>
<th>Ngày test</th>
<th>Người test</th>
<th>Ghi chú / Loại</th>
</tr>
</thead>
<tbody>
<tr>
<td>TC-EX-01</td>
<td>Mở màn hình khám khi không có mã lịch hẹn hoặc mã không hợp lệ.</td>
<td>1. Đăng nhập bác sĩ.<br/>2. Thử mở màn khám mà không chọn mã lịch, hoặc nhập mã không phải số.</td>
<td>Hệ thống không mở form khám; quay về danh sách hàng đợi bác sĩ.</td>
<td>Đang đăng nhập bác sĩ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EX-02</td>
<td>Mở màn khám với mã lịch không tồn tại.</td>
<td>1. Đăng nhập bác sĩ.<br/>2. Mở màn khám với mã lịch không có trong hệ thống.</td>
<td>Thông báo không tìm thấy lịch; quay về hàng đợi với thông báo lỗi phù hợp.</td>
<td>Đang đăng nhập bác sĩ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EX-03</td>
<td>Tài khoản không gắn với hồ sơ bác sĩ không mở được màn khám.</td>
<td>1. Đăng nhập tài khoản không được gán vai trò bác sĩ trong dữ liệu nội bộ.<br/>2. Thử mở màn khám cho một lịch hợp lệ.</td>
<td>Từ chối truy cập; quay về hàng đợi với thông báo không được phép.</td>
<td>Tài khoản không liên kết bác sĩ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>An toàn</td>
</tr>
<tr>
<td>TC-EX-04</td>
<td>Lịch không ở trạng thái cho phép bắt đầu khám (chưa check-in hoặc không đúng bước).</td>
<td>1. Chọn lịch không ở trạng thái “đã check-in” hoặc “đang khám” theo quy định.<br/>2. Thử mở màn khám.</td>
<td>Không mở form; thông báo trạng thái không hợp lệ; quay về hàng đợi.</td>
<td>Có lịch ở trạng thái không phù hợp.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EX-05</td>
<td>Lịch đã được bác sĩ khác tiếp nhận khám.</td>
<td>1. Bác sĩ A đã tiếp nhận ca khám.<br/>2. Đăng nhập bác sĩ B và thử mở cùng lịch đó.</td>
<td>Không cho mở; thông báo ca đã bị khóa / thuộc bác sĩ khác.</td>
<td>Hai tài khoản bác sĩ và một lịch đã được nhận.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EX-06</td>
<td>Bác sĩ đang có một ca khám chưa kết thúc thì mở thêm ca khác.</td>
<td>1. Bác sĩ đang có lịch ở trạng thái đang khám.<br/>2. Thử mở màn khám cho lịch khác đủ điều kiện.</td>
<td>Hệ thống báo bận; không mở màn hình khám thứ hai.</td>
<td>Hai lịch hợp lệ; một ca đang mở.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EX-07</td>
<td>Mở màn khám hợp lệ: hiển thị đầy đủ thông tin lượt khám.</td>
<td>1. Có lịch đúng trạng thái và đúng bác sĩ.<br/>2. Mở màn khám từ hàng đợi hoặc đường dẫn hợp lệ.</td>
<td>Form khám hiển thị: thông tin lượt khám, dịch vụ, đơn thuốc, khu vực xét nghiệm (nếu có).</td>
<td>Lịch ở trạng thái cho phép và thuộc bác sĩ đang đăng nhập.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-EX-10</td>
<td>Lưu nháp thông tin khám chưa hoàn tất lượt khám.</td>
<td>1. Trên màn khám, điền hoặc sửa chẩn đoán, dịch vụ, đơn thuốc.<br/>2. Chọn thao tác lưu tạm (không hoàn tất lượt khám).</td>
<td>Dữ liệu được lưu; vẫn ở màn hình khám hoặc quay lại cùng lượt khám để tiếp tục.</td>
<td>Đang ở màn khám hợp lệ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-EX-11</td>
<td>Hoàn tất lượt khám khi đủ điều kiện nghiệp vụ.</td>
<td>1. Nhập đủ chẩn đoán, ít nhất một dịch vụ, thông tin đơn thuốc hợp lệ (nếu có).<br/>2. Chọn hoàn tất lượt khám.</td>
<td>Lượt khám kết thúc; lịch chuyển trạng thái chờ thanh toán (hoặc tương đương); hóa đơn/phí phát sinh nếu có quy tắc; lễ tân có thể nhận thông báo; quay về hàng đợi với xác nhận hoàn tất.</td>
<td>Dữ liệu nhập đủ theo quy tắc.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực / E2E</td>
</tr>
<tr>
<td>TC-EX-12</td>
<td>Gửi biểu mẫu gắn sai lịch với bác sĩ đang đăng nhập.</td>
<td>1. Ở màn khám, can thiệp gửi kèm mã lịch của ca không thuộc bác sĩ hiện tại (kiểm thử an toàn).</td>
<td>Hệ thống từ chối; quay về hàng đợi.</td>
<td>Đăng nhập bác sĩ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>An toàn</td>
</tr>
<tr>
<td>TC-EX-20</td>
<td>Không cho hoàn tất khi chưa nhập chẩn đoán.</td>
<td>1. Để trống chẩn đoán.<br/>2. Bấm hoàn tất lượt khám.</td>
<td>Hiển thị lỗi; không gửi hoàn tất.</td>
<td>Đang ở màn khám.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EX-21</td>
<td>Không cho hoàn tất khi chưa có dịch vụ nào.</td>
<td>1. Xóa hết dịch vụ đã chọn.<br/>2. Bấm hoàn tất.</td>
<td>Thông báo cần ít nhất một dịch vụ.</td>
<td>Đang ở màn khám.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EX-22</td>
<td>Đơn thuốc: liều lượng hoặc tần suất không hợp lệ.</td>
<td>1. Nhập tên thuốc nhưng liều không phải số hoặc thiếu tần suất.<br/>2. Hoàn tất.</td>
<td>Cảnh báo trên form; không cho hoàn tất.</td>
<td>Đang ở màn khám.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tiêu cực</td>
</tr>
<tr>
<td>TC-EX-23</td>
<td>Cảnh báo khi còn yêu cầu xét nghiệm chưa xong mà hoàn tất lượt khám.</td>
<td>1. Có yêu cầu xét nghiệm đang chờ trên lượt khám.<br/>2. Bấm hoàn tất.</td>
<td>Hiện hộp thoại cảnh báo; có thể cho phép hoàn tất bất chấp (nếu nghiệp vụ cho phép) hoặc yêu cầu xử lý trước.</td>
<td>Có xét nghiệm đang chờ.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Biên</td>
</tr>
<tr>
<td>TC-EX-30</td>
<td>Bắt đầu khám từ hàng đợi (thao tác nhanh trên danh sách).</td>
<td>1. Tại hàng đợi bác sĩ, chọn bắt đầu khám cho lịch hợp lệ.<br/>2. Thử lại với các trường hợp bận, đã bị khóa, hoặc thuộc bác sĩ khác.</td>
<td>Thành công khi hợp lệ; thông báo rõ khi thất bại (bận, khóa, không được phép).</td>
<td>Có dữ liệu hàng đợi.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích hợp</td>
</tr>
<tr>
<td>TC-EX-31</td>
<td>Tạo yêu cầu xét nghiệm từ màn hình khám.</td>
<td>1. Trên màn khám, điền biểu mẫu gửi xét nghiệm và xác nhận.<br/>2. Quay lại màn khám.</td>
<td>Yêu cầu gắn với lượt khám; hiển thị trong phần xét nghiệm của màn khám.</td>
<td>Đang mở màn khám.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
<tr>
<td>TC-EX-32</td>
<td>Xem kết quả xét nghiệm từ màn khám (cửa sổ xem nhanh).</td>
<td>1. Mở lượt khám đã có kết quả xét nghiệm.<br/>2. Dùng chức năng xem kết quả (nút hoặc liên kết trên màn hình).</td>
<td>Hiển thị nội dung kết quả đầy đủ, dễ đọc.</td>
<td>Đã có kết quả xét nghiệm.</td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Pending</td>
<td></td>
<td></td>
<td>Tích cực</td>
</tr>
</tbody></table>

---

## Ghi chú sử dụng tài liệu

- Cột **Round 1 / 2 / 3** mặc định **Pending** (giống dropdown trên Excel); sau khi chạy điền **Passed** / **Failed** hoặc **Đạt** / **Không đạt** theo quy ước nhóm.
- **Minh chứng**: đính kèm ảnh màn hình, mã lỗi hiển thị cho người dùng, hoặc mô tả ngắn hành vi thực tế — không bắt buộc ghi log kỹ thuật dạng mã nguồn.
- Bản song song có cấu trúc cột tương thích Excel nằm tại file dự án: `Anipats_System_Test_Complete.xlsx` (tạo bằng `npm run build-system-test-xlsx`). Tài liệu **.md** này ưu tiên **ngôn ngữ nghiệp vụ**; chi tiết kỹ thuật tra cứu trong mã nguồn khi cần.

