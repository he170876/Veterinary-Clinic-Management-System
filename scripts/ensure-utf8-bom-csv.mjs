/**
 * Prepend UTF-8 BOM to CSV files so Excel (Windows) opens UTF-8 correctly.
 * Close files in Excel before running.
 * Run: npm run utf8-bom-csv
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const FILES = [
  "System_Test_Cases_Anipats.csv",
  "System_Test_Cases_Anipats.new.csv",
  "System_Test_Cases_Anipats_ExcelFormat.csv",
];

const BOM = "\uFEFF";

for (const name of FILES) {
  const p = path.join(root, name);
  if (!fs.existsSync(p)) continue;
  try {
    let t = fs.readFileSync(p, "utf8").replace(/^\uFEFF/, "");
    fs.writeFileSync(p, BOM + t, "utf8");
    console.log("UTF-8 BOM written:", p);
  } catch (e) {
    console.warn("Skip (file locked or error):", p, e.code || e.message);
  }
}
