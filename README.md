# Hostel Facility Complaint Management System (HFCMS) — AI Case Manager

[![CI](https://github.com/ghodekarom/HostelAI/actions/workflows/ci.yml/badge.svg)](https://github.com/ghodekarom/HostelAI/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/version-1.0.0--SNAPSHOT-blue.svg)](https://github.com/ghodekarom/HostelAI)
[![Stack](https://img.shields.io/badge/tech--stack-Java21%20%7C%20SpringBoot3%20%7C%20Flutter-teal.svg)](https://github.com/ghodekarom/HostelAI)

> **Based on:** HFCMS PRD v1.3 & SRS v1.1  
> An AI-assisted case-management platform enabling hostel students to report facility issues and providing maintenance staff, wardens, and management with structured, transparent tracking, automated risk/SLA monitoring, and operational intelligence.

---

## 1. Monorepo Architecture

```text
HostelAI/
├── backend/                      # Java 21 + Spring Boot 3.x REST API
│   ├── src/main/java/com/hfcms/  # Feature-first modular business domain
│   ├── src/main/resources/       # Profiles & Flyway migrations
│   ├── pom.xml                   # Maven dependencies & build plugins
│   ├── mvnw & mvnw.cmd           # Maven wrapper scripts
│   └── .env.example              # Backend environment template
├── frontend/                     # Flutter multiplatform client (Web, Desktop, Mobile)
│   ├── lib/                      # Core widgets, Riverpod state, Dio client, routes
│   ├── pubspec.yaml              # Dart dependencies
│   └── .env.example              # Frontend environment template
├── docs/                         # Authoritative PRD & SRS documentation
├── .github/workflows/            # CI/CD pipeline definitions
├── docker-compose.yml            # Local PostgreSQL 15 & Mailpit services
└── progress.md                   # Live phase-by-phase implementation progress tracker
```

---

## 2. Environment-Driven Configuration (Strict Rule)

All configuration and secrets are **strictly environment-driven**. Real `.env` files must **NEVER** be committed into version control.

### 2.1 Backend Setup
1. Copy the environment template:
   ```bash
   cp backend/.env.example backend/.env
   ```
2. By default, `backend/.env` is configured for local development (`SPRING_PROFILES_ACTIVE=local`) pointing to Docker PostgreSQL and Mailpit with `AI_MOCK_ENABLED=true`.

### 2.2 Frontend Setup
1. Copy the environment template:
   ```bash
   cp frontend/.env.example frontend/.env
   ```
2. The frontend `.env` contains safe client URLs (`HFCMS_API_BASE_URL` and `HFCMS_WS_BASE_URL`).

---

## 3. Local Development Setup

### 3.1 Start Database & Email Services
Launch PostgreSQL 15 and Mailpit using Docker Compose:
```bash
docker compose up -d
```
- PostgreSQL available on `localhost:5432` (db: `hfcms`, user: `postgres`, password: `postgres`).
- Mailpit Web UI available on `http://localhost:8025` (SMTP port `1025`).

### 3.2 Run Backend (Spring Boot 3.x)
```bash
cd backend
./mvnw clean spring-boot:run
```
- API Base Path: `http://localhost:8080/api/v1`
- Swagger UI / OpenAPI Docs: `http://localhost:8080/swagger-ui.html`
- Health Checks: `http://localhost:8080/actuator/health`

### 3.3 Run Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run -d chrome # Or windows / macos / linux
```

---

## 4. Git Branching Strategy & Workflow

This project strictly adheres to the three-tier branching model defined in **SRS Section 14**:

```text
feature/phase-XX-<name> ──(PR)──> dev ──(PR after Phase 10)──> main (Release v1.0.0)
```

1. **`main`**: Permanent release branch. Contains only stable, release-ready code.
2. **`dev`**: Permanent integration branch. All feature branches merge into `dev`.
3. **`feature/phase-XX-*`**: Temporary phase branches originating from `dev` and merging back into `dev` via Pull Request after CI passes.

> Direct pushes to `dev` and `main` are strictly forbidden.

---

## 5. Development Phases

| Phase | Description | Feature Branch | Status |
|---|---|---|---|
| **Phase 1** | Project Setup & Monorepo Foundation | `feature/phase-01-project-setup` | In Progress |
| **Phase 2** | Database Infrastructure & Flyway Migrations | `feature/phase-02-database` | Pending |
| **Phase 3** | Core Backend REST API & Business Logic | `feature/phase-03-backend` | Pending |
| **Phase 4** | Flutter Frontend Architecture & Core UI | `feature/phase-04-frontend` | Pending |
| **Phase 5** | Authentication & Role-Based Access Control | `feature/phase-05-auth-rbac` | Pending |
| **Phase 6** | AI Case Manager & Automation Subsystem | `feature/phase-06-ai-automation` | Pending |
| **Phase 7** | Notifications & Real-Time Updates | `feature/phase-07-notifications` | Pending |
| **Phase 8** | Risk / SLA Monitoring & Escalation | `feature/phase-08-risk-sla` | Pending |
| **Phase 9** | Manager Analytics Dashboard | `feature/phase-09-analytics` | Pending |
| **Phase 10** | Testing, Hardening & Production Release | `feature/phase-10-testing-release` | Pending |
