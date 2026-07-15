# Smart City Backend (Go + Postgres)

## 1. Create the database

```bash
createdb smartcity
psql -d smartcity -f schema.sql
```

Or with `psql` directly:
```bash
psql -U postgres -c "CREATE DATABASE smartcity;"
psql -U postgres -d smartcity -f schema.sql
```

Edit the connection constants at the top of `db.go` (`dbUser`,
`dbPassword`, etc.) to match your local Postgres setup.

## 2. Register at least one staff number (for testing)

```sql
INSERT INTO staff_numbers (mobile_number, department)
VALUES ('9999999999', 'Municipal Ops');
```

Only this number will ever see the "citizen or staff" popup on
login. Every other number goes straight through as a citizen.

## 3. Install deps & run

```bash
go mod tidy
go run .
```

You should see:
```
connected to Postgres database: smartcity
smart city backend listening on 0.0.0.0:8080
```

## 4. Point your phone at the right address

This is the fix for the "captcha only works when plugged in"
problem: find this machine's LAN IP (`ipconfig` on Windows,
`ifconfig` / `ip addr` on Mac/Linux — look for something like
`192.168.1.42`), and set that as the base URL in the Flutter app's
`api_service.dart`. Your phone and this machine need to be on the
same WiFi network. Do NOT use `localhost` or `10.0.2.2` (those
only resolve inside an emulator or over a USB debug bridge).

## API endpoints

| Method | Path                 | Body                                              | Notes |
|--------|----------------------|----------------------------------------------------|-------|
| GET    | /api/captcha/new     | -                                                    | Returns `{captcha_id, image_bytes}` (PNG, base64) |
| POST   | /api/login           | `{mobile_number, captcha_id, captcha_answer}`       | Verifies captcha, sends OTP (printed to this terminal for now) |
| POST   | /api/otp/verify      | `{mobile_number, otp}`                              | Returns `{is_staff}` |

## Swapping the OTP terminal-print for real SMS later

Everything is isolated in `loginHandler` in `handlers.go` — replace
the `fmt.Printf(...)` line with a call to your SMS provider's API
(MSG91, Twilio, etc.) once you're ready. Nothing else needs to change.
