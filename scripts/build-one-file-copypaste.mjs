/**
 * Build a single TSV file for copy-paste or open in Excel (one tab = one column).
 * Run: node scripts/build-one-file-copypaste.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const SRC =
  fs.existsSync(path.join(root, "System_Test_Cases_Anipats.new.csv"))
    ? path.join(root, "System_Test_Cases_Anipats.new.csv")
    : path.join(root, "System_Test_Cases_Anipats.csv");
const OUT = path.join(root, "System_Test_Cases_Anipats_ONE_FILE_COPY_PASTE.tsv");

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

function tsvEscape(val) {
  const s = val == null ? "" : String(val);
  if (/[\t\n\r"]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

const raw = fs.readFileSync(SRC, "utf8").replace(/^\uFEFF/, "");
let rows = parseCSV(raw);
rows = rows.filter((cols) => cols.some((c) => String(c ?? "").trim() !== ""));
const lines = rows.map((cols) => cols.map(tsvEscape).join("\t"));
const BOM = "\uFEFF";
fs.writeFileSync(OUT, BOM + lines.join("\r\n") + "\r\n", "utf8");
console.log("Created:", OUT, "—", rows.length - 1, "data rows + header");
