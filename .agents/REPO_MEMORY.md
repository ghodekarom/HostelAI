# HFCMS Repository Memory (REPO_MEMORY.md)

**Project:** Hostel Facility Complaint Management System — AI Case Manager (HFCMS)  
**Authoritative Specs:** PRD v1.3 & SRS v1.1  
**Monorepo:** `backend/` (Spring Boot 3.3.4, Java 21) + `frontend/` (Flutter multiplatform)  
**Last Updated:** 2026-09-17 (Phase 3 Completed & Live Verified)

---

## 1. Active Git State & Remote Branches

- **Active Local Branch:** `dev` (clean working tree, in sync with `origin/dev`)
- **Remote Repository:** `https://github.com/ghodekarom/HostelAI.git`
- **Published Remote Branches:**
  - `origin/main` (Production release branch)
  - `origin/dev` (Active integration branch — Phase 1, 2, 3 merged)
  - `origin/feature/phase-01-project-setup` (Visible on remote)
  - `origin/feature/phase-02-database` (Visible on remote)
  - `origin/feature/phase-03-backend` (Visible on remote)
- **Branching Rules:**
  - Strict 3-tier: `feature/phase-XX-*` ➔ `dev` ➔ `main`.
  - Feature branches are never deleted from remote GitHub upon merging; keep them published.
  - Merges into `dev` must always use `--no-ff`.

---

## 2. Completed Phases Summary (30% Complete)

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
- **Live 14-Step Lifecycle Verified:**
  1. `POST /api/v1/admin/hostels` (Created Hostel 1)
  2. `POST /api/v1/admin/blocks` (Created Block 1)
  3. `POST /api/v1/admin/rooms` (Created Room 1)
  4. `POST /api/v1/complaints` (Reported `HFCMS-2026-477AC4`)
  5. `GET /api/v1/operator/queue` (Operator queue displayed case)
  6. `POST /api/v1/complaints/1/review` (Operator review -> `OPERATOR_REVIEW`)
  7. `POST /api/v1/complaints/1/missing-info/request` (Clarification -> `WAITING_FOR_INFORMATION`)
  8. `POST /api/v1/complaints/1/missing-info/respond` (Student replied -> `ACTIVE`)
  9. `POST /api/v1/complaints/1/assign` (Assigned technician Suresh Kumar -> `ASSIGNED`)
  10. `GET /api/v1/complaints/1/checklist` (Retrieved diagnostic checklist)
  11. `POST /api/v1/complaints/1/checklist/1/finding` (Logged finding -> `INVESTIGATED`)
  12. `POST /api/v1/complaints/1/repair-actions` (Logged washer seal repair -> `ACTION_TAKEN`)
  13. `POST /api/v1/complaints/1/resolution` (Proposed root cause resolution -> `RESOLUTION_PROPOSED`)
  14. `POST /api/v1/complaints/1/resolution/decision` (Student confirmed -> `CONFIRMED` -> `CLOSED`)
- **Swagger UI:** Verified operational in browser at `http://localhost:8080/swagger-ui/index.html`.

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

## 4. Next Phase to Implement: Phase 4

- **Phase 4 Name:** Flutter Frontend Architecture & Core UI
- **Target Branch:** `feature/phase-04-frontend` (branched from `dev`)
- **Core Scope:**
  - Feature-first folder architecture in `frontend/lib/features/` (`complaints/`, `operator/`, `technician/`, `team_lead/`, `manager/`, `admin/`).
  - State management (Riverpod), HTTP network layer (Dio with interceptors).
  - Declarative routing (`go_router`) with role-aware routes.
  - Student views: Dashboard, Filing form (category selection, photo picker), My Complaints, Case Detail timeline view, resolution confirmation/reopen dialog.
  - Operator views: Triage queue, Review modal, Duplicate comparison view, Technician assignment, Resolution proposal form.
  - Technician views: Assigned tasks queue, Checklist inspection, Repair action logging with photo upload.
  - Responsive layouts (Web, Desktop, Mobile).
  - Git flow: Commit ➔ Push `feature/phase-04-frontend` to `origin` ➔ Merge `--no-ff` into `dev` ➔ Push `dev` to `origin`.
