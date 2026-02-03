package service.impl;

import dao.ServiceDAO;
import dao.impl.ServiceJdbcDAO;
import java.util.List;
import java.util.Optional;
import model.Service;
import service.ServiceService;

/**
 * Default implementation of {@link ServiceService}.
 */
public class ServiceServiceImpl implements ServiceService {

    private final ServiceDAO serviceDAO;

    public ServiceServiceImpl() {
        this.serviceDAO = new ServiceJdbcDAO();
    }

    @Override
    public List<Service> getAllServices() {
        return serviceDAO.findAll();
    }

    @Override
    public List<Service> getServicesByCategory(String category) {
        return serviceDAO.findByCategory(category);
    }

    @Override
    public Optional<Service> getServiceById(int serviceId) {
        return serviceDAO.findById(serviceId);
    }

    @Override
    public Service createService(Service service) {
        return serviceDAO.create(service);
    }

    @Override
    public boolean updateService(Service service) {
        return serviceDAO.update(service);
    }

    @Override
    public boolean deleteService(int serviceId) {
        return serviceDAO.delete(serviceId);
    }
}