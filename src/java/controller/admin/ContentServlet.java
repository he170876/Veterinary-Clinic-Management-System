package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import model.ContentItem;
import model.Image;
import model.User;
import service.ContentService;
import service.ImageService;
import service.impl.ContentServiceImpl;
import service.impl.ImageServiceImpl;

@WebServlet(name = "ContentServlet", urlPatterns = {"/owner/content"})
public class ContentServlet extends HttpServlet {

    private ContentService contentService;
    private ImageService imageService;

    @Override
    public void init() throws ServletException {
        this.contentService = new ContentServiceImpl();
        this.imageService = new ImageServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getAuthorizedUserOrRedirect(request, response);
        if (currentUser == null) {
            return;
        }

        String locale = normalizeLocale(request.getParameter("locale"));

        List<ContentItem> latest = contentService.getLatestByLocale(locale, true);
        Map<String, ContentItem> byKey = new HashMap<>();
        for (ContentItem item : latest) {
            byKey.put(item.getKeyName(), item);
        }

        List<Image> images = imageService.getAllImagesOrderedBySort();

        request.setAttribute("locale", locale);
        request.setAttribute("contentByKey", byKey);
        request.setAttribute("textDefaults", contentService.getLandingTextDefaults());
        request.setAttribute("imageLabels", contentService.getLandingImageLabels());
        request.setAttribute("images", images);

        HttpSession session = request.getSession(false);
        if (session != null) {
            Object publishAllCount = session.getAttribute("contentPublishAllCount");
            Object publishAllKeys = session.getAttribute("contentPublishAllKeys");

            if (publishAllCount != null) {
                request.setAttribute("publishedAllCount", publishAllCount);
                session.removeAttribute("contentPublishAllCount");
            }
            if (publishAllKeys != null) {
                request.setAttribute("publishedAllKeys", publishAllKeys);
                session.removeAttribute("contentPublishAllKeys");
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/content.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());

        User currentUser = getAuthorizedUserOrRedirect(request, response);
        if (currentUser == null) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        String locale = normalizeLocale(request.getParameter("locale"));

        if ("save_text".equals(action)) {
            saveText(request, response, currentUser, locale);
            return;
        }

        if ("save_image".equals(action)) {
            saveImage(request, response, currentUser, locale);
            return;
        }

        if ("publish_key".equals(action)) {
            publishKey(request, response, currentUser, locale);
            return;
        }

        if ("publish_all".equals(action)) {
            List<String> draftKeys = collectLatestDraftKeys(locale);
            int published = contentService.publishAllDraftKeys(locale, currentUser.getUserId());

            HttpSession session = request.getSession();
            session.setAttribute("contentPublishAllCount", published);
            session.setAttribute("contentPublishAllKeys", draftKeys);

            response.sendRedirect(request.getContextPath() + "/owner/content?locale=" + encode(locale));
            return;
        }

        redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                "error", "Invalid action");
    }

    private void saveText(HttpServletRequest request, HttpServletResponse response, User user, String locale)
            throws IOException {
        String key = safeTrim(request.getParameter("keyName"));
        String valueType = safeTrim(request.getParameter("valueType"));
        String valueText = request.getParameter("valueText");

        if (key == null || !contentService.getLandingTextDefaults().containsKey(key)) {
            redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                    "error", "Invalid text key");
            return;
        }

        boolean ok = contentService.saveDraftText(key, locale, valueType, valueText, user.getUserId());
        redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                ok ? "saved" : "error",
                ok ? key : "Could not save text");
    }

    private void saveImage(HttpServletRequest request, HttpServletResponse response, User user, String locale)
            throws IOException {
        String key = safeTrim(request.getParameter("keyName"));
        String imageIdRaw = safeTrim(request.getParameter("imageId"));

        if (key == null || !contentService.getLandingImageLabels().containsKey(key)) {
            redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                    "error", "Invalid image key");
            return;
        }

        Long imageId = null;
        try {
            if (imageIdRaw != null && !imageIdRaw.isEmpty()) {
                imageId = Long.parseLong(imageIdRaw);
            }
        } catch (NumberFormatException e) {
            redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                    "error", "Invalid image id");
            return;
        }

        boolean ok = contentService.saveDraftImageRef(key, locale, imageId, user.getUserId());
        redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                ok ? "saved" : "error",
                ok ? key : "Could not save image");
    }

    private void publishKey(HttpServletRequest request, HttpServletResponse response, User user, String locale)
            throws IOException {
        String key = safeTrim(request.getParameter("keyName"));
        if (key == null) {
            redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                    "error", "Missing key");
            return;
        }

        boolean isValid = contentService.getLandingTextDefaults().containsKey(key)
                || contentService.getLandingImageLabels().containsKey(key);
        if (!isValid) {
            redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                    "error", "Invalid key");
            return;
        }

        boolean ok = contentService.publishKey(key, locale, user.getUserId());
        redirectWithMessage(response, request.getContextPath() + "/owner/content?locale=" + encode(locale),
                ok ? "published" : "error",
                ok ? key : "No draft to publish");
    }

    private User getAuthorizedUserOrRedirect(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        Object userObj = session.getAttribute("currentUser");
        if (!(userObj instanceof User)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User user = (User) userObj;
        if (!hasOwnerContentAccess(user)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?forbidden=1");
            return null;
        }
        return user;
    }

    private boolean hasOwnerContentAccess(User user) {
        if (user == null || user.getRole() == null || user.getRole().getRoleName() == null) {
            return false;
        }
        String normalizedRole = user.getRole().getRoleName()
                .trim()
                .toLowerCase()
                .replace("_", "")
                .replace(" ", "");

        return "admin".equals(normalizedRole)
                || "clinicowner".equals(normalizedRole)
                || "owner".equals(normalizedRole);
    }

    private String normalizeLocale(String locale) {
        if (locale == null || locale.trim().isEmpty()) {
            return ContentService.DEFAULT_LOCALE;
        }
        return locale.trim().toLowerCase();
    }

    private String safeTrim(String s) {
        return s == null ? null : s.trim();
    }

    private List<String> collectLatestDraftKeys(String locale) {
        List<ContentItem> latestItems = contentService.getLatestByLocale(locale, true);
        Set<String> keys = new LinkedHashSet<>();
        for (ContentItem item : latestItems) {
            if (item == null || item.getKeyName() == null) {
                continue;
            }

            boolean isDraft = "draft".equalsIgnoreCase(item.getStatus());
            if (!isDraft) {
                continue;
            }

            String keyName = item.getKeyName();
            boolean allowedKey = contentService.getLandingTextDefaults().containsKey(keyName)
                    || contentService.getLandingImageLabels().containsKey(keyName);
            if (allowedKey) {
                keys.add(keyName);
            }
        }
        return new ArrayList<>(keys);
    }

    private void redirectWithMessage(HttpServletResponse response, String baseUrl, String key, String value)
            throws IOException {
        response.sendRedirect(baseUrl + "&" + key + "=" + encode(value));
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
