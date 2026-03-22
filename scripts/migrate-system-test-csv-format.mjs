/**
 * Chuyển System_Test_Cases_Anipats.csv sang 8 cột giống generate-excel-copypaste.mjs:
 * Function | TC ID | Test Objective | Test Steps | Expected Results | Preconditions | Status | Date
 * Chạy: node scripts/migrate-system-test-csv-format.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const SRC = path.join(root, "System_Test_Cases_Anipats.csv");
const OUT = path.join(root, "System_Test_Cases_Anipats_ExcelFormat.csv");

function parseCSV(text) {
  const rows = [];
  let i = 0;
  let cur = [];
  let field = "";
  let inQ = false;
  const pushField = () => {
    cur.push(field);
    field = "";
  };
  const pushRow = () => {
    if (cur.length) rows.push(cur);
    cur = [];
  };
  while (i < text.length) {
    const c = text[i];
    if (inQ) {
      if (c === '"') {
        if (text[i + 1] === '"') {
          field += '"';
          i += 2;
          continue;
        }
        inQ = false;
        i++;
        continue;
      }
      field += c;
      i++;
      continue;
    }
    if (c === '"') {
      inQ = true;
      i++;
      continue;
    }
    if (c === ",") {
      pushField();
      i++;
      continue;
    }
    if (c === "\r") {
      i++;
      continue;
    }
    if (c === "\n") {
      pushField();
      pushRow();
      i++;
      continue;
    }
    field += c;
    i++;
  }
  pushField();
  if (cur.length) pushRow();
  return rows;
}

function csvEscape(field) {
  const s = field == null ? "" : String(field);
  if (/[",\n\r]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

const raw = fs.readFileSync(SRC, "utf8").replace(/^\uFEFF/, "");
const all = parseCSV(raw);
const hdr = all[0];
const idx = (h) => hdr.indexOf(h);
const g = (cols, j) => (cols[j] !== undefined ? cols[j] : "");

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
for (const cols of all.slice(1)) {
  const tcId = g(cols, idx("Test Case ID")).trim();
  if (!tcId) continue;
  let pre = g(cols, idx("Pre-conditions")).trim();
  const note = g(cols, idx("Note")).trim();
  const evid = g(cols, idx("Evidents")).trim();
  if (note) pre = pre ? `${pre} | Type: ${note}` : `Type: ${note}`;
  if (evid) pre = pre ? `${pre}; Evidents: ${evid}` : `Evidents: ${evid}`;
  let date = g(cols, idx("Round 1 Test date")).trim();
  const tester = g(cols, idx("Round 1 Tester")).trim();
  if (tester) date = `${date} ${tester}`.trim();
  const status = g(cols, idx("Round 1 Status")).trim() || "Pending";
  const row = [
    `Function: ${g(cols, idx("Scenario"))}`,
    tcId,
    g(cols, idx("Test Case Description")),
    g(cols, idx("Test Case Procedure")),
    g(cols, idx("Expected Results")),
    pre,
    status,
    date,
  ].map(csvEscape);
  lines.push(row.join(","));
}

const BOM = "\uFEFF";
fs.writeFileSync(OUT, BOM + lines.join("\r\n") + "\r\n", "utf8");
console.log("Đã tạo:", OUT, "—", all.length - 1, "test case(s).");
console.log("Nguồn:", SRC);
