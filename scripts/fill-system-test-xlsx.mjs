/**
 * Tạo Anipats_System_Test_Complete.xlsx từ Template3_System-Test.xlsx (giữ cấu trúc mẫu).
 * Chạy: npm run build-system-test-xlsx
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import XLSX from "xlsx";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");

const SRC = path.join(root, "Template3_System-Test.xlsx");
const OUT = path.join(root, "Anipats_System_Test_Complete.xlsx");

const SYSTEM_ROWS = [
  ["TC-PFP-01", "Profile Photo (PFP)", "Vet uploads valid JPG avatar and profile saves", "1. Login as Veterinarian.\n2. Open My Profile > Edit Profile.\n3. Choose a JPG file under 2MB via camera button.\n4. Save Changes.", "Profile redirects with success; Users.profile_picture_url is /uploads/avatars/vet-{userId}-{timestamp}.jpg; avatar shows on profile with new image.", "Active vet account; file <= 2MB", "", "Pending", "Positive"],
  ["TC-PFP-02", "Profile Photo (PFP)", "Upload PNG / GIF / WebP for any role using edit-profile", "1. Login (Customer or Admin or Lab or Receptionist).\n2. Edit Profile.\n3. Select PNG (or GIF/WebP) under 2MB.\n4. Save.", "File stored; DB path updated; image visible on profile and header (if applicable).", "Role has edit-profile page", "", "Pending", "Positive"],
  ["TC-PFP-03", "Profile Photo (PFP)", "Reject upload when file exceeds max size", "1. Edit Profile.\n2. Select image > 2MB.\n3. Save.", "Error or upload rejected; DB profile_picture_url unchanged (or no new file).", "Multipart limit 2MB file / 6MB request", "", "Pending", "Negative"],
  ["TC-PFP-04", "Profile Photo (PFP)", "Unsupported MIME / extension rejected", "1. Edit Profile.\n2. Upload non-image or unsupported type.\n3. Save.", "No new valid path saved; optional server log [PFP] unsupported image.", "—", "", "Pending", "Negative"],
  ["TC-PFP-05", "Profile Photo (PFP)", "Save profile text without choosing new photo", "1. Edit Profile.\n2. Change name/phone/address only; do not touch file input.\n3. Save.", "Fields update; profile_picture_url unchanged; no orphan requirement.", "Existing user", "", "Pending", "Regression"],
  ["TC-PFP-06", "Profile Photo (PFP)", "New upload replaces previous file (timestamp filename)", "1. User already has avatar URL.\n2. Upload new image.\n3. Save.", "New filename with new timestamp; old file deleted when save succeeds; DB shows new path.", "Had previous /uploads/avatars/...", "", "Pending", "Positive"],
  ["TC-PFP-07", "Profile Photo (PFP)", "Invalid stored path rejected on load (Windows path)", "1. (DB test) Set profile_picture_url to a Windows-style path.\n2. Reload user in app.", "User model normalizes to null or ignores bad path; UI shows initial letter not broken path.", "Data setup", "", "Pending", "Edge / security"],
  ["TC-PFP-08", "Profile Photo (PFP)", "GET /uploads/avatars/{file} serves saved file", "1. After successful upload note filename.\n2. Open browser GET {context}/uploads/avatars/{filename}.", "200; image bytes; correct Content-Type.", "File exists on disk (webapp or fallback dir)", "", "Pending", "Positive"],
  ["TC-PFP-09", "Profile Photo (PFP)", "Session user refreshed after save", "1. Save new avatar.\n2. Navigate profile/header without re-login.", "currentUser shows updated profile_picture_url and updated_at.", "Logged in", "", "Pending", "Positive"],
  ["TC-EP-01", "Edit Profile", "Full name validation (required / letters)", "1. Edit Profile.\n2. Clear name or enter invalid characters.\n3. Save.", "Redirect with validation error; no partial corrupt save.", "—", "", "Pending", "Negative"],
  ["TC-EP-02", "Edit Profile", "Phone format (10 digits starting with 0)", "1. Enter phone not matching 0 + 9 digits.\n2. Save.", "Validation error message.", "—", "", "Pending", "Negative"],
  ["TC-EP-03", "Edit Profile", "Address max length", "1. Enter address > 500 chars.\n2. Save.", "Validation error.", "—", "", "Pending", "Negative"],
  ["TC-EP-04", "Edit Profile", "Email read-only not changed via form", "1. Edit Profile.\n2. Attempt to change email field (if not editable).", "Email unchanged in DB.", "—", "", "Pending", "Positive"],
  ["TC-RS-01", "Receptionist UI", "Edit Profile layout matches Vet (sidebar + card)", "1. Login as Receptionist.\n2. Open Edit Profile.", "Sidebar Anipats; breadcrumb My Profile > Edit Profile; light card; camera control (not raw file input only).", "Receptionist role", "", "Pending", "UI / Regression"],
  ["TC-RS-02", "Receptionist UI", "Pending phone required flow", "1. Session pendingPhoneRequired.\n2. Open Edit Profile with ?required=phone.", "Banner + phone required; successful save clears pending and redirects per servlet.", "Feature enabled in session", "", "Pending", "Business rule"],
  ["TC-OW-01", "Owner / Admin UI", "Owner-area header shows live avatar", "1. Login as Clinic Owner/Admin on owner dashboard or services.\n2. Set profile photo in admin profile.\n3. Reopen owner sheet page.", "Header circle shows uploaded image not Google placeholder.", "profile_picture_url set", "", "Pending", "Positive"],
  ["TC-OW-02", "Owner / Admin UI", "Header fallback initial when no photo", "1. User without profile_picture_url.\n2. Open owner pages with header fragment.", "Letter avatar (initial) displayed.", "No PFP in DB", "", "Pending", "Positive"],
  ["TC-PW-01", "Change Password", "Successful change with valid new password", "1. Profile > Change Password.\n2. Enter correct current password.\n3. New = Confirm = valid (e.g. Dev123: upper+digit, 6+ chars).\n4. Submit.", "Redirect ?pw=1; login works with new password.", "Local (non-Google) user", "", "Pending", "Positive"],
  ["TC-PW-02", "Change Password", "Reject new password without uppercase", "1. New password = dev123 (all lower).\n2. Submit.", "Error: 6-128 chars with 1 uppercase and 1 number.", "—", "", "Pending", "Negative"],
  ["TC-PW-03", "Change Password", "Reject wrong current password", "1. Enter wrong current password.\n2. Valid new password.\n3. Submit.", "Error: current password incorrect.", "Know real password for comparison", "", "Pending", "Negative"],
  ["TC-PW-04", "Change Password", "New and confirm mismatch", "1. New != Confirm.\n2. Submit.", "Error: passwords do not match.", "—", "", "Pending", "Negative"],
  ["TC-PW-05", "Change Password", "Google user cannot change password", "1. Login as Google-linked user.\n2. Open change password (if shown).", "Blocked or error message for Google account.", "is_google_user = true", "", "Pending", "Negative"],
  ["TC-DB-01", "Database / DAO", "updateUser writes profile_picture_url", "1. Change avatar.\n2. Query Users.profile_picture_url for user_id.", "Column matches /uploads/avatars/... path.", "SQL Server schema has profile_picture_url", "", "Pending", "Integration"],
  ["TC-AC-01", "Security / RBAC", "RoleBasedAccessFilter blocks wrong role", "1. Login as Customer.\n2. Manually request /vet/dashboard.", "Redirect forbidden or login as per filter.", "—", "", "Pending", "Security"],
  ["TC-AC-02", "Security / RBAC", "Vet can access /vet/* when role Veterinarian", "1. Login as Vet.\n2. Open vet pages.", "200 / normal page.", "Vet user", "", "Pending", "Positive"],
  ["TC-REG-01", "System Test Doc", "Import system test CSV into Template3 sheet", "1. Open System_Test_Cases_Anipats.csv in Excel.\n2. Copy rows into workflow sheets as needed.", "Data aligns with project scope.", "Template3_System-Test.xlsx", "", "Pending", "Process"],
];

const EX_ROWS = [
  ["TC-EX-01", "Vet Examination (GET)", "Missing or non-numeric appointment id", "1. Login as Veterinarian.\n2. Open GET /vet/examination without id or id=abc.", "Redirect to /vet/queue.", "Vet logged in", "Pending", "Negative"],
  ["TC-EX-02", "Vet Examination (GET)", "Appointment does not exist", "1. GET /vet/examination?id=999999999 (invalid id).", "Redirect .../queue?error=notfound", "Vet logged in", "Pending", "Negative"],
  ["TC-EX-03", "Vet Examination (GET)", "User not linked to vet record", "1. Use account without vet mapping.\n2. Request examination for valid id.", "Redirect .../queue?error=unauthorized", "Account without vet_id", "Pending", "Security"],
  ["TC-EX-04", "Vet Examination (GET)", "Invalid appointment status for examination", "1. Open examination for appointment not in Checked-in / In-Examination.", "Redirect .../queue?error=invalidstatus", "Appointment wrong status", "Pending", "Negative"],
  ["TC-EX-05", "Vet Examination (GET)", "Checked-in but claimed by another vet", "1. Vet A claimed; login as Vet B; open same appointment examination.", "Redirect .../queue?error=locked", "Two vet accounts", "Pending", "Negative"],
  ["TC-EX-06", "Vet Examination (GET)", "Vet already has another In-Examination visit", "1. Vet has one visit In-Examination.\n2. Try to open another examination.", "Redirect .../queue?error=busy", "Two eligible appointments", "Pending", "Negative"],
  ["TC-EX-07", "Vet Examination (GET)", "Valid access — form loads", "1. Eligible appointment for this vet.\n2. GET /vet/examination?id={id}.", "Examination page loads: visit, services, prescription, lab section as designed.", "Checked-in or In-Examination for this vet", "Pending", "Positive"],
  ["TC-EX-10", "Vet Examination (POST)", "Save draft (not complete)", "1. On examination form, edit MR/services/prescription.\n2. Submit without action=complete.", "Data saved; redirect back to examination?id=...", "On examination page", "Pending", "Positive"],
  ["TC-EX-11", "Vet Examination (POST)", "Complete visit after validation", "1. Fill diagnosis, at least one service, valid prescription rows.\n2. Submit action=complete.", "Visit completed; appointment Waiting-for-Payment; cancel pending lab if applicable; invoice if fees; notify Receptionist; redirect queue?completed=1", "Valid examination data", "Pending", "Positive / E2E"],
  ["TC-EX-12", "Vet Examination (POST)", "Appointment id does not match vet", "1. Tamper POST appointmentId to another vet's case.", "Redirect /vet/queue", "Vet logged in", "Pending", "Security"],
  ["TC-EX-20", "Vet Examination (UI)", "Complete with empty diagnosis", "1. Leave diagnosis empty.\n2. Click Complete.", "Client validation; error for diagnosis; no submit", "On examination page", "Pending", "Negative"],
  ["TC-EX-21", "Vet Examination (UI)", "Complete with no services", "1. Remove all services.\n2. Click Complete.", "Banner: add at least one service", "On examination page", "Pending", "Negative"],
  ["TC-EX-22", "Vet Examination (UI)", "Prescription dosage / frequency invalid", "1. Enter drug name but invalid dose (non-numeric) or missing frequency.\n2. Complete.", "Prescription validation banner; no submit", "On examination page", "Pending", "Negative"],
  ["TC-EX-23", "Vet Examination (UI)", "Complete with pending lab requests", "1. Have pending lab on visit.\n2. Click Complete.", "Warning modal; option Complete Anyway if implemented", "Pending lab exists", "Pending", "Edge"],
  ["TC-EX-30", "Vet Start Examination (AJAX)", "Start examination from queue", "1. From queue, trigger start examination (AJAX).\n2. Repeat for locked/busy cases.", "JSON success/fail; messages for busy/locked/other vet", "Vet queue data", "Pending", "Integration"],
  ["TC-EX-31", "Vet Lab Request", "Create lab request from examination", "1. On examination, submit lab request form.\n2. Return to examination.", "Request tied to visit; visible in examination lab section", "Examination open", "Pending", "Positive"],
  ["TC-EX-32", "Vet Lab", "View lab result modal", "1. Open examination with lab results.\n2. Use viewer/modal from GET params.", "Result content displayed", "Lab result exists", "Pending", "Positive"],
];

/** WF1: ID, Scenario, Desc, Proc, Expected, Pre, Evid, Round, Note — EX thêm cột Evid rỗng */
const ALL_ROWS = [
  ...SYSTEM_ROWS.map((r) => [...r]),
  ...EX_ROWS.map((r) => [r[0], r[1], r[2], r[3], r[4], r[5], "", r[6], r[7]]),
];

