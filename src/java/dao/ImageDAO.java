package dao;

import java.util.List;
import java.util.Optional;
import model.Image;

/**
 * DAO interface for accessing Images.
 */
public interface ImageDAO {
    
    List<Image> findAll();
    
    List<Image> findBySection(String section);
    
    Optional<Image> findById(long id);
    
    Image create(Image image);
    
    boolean update(Image image);
    
    boolean delete(long id);
    
    List<Image> findAllOrderBySort();
}
