/**
 * Sinh CSV kiểm thử hệ thống đúng 7 cột như mẫu Excel (Template3 / screenshot):
 * Test Case ID | Test Objective / Description | Steps to Reproduce | Expected Result |
 * Pre-conditions / Notes | Status | Date
 *
 * Có dòng phân nhóm "Function: ..." (merge + tô xanh trong Excel).
 *
 * Chạy: node scripts/generate-system-test-template7.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { CASES_VI, SCENARIOS_VI } from "./data/test-cases-vietnamese.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const OUT = path.join(root, "System_Test_Cases_Anipats_Template7.csv");

const GROUP_ORDER = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];

function csvEscape(field) {
  const s = field == null ? "" : String(field);
  if (/[",\n\r]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

/** Tiêu đề nhóm cho hàng Function: (bỏ prefix "Scenario X —") */
function functionTitle(groupKey) {
  const full = SCENARIOS_VI[groupKey] || `Nhóm ${groupKey}`;
  return full.replace(/^Scenario [A-I] —\s*/i, "").trim() || full;
}

function main() {
  const headers = [
    "Test Case ID",
    "Test Objective / Description",
    "Steps to Reproduce / Execution Steps",
    "Expected Result",
    "Pre-conditions / Notes",
    "Status",
    "Date",
  ];

  const byGroup = new Map();
  for (const k of GROUP_ORDER) byGroup.set(k, []);
  for (const c of CASES_VI) {
    const list = byGroup.get(c.group);
    if (list) list.push(c);
  }

  const lines = [headers.join(",")];

  for (const g of GROUP_ORDER) {
    const cases = byGroup.get(g) || [];
    if (cases.length === 0) continue;

    // Dòng thanh Function (merge 7 cột trong Excel; CSV chỉ ghi cột 1)
    const fnRow = [
      `Function: ${functionTitle(g)}`,
      "",
      "",
      "",
      "",
      "",
      "",
    ].map(csvEscape);
    lines.push(fnRow.join(","));

    for (const c of cases) {
      const preNote = [c.pre, c.note ? `Loại: ${c.note}` : ""].filter(Boolean).join(" | ");
      const row = [
        c.id,
        c.desc,
        c.proc.trim(),
        c.expected.trim(),
        preNote,
        "Pending",
        "",
      ].map(csvEscape);
      lines.push(row.join(","));
    }
  }

  const BOM = "\uFEFF";
  fs.writeFileSync(OUT, BOM + lines.join("\r\n") + "\r\n", "utf8");
  console.log("Đã tạo:", OUT);
  console.log("Mở Excel: Data > From Text/CSV (UTF-8). Hàng 'Function:' → chọn dòng > Merge & Center > tô màu xanh như mẫu.");
}

main();
