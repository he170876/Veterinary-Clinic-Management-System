package service.impl;

import dao.ContentDAO;
import dao.ImageDAO;
import dao.impl.ContentJdbcDAO;
import dao.impl.ImageJdbcDAO;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import model.ContentItem;
import model.Image;
import service.ContentService;

public class ContentServiceImpl implements ContentService {

    private final ContentDAO contentDAO;
    private final ImageDAO imageDAO;

    private static final Map<String, String> LANDING_TEXT_DEFAULTS;
    private static final Map<String, String> LANDING_IMAGE_LABELS;

    static {
        Map<String, String> textDefaults = new LinkedHashMap<>();
        textDefaults.put("home.meta.title", "Anipats - Professional Veterinary Medical Center");
        textDefaults.put("home.topbar.phone", "+1 (555) 000-1234");
        textDefaults.put("home.topbar.email", "contact@anipats.com");
        textDefaults.put("home.topbar.follow", "Follow us:");

        textDefaults.put("home.hero.kicker", "Professional Vet Care");
        textDefaults.put("home.hero.title", "We Care Your Pets");
        textDefaults.put("home.hero.subtitle", "Professional veterinary medical center providing specialized care for your beloved animal companions. Expert medical standards meets compassionate care.");
        textDefaults.put("home.hero.cta_primary", "Get Started");
        textDefaults.put("home.hero.cta_secondary", "Our Services");

        textDefaults.put("home.stats.clients.label", "Happy Clients");
        textDefaults.put("home.stats.pets.label", "Pets Available");
        textDefaults.put("home.stats.vets.label", "Expert Vets");
        textDefaults.put("home.stats.guarantee.label", "Care Guarantee");

        textDefaults.put("home.services.kicker", "What we do");
        textDefaults.put("home.services.title", "Our Specialized Services");
        textDefaults.put("home.services.card1.title", "Pet Boarding");
        textDefaults.put("home.services.card1.body", "Safe and comfortable home away from home. 24/7 supervision and climate-controlled luxury suites for your pets.");
        textDefaults.put("home.services.card2.title", "Healthy Meals");
        textDefaults.put("home.services.card2.body", "Nutritious plans tailored for your pet's needs. Customized diet plans designed by our in-house nutritionists.");
        textDefaults.put("home.services.card3.title", "Pet Spa");
        textDefaults.put("home.services.card3.body", "Professional grooming and relaxation services. Aromatherapy, massage, and therapeutic baths for ultimate comfort.");
        textDefaults.put("home.services.learn_more", "Learn More");

        textDefaults.put("home.about.kicker", "About Anipats");
        textDefaults.put("home.about.title", "Exceptional Pet Care Standards");
        textDefaults.put("home.about.body", "Our team of expert veterinarians ensures your pets receive the highest quality medical attention with modern equipment and heartfelt care. We treat every animal like our own family.");
        textDefaults.put("home.about.bullet1", "Modern Medical Technology");
        textDefaults.put("home.about.bullet2", "24/7 Emergency Support");
        textDefaults.put("home.about.bullet3", "Certified Pet Nutritionists");
        textDefaults.put("home.about.cta", "Learn More About Us");

        textDefaults.put("home.team.kicker", "Our Experts");
        textDefaults.put("home.team.title", "Meet Our Professional Team");

        textDefaults.put("home.footer.brand", "Anipats");
        textDefaults.put("home.footer.about", "Setting the gold standard in pet healthcare. Modern medical expertise with heart and compassion since 2010.");
        textDefaults.put("home.footer.quick_links", "Quick Links");
        textDefaults.put("home.footer.quick.home", "Home Page");
        textDefaults.put("home.footer.quick.about", "About Us");
        textDefaults.put("home.footer.quick.services", "Medical Services");
        textDefaults.put("home.footer.quick.adoption", "Pet Adoption");
        textDefaults.put("home.footer.quick.pros", "Our Professionals");
        textDefaults.put("home.footer.quick.dashboard", "Dashboard");
        textDefaults.put("home.footer.quick.logout", "Logout");
        textDefaults.put("home.footer.quick.login", "Login");
        textDefaults.put("home.footer.quick.register", "Register");
        textDefaults.put("home.footer.contact_title", "Get In Touch");
        textDefaults.put("home.footer.newsletter_title", "Newsletter");
        textDefaults.put("home.footer.newsletter_body", "Get healthy pet tips and news delivered to your inbox weekly.");
        textDefaults.put("home.footer.newsletter_placeholder", "Your Email Address");
        textDefaults.put("home.footer.newsletter_button", "Subscribe Now");
        textDefaults.put("home.footer.location", "123 Medical Plaza, Downtown, NY 10001");
        textDefaults.put("home.footer.phone", "+1 (555) 000-1234");
        textDefaults.put("home.footer.email", "emergency@anipats.com");
        textDefaults.put("home.footer.copyright_suffix", "Anipats Veterinary Medical Center. All rights reserved.");
        textDefaults.put("home.footer.privacy", "Privacy Policy");
        textDefaults.put("home.footer.terms", "Terms of Service");

        textDefaults.put("home.book_modal.title", "Book Appointment");

        LANDING_TEXT_DEFAULTS = Collections.unmodifiableMap(textDefaults);

        Map<String, String> imageLabels = new LinkedHashMap<>();
        imageLabels.put("home.hero.banner.image", "Hero Banner Image");
        imageLabels.put("home.about.image.1", "About Section Image 1");
        imageLabels.put("home.about.image.2", "About Section Image 2");
        LANDING_IMAGE_LABELS = Collections.unmodifiableMap(imageLabels);
    }

