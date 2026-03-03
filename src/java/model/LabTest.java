package model;

/**
 * Lab test type. Maps to LabTests table.
 */
public class LabTest {

    private int testId;
    private String testName;
    private String description;
    private String normalRange;
    private String unit;
    private String status;

    public int getTestId() { return testId; }
    public void setTestId(int testId) { this.testId = testId; }
    public String getTestName() { return testName; }
    public void setTestName(String testName) { this.testName = testName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getNormalRange() { return normalRange; }
    public void setNormalRange(String normalRange) { this.normalRange = normalRange; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
