package model;

import java.time.LocalDateTime;

/**
 * Medical record for a visit. Maps to MedicalRecords table.
 */
public class MedicalRecord {

    private int recordId;
    private int visitId;
    private int veterinarianId;
    private String diagnosis;
    private String treatment;
    private String note;
    private LocalDateTime createdAt;

    public int getRecordId() { return recordId; }
    public void setRecordId(int recordId) { this.recordId = recordId; }
    public int getVisitId() { return visitId; }
    public void setVisitId(int visitId) { this.visitId = visitId; }
    public int getVeterinarianId() { return veterinarianId; }
    public void setVeterinarianId(int veterinarianId) { this.veterinarianId = veterinarianId; }
    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }
    public String getTreatment() { return treatment; }
    public void setTreatment(String treatment) { this.treatment = treatment; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
