/**
 * Build Anipats_System_Test_Complete.xlsx from Template3_System-Test.xlsx.
 * System tests: examination + lab request + lab upload + vet notification.
 * Run: npm run build-system-test-xlsx
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import XLSX from "xlsx";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");

const SRC = path.join(root, "Template3_System-Test.xlsx");
const OUT = path.join(root, "Anipats_System_Test_Complete.xlsx");

/** Sync with System_Test_Cases_Anipats.csv — columns: ID, Scenario, Desc, Proc, Expected, Pre, Status, Note */
const EX_ROWS = [
  ["TC-EX-10", "Examination — Save", "Save draft without completing the visit", "1. Edit diagnosis / services / prescription.\n2. Click Save (not Complete).", "Data is saved; user stays on (or returns to) the same examination screen.", "On examination screen", "Pending", "Positive"],
  ["TC-EX-11", "Examination — Complete", "Complete visit with valid input", "1. Enter diagnosis, at least one service, valid prescription.\n2. Click Complete.", "Visit ends; appointment moves to payment; invoice if applicable; receptionist notified; return to queue with success message.", "Valid data", "Pending", "Positive / E2E"],
  ["TC-EX-12", "Examination — Security", "Submit form with another vet's appointment ID", "1. Tamper appointment ID on the form to another vet's case if possible.\n2. Submit.", "Wrong processing is blocked; redirect to queue or rejection.", "Logged in as veterinarian", "Pending", "Security"],
  ["TC-EX-20", "Examination — Form validation", "Complete with empty diagnosis", "1. Leave diagnosis empty.\n2. Click Complete.", "Validation error on form; submit blocked.", "On examination screen", "Pending", "Negative"],
  ["TC-EX-21", "Examination — Form validation", "Complete with no services selected", "1. Remove all services.\n2. Click Complete.", "Message requires at least one service; cannot complete.", "On examination screen", "Pending", "Negative"],
  ["TC-EX-22", "Examination — Form validation", "Invalid prescription dose or frequency", "1. Enter drug name but non-numeric dose or missing frequency.\n2. Complete.", "Prescription validation error; cannot complete.", "On examination screen", "Pending", "Negative"],
  ["TC-EX-23", "Examination — Form validation", "Complete while lab tests are still pending", "1. A lab request is pending.\n2. Click Complete.", "Warning shown (optional complete anyway if implemented).", "Pending lab request exists", "Pending", "Edge"],
  ["TC-EX-30", "Queue — Start exam", "Start examination from queue", "1. On the queue, click start examination.\n2. Try locked or busy cases.", "Success opens examination; otherwise clear error (busy, taken by another vet, etc.).", "Queue data available", "Pending", "Integration"],
  ["TC-EX-31", "Lab — Request", "Vet submits lab request from examination", "1. On examination, select test type and submit.\n2. Verify list on the same screen.", "Request tied to visit; lab staff notified; visible in lab section.", "Examination screen open", "Pending", "Positive"],
  ["TC-EX-32", "Lab — View result", "View existing lab test result", "1. When a result exists.\n2. Open viewer/modal or detail on screen.", "Result content displays correctly.", "Lab result exists", "Pending", "Positive"],
  ["TC-LAB-01", "Lab — Queue", "Lab staff views pending queue", "1. Log in as lab staff.\n2. Open lab queue.", "Pending requests listed; search/pagination if available.", "Lab account; pending requests", "Pending", "Positive"],
  ["TC-LAB-02", "Lab — Submit result", "Submit result with text note and image", "1. Select a pending request.\n2. Enter result note.\n3. Attach image (JPG/PNG/GIF/WebP).\n4. Submit.", "Success: return to queue with confirmation; request completed; veterinarian notified.", "Pending request available", "Pending", "Positive / E2E"],
  ["TC-LAB-03", "Lab — Submit result", "Missing text note or image", "1. Submit with empty note or no image.", "Error for missing note or image; result not saved.", "Pending request", "Pending", "Negative"],
  ["TC-LAB-04", "Lab — Submit result", "Invalid image format", "1. Attach a file that is not an allowed image type (if testable).", "Cannot save image; allowed formats indicated.", "—", "Pending", "Negative"],
  ["TC-LAB-05", "Lab — Vet notification", "Vet sees notification after lab uploads result", "1. Vet submits lab request.\n2. Lab submits result successfully.\n3. Vet opens in-app notifications.", "Notification that lab result is available for the request.", "End-to-end flow", "Pending", "Integration"],
];

