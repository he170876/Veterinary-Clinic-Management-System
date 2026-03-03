# Troubleshooting – Anipats VCMS

Common issues and how to fix them.

---

## 0. Database setup: "Access is denied" or "CREATE DATABASE failed"

**Symptom:** Running `database/script.sql` fails with:
- `Msg 5123: CREATE FILE encountered operating system error 5(Access is denied.)`  
- `CREATE DATABASE failed. Some file names listed could not be created.`

**Cause:** The script was generated with explicit file paths under `C:\Program Files\...`. The account running the script (or the SQL Server service) may not have permission to create files there.

**Fix (already applied in this project):** The script was updated to create the database **without** explicit paths, so SQL Server uses its default data directory (where it has access):

```sql
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'VetClinicManagement')
BEGIN
    CREATE DATABASE [VetClinicManagement]
END
```

If you still see "Access is denied" when creating the database, run **SQL Server Management Studio (or sqlcmd) as Administrator**, or create the database manually in SSMS (right‑click Databases → New Database → name: `VetClinicManagement`) and then run only the rest of `script.sql` (from `USE [VetClinicManagement]` and the `CREATE TABLE` statements).

---

### "Database does not exist" then "There is already an object named '...'"

**Symptom:** First run fails at CREATE DATABASE; later you create the database manually or fix permissions. When you run the full script again, you get "Database 'VetClinicManagement' does not exist" in one run, and in another run "There is already an object named 'Appointments'" (and similar for every table).

**Cause:** The database didn’t exist on the first run; after you create it and re-run the script, the script tries to create tables that already exist.

**Fix:**

- **Clean start:** In SSMS, run:
  ```sql
  USE master;
  GO
  DROP DATABASE IF EXISTS [VetClinicManagement];
  GO
  ```
  Then run the full `script.sql` again, followed by `seed_data.sql` and `seed_test_screens.sql`.

- **Keep existing data:** Do **not** run the CREATE TABLE part again. Run only:
  - `seed_data.sql` (if the database is empty and you need base data), or  
  - `seed_test_screens.sql` (if you already ran `seed_data.sql` and only need today’s appointments and a pending lab request).

---

## 0b. "The requested resource [/Veterinary_Clinic_Management_System] is not available"

**Symptom:** Browser or Postman shows a **404** or "Status Report – The requested resource [...] is not available. The origin server did not find a current representation for the target resource."

**What to check:**

1. **Use the full URL including context path**  
   The app is deployed at:
   - **`http://localhost:9999/Veterinary_Clinic_Management_System/`**
   - Login: **`http://localhost:9999/Veterinary_Clinic_Management_System/login`**
   Replace `9999` with your Tomcat port if different (e.g. 8080, 8084).

2. **App failed to start**  
   If the context path is correct but you still get "not available", the app may have failed to start. Check:
   - **Tomcat console / IDE run output** for `ServletException`, `ClassNotFoundException`, or database errors.
   - **Tomcat `logs/catalina.out`** (or `localhost*.log`) for stack traces during deployment.

3. **Context path**  
   The app is deployed at **`/Veterinary_Clinic_Management_System`**. Use **`http://localhost:9999/Veterinary_Clinic_Management_System/`** or **`http://localhost:9999/Veterinary_Clinic_Management_System/login`**. (Root path `/` is not used because Tomcat often already has an app there, which causes "Application already exists at path [/]" on deploy.)

---

## 1. Forgot password: no email received

**Symptom:** You click "Send Reset Link" and see the success message, but the reset email never arrives.

### 1.1 Use the correct SMTP server

