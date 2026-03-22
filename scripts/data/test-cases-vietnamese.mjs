/**
 * Nội dung test case diễn đạt theo văn phong tài liệu kiểm thử (tiếng Việt),
 * không dùng thuật ngữ code — tham chiếu nghiệp vụ Anipats.
 * group: A–I khớp các nhóm Scenario trong sheet mẫu.
 */

export const SCENARIOS_VI = {
  A: "Scenario A — Ảnh đại diện & cập nhật hồ sơ",
  B: "Scenario B — Chỉnh sửa thông tin cá nhân",
  C: "Scenario C — Lễ tân: giao diện hồ sơ",
  D: "Scenario D — Chủ phòng khám / Quản trị: thanh điều hướng",
  E: "Scenario E — Đổi mật khẩu",
  F: "Scenario F — Đồng bộ dữ liệu ảnh trên hồ sơ người dùng",
  G: "Scenario G — Phân quyền theo vai trò",
  H: "Scenario H — Quy trình tài liệu kiểm thử",
  I: "Scenario I — Khám bệnh, xét nghiệm & hàng đợi bác sĩ",
};

/** @type {Array<{ id: string; group: keyof typeof SCENARIOS_VI; desc: string; proc: string; expected: string; pre: string; note: string }>} */
export const CASES_VI = [
  // —— A ——
  {
    id: "TC-PFP-01",
    group: "A",
    desc: "Bác sĩ tải ảnh đại diện định dạng JPG hợp lệ và lưu hồ sơ thành công.",
    proc: `1. Đăng nhập bằng tài khoản Bác sĩ thú y.
2. Vào mục Hồ sơ của tôi, chọn Chỉnh sửa hồ sơ.
3. Chọn ảnh JPG có dung lượng trong giới hạn cho phép (không vượt quá mức tối đa), dùng nút chọn ảnh.
4. Bấm Lưu thay đổi.`,
    expected: `Hệ thống lưu thành công; ảnh đại diện hiển thị đúng trên trang hồ sơ; thông tin lưu trữ ảnh trên hệ thống được cập nhật tương ứng.`,
    pre: `Tài khoản bác sĩ đang hoạt động; file ảnh đúng định dạng và trong giới hạn dung lượng.`,
    note: "Tích cực",
  },
  {
    id: "TC-PFP-02",
    group: "A",
    desc: "Người dùng các vai trò (khách, quản trị, xét nghiệm, lễ tân) tải ảnh PNG / GIF / WebP hợp lệ khi chỉnh sửa hồ sơ.",
    proc: `1. Đăng nhập theo từng vai trò được hỗ trợ chỉnh sửa hồ sơ.
2. Mở màn hình Chỉnh sửa hồ sơ.
3. Chọn ảnh PNG, GIF hoặc WebP trong giới hạn dung lượng.
4. Lưu thay đổi.`,
    expected: `Ảnh được lưu; hồ sơ cập nhật đường dẫn ảnh; ảnh hiển thị trên trang hồ sơ và (nếu có) khu vực đầu trang.`,
    pre: `Tài khoản có quyền truy cập trang chỉnh sửa hồ sơ.`,
    note: "Tích cực",
  },
  {
    id: "TC-PFP-03",
    group: "A",
    desc: "Từ chối tải lên khi file ảnh vượt quá dung lượng cho phép.",
    proc: `1. Mở Chỉnh sửa hồ sơ.
2. Chọn một file ảnh có dung lượng lớn hơn mức tối đa cho phép.
3. Thử lưu.`,
    expected: `Hệ thống báo lỗi hoặc không chấp nhận tải lên; đường dẫn ảnh trên hồ sơ không đổi (hoặc không tạo file lưu trữ mới không hợp lệ).`,
    pre: `Đã cấu hình giới hạn dung lượng tải lên theo quy định hệ thống.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-PFP-04",
    group: "A",
    desc: "Từ chối file không phải ảnh hoặc định dạng không được hỗ trợ.",
    proc: `1. Mở Chỉnh sửa hồ sơ.
2. Chọn file không phải ảnh hoặc loại không nằm trong danh sách cho phép.
3. Lưu.`,
    expected: `Không lưu đường dẫn ảnh hợp lệ; hệ thống có thể ghi nhận từ chối theo quy tắc kiểm tra loại file.`,
    pre: `—`,
    note: "Tiêu cực",
  },
  {
    id: "TC-PFP-05",
    group: "A",
    desc: "Chỉ cập nhật họ tên / số điện thoại / địa chỉ mà không chọn ảnh mới.",
    proc: `1. Mở Chỉnh sửa hồ sơ.
2. Sửa các trường thông tin chữ; không thay đổi ô chọn ảnh.
3. Lưu.`,
    expected: `Các trường thông tin được cập nhật; ảnh đại diện hiện tại giữ nguyên.`,
    pre: `Người dùng đã tồn tại trên hệ thống.`,
    note: "Hồi quy",
  },
  {
    id: "TC-PFP-06",
    group: "A",
    desc: "Tải ảnh mới thay thế ảnh đại diện cũ.",
    proc: `1. Người dùng đã có ảnh đại diện.
2. Chọn ảnh mới và lưu.`,
    expected: `Ảnh mới được lưu; ảnh cũ được xử lý theo quy tắc (ví dụ thay thế); hồ sơ hiển thị ảnh mới.`,
    pre: `Đã có ảnh đại diện trước đó.`,
    note: "Tích cực",
  },
  {
    id: "TC-PFP-07",
    group: "A",
    desc: "Khi trong hệ thống lưu sẵn đường dẫn ảnh không hợp lệ (ví dụ định dạng đường dẫn máy trạm), giao diện không hiển thị sai.",
    proc: `1. (Thiết lập kiểm thử) Gán giá trị đường dẫn ảnh không hợp lệ cho hồ sơ.
2. Đăng nhập và tải lại trang hồ sơ / đầu trang.`,
    expected: `Hệ thống bỏ qua đường dẫn không hợp lệ; hiển thị chữ cái đầu hoặc trạng thái mặc định, không hiện chuỗi đường dẫn lỗi.`,
    pre: `Môi trường cho phép thiết lập dữ liệu thử.`,
    note: "Biên / an toàn",
  },
  {
    id: "TC-PFP-08",
    group: "A",
    desc: "Trình duyệt mở được ảnh đại diện đã lưu qua đường dẫn công khai hợp lệ.",
    proc: `1. Sau khi tải ảnh thành công, ghi nhận đường dẫn hiển thị ảnh.
2. Mở đường dẫn đó trên trình duyệt (cùng ứng dụng).`,
    expected: `Trình duyệt nhận được nội dung ảnh; loại nội dung phù hợp với ảnh.`,
    pre: `File ảnh tồn tại trên máy chủ theo cấu hình lưu trữ.`,
    note: "Tích cực",
  },
  {
    id: "TC-PFP-09",
    group: "A",
    desc: "Sau khi đổi ảnh, phiên làm việc hiển thị ảnh mới không cần đăng nhập lại.",
    proc: `1. Lưu ảnh đại diện mới.
2. Chuyển sang trang hồ sơ hoặc khu vực hiển thị avatar mà không đăng xuất.`,
    expected: `Thông tin người dùng trong phiên phản ánh ảnh và thời gian cập nhật mới.`,
    pre: `Đang đăng nhập.`,
    note: "Tích cực",
  },
  // —— B ——
  {
    id: "TC-EP-01",
    group: "B",
    desc: "Kiểm tra ràng buộc họ tên (bắt buộc, ký tự hợp lệ).",
    proc: `1. Mở Chỉnh sửa hồ sơ.
2. Xóa họ tên hoặc nhập ký tự không cho phép.
3. Lưu.`,
    expected: `Hệ thống báo lỗi xác thực; không lưu dữ liệu sai.`,
    pre: `—`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EP-02",
    group: "B",
    desc: "Kiểm tra định dạng số điện thoại (10 số, bắt đầu bằng 0).",
    proc: `1. Nhập số điện thoại không đúng quy tắc.
2. Lưu.`,
    expected: `Thông báo lỗi định dạng số điện thoại.`,
    pre: `—`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EP-03",
    group: "B",
    desc: "Giới hạn độ dài địa chỉ.",
    proc: `1. Nhập địa chỉ vượt quá giới hạn ký tự cho phép.
2. Lưu.`,
    expected: `Hệ thống báo lỗi; không lưu vượt quá.`,
    pre: `—`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EP-04",
    group: "B",
    desc: "Email chỉ đọc, không đổi được qua biểu mẫu (nếu thiết kế như vậy).",
    proc: `1. Mở Chỉnh sửa hồ sơ.
2. Thử thay đổi email (nếu ô bị khóa hoặc không gửi được).`,
    expected: `Email trong cơ sở dữ liệu không đổi theo thao tác không được phép.`,
    pre: `—`,
    note: "Tích cực",
  },
  // —— C ——
  {
    id: "TC-RS-01",
    group: "C",
    desc: "Giao diện chỉnh sửa hồ sơ của Lễ tân thống nhất với Bác sĩ (menu, thẻ nội dung, nút chọn ảnh).",
    proc: `1. Đăng nhập vai trò Lễ tân.
2. Mở Chỉnh sửa hồ sơ.`,
    expected: `Hiển thị bố cục thương hiệu thống nhất; đường dẫn điều hướng rõ ràng; có điều khiển chọn ảnh thân thiện (không chỉ ô tải file thô).`,
    pre: `Tài khoản lễ tân hoạt động.`,
    note: "Giao diện / hồi quy",
  },
  {
    id: "TC-RS-02",
    group: "C",
    desc: "Khi hệ thống yêu cầu bổ sung số điện thoại, lễ tân thấy thông báo và phải nhập đủ trước khi tiếp tục.",
    proc: `1. Phiên làm việc đang trong trạng thái cần bổ sung số điện thoại (theo luồng nghiệp vụ).
2. Mở trang chỉnh sửa hồ sơ với tham số yêu cầu số điện thoại (nếu có).
3. Nhập số hợp lệ và lưu.`,
    expected: `Có thông báo/banner hướng dẫn; sau khi lưu thành công, trạng thái chờ số điện thoại được xử lý và chuyển trang theo quy tắc.`,
    pre: `Luồng bắt buộc số điện thoại được bật trong phiên.`,
    note: "Nghiệp vụ",
  },
  // —— D ——
  {
    id: "TC-OW-01",
    group: "D",
    desc: "Khu vực chủ phòng khám / quản trị hiển thị ảnh đại diện đã cập nhật trên thanh điều hướng.",
    proc: `1. Đăng nhập vai trò chủ phòng khám hoặc quản trị tại các màn hình có thanh đầu trang.
2. Cập nhật ảnh hồ sơ trong phần quản lý tài khoản.
3. Quay lại trang có thanh điều hướng.`,
    expected: `Vòng tròn avatar hiển thị ảnh người dùng đã tải, không cố định ảnh mặc định ngoài thiết kế.`,
    pre: `Đã đặt ảnh đại diện cho tài khoản.`,
    note: "Tích cực",
  },
  {
    id: "TC-OW-02",
    group: "D",
    desc: "Khi chưa có ảnh đại diện, thanh điều hướng hiển thị chữ cái đầu tên.",
    proc: `1. Tài khoản không có ảnh đại diện trong hồ sơ.
2. Mở trang có thanh điều hướng.`,
    expected: `Hiển thị avatar dạng chữ cái đầu (hoặc ký hiệu mặc định an toàn).`,
    pre: `Hồ sơ không có ảnh.`,
    note: "Tích cực",
  },
  // —— E ——
  {
    id: "TC-PW-01",
    group: "E",
    desc: "Đổi mật khẩu thành công khi nhập đúng mật khẩu hiện tại và mật khẩu mới đạt quy tắc.",
    proc: `1. Vào Hồ sơ > Đổi mật khẩu.
2. Nhập đúng mật khẩu hiện tại.
3. Mật khẩu mới và xác nhận giống nhau, có chữ hoa và số, độ dài trong khoảng cho phép (ví dụ dạng hợp lệ: mật khẩu có chữ hoa và số).
4. Gửi biểu mẫu.`,
    expected: `Hệ thống xác nhận đổi thành công; đăng nhập lại bằng mật khẩu mới được.`,
    pre: `Tài khoản đăng nhập bằng mật khẩu cục bộ (không phải tài khoản chỉ đăng nhập mạng xã hội).`,
    note: "Tích cực",
  },
  {
    id: "TC-PW-02",
    group: "E",
    desc: "Từ chối mật khẩu mới không có chữ in hoa.",
    proc: `1. Nhập mật khẩu mới toàn chữ thường và số, thiếu chữ hoa.
2. Gửi.`,
    expected: `Báo lỗi theo quy tắc: độ dài cho phép, có ít nhất một chữ hoa và một chữ số.`,
    pre: `—`,
    note: "Tiêu cực",
  },
  {
    id: "TC-PW-03",
    group: "E",
    desc: "Từ chối khi mật khẩu hiện tại nhập sai.",
    proc: `1. Nhập sai mật khẩu hiện tại.
2. Nhập mật khẩu mới hợp lệ và gửi.`,
    expected: `Thông báo mật khẩu hiện tại không đúng.`,
    pre: `Biết mật khẩu thật để đối chiếu.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-PW-04",
    group: "E",
    desc: "Từ chối khi mật khẩu mới và xác nhận không khớp.",
    proc: `1. Hai ô mật khẩu mới và xác nhận khác nhau.
2. Gửi.`,
    expected: `Báo lỗi hai mật khẩu không trùng.`,
    pre: `—`,
    note: "Tiêu cực",
  },
  {
    id: "TC-PW-05",
    group: "E",
    desc: "Tài khoản chỉ đăng nhập qua nhà cung cấp bên ngoài không đổi mật khẩu cục bộ.",
    proc: `1. Đăng nhập bằng tài khoản liên kết bên ngoài.
2. Thử mở đổi mật khẩu (nếu có).`,
    expected: `Không cho phép hoặc thông báo không áp dụng đổi mật khẩu cục bộ.`,
    pre: `Tài khoản được đánh dấu đăng nhập qua nhà cung cấp bên ngoài.`,
    note: "Tiêu cực",
  },
  // —— F ——
  {
    id: "TC-DB-01",
    group: "F",
    desc: "Sau khi đổi ảnh, bản ghi người dùng trong cơ sở dữ liệu lưu đúng đường dẫn ảnh.",
    proc: `1. Thực hiện đổi ảnh đại diện thành công trên giao diện.
2. Kiểm tra trên cơ sở dữ liệu giá trị đường dẫn ảnh của người dùng.`,
    expected: `Cột đường dẫn ảnh khớp với đường dẫn lưu trữ hợp lệ trên hệ thống.`,
    pre: `Quyền truy vấn cơ sở dữ liệu kiểm thử.`,
    note: "Tích hợp",
  },
  // —— G ——
  {
    id: "TC-AC-01",
    group: "G",
    desc: "Người dùng sai vai trò không truy cập được khu vực dành cho Bác sĩ.",
    proc: `1. Đăng nhập vai trò Khách hàng.
2. Thử mở trang bảng điều khiển hoặc đường dẫn dành cho bác sĩ bằng tay (nhập địa chỉ trực tiếp).`,
    expected: `Hệ thống từ chối hoặc chuyển về trang đăng nhập / thông báo không có quyền theo thiết kế.`,
    pre: `—`,
    note: "An toàn",
  },
  {
    id: "TC-AC-02",
    group: "G",
    desc: "Bác sĩ truy cập bình thường các màn hình thuộc phần dành cho bác sĩ.",
    proc: `1. Đăng nhập tài khoản Bác sĩ thú y.
2. Mở các trang nghiệp vụ bác sĩ.`,
    expected: `Trang tải thành công, hiển thị nội dung đúng vai trò.`,
    pre: `Tài khoản có vai trò bác sĩ.`,
    note: "Tích cực",
  },
  // —— H ——
  {
    id: "TC-REG-01",
    group: "H",
    desc: "Nhập danh sách test case từ bảng tính vào mẫu tài liệu kiểm thử hệ thống.",
    proc: `1. Mở file danh sách test case dạng bảng.
2. Sao chép các dòng vào đúng sheet quy trình trong mẫu tài liệu kiểm thử.`,
    expected: `Dữ liệu khớp phạm vi dự án; cột và số lượng test case nhất quán.`,
    pre: `Có file mẫu tài liệu kiểm thử hệ thống.`,
    note: "Quy trình",
  },
  // —— I ——
  {
    id: "TC-EX-01",
    group: "I",
    desc: "Mở màn hình khám khi không có mã lịch hẹn hoặc mã không hợp lệ.",
    proc: `1. Đăng nhập bác sĩ.
2. Thử mở màn khám mà không chọn mã lịch, hoặc nhập mã không phải số.`,
    expected: `Hệ thống không mở form khám; quay về danh sách hàng đợi bác sĩ.`,
    pre: `Đang đăng nhập bác sĩ.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EX-02",
    group: "I",
    desc: "Mở màn khám với mã lịch không tồn tại.",
    proc: `1. Đăng nhập bác sĩ.
2. Mở màn khám với mã lịch không có trong hệ thống.`,
    expected: `Thông báo không tìm thấy lịch; quay về hàng đợi với thông báo lỗi phù hợp.`,
    pre: `Đang đăng nhập bác sĩ.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EX-03",
    group: "I",
    desc: "Tài khoản không gắn với hồ sơ bác sĩ không mở được màn khám.",
    proc: `1. Đăng nhập tài khoản không được gán vai trò bác sĩ trong dữ liệu nội bộ.
2. Thử mở màn khám cho một lịch hợp lệ.`,
    expected: `Từ chối truy cập; quay về hàng đợi với thông báo không được phép.`,
    pre: `Tài khoản không liên kết bác sĩ.`,
    note: "An toàn",
  },
  {
    id: "TC-EX-04",
    group: "I",
    desc: "Lịch không ở trạng thái cho phép bắt đầu khám (chưa check-in hoặc không đúng bước).",
    proc: `1. Chọn lịch không ở trạng thái “đã check-in” hoặc “đang khám” theo quy định.
2. Thử mở màn khám.`,
    expected: `Không mở form; thông báo trạng thái không hợp lệ; quay về hàng đợi.`,
    pre: `Có lịch ở trạng thái không phù hợp.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EX-05",
    group: "I",
    desc: "Lịch đã được bác sĩ khác tiếp nhận khám.",
    proc: `1. Bác sĩ A đã tiếp nhận ca khám.
2. Đăng nhập bác sĩ B và thử mở cùng lịch đó.`,
    expected: `Không cho mở; thông báo ca đã bị khóa / thuộc bác sĩ khác.`,
    pre: `Hai tài khoản bác sĩ và một lịch đã được nhận.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EX-06",
    group: "I",
    desc: "Bác sĩ đang có một ca khám chưa kết thúc thì mở thêm ca khác.",
    proc: `1. Bác sĩ đang có lịch ở trạng thái đang khám.
2. Thử mở màn khám cho lịch khác đủ điều kiện.`,
    expected: `Hệ thống báo bận; không mở màn hình khám thứ hai.`,
    pre: `Hai lịch hợp lệ; một ca đang mở.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EX-07",
    group: "I",
    desc: "Mở màn khám hợp lệ: hiển thị đầy đủ thông tin lượt khám.",
    proc: `1. Có lịch đúng trạng thái và đúng bác sĩ.
2. Mở màn khám từ hàng đợi hoặc đường dẫn hợp lệ.`,
    expected: `Form khám hiển thị: thông tin lượt khám, dịch vụ, đơn thuốc, khu vực xét nghiệm (nếu có).`,
    pre: `Lịch ở trạng thái cho phép và thuộc bác sĩ đang đăng nhập.`,
    note: "Tích cực",
  },
  {
    id: "TC-EX-10",
    group: "I",
    desc: "Lưu nháp thông tin khám chưa hoàn tất lượt khám.",
    proc: `1. Trên màn khám, điền hoặc sửa chẩn đoán, dịch vụ, đơn thuốc.
2. Chọn thao tác lưu tạm (không hoàn tất lượt khám).`,
    expected: `Dữ liệu được lưu; vẫn ở màn hình khám hoặc quay lại cùng lượt khám để tiếp tục.`,
    pre: `Đang ở màn khám hợp lệ.`,
    note: "Tích cực",
  },
  {
    id: "TC-EX-11",
    group: "I",
    desc: "Hoàn tất lượt khám khi đủ điều kiện nghiệp vụ.",
    proc: `1. Nhập đủ chẩn đoán, ít nhất một dịch vụ, thông tin đơn thuốc hợp lệ (nếu có).
2. Chọn hoàn tất lượt khám.`,
    expected: `Lượt khám kết thúc; lịch chuyển trạng thái chờ thanh toán (hoặc tương đương); hóa đơn/phí phát sinh nếu có quy tắc; lễ tân có thể nhận thông báo; quay về hàng đợi với xác nhận hoàn tất.`,
    pre: `Dữ liệu nhập đủ theo quy tắc.`,
    note: "Tích cực / E2E",
  },
  {
    id: "TC-EX-12",
    group: "I",
    desc: "Gửi biểu mẫu gắn sai lịch với bác sĩ đang đăng nhập.",
    proc: `1. Ở màn khám, can thiệp gửi kèm mã lịch của ca không thuộc bác sĩ hiện tại (kiểm thử an toàn).`,
    expected: `Hệ thống từ chối; quay về hàng đợi.`,
    pre: `Đăng nhập bác sĩ.`,
    note: "An toàn",
  },
  {
    id: "TC-EX-20",
    group: "I",
    desc: "Không cho hoàn tất khi chưa nhập chẩn đoán.",
    proc: `1. Để trống chẩn đoán.
2. Bấm hoàn tất lượt khám.`,
    expected: `Hiển thị lỗi; không gửi hoàn tất.`,
    pre: `Đang ở màn khám.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EX-21",
    group: "I",
    desc: "Không cho hoàn tất khi chưa có dịch vụ nào.",
    proc: `1. Xóa hết dịch vụ đã chọn.
2. Bấm hoàn tất.`,
    expected: `Thông báo cần ít nhất một dịch vụ.`,
    pre: `Đang ở màn khám.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EX-22",
    group: "I",
    desc: "Đơn thuốc: liều lượng hoặc tần suất không hợp lệ.",
    proc: `1. Nhập tên thuốc nhưng liều không phải số hoặc thiếu tần suất.
2. Hoàn tất.`,
    expected: `Cảnh báo trên form; không cho hoàn tất.`,
    pre: `Đang ở màn khám.`,
    note: "Tiêu cực",
  },
  {
    id: "TC-EX-23",
    group: "I",
    desc: "Cảnh báo khi còn yêu cầu xét nghiệm chưa xong mà hoàn tất lượt khám.",
    proc: `1. Có yêu cầu xét nghiệm đang chờ trên lượt khám.
2. Bấm hoàn tất.`,
    expected: `Hiện hộp thoại cảnh báo; có thể cho phép hoàn tất bất chấp (nếu nghiệp vụ cho phép) hoặc yêu cầu xử lý trước.`,
    pre: `Có xét nghiệm đang chờ.`,
    note: "Biên",
  },
  {
    id: "TC-EX-30",
    group: "I",
    desc: "Bắt đầu khám từ hàng đợi (thao tác nhanh trên danh sách).",
    proc: `1. Tại hàng đợi bác sĩ, chọn bắt đầu khám cho lịch hợp lệ.
2. Thử lại với các trường hợp bận, đã bị khóa, hoặc thuộc bác sĩ khác.`,
    expected: `Thành công khi hợp lệ; thông báo rõ khi thất bại (bận, khóa, không được phép).`,
    pre: `Có dữ liệu hàng đợi.`,
    note: "Tích hợp",
  },
  {
    id: "TC-EX-31",
    group: "I",
    desc: "Tạo yêu cầu xét nghiệm từ màn hình khám.",
    proc: `1. Trên màn khám, điền biểu mẫu gửi xét nghiệm và xác nhận.
2. Quay lại màn khám.`,
    expected: `Yêu cầu gắn với lượt khám; hiển thị trong phần xét nghiệm của màn khám.`,
    pre: `Đang mở màn khám.`,
    note: "Tích cực",
  },
  {
    id: "TC-EX-32",
    group: "I",
    desc: "Xem kết quả xét nghiệm từ màn khám (cửa sổ xem nhanh).",
    proc: `1. Mở lượt khám đã có kết quả xét nghiệm.
2. Dùng chức năng xem kết quả (nút hoặc liên kết trên màn hình).`,
    expected: `Hiển thị nội dung kết quả đầy đủ, dễ đọc.`,
    pre: `Đã có kết quả xét nghiệm.`,
    note: "Tích cực",
  },
];
