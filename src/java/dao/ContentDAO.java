package dao;

import java.util.List;
import java.util.Optional;
import model.ContentItem;

public interface ContentDAO {

    Optional<ContentItem> findLatestByKey(String keyName, String locale, boolean includeDraft);

    List<ContentItem> findLatestByLocale(String locale, boolean includeDraft);

    Optional<ContentItem> findLatestDraftByKey(String keyName, String locale);

    int findMaxVersion(String keyName, String locale);

    long create(ContentItem item);

    boolean update(ContentItem item);

    boolean publishKey(String keyName, String locale, Integer updatedBy);
}