    public ContentServiceImpl() {
        this.contentDAO = new ContentJdbcDAO();
        this.imageDAO = new ImageJdbcDAO();
    }

    @Override
    public String getTextValue(String keyName, String locale, boolean includeDraft, String fallbackValue) {
        Optional<ContentItem> itemOpt = contentDAO.findLatestByKey(keyName, normalizeLocale(locale), includeDraft);
        if (!itemOpt.isPresent()) {
            return fallbackValue;
        }

        ContentItem item = itemOpt.get();
        if (item.getValueText() == null || item.getValueText().trim().isEmpty()) {
            return fallbackValue;
        }
        return item.getValueText();
    }

    @Override
    public String getImageUrl(String keyName, String locale, boolean includeDraft, String fallbackUrl) {
        Optional<ContentItem> itemOpt = contentDAO.findLatestByKey(keyName, normalizeLocale(locale), includeDraft);
        if (!itemOpt.isPresent() || itemOpt.get().getImageId() == null) {
            return fallbackUrl;
        }

        Optional<Image> imageOpt = imageDAO.findById(itemOpt.get().getImageId());
        if (!imageOpt.isPresent() || imageOpt.get().getUrl() == null || imageOpt.get().getUrl().trim().isEmpty()) {
            return fallbackUrl;
        }
        return imageOpt.get().getUrl();
    }

    @Override
    public String getImageAlt(String keyName, String locale, boolean includeDraft, String fallbackAltText) {
        Optional<ContentItem> itemOpt = contentDAO.findLatestByKey(keyName, normalizeLocale(locale), includeDraft);
        if (!itemOpt.isPresent() || itemOpt.get().getImageId() == null) {
            return fallbackAltText;
        }

        Optional<Image> imageOpt = imageDAO.findById(itemOpt.get().getImageId());
        if (!imageOpt.isPresent() || imageOpt.get().getAltText() == null || imageOpt.get().getAltText().trim().isEmpty()) {
            return fallbackAltText;
        }
        return imageOpt.get().getAltText();
    }

    @Override
    public List<ContentItem> getLatestByLocale(String locale, boolean includeDraft) {
        return contentDAO.findLatestByLocale(normalizeLocale(locale), includeDraft);
    }

    @Override
    public boolean saveDraftText(String keyName, String locale, String valueType, String valueText, Integer updatedBy) {
        String safeType = sanitizeTextType(valueType);
        String safeLocale = normalizeLocale(locale);

        Optional<ContentItem> draftOpt = contentDAO.findLatestDraftByKey(keyName, safeLocale);
        if (draftOpt.isPresent()) {
            ContentItem draft = draftOpt.get();
            draft.setValueType(safeType);
            draft.setValueText(valueText);
            draft.setImageId(null);
            draft.setUpdatedBy(updatedBy);
            return contentDAO.update(draft);
        }

        ContentItem item = new ContentItem();
        item.setKeyName(keyName);
        item.setLocale(safeLocale);
        item.setStatus("draft");
        item.setVersion(contentDAO.findMaxVersion(keyName, safeLocale) + 1);
        item.setValueType(safeType);
        item.setValueText(valueText);
        item.setImageId(null);
        item.setUpdatedBy(updatedBy);
        return contentDAO.create(item) > 0;
    }

    @Override
    public boolean saveDraftImageRef(String keyName, String locale, Long imageId, Integer updatedBy) {
        String safeLocale = normalizeLocale(locale);

        Optional<ContentItem> draftOpt = contentDAO.findLatestDraftByKey(keyName, safeLocale);
        if (draftOpt.isPresent()) {
            ContentItem draft = draftOpt.get();
            draft.setValueType("image_ref");
            draft.setValueText(null);
            draft.setImageId(imageId);
            draft.setUpdatedBy(updatedBy);
            return contentDAO.update(draft);
        }

        ContentItem item = new ContentItem();
        item.setKeyName(keyName);
        item.setLocale(safeLocale);
        item.setStatus("draft");
        item.setVersion(contentDAO.findMaxVersion(keyName, safeLocale) + 1);
        item.setValueType("image_ref");
        item.setValueText(null);
        item.setImageId(imageId);
        item.setUpdatedBy(updatedBy);
        return contentDAO.create(item) > 0;
    }

    @Override
    public boolean publishKey(String keyName, String locale, Integer updatedBy) {
        return contentDAO.publishKey(keyName, normalizeLocale(locale), updatedBy);
    }

    @Override
    public int publishAllDraftKeys(String locale, Integer updatedBy) {
        int total = 0;
        List<ContentItem> latestItems = getLatestByLocale(locale, true);
        for (ContentItem item : latestItems) {
            if (item != null && "draft".equalsIgnoreCase(item.getStatus())) {
                if (publishKey(item.getKeyName(), locale, updatedBy)) {
                    total++;
                }
            }
        }
        return total;
    }

    @Override
    public Map<String, String> getLandingTextDefaults() {
        return LANDING_TEXT_DEFAULTS;
    }

    @Override
    public Map<String, String> getLandingImageLabels() {
        return LANDING_IMAGE_LABELS;
    }

    private String normalizeLocale(String locale) {
        if (locale == null || locale.trim().isEmpty()) {
            return DEFAULT_LOCALE;
        }
        return locale.trim().toLowerCase();
    }

    private String sanitizeTextType(String valueType) {
        if ("textarea".equalsIgnoreCase(valueType) || "richtext".equalsIgnoreCase(valueType) || "json".equalsIgnoreCase(valueType)) {
            return valueType.toLowerCase();
        }
        return "text";
    }
}
