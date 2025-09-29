# bookN

## Configuration

This backend no longer stores sensitive credentials in `appsettings.json`. Before running the API, provide the following environment variables (for development you can use a tool like [`dotnet user-secrets`](https://learn.microsoft.com/aspnet/core/security/app-secrets) or a `.env` loader):

| Environment variable | Purpose |
| --- | --- |
| `DEFAULT_CONNECTION_STRING` **or** `ConnectionStrings__DefaultConnection` | Full SQL Server connection string |
| `JWT_SECRET` | Signing key for JWT tokens |
| `SENDGRID_API_KEY` | SendGrid SMTP/API key used by `EmailSettings:Password` |
| `SENDGRID_USERNAME` *(optional)* | SMTP username; defaults to `apikey` when omitted |

You can also override any individual setting via the double underscore (`__`) syntax, e.g. `EmailSettings__FromEmail`.

> **Reminder:** Rotate any credentials that were previously committed to the repository before deploying to production.