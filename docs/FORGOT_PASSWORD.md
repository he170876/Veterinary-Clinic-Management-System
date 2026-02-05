# Forgot Password (Email-Based Reset)

## Flow

1. User clicks **Forgot password?** on the login page → `/forgot-password`.
2. User enters Gmail address and submits.
3. If the email is registered and is **not** a Google sign-in account, a reset token is created (valid 1 hour) and:
   - If **mail is configured**: an email is sent with the reset link.
   - If **mail is not configured**: the reset link is shown on the success page (e.g. for development).
4. User opens the reset link → `/reset-password?token=...`.
5. User enters new password (and confirm), submits. Password is updated and token is invalidated.
6. User is redirected to login with a success message.

Google sign-in accounts cannot use forgot password; they must sign in with Google.

## Database

Run once:

```sql
-- See database/password_reset_tokens.sql
```

This creates the `PasswordResetTokens` table (token, email, expires_at, created_at).

## Enabling Email Sending

1. Add **Jakarta Mail** (and **Jakarta Activation**) to your project `lib` folder, for example:
   - [Eclipse Angus Mail](https://eclipse-ee4j.github.io/angus-mail/) (implementation)
   - `jakarta.mail-api` (API)

2. In `web/WEB-INF/web.xml`, set context params:

   - `mail.enabled` = `true`
   - `mail.smtp.host` = e.g. `smtp.gmail.com`
   - `mail.smtp.port` = e.g. `587`
   - `mail.smtp.starttls` = `true`
   - `mail.smtp.user` = your SMTP username (e.g. Gmail address)
   - `mail.smtp.password` = your SMTP password or app password
   - `mail.from` = from address (e.g. `noreply@yourdomain.com`)

For Gmail, use an [App Password](https://support.google.com/accounts/answer/185833) if 2FA is enabled.

If `mail.enabled` is `false` or mail is not configured, the reset link is shown on the forgot-password success page so you can test without SMTP.
