package service.impl;

import dao.ImageDAO;
import dao.impl.ImageJdbcDAO;
import java.util.List;
import java.util.Optional;
import model.Image;
import service.ImageService;

/**
 * Default implementation of {@link ImageService}.
 */
public class ImageServiceImpl implements ImageService {

    private final ImageDAO imageDAO;

    public ImageServiceImpl() {
        this.imageDAO = new ImageJdbcDAO();
    }

    @Override
    public List<Image> getAllImages() {
        return imageDAO.findAll();
    }

    @Override
    public List<Image> getImagesBySection(String section) {
        return imageDAO.findBySection(section);
    }

    @Override
    public Optional<Image> getImageById(long id) {
        return imageDAO.findById(id);
    }

    @Override
    public Image createImage(Image image) {
        return imageDAO.create(image);
    }

    @Override
    public boolean updateImage(Image image) {
        return imageDAO.update(image);
    }

    @Override
    public boolean deleteImage(long id) {
        return imageDAO.delete(id);
    }

    @Override
    public List<Image> getAllImagesOrderedBySort() {
        return imageDAO.findAllOrderBySort();
    }
}
