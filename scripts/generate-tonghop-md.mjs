/**
 * Sinh TongHop_NoiDung_Da_Nho.md — layout giống sheet Excel,
 * nội dung tiếng Việt (văn phong tài liệu kiểm thử), không dùng thuật ngữ code.
 * Chạy: npm run build-tonghop-md
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { CASES_VI, SCENARIOS_VI } from "./data/test-cases-vietnamese.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const OUT = path.join(root, "TongHop_NoiDung_Da_Nho.md");

function esc(s) {
  return String(s ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/\n/g, "<br/>");
}

function toRow(c) {
  return {
    id: c.id,
    desc: c.desc,
    proc: c.proc,
    expected: c.expected,
    pre: c.pre,
    evid: "",
    r1: "Pending",
    d1: "",
    t1: "",
    r2: "Pending",
    d2: "",
    t2: "",
    r3: "Pending",
    d3: "",
    t3: "",
    note: c.note,
  };
}

function tableHtml(rows) {
  let h = `<table>
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
`;
  for (const r of rows) {
    h += `<tr>
<td>${esc(r.id)}</td>
<td>${esc(r.desc)}</td>
<td>${esc(r.proc)}</td>
<td>${esc(r.expected)}</td>
<td>${esc(r.pre)}</td>
<td>${esc(r.evid)}</td>
<td>${esc(r.r1)}</td>
<td>${esc(r.d1)}</td>
<td>${esc(r.t1)}</td>
<td>${esc(r.r2)}</td>
<td>${esc(r.d2)}</td>
<td>${esc(r.t2)}</td>
<td>${esc(r.r3)}</td>
<td>${esc(r.d3)}</td>
<td>${esc(r.t3)}</td>
<td>${esc(r.note)}</td>
</tr>
`;
  }
  h += `</tbody></table>
`;
  return h;
}

function main() {
  const n = CASES_VI.length;
  const byGroup = new Map();
  for (const c of CASES_VI) {
    if (!byGroup.has(c.group)) byGroup.set(c.group, []);
    byGroup.get(c.group).push(toRow(c));
  }

  const order = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];

  let md = `# Anipats — Danh sách kiểm thử hệ thống

Tài liệu bám **bố cục sheet kiểm thử** (Workflow, yêu cầu, số lượng case, tổng hợp theo vòng, nhóm **Scenario**, bảng chi tiết).  
**Toàn bộ nội dung diễn đạt bằng tiếng Việt** theo phong cách mô tả nghiệp vụ (không nhúng mã lệnh, tên lớp hay đường dẫn kỹ thuật).

---

## Phần đầu (thông tin chung & tổng hợp theo vòng)

| Hạng mục | Nội dung |
|----------|----------|
| **Workflow** | Quy trình nghiệp vụ Anipats: hồ sơ & ảnh đại diện, lễ tân, chủ phòng khám, đổi mật khẩu, phân quyền, đồng bộ dữ liệu, **khám bệnh — xét nghiệm — hàng đợi bác sĩ**. |
| **Yêu cầu kiểm thử** | Xác minh đúng luồng nghiệp vụ và trải nghiệm người dùng trên ứng dụng quản lý phòng khám thú y; bao gồm các tình huống thành công, từ chối hợp lệ, và phân quyền. |
| **Số lượng test case** | **${n}** |

### Tổng hợp theo vòng kiểm thử

| Vòng | Đạt | Không đạt | Chưa chạy | Không áp dụng |
|------|-----|-----------|-----------|----------------|
| Vòng 1 | 0 | 0 | ${n} | 0 |
| Vòng 2 | 0 | 0 | ${n} | 0 |
| Vòng 3 | 0 | 0 | ${n} | 0 |

*Khi thực hiện test: cập nhật số liệu Đạt / Không đạt / Chưa chạy; ở bảng chi tiết điền ngày và người thực hiện từng vòng.*

---

## Chi tiết test case theo Scenario

`;

  for (const g of order) {
    const list = byGroup.get(g);
    if (!list || !list.length) continue;
    const title = SCENARIOS_VI[g] || `Scenario ${g}`;
    md += `### ${title}\n\n`;
    md += tableHtml(list);
    md += `\n`;
  }

  md += `---

## Ghi chú sử dụng tài liệu

- Cột **Round 1 / 2 / 3** mặc định **Pending** (giống dropdown trên Excel); sau khi chạy điền **Passed** / **Failed** hoặc **Đạt** / **Không đạt** theo quy ước nhóm.
- **Minh chứng**: đính kèm ảnh màn hình, mã lỗi hiển thị cho người dùng, hoặc mô tả ngắn hành vi thực tế — không bắt buộc ghi log kỹ thuật dạng mã nguồn.
- Bản song song có cấu trúc cột tương thích Excel nằm tại file dự án: \`Anipats_System_Test_Complete.xlsx\` (tạo bằng \`npm run build-system-test-xlsx\`). Tài liệu **.md** này ưu tiên **ngôn ngữ nghiệp vụ**; chi tiết kỹ thuật tra cứu trong mã nguồn khi cần.

`;

  fs.writeFileSync(OUT, md, "utf8");
  console.log("Đã ghi:", OUT, "| TC:", n, "| Tiếng Việt (không code)");
}

main();
