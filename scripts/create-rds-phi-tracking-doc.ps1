# Creates a small Word file with ONLY:
# (1) Record of Changes rows (PhiNH) - paste into template if needed
# (2) Functional requirement tracking table - same format as backlog spreadsheet
# Fast: does not open the large Template1_RDS-Document.docx

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSScriptRoot -Parent
$outPath  = Join-Path $repoRoot "docs\RDS_Appendix_PhiNH_Functional_Tracking.docx"

$recordRows = @(
  @("V1.1","05/03/2026","A","PhiNH","Laboratory: functional requirement - lab result upload to veterinarian is PDF-only; vet viewer uses PDF embed + open in new tab."),
  @("V1.1","05/03/2026","A","PhiNH","Examination (4.3): validation - diagnosis required, at least one service, prescription dose numeric + frequency, block complete if lab pending."),
  @("V1.1","05/03/2026","A","PhiNH","Functional requirement tracking (this appendix): aligned with backlog - Category, Screen, Actor, Description, Iteration, Status, In charge = PhiNH.")
)

$frTracking = @(
  @("Authentication","Login / Logout / Register / Forgot password / Change password","User","As a user I want secure access and account recovery so that I can use role-based features.","Iter 1","Done","PhiNH"),
  @("Notification","Notification center","Lab, Veterinarian","As lab/vet I want in-app notifications for lab submit/request and billing-related events.","Iter 3","Doing","PhiNH"),
  @("Medical records","Create/update record (examination)","Veterinarian","As a vet I want diagnosis, treatment, services, prescriptions saved during examination.","Iter 2","Done","PhiNH"),
  @("Medical records","Revisit note","Veterinarian","As a vet I want revisit/follow-up notes for continuity of care.","Iter 3","To do","PhiNH"),
  @("Laboratory","Lab queue + Upload result (PDF + note)","Lab staff","As lab staff I want to upload PDF results and notes so the vet can review.","Iter 3","Done","PhiNH"),
  @("Laboratory","View lab result (vet)","Veterinarian","As a vet I want to open completed lab results (PDF) from examination before completing the visit.","Iter 2-3","Done","PhiNH"),
  @("Examination","Patient examination","Veterinarian","As a vet I want to request lab tests, save progress, and complete visit when labs are done and validations pass.","Iter 1-2","Done","PhiNH"),
  @("Receptionist","Check-in / Staff queue / Appointments","Receptionist","As receptionist I want check-in and appointment management to align visit flow.","Iter 2","Done","PhiNH")
)

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$doc = $null
try {
  $doc = $word.Documents.Add()
  $doc.Content.Text = ""

  $r = $doc.Paragraphs.First.Range
  $r.Text = "RDS - Record of Changes (rows to merge) - PhiNH`r`n"
  $r.Style = "Heading 1"
  $r.InsertParagraphAfter()

  $t1 = $doc.Tables.Add($doc.Paragraphs.Last.Range, $recordRows.Count + 1, 5)
  $h1 = @("Version","Date","A/M/D","In charge","Change Description")
  for ($c = 0; $c -lt 5; $c++) { $t1.Cell(1, $c + 1).Range.Text = $h1[$c] }
  for ($r = 0; $r -lt $recordRows.Count; $r++) {
    for ($c = 0; $c -lt 5; $c++) { $t1.Cell($r + 2, $c + 1).Range.Text = $recordRows[$r][$c] }
  }
  $doc.Paragraphs.Add() | Out-Null

  $r2 = $doc.Paragraphs.Last.Range
  $r2.Text = "Functional requirement tracking (format: Screen / Function backlog) - In charge PhiNH`r`n"
  $r2.Style = "Heading 1"
  $r2.InsertParagraphAfter()

  $t2 = $doc.Tables.Add($doc.Paragraphs.Last.Range, $frTracking.Count + 1, 7)
  $h2 = @("Category","Screen / Function","Actor","Description (user story)","Iteration","Status","In charge")
  for ($c = 0; $c -lt 7; $c++) { $t2.Cell(1, $c + 1).Range.Text = $h2[$c] }
  for ($r = 0; $r -lt $frTracking.Count; $r++) {
    for ($c = 0; $c -lt 7; $c++) { $t2.Cell($r + 2, $c + 1).Range.Text = $frTracking[$r][$c] }
  }

  $doc.Paragraphs.Add() | Out-Null
  $doc.Paragraphs.Last.Range.Text = "Instructions: Copy the tables above into Template1_RDS-Document.docx - Record of Changes section and II. Functional Requirements / appendix as required.`r`n"

  $outDir = Split-Path $outPath -Parent
  if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
  $doc.SaveAs2($outPath, 16)
  Write-Host "OK: $outPath"
}
finally {
  if ($null -ne $doc) { $doc.Close($false) | Out-Null }
  if ($null -ne $word) { $word.Quit() | Out-Null; [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) }
}