| Sender email        | SMTP host              | Password |
|---------------------|-------------------------|----------|
| **@gmail.com**      | `smtp.gmail.com`        | [Gmail App Password](https://myaccount.google.com/apppasswords) (not your normal password if you use 2FA). |
| **@fpt.edu.vn** / Outlook / Office 365 | `smtp.office365.com` | Your account password (or org app password). |
| Other               | Look up "SMTP settings" for your provider. | That account’s password. |

In **`web/WEB-INF/web.xml`** set:

- `mail.smtp.host` (e.g. `smtp.gmail.com` or `smtp.office365.com`)
- `mail.smtp.user` = full email
- `mail.smtp.password` = password for **that** account
- `mail.from` = same as `mail.smtp.user`

### 1.2 Check spam / junk

- Check the **Spam** or **Junk** folder of the address you’re resetting (the "To" address).

### 1.3 Check server logs for the real error

- After clicking "Send Reset Link", check **Tomcat logs**: `logs/catalina.out` or the IDE console.
- Search for `jakarta.mail`, `javax.mail`, or the exception message (e.g. "Authentication failed", "Connection refused").
- Use that message to fix: wrong host, wrong password, firewall, etc.

### 1.4 Confirm mail is enabled

- In **web.xml**, `mail.enabled` must be **true**.
- Restart Tomcat after changing `web.xml`.

---

## 2. HTTP 500 / ClassNotFoundException: jakarta.activation.DataHandler

**Symptom:** Forgot password (or any use of mail) throws 500 and the stack trace shows `NoClassDefFoundError` or `ClassNotFoundException: jakarta.activation.DataHandler`.

**Cause:** Jakarta Mail needs **Jakarta Activation** on the classpath.

**Fix:** Add these JARs to your project **lib** folder (next to `jakarta.mail-2.0.3.jar`):

| JAR | Download |
|-----|----------|
| jakarta.activation-api-2.1.2.jar | https://repo1.maven.org/maven2/jakarta/activation/jakarta.activation-api/2.1.2/jakarta.activation-api-2.1.2.jar |
| angus-activation-2.0.2.jar       | https://repo1.maven.org/maven2/org/eclipse/angus/angus-activation/2.0.2/angus-activation-2.0.2.jar |

Then **restart Tomcat**.

---

## 3. Login / registration issues

### "Invalid email or password"

- Ensure the account exists and is **Active**.
- Use the **exact** email (Gmail only; case doesn’t matter).
- If you just reset the password, use the **new** password.

### "This email is already registered"

- That Gmail is already in use. Use **Login** or **Forgot password**, or register with another Gmail.

### "Email must be a Gmail address (@gmail.com)" (or "Please enter a valid email address.")

- The app accepts **any valid email** (e.g. `dr.smith@anipats.com`, `dev@anipats.com`, or `user@gmail.com`). Use your account email and password (seed accounts: password `dev123`).

### "Phone number is required"

- Registration requires a phone (10 digits, starting with 0). Edit profile requires it for Google users who don’t have one yet.

---

## 4. Database connection errors

**Symptom:** 500 or "Could not get connection" / SQL errors when loading pages or submitting forms.

**Checks:**

- **SQL Server** is running and reachable.
- **`src/java/utils/DBContext.java`** (or your config) has the correct: server, database name, username, password, port (e.g. 1433).
- **Database and tables exist:** run `database/run_all_migrations_once.sql` (or your schema + migrations) once.
- **JDBC driver** (e.g. `mssql-jdbc-*.jar`) is in **lib** and on the classpath.

---

## 5. Validation errors on form submit

### "Full name must be 1–30 characters, letters and spaces only (any language)"

- Use only letters and spaces; 1–30 characters. Diacritics (e.g. Vietnamese) are allowed.

### "Password must be 6–128 characters with 1 uppercase letter and 1 number"

- New password (and registration password) must have at least 6 characters, at least one uppercase letter, and at least one digit.

### "Phone must be 10 digits starting with 0"

- Example: `0123456789`. No spaces or other characters.

### "Preferred date cannot be in the past"

- On the booking form, choose today or a future date.

---

## 6. Google login issues

### "Access blocked" / "This app isn't verified"

- Your OAuth app is in **Testing** mode. Either:
  - Add the Gmail addresses as **Test users** in [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → OAuth consent screen → Test users, or  
  - Publish the app (move consent screen to "In production").

### "Could not get email from Google"

- The user did not grant the email scope or something failed on Google’s side. Try again or use a different browser/account.

### Google user: no "Change Password"

- By design. Google accounts sign in with Google only; they don’t have a password in this app. Use **Sign in with Google** or [Google account recovery](https://accounts.google.com/signin/recovery) if they lost access.

---

## 7. Access denied / redirect to login

**Symptom:** Opening `/customer/dashboard` (or other `/customer/*`) redirects to login or "forbidden".

- You must be **logged in** and have the **Customer** role (or another role allowed for that path by `RoleBasedAccessFilter`).
- Log in first; then open the customer URL again.

---

## 8. No token created (no row in PasswordResetTokens)

**Symptom:** You submit the forgot-password form with an email but no new row appears in `PasswordResetTokens` (or you expect a token for a different email and it never appears).

Your screenshot shows a token **was** created for `ens2004ck@gmail.com`. If you are testing with **another** email and no row is created, the app intentionally skips creating a token in these cases:

| Condition | What to do |
|-----------|------------|
| **Email not in `Users` table** | Only registered (non-Google) accounts get a token. Register that email first, or use an email that already exists in `Users`. |
| **User is Google-only** | Accounts that signed up with "Sign in with Google" (`is_google_user = 1`) do not get a password reset token. They must use "Sign in with Google" or [Google account recovery](https://accounts.google.com/signin/recovery). |
| **User status is not `Active`** | The account must have status `Active` in the `Users` table. Check and update status if needed. |

**To confirm which case:**

- In SQL Server, run:
  - `SELECT UserId, Email, Status, is_google_user FROM Users WHERE Email = N'your@email.com'`
- If no row: email is not registered (or wrong casing – the app uses lowercase).
- If `is_google_user = 1`: no token is created by design.
- If `Status <> 'Active'`: set it to `Active` for testing, or use an active account.

If the **same** email that used to get a token suddenly doesn’t create one, check **Tomcat logs** (e.g. `logs/catalina.out`) for `SQLException` or "Failed to create password reset token". That usually means a DB/connection or table issue.

**Only one token per email.** Each time you submit “Forgot password” for an email, the app **replaces** the previous token (deletes the old row, inserts a new one). So you will never see two rows for the same email—that’s by design. If you send twice for `eris2004dk@gmail.com`, the table should still show **one** row for that email (the latest token).

**If no row appears at all** for an eligible user (e.g. `eris2004dk@gmail.com` is Active, not Google): the app finds the user with a query that **JOINs `Users` and `Roles`**. If the user’s `role_id` is missing in the `Roles` table, the user won’t be found and no token is created. In SSMS run the same lookup the app uses:

```sql
SELECT u.user_id, u.email, u.status, u.is_google_user
FROM Users u
JOIN Roles r ON u.role_id = r.role_id
WHERE u.email = N'eris2004dk@gmail.com';
```

If this returns no rows, fix the user’s `role_id` (or add the missing role to `Roles`) and try again.

**Different email doesn’t create a token.** When you submit with a *second* email and no new row appears, the app is still returning “sent” but not creating a token for that email—so one of the conditions above applies (user not found, Google user, or not Active). For each email, run the same `Users u JOIN Roles r` query above; if it returns no rows for that email, the app will not create a token. **Server logs:** After redeploying, send two requests (e.g. first email A, then email B) and check Tomcat’s console or `logs/catalina.out`. You should see lines like:
- `Forgot password request for email: a@gmail.com` then `Password reset: token created for 'a@gmail.com'`
- `Forgot password request for email: b@gmail.com` then either `Password reset: token created for 'b@gmail.com'` or `Password reset: no token created for 'b@gmail.com' (user not found or Roles JOIN failed)` (or Google user / status).  
That tells you why the second email got no token.

---

## 9. Reset link expired or invalid

**Symptom:** After clicking the link in the reset email, you see "Reset link expired or invalid".

- Reset links are valid for **1 hour**. Request a new one from the Forgot password page.
- Use the link only once; after a successful reset it is invalidated.

---

## 10. Where to look next

| Problem type      | Where to look |
|-------------------|----------------|
| Mail not sent     | `docs/REAL_MAIL_SETUP.md`, Tomcat logs, `web.xml` mail params. |
| Missing JAR / 500 | Add JARs to **lib**, restart server. See `docs/REAL_MAIL_SETUP.md`. |
| DB errors         | `DBContext.java`, SQL Server, run migrations. |
| Flow / behaviour  | `docs/FLOW_EVERYTHING.md`, `docs/FORGOT_PASSWORD_NEXT_STEPS.md`. |
