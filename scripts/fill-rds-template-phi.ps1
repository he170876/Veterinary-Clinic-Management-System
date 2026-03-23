# Fills Template1_RDS-Document.docx: Record of Changes (PhiNH) + Appendix FR tracking table.
# Requires Microsoft Word installed. Run locally if Word COM is slow on large templates.
# Alternative: use docs/RDS_Appendix_PhiNH_Functional_Tracking.html - open in Word, Save As .docx, then merge.

$ErrorActionPreference = "Stop"
$templatePath = "c:\Users\Admin\Downloads\Template1_RDS-Document.docx"
$repoRoot = Split-Path $PSScriptRoot -Parent
$outPath  = Join-Path $repoRoot "docs\RDS-Document_Template1_PhiNH_Filled.docx"

if (-not (Test-Path $templatePath)) {
  Write-Error "Template not found: $templatePath"
}

$recordRows = @(
  @{ Ver="V1.1"; Date="05/03/2026"; AMD="A"; Who="PhiNH"; Desc="Laboratory: functional requirement - lab result upload to veterinarian is PDF-only; vet viewer uses PDF embed + open in new tab." },
  @{ Ver="V1.1"; Date="05/03/2026"; AMD="A"; Who="PhiNH"; Desc="Examination (4.3): validation rules - diagnosis required, at least one service, prescription dose numeric + frequency, block complete if lab pending." },
  @{ Ver="V1.1"; Date="05/03/2026"; AMD="A"; Who="PhiNH"; Desc="Functional requirement tracking table (Appendix A): screen/function list with Actor, Iteration, Status, In charge = PhiNH (aligned with backlog spreadsheet)." }
)

$frTracking = @(
  @{ Cat="Authentication"; Screen="Login / Logout / Register / Forgot password / Change password"; Actor="User"; Story="As a user I want secure access and account recovery so that I can use role-based features."; Iter="Iter 1"; Stat="Done"; Who="PhiNH" },
  @{ Cat="Notification"; Screen="Notification center"; Actor="Lab, Veterinarian"; Story="As lab/vet I want in-app notifications for lab submit/request and billing-related events."; Iter="Iter 3"; Stat="Doing"; Who="PhiNH" },
  @{ Cat="Medical records"; Screen="Create/update record (examination)"; Actor="Veterinarian"; Story="As a vet I want diagnosis, treatment, services, prescriptions saved during examination."; Iter="Iter 2"; Stat="Done"; Who="PhiNH" },
  @{ Cat="Medical records"; Screen="Revisit note"; Actor="Veterinarian"; Story="As a vet I want revisit/follow-up notes for continuity of care."; Iter="Iter 3"; Stat="To do"; Who="PhiNH" },
  @{ Cat="Laboratory"; Screen="Lab queue + Upload result (PDF + note)"; Actor="Lab staff"; Story="As lab staff I want to upload PDF results and notes so the vet can review."; Iter="Iter 3"; Stat="Done"; Who="PhiNH" },
  @{ Cat="Laboratory"; Screen="View lab result (vet)"; Actor="Veterinarian"; Story="As a vet I want to open completed lab results (PDF) from examination before completing the visit."; Iter="Iter 2-3"; Stat="Done"; Who="PhiNH" },
  @{ Cat="Examination"; Screen="Patient examination"; Actor="Veterinarian"; Story="As a vet I want to request lab tests, save progress, and complete visit when labs are done and validations pass."; Iter="Iter 1-2"; Stat="Done"; Who="PhiNH" },
  @{ Cat="Receptionist"; Screen="Check-in / Staff queue / Appointments"; Actor="Receptionist"; Story="As receptionist I want check-in and appointment management to align visit flow."; Iter="Iter 2"; Stat="Done"; Who="PhiNH" }
)

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$doc = $null
try {
  $doc = $word.Documents.Open($templatePath, $false, $false)

  function Get-CellCleanText($cell) {
    ($cell.Range.Text -replace "(`r|`n|\x07|\a)", "").Trim()
  }
  $targetTable = $null
  for ($i = 1; $i -le $doc.Tables.Count; $i++) {
    $t = $doc.Tables.Item($i)
    for ($rr = 1; $rr -le [Math]::Min(3, $t.Rows.Count); $rr++) {
      try {
        $c1 = Get-CellCleanText $t.Cell($rr, 1)
        if ($c1 -eq "Version") {
          $targetTable = $t
          break
        }
      } catch { }
    }
    if ($null -ne $targetTable) { break }
  }

  if ($null -eq $targetTable) {
    Write-Warning "Table with header 'Version' not found; skipping Record of Changes rows."
  } else {
    foreach ($r in $recordRows) {
      $newRow = $targetTable.Rows.Add()
      $newRow.Cells.Item(1).Range.Text = $r.Ver
      $newRow.Cells.Item(2).Range.Text = $r.Date
      $newRow.Cells.Item(3).Range.Text = $r.AMD
      $newRow.Cells.Item(4).Range.Text = $r.Who
      $newRow.Cells.Item(5).Range.Text = $r.Desc
    }
  }

  $end = $doc.Content
  $end.InsertAfter("`r`n")
  $rng = $doc.Content
  $rng.Collapse(0)

  $p = $doc.Paragraphs.Add($rng)
  $p.Range.Text = "Appendix A - Functional requirement tracking (PhiNH)"
  $p.Range.Style = "Heading 1"
  $p.Range.InsertParagraphAfter()

  $p2 = $doc.Paragraphs.Add($doc.Paragraphs.Last.Range)
  $p2.Range.Text = "The following table follows the functional-requirement backlog format: category, screen/function, actor, user story, iteration, status, and in charge (PhiNH)."
  $p2.Range.Style = "Normal"
  $p2.Range.InsertParagraphAfter()

  $nRows = $frTracking.Count + 1
  $nCols = 7
  $tblRange = $doc.Paragraphs.Last.Range
  $tblRange.Collapse(0)
  $frTbl = $doc.Tables.Add($tblRange, $nRows, $nCols)

  $headers = @("Category", "Screen / Function", "Actor", "Description (user story)", "Iteration", "Status", "In charge")
  for ($c = 0; $c -lt $headers.Count; $c++) {
    $frTbl.Cell(1, $c + 1).Range.Text = $headers[$c]
  }
  for ($r = 0; $r -lt $frTracking.Count; $r++) {
    $row = $frTracking[$r]
    $frTbl.Cell($r + 2, 1).Range.Text = $row.Cat
    $frTbl.Cell($r + 2, 2).Range.Text = $row.Screen
    $frTbl.Cell($r + 2, 3).Range.Text = $row.Actor
    $frTbl.Cell($r + 2, 4).Range.Text = $row.Story
    $frTbl.Cell($r + 2, 5).Range.Text = $row.Iter
    $frTbl.Cell($r + 2, 6).Range.Text = $row.Stat
    $frTbl.Cell($r + 2, 7).Range.Text = $row.Who
  }

  $outDir = Split-Path $outPath -Parent
  if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
  $fmt = 16 # wdFormatDocumentDefault (Word 2007+ .docx)
  $doc.SaveAs2($outPath, $fmt)
  Write-Host "Saved: $outPath"
}
finally {
  if ($null -ne $doc) { $doc.Close($false) | Out-Null }
  if ($null -ne $word) { $word.Quit() | Out-Null; [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) }
}
