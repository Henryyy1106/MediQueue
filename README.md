# MediQueue

[![CI](https://github.com/Henryyy1106/MediQueue/actions/workflows/ci.yml/badge.svg)](https://github.com/Henryyy1106/MediQueue/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

AI-Powered Smart Public Clinic Queue & Appointment System — a Jakarta EE web app for Malaysian public clinics. Patients can find clinics, book appointments, join a live queue, and rate their visits; an AI helper (Claude) assists with urgency triage, clinic recommendations, pre-visit care tips, and a chat assistant.

> SWE3024 Code Camp · Sunway University

## Quick start (teammates)

The easiest way to run it on any OS — only [Docker Desktop](https://www.docker.com/products/docker-desktop/) required (no Java/Maven/MySQL needed):

```bash
git clone https://github.com/Henryyy1106/MediQueue.git
cd MediQueue
docker compose up --build
```

First run takes a few minutes (it downloads images and builds). When Tomcat prints *"Server startup..."*, open **http://localhost:8080/mediqueue/** and log in:

| Role    | Email                | Password   |
|---------|----------------------|------------|
| Patient | patient@mediqueue.my | patient123 |
| Admin   | admin@mediqueue.my   | admin123   |

Stop with `Ctrl+C`, then `docker compose down` (add `-v` to also wipe the database).

> Notes: Docker uses ports **8080** and **3307** — free them if they're in use. AI features run in fallback mode with no setup; for live AI, `export CLAUDE_API_KEY="..."` before running. Prefer no Docker? See [Run it](#run-it) for the Mac-script and manual options.

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

- **Easiest:** just **Docker** — see [Option A](#option-a--docker-any-os-recommended-for-teammates) (no local Java/MySQL/Tomcat needed).
- **Without Docker:** JDK 11+, Maven 3.6+, MySQL 8, and a Servlet 5.0+ container (**Tomcat 11** recommended).
- *(Optional)* a Claude API key for live AI features — the app runs with graceful fallbacks without one.

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

## Run it

Pick whichever fits your machine. All three serve the app at **http://localhost:8080/mediqueue/**.

### Option A — Docker (any OS, recommended for teammates)

The only requirement is Docker Desktop. This builds the app, starts MySQL, loads the schema, and runs Tomcat — one command, no local Java/Maven/MySQL needed:

```bash
docker compose up --build
```

Stop with `Ctrl+C`, or `docker compose down` (add `-v` to also wipe the database). To enable live AI, export `CLAUDE_API_KEY` before running.

### Option B — Helper scripts (macOS + Homebrew)

Requires `brew install mysql tomcat maven` and a JDK. Spins up an isolated MySQL on port 3307, loads the schema, builds, and deploys automatically:

```bash
./start.sh    # build + start MySQL + Tomcat + deploy
./stop.sh     # shut everything down
```

### Option C — Manual (any OS)

1. Install **MySQL 8**, **Maven**, a **JDK 11+**, and **Tomcat 11**.
2. Create the database and load the schema:
   ```bash
   mysql -u root -p < sql/mediqueue_schema.sql
   ```
3. Build the WAR:
   ```bash
   mvn clean package          # -> target/mediqueue.war
   ```
4. Tell the app how to reach your database (if it isn't the default `root@localhost:3306`) via env vars or `-D` system properties — see [Setup](#setup).
5. Copy `target/mediqueue.war` into Tomcat's `webapps/` and start Tomcat.

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

## License

Released under the [MIT License](LICENSE).
