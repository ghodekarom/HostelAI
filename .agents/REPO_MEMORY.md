# HFCMS Repository Memory (REPO_MEMORY.md)

**Project:** Hostel Facility Complaint Management System — AI Case Manager (HFCMS)  
**Authoritative Specs:** PRD v1.3 & SRS v1.1  
**Monorepo:** `backend/` (Spring Boot 3.3.4, Java 21) + `frontend/` (Flutter multiplatform)  
**Last Updated:** 2026-09-17 (Phase 5 Authentication & RBAC Completed)

---

## 1. Active Git State & Remote Branches

- **Active Local Branch:** `feature/phase-05-auth-rbac` (ready to merge into `dev`)
- **Remote Repository:** `https://github.com/ghodekarom/HostelAI.git`
- **Published Remote Branches:**
  - `origin/main` (Production release branch)
  - `origin/dev` (Active integration branch — Phases 1-4 merged)
  - `origin/feature/phase-01-project-setup`
  - `origin/feature/phase-02-database`
  - `origin/feature/phase-03-backend`
  - `origin/feature/phase-04-frontend`
  - `origin/feature/phase-04-frontend-full`
  - `origin/feature/phase-04-multiplatform`
- **Branching Rules:**
  - Strict 3-tier: `feature/phase-XX-*` ➔ `dev` ➔ `main`.
  - Feature branches are never deleted from remote GitHub upon merging; keep them published.
  - Merges into `dev` must always use `--no-ff`.

---

## 2. Completed Phases Summary (50% Complete)

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
- **Backend Spring Security 6 Architecture:**
  - Stateless JWT authentication filter (`JwtAuthenticationFilter`) with HMAC-SHA256 signing (JJWT 0.12.6).
  - BCrypt password encoder configured with strength 12.
  - Method-level security enabled (`@EnableMethodSecurity`) across all controllers (`@PreAuthorize("hasRole(...)")` / `hasAnyRole(...)`).
  - Dynamic user identity resolution from `SecurityContextHolder` `UserPrincipal` with backward-compatible request header fallback.
- **REST Auth Endpoints (`/api/v1/auth/*`):**
  - `POST /signup`: Validates input, hashes password with BCrypt (12), creates user in `PENDING_VERIFICATION` status, dispatches 6-digit email OTP.
  - `POST /verify`: Verifies active OTP code within 15-minute expiry, increments attempt counter, transitions status to `ACTIVE`, issues access/refresh tokens.
  - `POST /resend-code`: Invalidates previous unverified OTPs and generates fresh 6-digit OTP.
  - `POST /signin`: Authenticates credentials with BCrypt, enforces `ACTIVE` user check, issues 15-minute access token and 7-day refresh token.
  - `POST /refresh`: Performs rotating refresh token validation, hashes token with SHA-256, revokes previous token, and issues fresh token pair.
  - `POST /password-reset/request`: Generates `PASSWORD_RESET` OTP.
  - `POST /password-reset/confirm`: Verifies reset OTP, updates BCrypt password hash, and revokes all active refresh tokens for the user.
  - `POST /logout`: Revokes user's active refresh tokens.
- **Backend Test Suite (100% Pass Rate):**
  - `AuthServiceTest` (9 tests): Signup, duplicate email, OTP verification, invalid code attempts, signin, token rotation, logout.
  - `JwtTokenProviderTest` (2 tests): Token generation, claim validation, signature tampering rejection.
  - `SecurityRbacIntegrationTest` (4 tests): Unauthenticated access rejection (403), public auth endpoint access (400), cross-role access rejection (`ROLE_STUDENT` accessing operator queue -> 403), authorized access allowance (`ROLE_OPERATOR` -> 200).
- **Frontend Security Integration:**
  - `ApiClient`: Dio `AuthInterceptor` injecting Bearer token for all non-auth endpoints.
  - Automatic 401 Interception: Dispatches `/auth/refresh` on 401 errors, saves rotated tokens in `SecureStorageService`, and retries the original request transparently.
  - `AuthRepository` & `AuthProvider`: Unwraps `ApiException` field and message details, synchronizes active persona with `roleProvider`, and auto-initializes auth state via `checkAuth()`.

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

## 4. Next Phase to Implement: Phase 6

- **Phase 6 Name:** AI Complaint Analysis Pipeline
- **Target Branch:** `feature/phase-06-ai-pipeline` (to be branched from `dev`)
- **Core Scope:**
  - Google Gemini 1.5 Flash integration via Google GenAI SDK.
  - Complaint analysis pipeline: Category classification, Subcategory detection, Severity scoring (LOW, MEDIUM, HIGH, CRITICAL), Priority assignment (P1-P4), SLA deadline calculation, Maintenance team suggestion, Diagnostic checklist generation.
  - Duplicate & related cases detection via PostgreSQL `pg_trgm` similarity queries (`similarity(description, ?) > 0.3`).
  - Fallback deterministic rule engine for offline/resilience scenarios.
  - AI analysis logging into `ai_analysis_log` table for auditability.
