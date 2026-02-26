package service;

import java.util.List;
import java.util.Optional;
import model.Image;

/**
 * Service interface for image-related use cases.
 */
public interface ImageService {

    List<Image> getAllImages();

    List<Image> getImagesBySection(String section);

    Optional<Image> getImageById(long id);

    Image createImage(Image image);

    boolean updateImage(Image image);

    boolean deleteImage(long id);

    List<Image> getAllImagesOrderedBySort();
}
