# HFCMS Repository Memory (REPO_MEMORY.md)

**Project:** Hostel Facility Complaint Management System — AI Case Manager (HFCMS)  
**Authoritative Specs:** PRD v1.3 & SRS v1.1  
**Monorepo:** `backend/` (Spring Boot 3.3.4, Java 21) + `frontend/` (Flutter multiplatform)  
**Last Updated:** 2026-09-17 (Phase 6 AI Complaint Analysis Pipeline Completed)

---

## 1. Active Git State & Remote Branches

- **Active Local Branch:** `feature/phase-06-ai-pipeline` (ready to merge into `dev`)
- **Remote Repository:** `https://github.com/ghodekarom/HostelAI.git`
- **Published Remote Branches:**
  - `origin/main` (Production release branch)
  - `origin/dev` (Active integration branch — Phases 1-5 merged)
  - `origin/feature/phase-01-project-setup`
  - `origin/feature/phase-02-database`
  - `origin/feature/phase-03-backend`
  - `origin/feature/phase-04-frontend`
  - `origin/feature/phase-04-frontend-full`
  - `origin/feature/phase-04-multiplatform`
  - `origin/feature/phase-05-auth-rbac`
- **Branching Rules:**
  - Strict 3-tier: `feature/phase-XX-*` ➔ `dev` ➔ `main`.
  - Feature branches are never deleted from remote GitHub upon merging; keep them published.
  - Merges into `dev` must always use `--no-ff`.

---

## 2. Completed Phases Summary (60% Complete)

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
- **Multi-Provider AI Architecture:** Extensible `AiClient` interface with implementations for Google Gemini 1.5 Flash (`GeminiAiClient`), Anthropic Claude 3.5 Sonnet (`AnthropicAiClient`), and deterministic local fallback (`RuleBasedMockAiClient`).
- **Automated Triage Pipeline:** Automatic complaint understanding upon submission — categorizes issues, assesses severity (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`), assigns priority (`P1`–`P4`), computes SLA deadlines, suggests maintenance team, generates concise AI summary, and identifies missing information.
- **Duplicate & Related Case Linking:** Uses PostgreSQL `pg_trgm` GIN index similarity search (`similarity >= 0.3`) to automatically identify related cases and link them in `complaint_related_cases` with `PENDING_REVIEW` status.
- **Dynamic Diagnostic Checklists:** Generates domain-tailored investigation checklists and checklist items (`investigation_checklists`, `checklist_items`) based on inferred category.
- **Lifecycle Automation:** Automatically progresses status: `REPORTED` ➔ `UNDERSTOOD` ➔ `RELATED_CASES_CHECKED` ➔ `OPERATOR_REVIEW`.
- **Inference Audit Logging & Resilience:** Logs latency, model name, status, and raw prompts/responses in `ai_analysis_log`. Adheres to non-blocking AI design (FR-18.1): complaint filing never fails if AI is unreachable.
- **Operator On-Demand Re-Analysis:** Exposes `POST /api/v1/complaints/{id}/ai/analyze` for manual AI re-triggering.
- **100% Test Coverage:** 25/25 backend tests passing across all suites.

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

## 4. Next Phase to Implement: Phase 7

- **Phase 7 Name:** Notifications & Real-Time Updates
- **Target Branch:** `feature/phase-07-notifications` (to be branched from `dev`)
- **Core Scope:**
  - In-app notification service and WebSocket/SSE real-time event dispatcher.
  - Transactional email dispatch via JavaMailSender / Mailpit for critical lifecycle events (status change, technician assigned, resolution proposed).
  - Notification preference management and unread count badges.
  - Frontend notification center integration and live toast alerts.
