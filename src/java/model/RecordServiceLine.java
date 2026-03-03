package model;

/**
 * One line of MedicalRecordServices (record_id, service_id, quantity, price) with service name for display.
 */
public class RecordServiceLine {

    private int recordServiceId;
    private int recordId;
    private int serviceId;
    private String serviceName;
    private int quantity;
    private Double price;

    public int getRecordServiceId() { return recordServiceId; }
    public void setRecordServiceId(int recordServiceId) { this.recordServiceId = recordServiceId; }
    public int getRecordId() { return recordId; }
    public void setRecordId(int recordId) { this.recordId = recordId; }
    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }
    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }
}
