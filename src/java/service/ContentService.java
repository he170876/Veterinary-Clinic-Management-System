package service;

import java.util.List;
import java.util.Map;
import model.ContentItem;

public interface ContentService {

    String DEFAULT_LOCALE = "vi";

    String getTextValue(String keyName, String locale, boolean includeDraft, String fallbackValue);

    String getImageUrl(String keyName, String locale, boolean includeDraft, String fallbackUrl);

    String getImageAlt(String keyName, String locale, boolean includeDraft, String fallbackAltText);

    List<ContentItem> getLatestByLocale(String locale, boolean includeDraft);

    boolean saveDraftText(String keyName, String locale, String valueType, String valueText, Integer updatedBy);

    boolean saveDraftImageRef(String keyName, String locale, Long imageId, Integer updatedBy);

    boolean publishKey(String keyName, String locale, Integer updatedBy);

    int publishAllDraftKeys(String locale, Integer updatedBy);

    Map<String, String> getLandingTextDefaults();

    Map<String, String> getLandingImageLabels();
}
