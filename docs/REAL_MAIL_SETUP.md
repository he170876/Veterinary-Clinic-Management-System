# Real Mail Setup (Forgot Password)

Follow these steps to send reset links by email instead of showing them on the page.

---

## 1. Add Jakarta Mail and Activation JARs to your project

The app uses **Jakarta Mail**, which requires **Jakarta Activation** (for `DataHandler`, etc.). Add **both** to your **lib** folder.

### Download (all three JARs)

| JAR | Purpose | Direct download |
|-----|---------|-----------------|
| **jakarta.mail-2.0.3.jar** | Mail API + implementation | https://repo1.maven.org/maven2/org/eclipse/angus/jakarta.mail/2.0.3/jakarta.mail-2.0.3.jar |
| **jakarta.activation-api-2.1.2.jar** | Activation API | https://repo1.maven.org/maven2/jakarta/activation/jakarta.activation-api/2.1.2/jakarta.activation-api-2.1.2.jar |
| **angus-activation-2.0.2.jar** | Activation implementation | https://repo1.maven.org/maven2/org/eclipse/angus/angus-activation/2.0.2/angus-activation-2.0.2.jar |

### Where to put them

- Copy all **three** JARs into your project’s **lib** folder (same folder as `mssql-jdbc-*.jar`, `jakarta.servlet.jsp.jstl-*.jar`, etc.).
- Rebuild the project and restart Tomcat so the JARs are on the classpath.

**Without the activation JARs** you will get: `java.lang.ClassNotFoundException: jakarta.activation.DataHandler`

---

## 2. Configure Gmail in web.xml

Edit **`web/WEB-INF/web.xml`** and replace the placeholder values with your real Gmail settings.

| Parameter | What to set |
|-----------|-------------|
| **mail.smtp.user** | Your full Gmail address (e.g. `myclinic@gmail.com`). |
| **mail.smtp.password** | Your **Gmail App Password** (see below), not your normal Gmail password. |
| **mail.from** | Same as **mail.smtp.user** (e.g. `myclinic@gmail.com`). |

**mail.enabled** is already set to **true** in `web.xml`. Leave **mail.smtp.host** as `smtp.gmail.com`, **port** `587`, **starttls** `true` for Gmail.

### Gmail App Password (required if you use 2-Step Verification)

1. Open https://myaccount.google.com/apppasswords (you must have 2-Step Verification turned on).
2. Sign in to your Google account.
3. Under “App passwords”, choose “Mail” and your device, then click **Generate**.
4. Copy the **16-character password** (no spaces).
5. Paste it into **mail.smtp.password** in `web.xml` (exactly as shown, no spaces).

If you don’t use 2-Step Verification, you can try your normal Gmail password in **mail.smtp.password**; Google may block it. Using an App Password is recommended.

---

## 3. Restart and test

1. **Restart** your application server (e.g. Tomcat) so it loads the new JAR and the updated `web.xml`.
2. Open your app → **Login** → **Forgot password?**.
3. Enter a **registered Gmail** (non–Google account) and submit.
4. Check that account’s **inbox** (and spam folder) for the reset email.
5. Click the link in the email and complete the reset; then sign in with the new password.

---

## Summary checklist

- [ ] Add **jakarta.mail-2.0.3.jar** (and if needed **jakarta.activation-api-2.1.2.jar**) to **lib**.
- [ ] In **web.xml**: set **mail.smtp.user** and **mail.from** to your Gmail.
- [ ] In **web.xml**: set **mail.smtp.password** to your Gmail App Password (16 characters).
- [ ] Restart the server and test forgot password with a real email.

After this, reset links will be sent by real mail instead of only being shown on the page.

---

## Troubleshooting: "Done all steps but no email received"

### 1. Use the correct SMTP server for your email

- **@gmail.com** → `mail.smtp.host` = **smtp.gmail.com**, password = [Gmail App Password](https://myaccount.google.com/apppasswords).
- **@fpt.edu.vn** or other university / Outlook → `mail.smtp.host` = **smtp.office365.com**, port **587**, password = your **FPT/Office 365 account password** (or app password if your org uses 2FA). The project is preconfigured for FPT with `smtp.office365.com`.

If your school uses a different provider, look up "SMTP settings" for your email (e.g. FPT IT support) and set `mail.smtp.host` and port in `web.xml` accordingly.

### 2. Password must match the email

- For **phinhhe181076@fpt.edu.vn** the password in `mail.smtp.password` must be the one for **that FPT/Office 365 account**, not a Gmail App Password. A 16-character Google App Password only works with Gmail and `smtp.gmail.com`.

### 3. Check spam / junk

- Look in **Spam** or **Junk** in the inbox of the address you’re resetting (the "To" address).

### 4. Check server logs for the real error

- If the email still doesn’t send, the app logs the exception. In Tomcat: check **logs/catalina.out** or the console where Tomcat runs (e.g. in NetBeans/Eclipse). Search for `javax.mail` or `jakarta.mail` or the stack trace after you click "Send Reset Link". The message (e.g. "Authentication failed", "Connection refused") will tell you what’s wrong (wrong host, wrong password, firewall, etc.).
