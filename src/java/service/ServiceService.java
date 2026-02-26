package service;

import java.util.List;
import java.util.Optional;
import model.Service;

/**
 * Service interface for service-related use cases.
 */
public interface ServiceService {

    List<Service> getAllServices();

    List<Service> getServicesByCategory(String category);

    Optional<Service> getServiceById(int serviceId);

    Service createService(Service service);

    boolean updateService(Service service);

    boolean deleteService(int serviceId);
}