/** WF1: ID, Scenario, Desc, Proc, Expected, Pre, Evid, Round, Note */
const ALL_ROWS = EX_ROWS.map((r) => [r[0], r[1], r[2], r[3], r[4], r[5], "", r[6], r[7]]);

function setCell(ws, row1, col1, value) {
  const addr = XLSX.utils.encode_cell({ r: row1 - 1, c: col1 - 1 });
  const v = value == null ? "" : value;
  ws[addr] = { t: "s", v: String(v) };
}

function fillWf1StyleSheet(ws, rows, meta) {
  const { workflowTitle, requirement, n } = meta;
  setCell(ws, 2, 2, workflowTitle);
  setCell(ws, 3, 2, requirement);
  setCell(ws, 4, 2, n);
  setCell(ws, 6, 2, 0);
  setCell(ws, 6, 3, 0);
  setCell(ws, 6, 4, n);
  setCell(ws, 6, 5, 0);
  setCell(ws, 7, 2, 0);
  setCell(ws, 7, 3, 0);
  setCell(ws, 7, 4, n);
  setCell(ws, 7, 5, 0);
  setCell(ws, 8, 2, 0);
  setCell(ws, 8, 3, 0);
  setCell(ws, 8, 4, n);
  setCell(ws, 8, 5, 0);

  setCell(ws, 11, 1, "Examination & lab tests (TC-EX + TC-LAB)");
  for (let i = 0; i < rows.length; i++) {
    const r = rows[i];
    const rowNum = 12 + i;
    setCell(ws, rowNum, 1, r[0]);
    setCell(ws, rowNum, 2, `(${r[1]}) ${r[2]}`);
    setCell(ws, rowNum, 3, r[3]);
    setCell(ws, rowNum, 4, r[4]);
    setCell(ws, rowNum, 5, r[5]);
    setCell(ws, rowNum, 6, r[6]);
    setCell(ws, rowNum, 7, r[7]);
    setCell(ws, rowNum, 16, r[8] ?? "");
  }

  const lastRow = 12 + rows.length - 1;
  const ref = XLSX.utils.decode_range(ws["!ref"] || "A1:P1000");
  ref.e.r = Math.max(ref.e.r, lastRow + 5);
  ref.e.c = Math.max(ref.e.c, 16);
  ws["!ref"] = XLSX.utils.encode_range(ref);
}

function fillWf2StyleSheet(ws, rows, meta) {
  const { workflowTitle, requirement, n } = meta;
  setCell(ws, 2, 2, workflowTitle);
  setCell(ws, 3, 2, requirement);
  setCell(ws, 4, 2, n);
  setCell(ws, 6, 2, 0);
  setCell(ws, 6, 3, 0);
  setCell(ws, 6, 4, n);
  setCell(ws, 6, 5, 0);
  setCell(ws, 7, 2, 0);
  setCell(ws, 7, 3, 0);
  setCell(ws, 7, 4, n);
  setCell(ws, 7, 5, 0);
  setCell(ws, 8, 2, 0);
  setCell(ws, 8, 3, 0);
  setCell(ws, 8, 4, n);
  setCell(ws, 8, 5, 0);

  setCell(ws, 11, 1, "Vet examination / lab (detail)");
  for (let i = 0; i < rows.length; i++) {
    const r = rows[i];
    const rowNum = 12 + i;
    setCell(ws, rowNum, 1, r[0]);
    setCell(ws, rowNum, 2, `(${r[1]}) ${r[2]}`);
    setCell(ws, rowNum, 3, r[3]);
    setCell(ws, rowNum, 4, r[4]);
    setCell(ws, rowNum, 5, r[5]);
    setCell(ws, rowNum, 6, r[6]);
    setCell(ws, rowNum, 15, r[7]);
  }
  const lastRow = 12 + rows.length - 1;
  const ref = XLSX.utils.decode_range(ws["!ref"] || "A1:P1000");
  ref.e.r = Math.max(ref.e.r, lastRow + 5);
  ws["!ref"] = XLSX.utils.encode_range(ref);
}

