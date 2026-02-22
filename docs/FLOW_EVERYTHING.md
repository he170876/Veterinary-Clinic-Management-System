# Anipats – Complete Flow Guide (Everything We Built)

This document explains **every flow** in the Veterinary Clinic Management System in simple, step-by-step terms. Each flow is aligned with the **exact code** that performs it, for university review.

---

## How to read the code mapping

Under each flow you will find a **Code mapping (for review)** box. It lists:

- **Servlet** – Class that handles the HTTP request; `doGet()` shows the form/page, `doPost()` processes the form.
- **Service** – Business logic (e.g. `AuthServiceImpl`); called by the servlet.
- **DAO** – Data access (e.g. `UserJdbcDAO`, `PasswordResetTokenJdbcDAO`); called by the service or servlet.
- **Utils** – Shared helpers (e.g. `ValidationUtil`, `PasswordUtil`, `MailSender`); used by servlets/services.
- **View** – JSP file that renders the page.

**Package base:** All Java code lives under `src/java/` with packages `controller.auth`, `controller.customer`, `controller.appointment`, `service`, `service.impl`, `dao`, `dao.impl`, `utils`, `filter`, `model`.

---

## Table of Contents

1. [How the app works (overview)](#1-how-the-app-works-overview)
2. [Registration (Create account)](#2-registration-create-account)
3. [Login (Sign in)](#3-login-sign-in)
4. [Google Login](#4-google-login)
5. [Forgot Password (Email-based reset)](#5-forgot-password-email-based-reset)
6. [Reset Password (from email link)](#6-reset-password-from-email-link)
7. [Customer Dashboard](#7-customer-dashboard)
8. [Customer Profile](#8-customer-profile)
9. [Edit Profile](#9-edit-profile)
10. [Change Password](#10-change-password)
11. [Logout](#11-logout)
12. [Guest booking (Appointment request from homepage)](#12-guest-booking-appointment-request-from-homepage)
13. [Access control (Who can see what)](#13-access-control-who-can-see-what)
14. [Validation rules (What we check)](#14-validation-rules-what-we-check)
15. [Master data & database](#15-master-data--database)
16. [URL & file map](#16-url--file-map)
17. [Quick code reference table (for reviewers)](#17-quick-code-reference-table-for-reviewers)

---

## 1. How the app works (overview)

- **Homepage** (`/` or `/index.jsp`): Anyone can see it. Has “Login”, “Register”, “Book appointment” (modal).
- **Login / Register**: Create or sign in to an account. Only **Gmail** emails are allowed.
- **After login**: User has a **role** (e.g. Customer). The app sends them to the right place (e.g. Customer → Dashboard).
- **Customer area** (`/customer/*`): Dashboard, Profile, Edit Profile, Change Password. Only logged-in customers (and the right role) can access.
- **Forgot password**: User enters email → we create a reset link (valid 1 hour) → we send it by email (or show it on the page if email is not configured).
- **Guest booking**: From the homepage, anyone can submit an appointment request form (name, email, phone, service, pet, date, time). It is saved as a request; no login required.

---

## 2. Registration (Create account)

**URL:** `GET /register` (show form), `POST /register` (submit)

**What happens step by step:**

1. User opens the registration page.
2. User fills: **Full name**, **Email** (Gmail only), **Phone** (required, 10 digits starting with 0), **Password**, **Confirm password**, and accepts terms.
3. Browser checks: length, pattern (e.g. Gmail, phone format). User submits.
4. Server checks:
   - No leading/trailing spaces in text fields.
   - Full name: 1–30 characters, letters and spaces only.
   - Email: must be `@gmail.com`, max 255 characters.
   - Phone: exactly 10 digits, starting with 0.
   - Password: 6–128 characters, at least 1 uppercase and 1 number.
   - Password and confirm must match.
   - **Email must not already be registered** (no duplicate accounts).
5. If any check fails → user sees the form again with an error message; entered data is kept.
6. If all OK → account is created (role = Customer), user is **automatically logged in**, and redirected to **Customer Dashboard**.

**Important:** Each email can only be used once. Phone is required for every new account.

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.auth.RegisterServlet.doGet()` | `src/java/controller/auth/RegisterServlet.java` | If already logged in → redirect dashboard; else forward to `register.jsp`. |
| Servlet  | `controller.auth.RegisterServlet.doPost()` | same | Read params; validate via ValidationUtil; call `authService.isEmailTaken(email)` then `authService.registerCustomer(...)`; on success create session, set `currentUser`, redirect `/customer/dashboard`. |
| Service  | `service.impl.AuthServiceImpl.isEmailTaken(String email)` | `src/java/service/impl/AuthServiceImpl.java` | Returns `userDAO.existsByEmail(email.trim().toLowerCase())`. |
| Service  | `service.impl.AuthServiceImpl.registerCustomer(...)` | same | Checks `userDAO.existsByEmail(...)`; builds User; `userDAO.findRoleByName("Customer")`; `userDAO.createCustomerUser(user)`. |
| DAO      | `dao.impl.UserJdbcDAO.existsByEmail(String)` | `src/java/dao/impl/UserJdbcDAO.java` | `SELECT 1 FROM Users WHERE email = ?`. |
| DAO      | `dao.impl.UserJdbcDAO.findRoleByName(String)` | same | `SELECT role_id, role_name FROM Roles WHERE role_name = ?`. |
| DAO      | `dao.impl.UserJdbcDAO.createCustomerUser(User)` | same | Inserts into Users + Customers. |
| Utils    | `utils.ValidationUtil.trim()`, `hasLeadingOrTrailingSpaces()`, `isValidFullName()`, `isValidGmail()`, `isValidPhone()`, `isValidPassword()` | `src/java/utils/ValidationUtil.java` | Used in doPost for all validations. |
| Utils    | `utils.PasswordUtil.hashPassword(String)` | `src/java/utils/PasswordUtil.java` | Called inside AuthServiceImpl.registerCustomer. |
| View     | `web/register.jsp` | `web/register.jsp` | Registration form; shows `error` and preserved form data. |

---

## 3. Login (Sign in)

**URL:** `GET /login` (show form), `POST /login` (submit)

**What happens step by step:**

1. User opens the login page.
2. User enters **Email** (Gmail) and **Password**.
3. Server checks: email format (Gmail), no leading/trailing spaces.
4. Server looks up the user by email and checks the password. Account must be **Active**.
5. If wrong email or password → “Invalid email or password.” and form is shown again.
6. If correct → a **session** is created, user is stored in session, and redirected by role:
   - **Customer** → `/customer/dashboard`
   - (Other roles can be sent to their own dashboards the same way.)

**Link on page:** “Forgot password?” goes to `/forgot-password`.

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.auth.LoginServlet.doGet()` | `src/java/controller/auth/LoginServlet.java` | If session has `currentUser` → `redirectToDashboard()`; else forward `login.jsp`. |
| Servlet  | `controller.auth.LoginServlet.doPost()` | same | Trim email; validate `hasLeadingOrTrailingSpaces`, `isValidGmail`; call `authService.login(email, password)`; on success create session, set `currentUser`, `redirectToDashboard(user)`. |
| Service  | `service.impl.AuthServiceImpl.login(String email, String password)` | `src/java/service/impl/AuthServiceImpl.java` | `userDAO.findByEmail(email.trim().toLowerCase())`; check status Active; `PasswordUtil.matches(password, user.getPasswordHash())`. |
| DAO      | `dao.impl.UserJdbcDAO.findByEmail(String)` | `src/java/dao/impl/UserJdbcDAO.java` | `SELECT` user + role from Users JOIN Roles WHERE email = ?. |
| Utils    | `utils.ValidationUtil.trim()`, `hasLeadingOrTrailingSpaces()`, `isValidGmail()` | `src/java/utils/ValidationUtil.java` | Used in doPost. |
| Utils    | `utils.PasswordUtil.matches(String, String)` | `src/java/utils/PasswordUtil.java` | Used in AuthServiceImpl.login. |
| View     | `web/login.jsp` | `web/login.jsp` | Login form; “Forgot password?” link to `/forgot-password`. |

---

## 4. Google Login

**URL:** `GET /google-login` (user is sent to Google, then back to our app)

**What happens step by step:**

1. User clicks “Sign in with Google” on the login page.
2. User is redirected to **Google** to sign in and allow our app.
3. Google redirects back to our server with a **code**. Our server exchanges the code for tokens and gets the user’s **email** and **name** from Google.
4. We look up the user by email:
   - **If found** → we log them in (same as normal login). If the account has no phone, we later force them to add one in Edit Profile.
   - **If not found** → we **create a new Customer** with that email and name, mark them as **Google user** (`is_google_user = 1`), set a random password (they never use it). Then we log them in.
5. Session is created and user is redirected (e.g. Customer → Dashboard).

**Special rules for Google users:**

- **Change Password** is hidden and disabled (they sign in with Google only).
- If they have **no phone number**, they cannot use Dashboard or Profile until they add a valid phone in **Edit Profile** (we redirect them to Edit Profile with a “phone required” message).

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.auth.GoogleLoginServlet.doGet()` | `src/java/controller/auth/GoogleLoginServlet.java` | Handles callback from Google: read `code`, `state`; exchange code for tokens; get email/name from userinfo or id_token; `userDAO.findByEmail(email)`; if null → `authService.registerCustomer(...)` then `userDAO.setGoogleUser(userId)`; create session; if phone empty → redirect `/customer/edit-profile?required=phone`, else redirect by role. |
| Service  | `service.impl.AuthServiceImpl.registerCustomer(...)` | `src/java/service/impl/AuthServiceImpl.java` | Same as registration (creates User with hashed password). |
| DAO      | `dao.impl.UserJdbcDAO.findByEmail(String)` | `src/java/dao/impl/UserJdbcDAO.java` | Find user by email. |
| DAO      | `dao.impl.UserJdbcDAO.setGoogleUser(int userId)` | same | `UPDATE Users SET is_google_user = 1 WHERE user_id = ?`. |
| View     | Login page link | `web/login.jsp` | “Sign in with Google” → `/google-login`. |

---

## 5. Forgot Password (Email-based reset)

**URL:** `GET /forgot-password` (show form), `POST /forgot-password` (submit)

**What happens step by step:**

1. User clicks “Forgot password?” on the login page and lands on the forgot-password page.
2. User enters their **Gmail** and submits.
3. Server checks: Gmail format, no leading/trailing spaces.
4. Server looks up the user by email:
   - If user **does not exist** or is a **Google-only** account → we still show the same success message (we don’t reveal who is registered). No email is sent, no link is created.
   - If user **exists** and is **not** Google-only → we create a **reset token** (random string), save it in the database with **expiry = 1 hour**, and build a **reset link** (e.g. `https://yoursite.com/app/reset-password?token=...`).
5. **If email is configured** (see docs/FORGOT_PASSWORD.md): we send an email to the user with that link.
6. **If email is not configured**: we redirect to the same page with a **success message** and show the **reset link on the page** so the user (or you in dev) can copy it and open it.
7. User is told: “If that email is registered, we sent a reset link. Check your inbox and spam.”

**Security:** We don’t say “this email is not registered” so that attackers can’t discover valid emails.

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.auth.ForgotPasswordServlet.doGet()` | `src/java/controller/auth/ForgotPasswordServlet.java` | If logged in → redirect dashboard; else forward `forgot-password.jsp`. |
| Servlet  | `controller.auth.ForgotPasswordServlet.doPost()` | same | Validate email (trim, hasLeadingOrTrailingSpaces, isValidGmail); `authService.createPasswordResetToken(email)`; build reset link URL; if mail enabled read context params and call `MailSender.send(...)`; redirect `?sent=1` and optionally `&devLink=...` if email not sent. |
| Service  | `service.impl.AuthServiceImpl.createPasswordResetToken(String email)` | `src/java/service/impl/AuthServiceImpl.java` | `userDAO.findByEmail(email)`; if missing or Google user or inactive → empty; else generate token, `resetTokenDAO.create(token, email, expiresAt)`, return Optional.of(token). |
| DAO      | `dao.impl.UserJdbcDAO.findByEmail(String)` | `src/java/dao/impl/UserJdbcDAO.java` | Check user exists. |
| DAO      | `dao.impl.PasswordResetTokenJdbcDAO.create(String token, String email, LocalDateTime expiresAt)` | `src/java/dao/impl/PasswordResetTokenJdbcDAO.java` | Delete existing for email; INSERT into PasswordResetTokens. |
| Utils    | `utils.ValidationUtil.trim()`, `hasLeadingOrTrailingSpaces()`, `isValidGmail()` | `src/java/utils/ValidationUtil.java` | Used in doPost. |
| Utils    | `utils.MailSender.send(...)` | `src/java/utils/MailSender.java` | Sends email via Jakarta Mail (reflection); used when mail.enabled and SMTP params set. |
| View     | `web/forgot-password.jsp` | `web/forgot-password.jsp` | Form with email; shows success message and optional dev link. |

---

## 6. Reset Password (from email link)

**URL:** `GET /reset-password?token=...` (show form), `POST /reset-password` (submit)

**What happens step by step:**

1. User opens the link from the forgot-password email (or the link shown on the page when email is off). URL contains `?token=...`.
2. Server shows a form: **New password**, **Confirm password**. The token is in a hidden field.
3. User enters the new password twice and submits.
4. Server checks:
   - Token is present and **valid** (exists in DB and not expired).
   - New password: 6–128 characters, at least 1 uppercase and 1 number.
   - New password and confirm match.
5. If any check fails → error message (e.g. “Passwords do not match” or “Reset link expired or invalid”).
6. If all OK → we **update the user’s password** in the database, **delete the token** (so the link can’t be used again), and redirect to **login** with “Password reset. You can now sign in.”

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.auth.ResetPasswordServlet.doGet()` | `src/java/controller/auth/ResetPasswordServlet.java` | If logged in → redirect dashboard; read `token` param; if missing → redirect forgot-password with error; else set `token` attribute, forward `reset-password.jsp`. |
| Servlet  | `controller.auth.ResetPasswordServlet.doPost()` | same | Read token, newPassword, confirmPassword; validate match and `ValidationUtil.isValidPassword(newPassword)`; call `authService.resetPasswordWithToken(token, newPassword)`; on success redirect `/login?reset=1`, else redirect login with error. |
| Service  | `service.impl.AuthServiceImpl.resetPasswordWithToken(String token, String newPassword)` | `src/java/service/impl/AuthServiceImpl.java` | Validates password; `resetTokenDAO.findEmailByToken(token)`; `userDAO.findByEmail(email)`; `userDAO.updatePassword(userId, hash)`; `resetTokenDAO.deleteByToken(token)`. |
| DAO      | `dao.impl.PasswordResetTokenJdbcDAO.findEmailByToken(String)` | `src/java/dao/impl/PasswordResetTokenJdbcDAO.java` | `SELECT email FROM PasswordResetTokens WHERE token = ? AND expires_at > now`. |
| DAO      | `dao.impl.PasswordResetTokenJdbcDAO.deleteByToken(String)` | same | `DELETE FROM PasswordResetTokens WHERE token = ?`. |
| DAO      | `dao.impl.UserJdbcDAO.findByEmail(String)`, `updatePassword(int, String)` | `src/java/dao/impl/UserJdbcDAO.java` | Find user; update password hash. |
| Utils    | `utils.ValidationUtil.isValidPassword(String)` | `src/java/utils/ValidationUtil.java` | 6–128 chars, 1 upper, 1 digit. |
| Utils    | `utils.PasswordUtil.hashPassword(String)` | `src/java/utils/PasswordUtil.java` | Used in AuthServiceImpl.resetPasswordWithToken. |
| View     | `web/reset-password.jsp` | `web/reset-password.jsp` | Form with hidden token, new password, confirm password. |

---

## 7. Customer Dashboard

**URL:** `GET /customer/dashboard`

**What happens step by step:**

1. User must be **logged in**. If not → redirect to login.
2. **Access control:** Only users with the **Customer** role can see this page. Others get “Access denied” or redirect.
3. If the user is a **Google user** and has **no phone** → redirect to **Edit Profile** with “You must add your phone number to continue.” They can’t use Dashboard until they add a valid phone.
4. If OK → we show the **customer dashboard** (e.g. welcome message, sidebar with Dashboard, Profile, Edit Profile, Change Password, Logout). The page uses the shared **customer sidebar** include.

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Filter   | `filter.RoleBasedAccessFilter.doFilter()` | `src/java/filter/RoleBasedAccessFilter.java` | Runs before `/customer/*`: if no session or no `currentUser` → redirect `/login`; else if role not in CUSTOMER_ROLES → redirect `?forbidden=1`; else chain.doFilter. |
| Servlet  | `controller.customer.CustomerDashboardServlet.doGet()` | `src/java/controller/customer/CustomerDashboardServlet.java` | Session check; get `currentUser`; if `user.getPhone()` null or empty → set pendingPhoneRequired, redirect `/customer/edit-profile?required=phone`; else set `user` attribute, forward `dashboard.jsp`. |
| View     | `web/WEB-INF/views/customer/dashboard.jsp` | `web/WEB-INF/views/customer/dashboard.jsp` | Dashboard content; includes `customer-sidebar.jsp`. |
| Include  | `web/WEB-INF/includes/customer-sidebar.jsp` | `web/WEB-INF/includes/customer-sidebar.jsp` | Shared sidebar (Dashboard, Profile, Edit Profile, Change Password, Logout). |

---

## 8. Customer Profile

**URL:** `GET /customer/profile`

**What happens step by step:**

1. User must be **logged in**. Only **Customer** role can access.
2. If Google user with **no phone** → redirect to Edit Profile (same as Dashboard).
3. We load the current user from the session and show **profile** page: full name, email, phone, address, profile picture.
4. **Change Password** button:
   - Shown only if the user is **not** a Google user.
   - If Google user → button is hidden (they can’t change password in our app).

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Filter   | `filter.RoleBasedAccessFilter.doFilter()` | `src/java/filter/RoleBasedAccessFilter.java` | Same as Dashboard: allows only Customer (and Admin/ClinicOwner) for `/customer/*`. |
| Servlet  | `controller.customer.CustomerProfileServlet.doGet()` | `src/java/controller/customer/CustomerProfileServlet.java` | Session check; get `currentUser`; if phone null/empty → set pendingPhoneRequired, redirect edit-profile?required=phone; else set `user`, forward `profile.jsp`. |
| View     | `web/WEB-INF/views/customer/profile.jsp` | `web/WEB-INF/views/customer/profile.jsp` | Shows fullName, email, phone, address, profile picture; Change Password button only if `!user.isGoogleUser()`. |

---

## 9. Edit Profile

**URL:** `GET /customer/edit-profile` (show form), `POST /customer/edit-profile` (submit)

**What happens step by step:**

1. User must be **logged in**. Only **Customer** role.
2. **GET:** We show a form with: Full name, Phone, Email (read-only), Address, Profile picture (upload/remove).
3. User edits and submits (form is multipart if they upload a photo).
4. Server checks:
   - No leading/trailing spaces.
   - Full name: 1–30 characters, letters and spaces only.
   - Phone: if provided, 10 digits starting with 0.
   - Address: optional, max 500 characters.
   - Photo: only JPEG/PNG/GIF, max 2 MB.
5. If the user was sent here because **phone was required** (e.g. after Google login with no phone): we require phone and, after saving, redirect to **Dashboard** and clear the “phone required” state.
6. Otherwise we update the user in the database, update the **session** with the new data, and redirect to **Profile** with “updated=1”.

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.customer.CustomerEditProfileServlet.doGet()` | `src/java/controller/customer/CustomerEditProfileServlet.java` | Session check; set `user`, forward `edit-profile.jsp`. |
| Servlet  | `controller.customer.CustomerEditProfileServlet.doPost()` | same | Read fullName, phone, address, optional profile Part; validate trim, hasLeadingOrTrailingSpaces, isValidFullName, phone (if present) isValidPhone, isValidAddress; handle removePhoto or image upload (JPEG/PNG/GIF, max 2MB); `userDAO.updateUser(user)`; update session `currentUser`; if pendingPhoneRequired redirect dashboard else redirect profile?updated=1. |
| DAO      | `dao.impl.UserJdbcDAO.updateUser(User)` | `src/java/dao/impl/UserJdbcDAO.java` | `UPDATE Users SET full_name, phone, address, profile_picture_url, updated_at WHERE user_id = ?`. |
| Utils    | `utils.ValidationUtil.trim()`, `hasLeadingOrTrailingSpaces()`, `isValidFullName()`, `isValidPhone()`, `isValidAddress()` | `src/java/utils/ValidationUtil.java` | Used in doPost. |
| View     | `web/WEB-INF/views/customer/edit-profile.jsp` | `web/WEB-INF/views/customer/edit-profile.jsp` | Form: fullName, phone, email (read-only), address, profile picture upload/remove. |

---

## 10. Change Password

**URL:** `POST /customer/change-password`

**What happens step by step:**

1. Available only to **logged-in customers** who are **not** Google users. (Google users don’t see the form.)
2. User enters **Current password**, **New password**, **Confirm new password** (e.g. in a modal on the Profile page).
3. Server checks:
   - Current password is correct.
   - New password: 6–128 characters, at least 1 uppercase and 1 number.
   - New password and confirm match.
4. If any check fails → redirect back to Profile with an error (e.g. “Current password is incorrect” or “New password must be 6–128 characters with 1 uppercase and 1 number”).
5. If OK → we **update the password** in the database and redirect to Profile with “Password changed” message.

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.customer.ChangePasswordServlet.doPost()` | `src/java/controller/customer/ChangePasswordServlet.java` | Session check; if `user.isGoogleUser()` → redirect profile with pwError; read currentPassword, newPassword, confirmPassword; validate non-empty, `ValidationUtil.isValidPassword(newPassword)`, match; `authService.changePassword(user.getUserId(), currentPassword, newPassword)`; redirect profile with ?pw=1 or ?pwError=.... |
| Service  | `service.impl.AuthServiceImpl.changePassword(int userId, String oldPassword, String newPassword)` | `src/java/service/impl/AuthServiceImpl.java` | `userDAO.findById(userId)`; `PasswordUtil.matches(oldPassword, user.getPasswordHash())`; `userDAO.updatePassword(userId, PasswordUtil.hashPassword(newPassword))`. |
| DAO      | `dao.impl.UserJdbcDAO.findById(int)`, `updatePassword(int, String)` | `src/java/dao/impl/UserJdbcDAO.java` | Find user; UPDATE Users SET password, updated_at WHERE user_id = ?. |
| Utils    | `utils.ValidationUtil.isValidPassword(String)` | `src/java/utils/ValidationUtil.java` | 6–128 chars, 1 upper, 1 digit. |
| Utils    | `utils.PasswordUtil.matches()`, `hashPassword()` | `src/java/utils/PasswordUtil.java` | Verify current; hash new. |
| View     | Form and modal on `web/WEB-INF/views/customer/profile.jsp` | `web/WEB-INF/views/customer/profile.jsp` | Change Password modal (hidden for Google users). |

---

## 11. Logout

**URL:** `GET /logout` (or POST, depending on how you link it)

**What happens step by step:**

1. We **invalidate the session** (user is logged out).
2. User is redirected to the **homepage** (e.g. `/index.jsp`).

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.auth.LogoutServlet.doGet()` / `doPost()` | `src/java/controller/auth/LogoutServlet.java` | `request.getSession(false)`; if session != null `session.invalidate()`; redirect `contextPath + "/index.jsp"`. |
| View     | Logout link on sidebar | `web/WEB-INF/includes/customer-sidebar.jsp` | Link to `/logout`. |

---

## 12. Guest booking (Appointment request from homepage)

**URL:** `POST /book` (form is on the homepage modal)

**What happens step by step:**

1. Anyone (guest or logged-in user) can open the **booking modal** on the homepage.
2. User fills: **Owner name**, **Email**, **Phone**, **Service** (dropdown), **Pet name**, **Pet type** (dropdown), **Preferred date**, **Preferred time**, **Notes** (optional).
3. Browser can validate: required fields, patterns (e.g. phone 10 digits starting with 0), date not in the past (we set `min=today` on the date field).
4. Server checks:
   - All required fields present.
   - Owner name: 1–100 characters, letters and spaces only.
   - Email: valid format (has @ and dot), max 255.
   - Phone: 10 digits starting with 0.
   - Pet name: 1–100 characters, letters and spaces only.
   - **Date must not be in the past.**
   - Notes: max 1000 characters.
5. If any check fails → redirect back to homepage with an error message (e.g. “Please fill in all required fields” or “Preferred date cannot be in the past”).
6. If OK → we **insert a row** into **AppointmentRequests** (or equivalent table) and redirect to homepage with “Booking received” or similar. No login is required.

**Note:** The service and pet type options in the form are **hardcoded** in the JSP (they are not loaded from the Services table in the database). The submitted values are stored as text.

**Code mapping (for review):**

| Layer    | Class / method | File | Action |
|----------|----------------|------|--------|
| Servlet  | `controller.appointment.BookAppointmentServlet.doPost()` | `src/java/controller/appointment/BookAppointmentServlet.java` | Read ownerName, email, phone, service, petName, petType, appointmentDate, appointmentTime, notes; validate required; `ValidationUtil.isValidOwnerOrPetName(ownerName)`, `isValidEmailFormat(email)`, `isValidPhone(phone)`, `isValidOwnerOrPetName(petName)`, `isDateNotInPast(appointmentDate)`; notes length ≤ NOTES_MAX_LENGTH; INSERT into AppointmentRequests via DBContext.getConnection() and PreparedStatement. |
| Utils    | `utils.ValidationUtil.isValidOwnerOrPetName()`, `isValidEmailFormat()`, `isValidPhone()`, `isDateNotInPast()` | `src/java/utils/ValidationUtil.java` | Used in doPost. |
| DB       | `utils.DBContext.getConnection()` | `src/java/utils/DBContext.java` | JDBC connection for INSERT. |
| View     | Modal form | `web/index.jsp` (includes `web/bookForm.jsp`) | Booking form; form action `POST /book`. |

---

## 13. Access control (Who can see what)

- **Role-based filter** runs on URLs like `/customer/*`, `/vet/*`, `/staff/*`, etc.
- For **`/customer/*`**: only users with role **Customer** are allowed. Others get “Access denied” or redirect to login.
- **Login check:** All customer pages require a logged-in user. If not logged in → redirect to `/login`.
- **Google + no phone:** Customer Dashboard and Profile redirect to Edit Profile until the user adds a valid phone.
- **Change Password:** Shown and allowed only for non–Google users.

So: **every flow** above either allows “everyone” (homepage, login, register, forgot password, reset password, guest booking) or “logged-in customer” (dashboard, profile, edit profile, change password), with extra rules for Google users and phone.

**Code mapping (for review):**

| Component | Class / method | File | Action |
|-----------|----------------|------|--------|
| Filter    | `filter.RoleBasedAccessFilter.doFilter()` | `src/java/filter/RoleBasedAccessFilter.java` | Applied to `/customer/*`, `/owner/*`, `/vet/*`, `/staff/*`, `/lab/*`. Gets `currentUser` from session; gets `roleName`; `allowedRolesForPath(path)` returns CUSTOMER_ROLES for `/customer/*` (Customer, Admin, ClinicOwner); if role not in allowed → redirect `?forbidden=1`. |
| Config    | Filter mapping | `web/WEB-INF/web.xml` | `<filter-mapping>` for RoleBasedAccessFilter and url-pattern `/customer/*`, etc. |
| Login check | Each customer servlet `doGet()` | e.g. CustomerDashboardServlet, CustomerProfileServlet, CustomerEditProfileServlet | Explicit check: `session == null \|\| session.getAttribute("currentUser") == null` → redirect `/login`. |

---

## 14. Validation rules (What we check)

Same idea everywhere: **no leading/trailing spaces**; then field-specific rules.

| Field / Topic        | Rule |
|----------------------|------|
| **Full name**        | 1–30 characters, letters and spaces only. |
| **Email (account)**  | Must be `@gmail.com`, max 255 characters. Must be unique when registering. |
| **Email (booking)**  | Valid format (e.g. has @ and dot), max 255. |
| **Phone**            | Required for registration and for Google users. Exactly 10 digits, starting with 0. |
| **Password**         | 6–128 characters, at least 1 uppercase and 1 number. |
| **Address**          | Optional. If present, max 500 characters. |
| **Owner / Pet name** | 1–100 characters, letters and spaces only. |
| **Notes (booking)**  | Max 1000 characters. |
| **Date (booking)**   | Must not be in the past. |

We do these checks in **both** the browser (HTML5/JS) and the server (e.g. `ValidationUtil` + servlets).

**Code mapping (for review):**

| Rule | ValidationUtil method | File | Used in |
|------|------------------------|------|---------|
| Trim; no leading/trailing spaces | `trim(String)`, `hasLeadingOrTrailingSpaces(String)` | `src/java/utils/ValidationUtil.java` | RegisterServlet, LoginServlet, ForgotPasswordServlet, ResetPasswordServlet, CustomerEditProfileServlet, BookAppointmentServlet |
| Full name 1–30, letters/spaces | `isValidFullName(String)` | same | RegisterServlet, CustomerEditProfileServlet |
| Email @gmail.com, max 255 | `isValidGmail(String)` | same | RegisterServlet, LoginServlet, ForgotPasswordServlet |
| Email format (booking), max 255 | `isValidEmailFormat(String)` | same | BookAppointmentServlet |
| Phone 10 digits, start 0 | `isValidPhone(String)` | same | RegisterServlet, CustomerEditProfileServlet, BookAppointmentServlet |
| Password 6–128, 1 upper, 1 digit | `isValidPassword(String)` | same | RegisterServlet, ChangePasswordServlet, ResetPasswordServlet, AuthServiceImpl.resetPasswordWithToken |
| Address max 500 | `isValidAddress(String)` | same | CustomerEditProfileServlet |
| Owner/pet name 1–100, letters/spaces | `isValidOwnerOrPetName(String)` | same | BookAppointmentServlet |
| Date not in past | `isDateNotInPast(String)` | same | BookAppointmentServlet |
| Constants | `EMAIL_MAX_LENGTH`, `PASSWORD_MIN_LENGTH`, `PASSWORD_MAX_LENGTH`, `ADDRESS_MAX_LENGTH`, `OWNER_OR_PET_NAME_MAX_LENGTH`, `NOTES_MAX_LENGTH` | same | Referenced in validation logic and servlets |

---

## 15. Master data & database

**Master/reference data** (from `database/seed_data.sql`):

- **Roles:** Customer, Veterinarian, Receptionist, LabStaff, Admin, ClinicOwner.
- **Services (DB):** General Checkup, Vaccination, Dental Cleaning, Blood Test, X-Ray, Surgery Consultation, Emergency Visit (with price and description).
- **Lab tests:** e.g. Complete Blood Count, Blood Glucose, Kidney Panel (with description, normal range, unit, status).
- **User status:** e.g. Active (and Inactive if you use it).
- **Appointment/Visit/Invoice statuses:** e.g. Scheduled, Completed, Paid.

**Important tables we use in the flows above:**

- **Users** – email, password, role, status, full_name, phone, address, profile_picture_url, is_google_user.
- **Roles** – role_id, role_name.
- **PasswordResetTokens** – token, email, expires_at (for forgot password).
- **AppointmentRequests** – guest booking (owner_name, email, phone, service, pet_name, pet_type, preferred_date, preferred_time, notes).

**Migrations to run (once):**

- `database/add_profile_picture.sql` – add profile picture column.
- `database/add_is_google_user.sql` – add Google user flag.
- `database/add_unique_email.sql` – unique index on email.
- `database/password_reset_tokens.sql` – table for reset tokens.

---

## 16. URL & file map

Quick reference so you know where each flow lives.

| What              | URL(s)                  | Main file(s) |
|-------------------|-------------------------|--------------|
| Homepage          | `/`, `/index.jsp`       | `web/index.jsp`, `web/bookForm.jsp` (modal) |
| Register          | `/register`             | `RegisterServlet`, `web/register.jsp` |
| Login             | `/login`                | `LoginServlet`, `web/login.jsp` |
| Google Login      | `/google-login`         | `GoogleLoginServlet` |
| Forgot password   | `/forgot-password`      | `ForgotPasswordServlet`, `web/forgot-password.jsp` |
| Reset password    | `/reset-password?token=...` | `ResetPasswordServlet`, `web/reset-password.jsp` |
| Customer Dashboard| `/customer/dashboard`   | `CustomerDashboardServlet`, `web/WEB-INF/views/customer/dashboard.jsp` |
| Customer Profile  | `/customer/profile`     | `CustomerProfileServlet`, `web/WEB-INF/views/customer/profile.jsp` |
| Edit Profile      | `/customer/edit-profile`| `CustomerEditProfileServlet`, `web/WEB-INF/views/customer/edit-profile.jsp` |
| Change Password   | `POST /customer/change-password` | `ChangePasswordServlet` (form on profile.jsp) |
| Logout            | `/logout`               | `LogoutServlet` |
| Guest booking     | `POST /book`            | `BookAppointmentServlet` (form in index.jsp / bookForm.jsp) |

**Shared UI:** Customer pages use `web/WEB-INF/includes/customer-sidebar.jsp` for the same sidebar/header.

**Config:** `web/WEB-INF/web.xml` – servlet mappings, RBAC filter, session timeout, and (optionally) mail context params for forgot-password emails.

---

## 17. Quick code reference table (for reviewers)

One table mapping **action → servlet method → service/DAO/util → view**. Use this to locate the exact function that performs each action.

| # | Flow | Servlet (class.method) | Service / DAO / Util | View / Config |
|---|------|------------------------|----------------------|---------------|
| 1 | Overview | (multiple) | — | index.jsp, login.jsp, register.jsp, etc. |
| 2 | Register | `RegisterServlet.doGet`, `doPost` | `AuthServiceImpl.isEmailTaken`, `registerCustomer`; `UserJdbcDAO.existsByEmail`, `findRoleByName`, `createCustomerUser`; `ValidationUtil.*`; `PasswordUtil.hashPassword` | register.jsp |
| 3 | Login | `LoginServlet.doGet`, `doPost` | `AuthServiceImpl.login`; `UserJdbcDAO.findByEmail`; `ValidationUtil.*`; `PasswordUtil.matches` | login.jsp |
| 4 | Google Login | `GoogleLoginServlet.doGet` | `UserJdbcDAO.findByEmail`, `setGoogleUser`; `AuthServiceImpl.registerCustomer` | login.jsp (link) |
| 5 | Forgot Password | `ForgotPasswordServlet.doGet`, `doPost` | `AuthServiceImpl.createPasswordResetToken`; `UserJdbcDAO.findByEmail`; `PasswordResetTokenJdbcDAO.create`; `ValidationUtil.*`; `MailSender.send` | forgot-password.jsp |
| 6 | Reset Password | `ResetPasswordServlet.doGet`, `doPost` | `AuthServiceImpl.resetPasswordWithToken`; `PasswordResetTokenJdbcDAO.findEmailByToken`, `deleteByToken`; `UserJdbcDAO.findByEmail`, `updatePassword`; `ValidationUtil.isValidPassword`; `PasswordUtil.hashPassword` | reset-password.jsp |
| 7 | Customer Dashboard | `CustomerDashboardServlet.doGet` | (none; uses session) | dashboard.jsp, customer-sidebar.jsp |
| 8 | Customer Profile | `CustomerProfileServlet.doGet` | (none; uses session) | profile.jsp |
| 9 | Edit Profile | `CustomerEditProfileServlet.doGet`, `doPost` | `UserJdbcDAO.updateUser`; `ValidationUtil.*` | edit-profile.jsp |
| 10 | Change Password | `ChangePasswordServlet.doPost` | `AuthServiceImpl.changePassword`; `UserJdbcDAO.findById`, `updatePassword`; `ValidationUtil.isValidPassword`; `PasswordUtil.matches`, `hashPassword` | profile.jsp (modal) |
| 11 | Logout | `LogoutServlet.doGet`/`doPost` | (none) | customer-sidebar.jsp (link) |
| 12 | Guest booking | `BookAppointmentServlet.doPost` | `ValidationUtil.*`; `DBContext.getConnection` + PreparedStatement INSERT | index.jsp, bookForm.jsp |
| 13 | Access control | `RoleBasedAccessFilter.doFilter` | — | web.xml (filter-mapping) |
| 14 | Validation | (all servlets above) | `ValidationUtil` (see table in §14) | (same) |
| 15 | Master data | — | Tables: Roles, Services, Users, PasswordResetTokens, AppointmentRequests | seed_data.sql, migration scripts |
| 16 | URL map | web.xml servlet-mapping | — | web.xml |

---

This is the **full flow of everything we built**: from opening the site, to registering, logging in (normal and Google), resetting password, using the customer area (dashboard, profile, edit profile, change password), logging out, and submitting a guest booking, plus how access and validation work and where master data and URLs live.