function setCell(ws, row1, col1, value) {
  const addr = XLSX.utils.encode_cell({ r: row1 - 1, c: col1 - 1 });
  const v = value == null ? "" : value;
  ws[addr] = { t: "s", v: String(v) };
}

/** WF1 mẫu: A=ID, B=Test Case Description, C=Procedure, D=Expected, E=Pre, F=Evidents, G=Round 1, … P=Note — gộp Scenario vào B */
function fillWf1StyleSheet(ws, rows, meta) {
  const { workflowTitle, requirement, n } = meta;
  setCell(ws, 2, 2, workflowTitle);
  setCell(ws, 3, 2, requirement);
  setCell(ws, 4, 2, n);
  /** Row Testing Round: B=Passed, C=Failed, D=Pending, E=N/A */
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

  setCell(ws, 11, 1, "Anipats — scenario groups (System + Examination)");
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

/** WF2: no Scenario col, no Evidents — A=ID, B=Desc, C=Proc, D=Expected, E=Pre, F=Round1 ... */
function fillWf2StyleSheet(ws, rows, meta) {
  const { workflowTitle, requirement, n } = meta;
  setCell(ws, 2, 2, workflowTitle);
  setCell(ws, 3, 2, requirement);
  setCell(ws, 4, 2, n);
  /** Row Testing Round: B=Passed, C=Failed, D=Pending, E=N/A */
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

  setCell(ws, 11, 1, "Vet Examination / Lab (chi tiết)");
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
    console.error("Không thấy file mẫu:", SRC);
    process.exit(1);
  }

  const wb = XLSX.readFile(SRC, { cellDates: true, dense: false });

  const wf1 = wb.Sheets["WF1 - Appointment"];
  if (!wf1) {
    console.error("Thiếu sheet WF1 - Appointment");
    process.exit(1);
  }

  const newName = "Anipats System & Examination";
  wb.SheetNames.push(newName);
  wb.Sheets[newName] = cloneSheet(wf1);

  fillWf1StyleSheet(wb.Sheets[newName], ALL_ROWS, {
    workflowTitle: "WF-Anipats: System (PFP, Profile, Receptionist, Owner, Password, RBAC) + Vet Examination",
    requirement:
      "Đầy đủ test case đồng bộ System_Test_Cases_Anipats.csv + TC-EX (khám bệnh). Servlet: VetExaminationServlet, VetStartExaminationServlet, VetLabRequestServlet; JSP: vet/examination.jsp.",
    n: ALL_ROWS.length,
  });

  const wf2 = wb.Sheets["WF2 - Reception Vet"];
  if (wf2) {
    fillWf2StyleSheet(wf2, EX_ROWS, {
      workflowTitle: "WF2 — Lễ tân, Vet khám, Lab (màn khám & lab)",
      requirement:
        "GET/POST examination, validate Complete, lab request, start examination AJAX. Đồng bộ sheet «Anipats System & Examination» (phần TC-EX).",
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
    setCell(idx, 14, 2, "Anipats system + Examination (đầy đủ)");
    setCell(idx, 14, 3, newName);
    setCell(idx, 14, 4, "PFP, Edit Profile, Receptionist, Owner, Password, DB, RBAC, Vet examination GET/POST, lab, AJAX.");
    const iref = XLSX.utils.decode_range(idx["!ref"] || "A1:E20");
    iref.e.r = Math.max(iref.e.r, 13);
    idx["!ref"] = XLSX.utils.encode_range(iref);
  }

  const stat = wb.Sheets["Test Statistics"];
  if (stat) {
    setCell(stat, 11, 2, "Anipats System & Examination (full)");
    setCell(stat, 11, 5, ALL_ROWS.length);
    setCell(stat, 11, 7, ALL_ROWS.length);
    setCell(stat, 12, 2, "WF2 — Reception Vet (Examination focus)");
    setCell(stat, 12, 5, EX_ROWS.length);
    setCell(stat, 12, 7, EX_ROWS.length);
    const sum = ALL_ROWS.length + EX_ROWS.length;
    setCell(stat, 14, 5, sum);
    setCell(stat, 14, 7, sum);
  }

  XLSX.writeFile(wb, OUT, { bookType: "xlsx" });
  console.log("Đã tạo:", OUT);
  console.log("Tổng TC sheet «" + newName + "»:", ALL_ROWS.length, "| WF2 (chỉ TC-EX):", EX_ROWS.length);
}

main();