function cloneSheet(ws) {
  return JSON.parse(JSON.stringify(ws));
}

function main() {
  if (!fs.existsSync(SRC)) {
    console.error("Template not found:", SRC);
    process.exit(1);
  }

  const wb = XLSX.readFile(SRC, { cellDates: true, dense: false });

  const wf1 = wb.Sheets["WF1 - Appointment"];
  if (!wf1) {
    console.error("Missing sheet: WF1 - Appointment");
    process.exit(1);
  }

  const newName = "Anipats Examination & Lab";
  wb.SheetNames.push(newName);
  wb.Sheets[newName] = cloneSheet(wf1);

  fillWf1StyleSheet(wb.Sheets[newName], ALL_ROWS, {
    workflowTitle: "WF-Anipats: Examination (VetExamination) + lab request + lab upload + vet notification",
    requirement:
      "Servlets: VetExaminationServlet, VetStartExaminationServlet, VetLabRequestServlet, LabUploadResultServlet, LabDashboardServlet. JSP: vet/examination.jsp, lab/labqueue.jsp. Source: System_Test_Cases_Anipats.csv.",
    n: ALL_ROWS.length,
  });

  const wf2 = wb.Sheets["WF2 - Reception Vet"];
  if (wf2) {
    fillWf2StyleSheet(wf2, EX_ROWS, {
      workflowTitle: "WF2 — Examination, lab request, lab queue, result upload",
      requirement:
        "GET/POST examination, lab request (notify LabStaff), lab queue, POST /lab/result, notification to veterinarian when result is ready.",
      n: EX_ROWS.length,
    });
  }

  const idx = wb.Sheets["Test Cases"];
  if (idx) {
    setCell(idx, 3, 3, "Anipats Veterinary Clinic Management System (VCMS)");
    setCell(idx, 4, 3, "VCMS-ANIPATS");
    let nextNo = 1;
    for (let r = 9; r <= 30; r++) {
      const v = idx[XLSX.utils.encode_cell({ r: r - 1, c: 0 })]?.v;
      if (v != null && String(v).trim() !== "" && !Number.isNaN(Number(v))) nextNo = Math.max(nextNo, Number(v) + 1);
    }
    setCell(idx, 14, 1, nextNo);
    setCell(idx, 14, 2, "Examination + Lab (E2E)");
    setCell(idx, 14, 3, newName);
    setCell(idx, 14, 4, "Examination GET/POST, start exam AJAX, lab request, lab queue, upload result, notify vet.");
    const iref = XLSX.utils.decode_range(idx["!ref"] || "A1:E20");
    iref.e.r = Math.max(iref.e.r, 13);
    idx["!ref"] = XLSX.utils.encode_range(iref);
  }

  const stat = wb.Sheets["Test Statistics"];
  if (stat) {
    const n = EX_ROWS.length;
    setCell(stat, 11, 2, "Anipats Examination & Lab (main sheet)");
    setCell(stat, 11, 5, n);
    setCell(stat, 11, 7, n);
    setCell(stat, 12, 2, "WF2 — same test set");
    setCell(stat, 12, 5, n);
    setCell(stat, 12, 7, n);
    setCell(stat, 14, 5, n);
    setCell(stat, 14, 7, n);
  }

  XLSX.writeFile(wb, OUT, { bookType: "xlsx" });
  console.log("Created:", OUT);
  console.log("Test cases:", EX_ROWS.length, "| Sheet «" + newName + "» + WF2");
}

main();
