# MediQueue

[![CI](https://github.com/Henryyy1106/MediQueue/actions/workflows/ci.yml/badge.svg)](https://github.com/Henryyy1106/MediQueue/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

AI-powered smart public clinic queue and appointment system built with Jakarta EE for Malaysian public clinics. Patients can find clinics, book appointments, join a live queue, and review visits. Admins can monitor the queue, manage users, moderate appointments, and generate reports.

> SWE3024 Code Camp | Sunway University

## Quick start

If you just want the app running with the least setup:

```bash
git clone https://github.com/Henryyy1106/MediQueue.git
cd MediQueue
docker compose up --build
```

Then open:

`http://localhost:8080/mediqueue/`

Default logins:

| Role    | Email                | Password   |
|---------|----------------------|------------|
| Patient | patient@mediqueue.my | patient123 |
| Admin   | admin@mediqueue.my   | admin123   |

## Features

- Patient registration and login
- Clinic browsing and appointment booking
- Live queue tracking
- Visit history and clinic ratings
- Admin dashboard
- Admin queue management
- Admin user management
- Admin appointment moderation
- Admin reports
- AI helper with safe fallback mode when no API key is configured

## Tech stack

- Java 11+ / Jakarta EE 9
- JSP / JSTL / Servlets
- MySQL 8
- Maven WAR build
- Tomcat 11
- HikariCP
- BCrypt

## Run options

All run modes serve the app at:

`http://localhost:8080/mediqueue/`

### Option A: Full Docker

Best if you want the simplest setup and do not mind rebuilding the app container.

```bash
docker compose up --build
```

Stop it with:

```bash
docker compose down
```

### Option B: Windows local app + Docker DB

Best for active development on Windows.

Requirements:

- Java JDK installed
- Maven installed
- Docker Desktop installed
- Tomcat 11 installed

Recommended Tomcat setup:

- Extract Tomcat to a path like `C:\apache-tomcat-11.0.11`
- Set `CATALINA_HOME` to that Tomcat folder

Then run:

```powershell
.\run-local.ps1
```

That script will:

- start the MySQL Docker container
- set the DB env vars for the current shell
- run `mvn clean package`
- deploy `target\mediqueue.war` into Tomcat
- start Tomcat

For a quicker rebuild without tests:

```powershell
.\run-local.ps1 -SkipTests
```

To stop the local stack:

```powershell
.\stop-local.ps1
```

### Option C: macOS helper scripts

If you are on macOS with Homebrew:

```bash
./start.sh
./stop.sh
```

### Option D: Manual

1. Start MySQL and create the `mediqueue` database.
2. Load the schema:
   ```bash
   mysql -u root -p < sql/mediqueue_schema.sql
   ```
3. Build the WAR:
   ```bash
   mvn clean package
   ```
4. Set DB connection values if needed:
   - `MEDIQUEUE_DB_URL`
   - `MEDIQUEUE_DB_USERNAME`
   - `MEDIQUEUE_DB_PASSWORD`
5. Copy `target/mediqueue.war` into Tomcat `webapps`.
6. Start Tomcat.

## Database notes

Default local DB credentials in this project are:

- username: `root`
- password: `root`

If you use Docker for DB only, the project expects MySQL on host port `3307`.

## Tests

Run:

```bash
mvn test
```

If you are using Docker only for the database, make sure the DB container is running before tests. The Windows helper script already handles this setup.

## Why you might still see old UI

If you still see the old admin navbar with `Settings`, that usually means the browser is showing an older deployed WAR, not the current source code.

Current source navbar:

- Dashboard
- Queue Panel
- Users
- Appointments
- Reports

`Settings` has already been removed from the source include.

To refresh the deployed app:

1. Rebuild and redeploy:
   ```powershell
   .\run-local.ps1 -SkipTests
   ```
2. Hard refresh the browser with `Ctrl + F5`
3. If needed, stop and restart Tomcat, then reload

If you are using the full Docker app instead of local Tomcat, rebuild the app container:

```powershell
docker compose up --build
```

## Project structure

```text
src/main/java/com/mediqueue/
  ai/
  controller/
  dao/
  filter/
  listener/
  model/
  util/
src/main/webapp/
sql/
```

## License

Released under the [MIT License](LICENSE).
