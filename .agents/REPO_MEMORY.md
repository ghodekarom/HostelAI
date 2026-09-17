# HFCMS Repository Memory (REPO_MEMORY.md)

**Project:** Hostel Facility Complaint Management System — AI Case Manager (HFCMS)  
**Authoritative Specs:** PRD v1.3 & SRS v1.1  
**Monorepo:** `backend/` (Spring Boot 3.3.4, Java 21) + `frontend/` (Flutter multiplatform)  
**Last Updated:** 2026-09-17 (Phase 7 Notifications & Real-Time Updates Completed)

---

## 1. Active Git State & Remote Branches

- **Active Local Branch:** `feature/phase-07-notifications` (ready to merge into `dev`)
- **Remote Repository:** `https://github.com/ghodekarom/HostelAI.git`
- **Published Remote Branches:**
  - `origin/main` (Production release branch)
  - `origin/dev` (Active integration branch — Phases 1-6 merged)
  - `origin/feature/phase-01-project-setup`
  - `origin/feature/phase-02-database`
  - `origin/feature/phase-03-backend`
  - `origin/feature/phase-04-frontend`
  - `origin/feature/phase-04-frontend-full`
  - `origin/feature/phase-04-multiplatform`
  - `origin/feature/phase-05-auth-rbac`
  - `origin/feature/phase-06-ai-pipeline`
- **Branching Rules:**
  - Strict 3-tier: `feature/phase-XX-*` ➔ `dev` ➔ `main`.
  - Feature branches are never deleted from remote GitHub upon merging; keep them published.
  - Merges into `dev` must always use `--no-ff`.

---

## 2. Completed Phases Summary (70% Complete)

### Phase 1: Project Setup & Monorepo Foundation
- Monorepo directory structure: `backend/`, `frontend/`, `docs/`, `.github/workflows/ci.yml`.
- Strict `.gitignore` protecting `.env`, credentials, IDE, and build files.
- `.env.example` templates committed for backend and frontend.
- `docker-compose.yml` configured for PostgreSQL 15 and Mailpit.
- Spring Boot 3.3.4 skeleton with Java 21, Maven wrapper (`mvnw.cmd`), OpenAPI 3.0, and centralized exception handling.
- Flutter multiplatform skeleton with base theme, routing, and network client.

### Phase 2: Database Infrastructure & Migrations
- 7 Flyway versioned migration scripts in `backend/src/main/resources/db/migration/`:
  - `V1__init_extensions_and_auth.sql` (`pg_trgm`, `roles`, `users`, `verification_codes`, `refresh_tokens`)
  - `V2__init_hostel_infrastructure.sql` (`hostels`, `blocks`, `rooms`, `categories`, `teams`, `technicians`)
  - `V3__init_complaint_core.sql` (`complaints` with 14 statuses, `complaint_evidence`, `complaint_related_cases`)
  - `V4__init_lifecycle_and_tasks.sql` (`assignment_history`, `missing_info_requests`, `investigation_checklists`, `checklist_items`, `repair_actions`, `resolutions`, `case_status_history`)
  - `V5__init_notifications_and_ai_log.sql` (`notifications`, `ai_analysis_log`)
  - `V6__create_indexes_and_trigrams.sql` (GIN trigram index on `complaints(description)` + composite indexes)
  - `V7__seed_reference_data.sql` (6 roles, 6 maintenance teams, 10 complaint categories matching PRD §9)

### Phase 3: Core Backend REST API & Business Logic (Verified on Live DB)
- Local PostgreSQL 18 database `hfcms` created with user `postgres` and password `password`.
- Automatic .env loader in `HfcmsApplication.java`.
- Hibernate JSON mapping with `@JdbcTypeCode(SqlTypes.JSON)`.
- Centralized exception handling with RFC 7807 problem details.
- Full 14-step complaint lifecycle verified via Swagger UI.

### Phase 4: Flutter Frontend Architecture & Full SRS UI (Adhering to SRS v1.1)
- Feature-First Architecture (`frontend/lib/features/`): `auth/`, `complaints/`, `operator/`, `technician/`, `team_lead/`, `manager/`, `admin/`, `notifications/`, `portal/`.
- Global responsive shell (`AppShell`) adapting between Desktop sidebar and Mobile navigation bar.
- Multiplatform native build harnesses for all 6 target OS: Android (SDK 34), iOS (CocoaPods/Xcode), Windows (Win32 CMake C++17), Linux (GTK 3.0 CMake), macOS (Cocoa Swift), Web (PWA).

