package dao;

import java.util.List;
import java.util.Optional;
import model.Service;

/**
 * DAO interface for accessing Services.
 */
public interface ServiceDAO {

    List<Service> findAll();

    List<Service> findByCategory(String category);

    Optional<Service> findById(int serviceId);

    boolean existsByName(String name);

    Optional<Service> findDeletedExactMatch(String name, double price, String description);

    boolean restore(int serviceId);

    Service create(Service service);

    boolean update(Service service);

    boolean delete(int serviceId);
}