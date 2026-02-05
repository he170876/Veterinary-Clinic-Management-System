package utils;

import java.lang.reflect.Array;
import java.util.Date;
import java.util.Properties;

/**
 * Sends email via SMTP using Jakarta Mail if available (reflection-based so the project
 * compiles without jakarta.mail on classpath). Add jakarta.mail and jakarta.activation
 * to lib for real email sending; otherwise returns false and the app can show the reset link.
 */
public final class MailSender {

    private MailSender() {}

    /**
     * Send a plain-text email.
     *
     * @param smtpHost SMTP host (e.g. smtp.gmail.com)
     * @param smtpPort SMTP port (e.g. 587 for TLS)
     * @param smtpUser SMTP username (or null if no auth)
     * @param smtpPass SMTP password (or null)
     * @param useTls  true for STARTTLS
     * @param from    From address
     * @param to      To address
     * @param subject Subject line
     * @param body    Plain text body
     * @return true if sent, false if Jakarta Mail not available or send failed
     */
    public static boolean send(String smtpHost, int smtpPort, String smtpUser, String smtpPass,
                              boolean useTls, String from, String to, String subject, String body) {
        if (smtpHost == null || smtpHost.isEmpty() || from == null || to == null) {
            return false;
        }
        try {
            Class<?> sessionClass = Class.forName("jakarta.mail.Session");
            Class<?> messageClass = Class.forName("jakarta.mail.internet.MimeMessage");
            Class<?> transportClass = Class.forName("jakarta.mail.Transport");
            Class<?> addressClass = Class.forName("jakarta.mail.Address");
            Class<?> internetAddressClass = Class.forName("jakarta.mail.internet.InternetAddress");
            Class<?> recipientTypeClass = Class.forName("jakarta.mail.Message$RecipientType");

            Properties props = new Properties();
            props.put("mail.smtp.host", smtpHost);
            props.put("mail.smtp.port", String.valueOf(smtpPort));
            props.put("mail.smtp.auth", smtpUser != null && !smtpUser.isEmpty() ? "true" : "false");
            if (useTls) {
                props.put("mail.smtp.starttls.enable", "true");
            }

            Object session = sessionClass.getMethod("getInstance", Properties.class).invoke(null, props);
            Object msg = messageClass.getConstructor(sessionClass).newInstance(session);

            Object fromAddr = internetAddressClass.getMethod("parse", String.class).invoke(null, from);
            messageClass.getMethod("setFrom", addressClass).invoke(msg, fromAddr);

            Object[] toAddrs = (Object[]) internetAddressClass.getMethod("parse", String.class).invoke(null, to);
            Object toType = recipientTypeClass.getField("TO").get(null);
            messageClass.getMethod("setRecipients", recipientTypeClass, Array.newInstance(addressClass, 0).getClass()).invoke(msg, toType, toAddrs);

            messageClass.getMethod("setSubject", String.class).invoke(msg, subject != null ? subject : "");
            messageClass.getMethod("setSentDate", Date.class).invoke(msg, new Date());
            messageClass.getMethod("setText", String.class).invoke(msg, body != null ? body : "");

            if (smtpUser != null && !smtpUser.isEmpty() && smtpPass != null) {
                transportClass.getMethod("send", Class.forName("jakarta.mail.Message"), String.class, String.class)
                        .invoke(null, msg, smtpUser, smtpPass);
            } else {
                transportClass.getMethod("send", Class.forName("jakarta.mail.Message")).invoke(null, msg);
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
