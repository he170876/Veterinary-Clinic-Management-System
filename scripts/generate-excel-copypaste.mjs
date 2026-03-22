/**
 * Sinh file CSV (UTF-8 BOM) để mở trực tiếp trong Excel hoặc copy-paste.
 * Cột: Function | TC ID | Test Objective | Test Steps | Expected Results | Preconditions | Status | Date
 * Chạy: npm run build-excel-copypaste
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const OUT = path.join(root, "Anipats_Test_Cases_Excel_CopyPaste.csv");

/** @type {Array<{ fn: string; id: string; obj: string; steps: string; exp: string; pre: string; status?: string; date?: string }>} */
const ROWS = [
  {
    fn: "Function: Hồ sơ & ảnh đại diện (PFP)",
    id: "TC_01",
    obj: "Verify bác sĩ tải ảnh đại diện JPG hợp lệ và ảnh hiển thị đúng trên hồ sơ.",
    steps: `**A. VETERINARIAN**
1. Login as Veterinarian.
2. Open menu "**Hồ sơ**" / "**Tài khoản**" then "**Chỉnh sửa hồ sơ**".
3. Click nút chọn ảnh (camera / upload).
4. Chọn file ảnh JPG dưới mức dung lượng tối đa cho phép.
5. Click "**Lưu**" / "**Lưu thay đổi**".`,
    exp: `1. Màn hình chỉnh sửa hồ sơ hiển thị.
2. Form chỉnh sửa mở đúng.
3. Hộp chọn file hiển thị.
4. Ảnh được chọn, xem trước (nếu có).
5. Thông báo lưu thành công; ảnh đại diện cập nhật trên trang hồ sơ và thanh điều hướng (nếu áp dụng).`,
    pre: `1. Tài khoản bác sĩ hoạt động.
2. Có file JPG hợp lệ, dung lượng trong giới hạn.
3. Internet kết nối ổn định.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Hồ sơ & ảnh đại diện (PFP)",
    id: "TC_02",
    obj: "Verify từ chối file ảnh quá dung lượng; hồ sơ không bị ghi đè sai.",
    steps: `**A. VETERINARIAN** (hoặc vai trò có chỉnh sửa hồ sơ)
1. Mở "**Chỉnh sửa hồ sơ**".
2. Chọn một file ảnh **lớn hơn** mức tối đa cho phép.
3. Click "**Lưu**".`,
    exp: `1. Form hiển thị.
2. File được chọn (hoặc báo không hợp lệ ngay).
3. Hệ thống báo lỗi / từ chối; ảnh đại diện cũ (nếu có) không đổi.`,
    pre: `1. Biết giới hạn dung lượng theo cấu hình hệ thống.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Lễ tân — Giao diện chỉnh sửa hồ sơ",
    id: "TC_03",
    obj: "Verify lễ tân có cùng bố cục chỉnh sửa hồ sơ với bác sĩ (sidebar, thẻ nội dung, nút chọn ảnh).",
    steps: `**A. RECEPTIONIST**
1. Login as Receptionist.
2. Mở "**Chỉnh sửa hồ sơ**" từ menu cá nhân / hồ sơ.

**B. VETERINARIAN** (so sánh tham chiếu)
3. Login as Veterinarian (phiên khác hoặc thiết bị khác).
4. Mở cùng màn "**Chỉnh sửa hồ sơ**".`,
    exp: `1–2. Lễ tân thấy sidebar thương hiệu, breadcrumb "**Hồ sơ**", thẻ nội dung, nút chọn ảnh (không chỉ ô file thô).
3–4. Bác sĩ thấy cùng kiểu bố cục; hai vai trò đồng nhất trải nghiệm UI.`,
    pre: `1. Tài khoản lễ tân và bác sĩ đều hoạt động.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Chủ phòng khám / Quản trị — Thanh điều hướng",
    id: "TC_04",
    obj: "Verify avatar trên thanh điều hướng khu Owner/Admin hiển thị ảnh đã cập nhật; khi không có ảnh thì hiện chữ cái đầu.",
    steps: `**A. CLINIC OWNER / ADMIN**
1. Login Owner hoặc Admin.
2. Cập nhật ảnh đại diện trong phần hồ sơ cá nhân.
3. Quay lại trang có thanh menu (dashboard dịch vụ, v.v.).
4. (Trường hợp 2) Xóa / không dùng ảnh đại diện (nếu luồng cho phép) hoặc dùng tài khoản chưa có ảnh; tải lại trang.`,
    exp: `1–3. Vòng tròn avatar hiển thị đúng ảnh vừa lưu (không cố định ảnh mặc định ngoài thiết kế).
4. Hiển thị chữ cái đầu tên khi không có ảnh.`,
    pre: `1. Tài khoản Owner/Admin có quyền chỉnh hồ sơ.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Đổi mật khẩu",
    id: "TC_05",
    obj: "Verify đổi mật khẩu thành công với mật khẩu mới đạt quy tắc; từ chối mật khẩu thiếu chữ hoa.",
    steps: `**OPTION A — Mật khẩu hợp lệ**
**A. USER (local)**
1. Vào "**Đổi mật khẩu**" từ hồ sơ.
2. Nhập đúng mật khẩu hiện tại.
3. Mật khẩu mới & xác nhận: có chữ hoa + số, độ dài trong khoảng cho phép (ví dụ dạng hợp lệ).
4. Submit.

**OPTION B — Thiếu chữ hoa**
**B. USER**
5. Nhập mật khẩu mới toàn chữ thường + số.
6. Submit.`,
    exp: `A: 4. Redirect / thông báo thành công; đăng nhập lại bằng mật khẩu mới thành công.
B: 6. Thông báo lỗi theo quy tắc (yêu cầu chữ hoa và số, độ dài).`,
    pre: `1. Tài khoản đăng nhập bằng mật khẩu cục bộ (không phải chỉ đăng nhập mạng xã hội) cho Option A/B.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Đổi mật khẩu — Tài khoản Google",
    id: "TC_06",
    obj: "Verify tài khoản liên kết Google không đổi mật khẩu cục bộ như user thường.",
    steps: `**A. USER (Google-linked)**
1. Login bằng tài khoản đã liên kết Google.
2. Mở "**Đổi mật khẩu**" (nếu còn hiển thị).
3. Thử thao tác đổi mật khẩu.`,
    exp: `2–3. Không cho phép hoặc thông báo không áp dụng đổi mật khẩu cục bộ.`,
    pre: `1. Tài khoản được đánh dấu đăng nhập qua Google.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Phân quyền theo vai trò",
    id: "TC_07",
    obj: "Verify khách hàng không truy cập được khu vực dành cho bác sĩ; bác sĩ truy cập bình thường.",
    steps: `**A. CUSTOMER**
1. Login as Customer.
2. Trên thanh địa chỉ, thử mở trang dành cho bác sĩ (dashboard / hàng đợi bác sĩ).

**B. VETERINARIAN**
3. Login as Veterinarian.
4. Mở các màn hình nghiệp vụ bác sĩ từ menu.`,
    exp: `A: 2. Bị từ chối hoặc chuyển về trang đăng nhập / thông báo không có quyền.
B: 4. Trang tải bình thường.`,
    pre: `1. Có đủ tài khoản Customer và Veterinarian.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Khám bệnh — Mở màn hình khám",
    id: "TC_08",
    obj: "Verify không mở được màn khám khi thiếu lịch, lịch không tồn tại, hoặc trạng thái không phù hợp; hệ thống đưa về hàng đợi với thông báo phù hợp.",
    steps: `**A. VETERINARIAN**
1. Login bác sĩ.
2. Từ menu / hàng đợi, thử mở "**Khám bệnh**" khi **chưa chọn** mã lịch hợp lệ (hoặc để trống).
3. Thử mở với mã lịch **không có** trong hệ thống.
4. Thử mở lịch **chưa check-in** / sai bước trạng thái (theo quy định nghiệp vụ).`,
    exp: `2. Không vào form khám; quay về **hàng đợi bác sĩ** (hoặc trang danh sách tương đương).
3. Thông báo không tìm thấy / không hợp lệ.
4. Thông báo trạng thái không cho phép khám.`,
    pre: `1. Tài khoản bác sĩ hoạt động; có hoặc tạo dữ liệu lịch để thử các nhánh.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Khám bệnh — Tiếp nhận & khóa ca",
    id: "TC_09",
    obj: "Verify bác sĩ khác không mở được ca đã được bác sĩ khác tiếp nhận; bác sĩ đang có ca khám không mở thêm ca thứ hai.",
    steps: `**A. VETERINARIAN A**
1. Tiếp nhận / bắt đầu khám một lịch hợp lệ.

**B. VETERINARIAN B**
2. Login bác sĩ B.
3. Thử mở **cùng** lịch đó.

**C. VETERINARIAN A**
4. Khi đang có lịch ở trạng thái đang khám, thử mở **một lịch khác** hợp lệ.`,
    exp: `B: 3. Không cho mở; thông báo ca đã thuộc bác sĩ khác / bị khóa.
C: 4. Thông báo đang bận (đang có ca khám chưa xong).`,
    pre: `1. Hai tài khoản bác sĩ; ít nhất hai lịch trong kịch bản.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Khám bệnh — Lưu nháp & hoàn tất",
    id: "TC_10",
    obj: "Verify lưu tạm thông tin khám; hoàn tất lượt khám khi đủ điều kiện và chuyển trạng thái lịch chờ thanh toán.",
    steps: `**A. VETERINARIAN**
1. Mở màn "**Khám bệnh**" với lịch hợp lệ.
2. Điền chẩn đoán, dịch vụ, đơn thuốc (nếu có).
3. Click "**Lưu nháp**" / tương đương (không hoàn tất).
4. Kiểm tra vẫn ở / quay lại đúng lượt khám.
5. Điền đủ theo quy tắc, click "**Hoàn tất**" / "**Kết thúc khám**".`,
    exp: `3–4. Dữ liệu được lưu; có thể tiếp tục chỉnh sửa.
5. Lượt khám kết thúc; lịch chuyển trạng thái **chờ thanh toán** (hoặc tương đương); lễ tân nhận thông báo (nếu có); quay về hàng đợi / thông báo hoàn tất.`,
    pre: `1. Lịch ở trạng thái cho phép khám; bác sĩ đúng người tiếp nhận.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Khám bệnh — Kiểm tra biểu mẫu (Complete)",
    id: "TC_11",
    obj: "Verify không cho hoàn tất khi thiếu chẩn đoán, không có dịch vụ, hoặc đơn thuốc sai liều/tần suất.",
    steps: `**A. VETERINARIAN**
1. Mở màn khám hợp lệ.
2. **OPTION A:** Để trống chẩn đoán, click hoàn tất.
3. **OPTION B:** Xóa hết dịch vụ, click hoàn tất.
4. **OPTION C:** Nhập tên thuốc nhưng liều không phải số hoặc thiếu tần suất, click hoàn tất.`,
    exp: `2. Cảnh báo chẩn đoán; không submit hoàn tất.
3. Thông báo cần ít nhất **một dịch vụ**.
4. Cảnh báo đơn thuốc; không hoàn tất.`,
    pre: `1. Đang ở màn khám với dữ liệu có thể chỉnh.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Khám bệnh — Xét nghiệm đang chờ",
    id: "TC_12",
    obj: "Verify cảnh báo khi còn yêu cầu xét nghiệm chưa xong mà bấm hoàn tất; có thể cho phép hoàn tất bất chấp (nếu nghiệp vụ có).",
    steps: `**A. VETERINARIAN**
1. Trên lượt khám có **yêu cầu xét nghiệm** đang chờ.
2. Click hoàn tất lượt khám.
3. Nếu có hộp thoại "**Hoàn tất dù xét nghiệm chưa xong**", chọn theo kịch bản.`,
    exp: `2. Hiện cảnh báo rõ ràng.
3. Hệ thống xử lý đúng lựa chọn (hủy / hoàn tất bất chấp theo thiết kế).`,
    pre: `1. Có lượt khám với xét nghiệm pending.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Hàng đợi bác sĩ — Bắt đầu khám",
    id: "TC_13",
    obj: "Verify bắt đầu khám từ hàng đợi: thành công khi hợp lệ; thông báo rõ khi bận / khóa / không được phép.",
    steps: `**A. VETERINARIAN**
1. Mở trang **hàng đợi / danh sách lịch** bác sĩ.
2. Chọn "**Bắt đầu khám**" (hoặc tương đương) cho lịch hợp lệ.
3. Lặp lại với lịch đã bị khóa / bác sĩ khác giữ / trạng thái bận.`,
    exp: `2. Vào được màn khám hoặc trạng thái đúng theo luồng.
3. Thông báo lỗi phù hợp (bận, khóa, không được phép).`,
    pre: `1. Có dữ liệu hàng đợi thực hoặc môi trường thử.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Xét nghiệm — Từ màn khám",
    id: "TC_14",
    obj: "Verify tạo yêu cầu xét nghiệm từ màn khám và xem kết quả khi đã có.",
    steps: `**A. VETERINARIAN**
1. Mở màn "**Khám bệnh**".
2. Điền biểu mẫu "**Yêu cầu xét nghiệm**" / gửi yêu cầu.
3. Quay lại màn khám — kiểm tra mục xét nghiệm hiển thị yêu cầu.
4. (Khi đã có kết quả) Mở "**Xem kết quả**" / cửa sổ xem nhanh.`,
    exp: `2–3. Yêu cầu gắn với lượt khám; hiển thị trong phần xét nghiệm.
4. Nội dung kết quả đọc được, đầy đủ.`,
    pre: `1. Lượt khám mở được; có hoặc mô phỏng kết quả xét nghiệm.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Chỉnh sửa hồ sơ — Validation",
    id: "TC_15",
    obj: "Verify ràng buộc họ tên, số điện thoại, độ dài địa chỉ; email không đổi qua form (nếu thiết kế read-only).",
    steps: `**A. USER (bất kỳ vai trò có chỉnh sửa hồ sơ)**
1. Mở "**Chỉnh sửa hồ sơ**".
2. Xóa họ tên hoặc nhập ký tự không hợp lệ — Lưu.
3. Nhập SĐT không đúng định dạng — Lưu.
4. Nhập địa chỉ vượt quá giới hạn — Lưu.
5. Thử sửa email nếu ô bị khóa.`,
    exp: `2–4. Thông báo lỗi tương ứng; không lưu sai.
5. Email không đổi (nếu read-only).`,
    pre: `1. Tài khoản có quyền chỉnh sửa hồ sơ.`,
    status: "Pending",
    date: "",
  },
  {
    fn: "Function: Tài liệu kiểm thử — Import / Export",
    id: "TC_16",
    obj: "Verify nhập danh sách test case từ bảng tính vào mẫu tài liệu kiểm thử hệ thống (copy-paste / import).",
    steps: `**A. TESTER / QA**
1. Mở file danh sách test case dạng bảng (CSV / Excel).
2. Copy các dòng vào đúng sheet mẫu tài liệu kiểm thử (theo hướng dẫn cột).
3. Kiểm tra số dòng, tiêu đề cột khớp phạm vi dự án.`,
    exp: `2–3. Dữ liệu nằm đúng cột; không mất ký tự tiếng Việt (UTF-8).`,
    pre: `1. Có mẫu tài liệu kiểm thử hệ thống (Excel).`,
    status: "Pending",
    date: "",
  },
];

function csvEscape(field) {
  const s = field == null ? "" : String(field);
  if (/[",\n\r]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

function main() {
  const headers = [
    "Function",
    "TC ID",
    "Test Objective",
    "Test Steps",
    "Expected Results",
    "Preconditions",
    "Status",
    "Date",
  ];
  const lines = [headers.join(",")];
  for (const r of ROWS) {
    const row = [
      r.fn,
      r.id,
      r.obj,
      r.steps,
      r.exp,
      r.pre,
      r.status ?? "Pending",
      r.date ?? "",
    ].map(csvEscape);
    lines.push(row.join(","));
  }
  const BOM = "\uFEFF";
  fs.writeFileSync(OUT, BOM + lines.join("\r\n"), "utf8");
  console.log("Đã tạo:", OUT);
  console.log("Mở bằng Excel: File > Open, chọn file CSV (UTF-8). Hoặc mở Excel > Data > From Text/CSV.");
}

main();
