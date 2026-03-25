package model;

import java.time.LocalDateTime;

/**
 * Domain model representing a Medical Record, mapped to the MedicalRecords table.
 */
public class MedicalRecord {

    private int recordId;
    private int visitId;
    private Pet pet;
    private int veterinarianId;
    private String veterinarianName;
    private String diagnosis;
    private String conclusion;
    private String note;
    /** Mã trạng thái lâm sàng: stable, monitoring, follow_up, urgent, critical */
    private String clinicalCondition;
    private LocalDateTime visitDate;
    private String visitStatus;
    private LocalDateTime createdAt;

    public MedicalRecord() {
    }

    public MedicalRecord(int recordId, int visitId, Pet pet, int veterinarianId,
            String veterinarianName, String diagnosis, String conclusion,
            String note, LocalDateTime visitDate, String visitStatus) {
        this.recordId = recordId;
        this.visitId = visitId;
        this.pet = pet;
        this.veterinarianId = veterinarianId;
        this.veterinarianName = veterinarianName;
        this.diagnosis = diagnosis;
        this.conclusion = conclusion;
        this.note = note;
        this.visitDate = visitDate;
        this.visitStatus = visitStatus;
    }

    public int getRecordId() {
        return recordId;
    }

    public void setRecordId(int recordId) {
        this.recordId = recordId;
    }

    public int getVisitId() {
        return visitId;
    }

    public void setVisitId(int visitId) {
        this.visitId = visitId;
    }

    public Pet getPet() {
        return pet;
    }

    public void setPet(Pet pet) {
        this.pet = pet;
    }

    public int getVeterinarianId() {
        return veterinarianId;
    }

    public void setVeterinarianId(int veterinarianId) {
        this.veterinarianId = veterinarianId;
    }

    public String getVeterinarianName() {
        return veterinarianName;
    }

    public void setVeterinarianName(String veterinarianName) {
        this.veterinarianName = veterinarianName;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public String getConclusion() {
        return conclusion;
    }

    public void setConclusion(String conclusion) {
        this.conclusion = conclusion;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getClinicalCondition() {
        return clinicalCondition;
    }

    public void setClinicalCondition(String clinicalCondition) {
        this.clinicalCondition = clinicalCondition;
    }

    public LocalDateTime getVisitDate() {
        return visitDate;
    }

    public void setVisitDate(LocalDateTime visitDate) {
        this.visitDate = visitDate;
    }

    public String getVisitStatus() {
        return visitStatus;
    }

    public void setVisitStatus(String visitStatus) {
        this.visitStatus = visitStatus;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "MedicalRecord{" +
                "recordId=" + recordId +
                ", visitId=" + visitId +
                ", pet=" + (pet != null ? pet.getName() : "null") +
                ", veterinarianName='" + veterinarianName + '\'' +
                ", diagnosis='" + diagnosis + '\'' +
                ", conclusion='" + conclusion + '\'' +
                ", visitDate=" + visitDate +
                '}';
    }
}
