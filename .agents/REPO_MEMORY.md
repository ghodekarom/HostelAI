# HFCMS Repository Memory (REPO_MEMORY.md)

**Project:** Hostel Facility Complaint Management System — AI Case Manager (HFCMS)  
**Authoritative Specs:** PRD v1.3 & SRS v1.1  
**Monorepo:** `backend/` (Spring Boot 3.3.4, Java 21) + `frontend/` (Flutter multiplatform)  
**Last Updated:** 2026-09-17 (Phase 4 Completed & SRS v1.1 Full Frontend Implemented)

---

## 1. Active Git State & Remote Branches

- **Active Local Branch:** `dev` (clean working tree, in sync with `origin/dev`)
- **Remote Repository:** `https://github.com/ghodekarom/HostelAI.git`
- **Published Remote Branches:**
  - `origin/main` (Production release branch)
  - `origin/dev` (Active integration branch — Phase 1, 2, 3, 4 merged)
  - `origin/feature/phase-01-project-setup` (Visible on remote)
  - `origin/feature/phase-02-database` (Visible on remote)
  - `origin/feature/phase-03-backend` (Visible on remote)
  - `origin/feature/phase-04-frontend` (Visible on remote)
  - `origin/feature/phase-04-frontend-full` (Visible on remote)
- **Branching Rules:**
  - Strict 3-tier: `feature/phase-XX-*` ➔ `dev` ➔ `main`.
  - Feature branches are never deleted from remote GitHub upon merging; keep them published.
  - Merges into `dev` must always use `--no-ff`.

---

## 2. Completed Phases Summary (40% Complete)

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
- **Database Initialized:** Local PostgreSQL 18 database `hfcms` created with user `postgres` and password `password`.
- **Automatic .env Loader:** `HfcmsApplication.java` reads `backend/.env` on startup.
- **Hibernate Fix:** Mapped PostgreSQL `jsonb` column `risk_reasons` with `@JdbcTypeCode(SqlTypes.JSON)`.
- **Security:** `SecurityConfig.java` permits Swagger UI and dev REST endpoints.
- **DTOs:** Created `ChecklistResponse` DTO to prevent Hibernate ByteBuddy serialization errors.
- **Admin APIs:** Added infrastructure endpoints (`POST /api/v1/admin/hostels`, `/blocks`, `/rooms`).
- **Live 14-Step Lifecycle Verified via Swagger UI (`http://localhost:8080/swagger-ui/index.html`):**
  Intake `REPORTED` ➔ Review `OPERATOR_REVIEW` ➔ Missing Info `WAITING_FOR_INFORMATION` ➔ Respond `ACTIVE` ➔ Assign `ASSIGNED` ➔ Checklist finding `INVESTIGATED` ➔ Repair action `ACTION_TAKEN` ➔ Resolution proposal `RESOLUTION_PROPOSED` ➔ Student decision `CONFIRMED`/`CLOSED`.

### Phase 4: Flutter Frontend Architecture & Full SRS UI (Adhering to SRS v1.1)
- **Feature-First Architecture (`frontend/lib/features/`):**
  - `auth/`: `SignInScreen` (`/login`), `SignUpScreen` (`/signup`), `VerifyCodeScreen` (`/verify`), `PasswordResetScreen` (`/password-reset`) matching SRS §5.
  - `complaints/`: `StudentDashboardScreen` (`/student`), `ComplaintFilingScreen` (`/student/new`), `ComplaintDetailScreen` (`/student/complaints/:id`), `MyComplaintsScreen`.
  - `operator/`: `OperatorQueueScreen` (`/operator`), `OperatorTriageScreen` (`/operator/complaints/:id`) with AI review override, duplicate comparison (`pg_trgm`), technician assignment, and resolution proposing.
  - `technician/`: `TechnicianTasksScreen` (`/technician`), `TechnicianTaskDetailScreen` (`/technician/complaints/:id`) with interactive diagnostic checklist findings (`INVESTIGATED`) and repair logging (`ACTION_TAKEN`).
  - `team_lead/`: `TeamLeadAtRiskScreen` (`/team-lead`), `TeamLeadInterventionScreen` (`/team-lead/complaints/:id`) with SLA context, risk factors, and intervention execution (`REASSIGN_TECHNICIAN`, `BOOST_PRIORITY`, `ADD_RESOURCES`, `ESCALATE`).
  - `manager/`: `ManagerAnalyticsScreen` (`/manager`) with MTTR, MTTA, SLA compliance, chronic hotspots, and 90-day recurring failure clustering matching SRS §8.7.
  - `admin/`: `AdminDashboardScreen` (`/admin`) for campus hostels, blocks, rooms, categories with SLA, and maintenance teams.
  - `notifications/`: `NotificationsScreen` (`/notifications`) with read/unread tracking and direct case navigation.
  - `portal/`: `PortalHomeScreen` (`/`) with 6-persona launcher and system health status.
- **Core Infrastructure & Design System:**
  - `AppShell`: Responsive navigation (Desktop sidebar vs Mobile navigation bar) with dynamic active role switcher across all 6 SRS personas, and live notification unread counter badge.
  - `AppTheme` & `AppColors`: Material 3 light and dark themes, status badges for all 14 statuses, `AiBadge`, `PriorityBadge` (P1-P4), `SeverityBadge`.
  - `Dio` Network Layer: Custom `ApiException` with `fieldErrors` mapping and timeouts.
  - `Riverpod` State Management: AsyncNotifiers and family providers for all domain layers.
  - `SecureStorageService`: Encrypted JWT and refresh token persistence.
  - Automated tests: `models_test.dart` and `widget_test.dart`.

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

## 4. Next Phase to Implement: Phase 5

- **Phase 5 Name:** Authentication & Role-Based Access Control (RBAC)
- **Target Branch:** `feature/phase-05-auth-rbac` (branched from `dev`)
- **Core Scope:**
  - Backend Spring Security 6 filter chain with stateless JWT validation.
  - BCrypt password hashing (strength 12).
  - Auth REST endpoints: `signup`, `verify` (6-digit OTP email), `signin`, `refresh`, `logout`, `password-reset`.
  - Method-level security annotations (`@PreAuthorize`) on all controller endpoints across all 6 roles.
  - Frontend `AuthInterceptor` on Dio client: attach Bearer token, handle 401 Unauthorized with automatic token refresh, redirect to `/login` upon expiration.
  - `GoRouter` authentication and RBAC navigation guards.
