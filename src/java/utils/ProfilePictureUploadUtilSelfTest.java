package utils;

import model.User;

/**
 * Chạy từ IDE: Run {@code main} (không cần server) để kiểm tra logic ảnh đại diện.
 */
public final class ProfilePictureUploadUtilSelfTest {

    private ProfilePictureUploadUtilSelfTest() {
    }

    public static void main(String[] args) {
        int fail = 0;
        if (!"jpg".equals(ProfilePictureUploadUtil.resolveImageExtension("image/jpeg", "x.jpg"))) {
            fail++;
            System.err.println("FAIL: jpeg + filename");
        }
        if (!"jpg".equals(ProfilePictureUploadUtil.resolveImageExtension("image/jpeg", null))) {
            fail++;
            System.err.println("FAIL: jpeg only");
        }
        if (!"png".equals(ProfilePictureUploadUtil.resolveImageExtension("application/octet-stream", "a.PNG"))) {
            fail++;
            System.err.println("FAIL: octet-stream + png name");
        }
        if (!"webp".equals(ProfilePictureUploadUtil.resolveImageExtension(null, "x.webp"))) {
            fail++;
            System.err.println("FAIL: webp from filename");
        }
        User u = new User();
        u.setProfilePictureUrl("/uploads/avatars/vet-1.jpg");
        if (!"/uploads/avatars/vet-1.jpg".equals(u.getProfilePictureUrl())) {
            fail++;
            System.err.println("FAIL: keep web path");
        }
        u.setProfilePictureUrl("C:\\\\fake\\\\path.jpg");
        if (u.getProfilePictureUrl() != null) {
            fail++;
            System.err.println("FAIL: reject C: drive path");
        }
        u.setProfilePictureUrl("Admin\\\\AppData\\\\Local\\\\x.jpg");
        if (u.getProfilePictureUrl() != null) {
            fail++;
            System.err.println("FAIL: reject Windows fragment path");
        }
        if (!ProfilePictureUploadUtil.hasNonEmptyFilePayload(null)) {
            // ok
        } else {
            fail++;
            System.err.println("FAIL: null part");
        }
        if (fail > 0) {
            System.err.println("ProfilePictureUploadUtilSelfTest: " + fail + " failure(s)");
            System.exit(1);
        }
        System.out.println("ProfilePictureUploadUtilSelfTest: OK");
    }
}
