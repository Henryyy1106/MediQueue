# MediQueue

AI-Powered Smart Public Clinic Queue & Appointment System — a Jakarta EE web app for Malaysian public clinics. Patients can find clinics, book appointments, join a live queue, and rate their visits; an AI helper (Claude) assists with urgency triage, clinic recommendations, pre-visit care tips, and a chat assistant.

> SWE3024 Code Camp · Sunway University

## Features

- **Patient:** registration/login, clinic search, appointment booking, live queue status, visit history, profile, clinic ratings
- **Admin:** dashboard, live queue management (call next / complete), reports
- **AI helper (Claude):** urgency classification, rating-aware clinic recommendation, pre-visit care tips, and a floating chat assistant — all with safe offline fallbacks when no API key is configured
- **Security:** session-based auth with role enforcement, CSRF protection, output escaping (XSS), rate limiting on login and AI endpoints, hardened session cookies

## Tech stack

- Java 11, Jakarta EE 9 (Servlet 5.0 / JSP / JSTL)
- MySQL 8 with HikariCP connection pooling
- Maven (WAR packaging)
- BCrypt password hashing, Claude API (Anthropic)
- Self-hosted Flaticon UIcons (no external CDN needed)

## Prerequisites

- JDK 11+ and Maven 3.6+
- MySQL 8
- A Servlet 5.0+ container — Apache **Tomcat 11** is recommended
- *(Optional)* a Claude API key for live AI features (the app runs with graceful fallbacks without one)

## Setup

1. **Create the database and load the schema:**
   ```bash
   mysql -u root -p < sql/mediqueue_schema.sql
   ```

2. **Configure the DB connection** (defaults to `jdbc:mysql://localhost:3306/mediqueue`, user `root`/`root`). Override via system properties or environment variables if needed:
   - `mediqueue.db.url` / `MEDIQUEUE_DB_URL`
   - `mediqueue.db.username` / `MEDIQUEUE_DB_USERNAME`
   - `mediqueue.db.password` / `MEDIQUEUE_DB_PASSWORD`

3. **(Optional) Enable live AI** by exporting your Claude API key before starting the server:
   ```bash
   export CLAUDE_API_KEY="your-key-here"
   ```

## Build & run

```bash
mvn clean package          # produces target/mediqueue.war
```

Deploy `target/mediqueue.war` to Tomcat, then open: http://localhost:8080/mediqueue/

**Local helper scripts** (macOS, Homebrew Tomcat + an isolated MySQL on port 3307):
```bash
./start.sh    # builds, starts MySQL + Tomcat, deploys the WAR
./stop.sh     # shuts everything down
```

## Default seed logins

| Role    | Email                   | Password     |
|---------|-------------------------|--------------|
| Patient | patient@mediqueue.my    | patient123   |
| Admin   | admin@mediqueue.my      | admin123     |

> Change or remove these before any real deployment.

## Tests

```bash
mvn test
```

Unit tests cover password hashing, model/presentation logic, and the AI offline-fallback safety rules. The AI tests auto-skip when `CLAUDE_API_KEY` is set (to avoid live API calls).

## Project structure

```
src/main/java/com/mediqueue/
  ai/          Claude integration + response model
  controller/  Servlets (auth, patient, admin, AI)
  dao/         Data access objects
  filter/      Auth, CSRF, rate-limiting filters
  listener/    App lifecycle (DB pool shutdown)
  model/       Entities
  util/        DB connection pool, password hashing
src/main/webapp/   JSP views, CSS, vendored icon fonts
sql/               Database schema + seed data
```

## Notes

- Default DB credentials and seed accounts are for local development only — do not use them in production.
- AI features degrade gracefully (keyword-based fallbacks) when no API key is present.
