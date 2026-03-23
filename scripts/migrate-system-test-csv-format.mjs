/**
 * Convert System_Test_Cases_Anipats.csv to 8 columns:
 * Function | TC ID | Test Objective | Test Steps | Expected Results | Preconditions | Status | Date
 * Supports new format (no Scenario/Evidents; Round 1/2 Test date columns) and legacy columns.
 * Run: node scripts/migrate-system-test-csv-format.mjs
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

/** Wide layout: Test Case ID…Note with Round 1/2/3 Test date columns (optional Evidents). */
const hasNewLayout = idx("Round 1 Test date") >= 0 && idx("Test Case Description") >= 0;

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
let rowCount = 0;
for (const cols of all.slice(1)) {
  const tcId = g(cols, idx("Test Case ID")).trim();
  if (!tcId) continue;
  rowCount++;

  let pre;
  let note;
  let date;
  let status;
  let desc;
  let proc;
  let exp;
  let fn;

  if (hasNewLayout) {
    desc = g(cols, idx("Test Case Description"));
    proc = g(cols, idx("Test Case Procedure"));
    exp = g(cols, idx("Expected Results"));
    pre = g(cols, idx("Pre-conditions")).trim();
    note = g(cols, idx("Note")).trim();
    const evid =
      idx("Evidents") >= 0 ? g(cols, idx("Evidents")).trim() : "";
    if (evid) pre = pre ? `${pre}; Evidents: ${evid}` : `Evidents: ${evid}`;
    const r1d = g(cols, idx("Round 1 Test date")).trim();
    const r2d = g(cols, idx("Round 2 Test date")).trim();
    const r3d = idx("Round 3 Test date") >= 0 ? g(cols, idx("Round 3 Test date")).trim() : "";
    const r1t = g(cols, idx("Round 1 Tester")).trim();
    const r2t = g(cols, idx("Round 2 Tester")).trim();
    const r3t = idx("Round 3 Tester") >= 0 ? g(cols, idx("Round 3 Tester")).trim() : "";
    const r3st = idx("Round 3") >= 0 ? g(cols, idx("Round 3")).trim() : "";
    status = g(cols, idx("Round 1")).trim() || "Pending";
    date = [r1d, r1t].filter(Boolean).join(" ").trim();
    if (r2d) date = date ? `${date} | R2: ${r2d}${r2t ? ` ${r2t}` : ""}` : `R2: ${r2d}`;
    if (r3d || r3t || r3st) {
      const r3part = [r3st || "", r3d || "", r3t || ""].filter(Boolean).join(" ").trim();
      date = date ? `${date} | R3: ${r3part}` : `R3: ${r3part}`;
    }
    fn = `Examination & Lab`;
  } else {
    pre = g(cols, idx("Pre-conditions")).trim();
    note = g(cols, idx("Note")).trim();
    const evid = idx("Evidents") >= 0 ? g(cols, idx("Evidents")).trim() : "";
    if (note) pre = pre ? `${pre} | Type: ${note}` : `Type: ${note}`;
    if (evid) pre = pre ? `${pre}; Evidents: ${evid}` : `Evidents: ${evid}`;
    date = g(cols, idx("Round 1 Test date")).trim();
    const tester = g(cols, idx("Round 1 Tester")).trim();
    if (tester) date = `${date} ${tester}`.trim();
    status = g(cols, idx("Round 1 Status")).trim() || "Pending";
    desc = g(cols, idx("Test Case Description"));
    proc = g(cols, idx("Test Case Procedure"));
    exp = g(cols, idx("Expected Results"));
    fn = `Function: ${g(cols, idx("Scenario"))}`;
  }

  if (note && hasNewLayout) {
    pre = pre ? `${pre} | Note: ${note}` : `Note: ${note}`;
  }

  const row = [fn, tcId, desc, proc, exp, pre, status, date].map(csvEscape);
  lines.push(row.join(","));
}

const BOM = "\uFEFF";
fs.writeFileSync(OUT, BOM + lines.join("\r\n") + "\r\n", "utf8");
console.log("Created:", OUT, "—", rowCount, "test case(s).");
console.log("Source:", SRC);
