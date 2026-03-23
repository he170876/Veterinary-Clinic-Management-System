package model;

import java.time.LocalDateTime;

/** Summary of a lab result for display (test name, note, date). */
public class LabResultSummary {
    private String testName;
    private String resultNote;
    private LocalDateTime resultDate;
    private String petName;
    private String status;  // Critical, Normal, Pending

    public String getTestName() { return testName; }
    public void setTestName(String testName) { this.testName = testName; }
    public String getResultNote() { return resultNote; }
    public void setResultNote(String resultNote) { this.resultNote = resultNote; }
    public LocalDateTime getResultDate() { return resultDate; }
    public void setResultDate(LocalDateTime resultDate) { this.resultDate = resultDate; }
    public String getPetName() { return petName; }
    public void setPetName(String petName) { this.petName = petName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