### Phase 5: Authentication & Role-Based Access Control (RBAC) (SRS §5, §8.2, §9 FR-17)
- **Backend Spring Security 6 Architecture:** Stateless JWT authentication filter (`JwtAuthenticationFilter`), BCrypt password encoder (strength 12), method-level `@PreAuthorize` across controllers.
- **REST Auth Endpoints (`/api/v1/auth/*`):** Signup, OTP verify, OTP resend, signin, token rotation refresh, password reset request/confirm, logout.
- **Frontend Security:** Dio `AuthInterceptor` injecting Bearer token, automatic 401 token rotation and retry, persistent secure storage session management.

### Phase 6: AI Complaint Analysis Pipeline (SRS §8.4, §9 FR-2, FR-3, FR-7, FR-18)
- **Multi-Provider AI Architecture:** Extensible `AiClient` interface (`gemini-1.5-flash`, `claude-3-5-sonnet`, `RuleBasedMockAiClient`).
- **Automated Triage Pipeline:** Automatic categorization, severity assessment, priority assignment, SLA calculation, team suggestion, AI summary, missing information detection.
- **Duplicate Linking & Checklists:** Trigram similarity matching (`pg_trgm`) and automated diagnostic checklist generation.

### Phase 7: Notifications & Real-Time Updates (SRS §8.6, §8.9, §9 FR-16, §11.2, §13 Phase 7)
- **Persistent In-App Notification Feed:** JPA `Notification` entity mapping `notifications` table, indexed queries by user and unread status.
- **STOMP / WebSocket Real-Time Push:** `@EnableWebSocketMessageBroker` registering `/ws/notifications` with SockJS fallback and `WebSocketAuthInterceptor` enforcing JWT token authentication on `CONNECT` frames. Broadcasts to `/topic/user.{userId}.notifications` and `/topic/user.{userId}.unread-count`.
- **Transactional Email Dispatch:** Asynchronous (`@Async`) `EmailDispatcherService` routing to `SmtpEmailService` (Mailpit port 1025) and `ResendEmailService` with non-blocking error degradation.
- **Lifecycle Event Hooks:** Automatic alerts on complaint intake, technician dispatch, clarification requests, repair progress, and resolution proposals/confirmations.
- **Frontend Real-Time Feed:** Connected `notification_repository.dart`, unread badge counter, and "Mark all read" controls in `notifications_screen.dart`.
- **100% Test Coverage:** 40/40 backend tests passing across all suites.

---

## 3. Local Environment & Service Configurations

| Service | Port | Details / Credentials |
|---|---|---|
| **Spring Boot Backend** | `8080` | Context path `/`, OpenAPI `/v3/api-docs`, Swagger `/swagger-ui/index.html` |
| **PostgreSQL 18** | `5432` | Database: `hfcms`, User: `postgres`, Password: `password` |
| **Mailpit (Docker)** | `1025` (SMTP) / `8025` (Web UI) | Local development transactional email capture |
| **Backend .env** | N/A | Ignored by Git, auto-loaded on startup, configured with `local` profile |
| **Frontend .env** | N/A | Ignored by Git, points to `http://localhost:8080/api/v1` |

---

## 4. Next Phase to Implement: Phase 8

- **Phase 8 Name:** Risk / SLA Monitoring & Escalation
- **Target Branch:** `feature/phase-08-risk-sla` (to be branched from `dev`)
- **Core Scope:**
  - Scheduled SLA monitoring job (`@Scheduled(cron = "0 */15 * * * *")`): checks active cases approaching or breaching SLA deadlines.
  - Automated risk evaluation: inactivity detection, affected student count evaluation, complexity risk scoring.
  - Status updates: flags `is_at_risk = TRUE`, records risk reason and risk score.
  - Team Lead Queue (`GET /api/v1/team-lead/at-risk`) and Case Context (`GET /api/v1/complaints/{id}/context`).
  - Team Lead Intervention (`POST /api/v1/complaints/{id}/intervene`): reassign technician, escalate priority, add resources, override SLA.
  - Audit logging in `assignment_history` and `case_status_history`.
