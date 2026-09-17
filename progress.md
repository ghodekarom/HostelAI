# HFCMS Project Implementation Progress

**Hostel Facility Complaint Management System — AI Case Manager (HFCMS)**  
- **SRS Version:** 1.1 | **PRD Version:** 1.3
- **Primary Tech Stack:** Java 21 + Spring Boot 3.x | Flutter (Web/Desktop/Mobile) | PostgreSQL 15+ (Flyway) | Anthropic Claude API | Supabase Storage | Resend
- **Target Architecture:** Monorepo (`backend/` + `frontend/`)
- **Git Branch Workflow:** `feature/phase-XX-*` → `dev` → `main`

---

## Overall Status Dashboard

| Metric | Status / Value |
|---|---|
| **Current Phase** | Phase 2 — Database Infrastructure & Migrations (Completed) |
| **Current Active Branch** | `feature/phase-02-database` |
| **Completed Phases** | 2 / 10 |
| **Overall Progress** | 20% |
| **Last Updated** | 2026-09-17 |

---

## Implementation Phases & Task Checklist

### [x] Phase 1: Project Setup & Foundation
- **Branch:** `feature/phase-01-project-setup`
- **Goal:** Establish monorepo structure, Spring Boot backend skeleton, Flutter frontend skeleton, CI/CD, and development tooling.
- **Tasks:**
  - [x] Initialize monorepo directory layout (`backend/`, `frontend/`, `docs/`)
  - [x] Create permanent `dev` branch from `main`
  - [x] Initialize Spring Boot 3.x backend (Java 21, Maven wrapper, standard dependencies)
  - [x] Initialize Flutter multiplatform project (Web, Desktop, Mobile)
  - [x] Configure Git and comprehensive `.gitignore` (ignoring `.env`, build artifacts, secrets)
  - [x] Create environment templates (`backend/.env.example`, `frontend/.env.example`)
  - [x] Configure code style & linting tools (Checkstyle/Spotless for Java, `flutter_lints` for Dart)
  - [x] Configure Docker Compose for local development (PostgreSQL 15+, Mailpit)
  - [x] Configure Spring profiles (`application-local.yml`, `application-prod.yml`)
  - [x] Configure GitHub Actions CI pipeline (build backend, analyze Flutter, run tests)
  - [x] Add root `README.md` with setup and execution instructions
- **Exit Criteria:** Backend and frontend skeletons initialized; CI pipeline configured; environment parity validated.

---

### [x] Phase 2: Database Infrastructure & Migrations
- **Branch:** `feature/phase-02-database`
- **Goal:** Create complete PostgreSQL schema with Flyway migrations and required seed data.
- **Tasks:**
  - [x] Configure Flyway migration directory and versioning strategy (`V1__...sql` to `V7__...sql`)
  - [x] Configure PostgreSQL with `pg_trgm` extension for text similarity matching
  - [x] Create Auth & User tables (`roles`, `users`, `verification_codes`, `refresh_tokens`)
  - [x] Create Hostel Infrastructure tables (`hostels`, `blocks`, `rooms`, `categories`, `teams`, `technicians`)
  - [x] Create Complaint Core tables (`complaints`, `complaint_evidence`, `complaint_related_cases`)
  - [x] Create Lifecycle & Task tables (`assignment_history`, `missing_info_requests`, `investigation_checklists`, `checklist_items`, `repair_actions`, `resolutions`, `case_status_history`)
  - [x] Create System tables (`notifications`, `ai_analysis_log`)
  - [x] Create primary keys, foreign key constraints, and operational indexes (`status`, `student_id`, `assigned_team_id`, `created_at`)
  - [x] Create GIN trigram index on `complaints(description)`
  - [x] Seed minimal required reference data (roles, standard teams, default complaint categories)
  - [x] Validate clean migration definitions and repeatable schema execution
- **Exit Criteria:** Complete PostgreSQL 15+ schema with GIN trigram search, foreign key constraints, indexes, and reference seeds ready for Flyway migration.

---

### [ ] Phase 3: Core Backend API & Business Logic
- **Branch:** `feature/phase-03-backend`
- **Goal:** Implement Spring Boot domain models, repositories, services, DTOs, REST controllers, and manual complaint lifecycle.
- **Tasks:**
  - [ ] Implement JPA Entities adhering strictly to database schema
  - [ ] Implement Spring Data JPA Repositories
  - [ ] Implement Request and Response DTOs (no entities exposed directly in APIs)
  - [ ] Implement Centralized Global Exception Handler (`@RestControllerAdvice`) and standard error response
  - [ ] Implement Server-side Bean Validation (`jakarta.validation`)
  - [ ] Implement Storage Service Abstraction (Supabase Storage with local filesystem fallback)
  - [ ] Implement Reference Data APIs (`/api/v1/admin/categories`, `/teams`, `/hostels`, `/blocks`, `/rooms`)
  - [ ] Implement Student Complaint APIs (`POST /api/v1/complaints`, `GET /mine`, `GET /{id}`, `POST /{id}/evidence`)
  - [ ] Implement Operator Queue & Review APIs (`GET /api/v1/operator/queue`, `POST /{id}/review`, `POST /{id}/assign`)
  - [ ] Implement Related Cases APIs (`GET /{id}/related-cases`, `POST /{id}/related-cases/{relatedId}/decision`)
  - [ ] Implement Missing Information Workflow APIs (operator request, student response)
  - [ ] Implement Technician Task & Checklist APIs (`GET /assigned`, `POST /checklist/{itemId}/finding`, `POST /repair-actions`)
  - [ ] Implement Resolution Proposal & Student Decision APIs (`POST /resolution`, `POST /resolution/decision`)
  - [ ] Implement Audit & Case Status History recording on every state transition
  - [ ] Configure OpenAPI / Swagger documentation (`springdoc-openapi`)
  - [ ] Configure SLF4J + Logback structured logging & Spring Actuator health checks
  - [ ] Write Backend Unit & Integration Tests (JUnit 5, Mockito, Testcontainers)
- **Exit Criteria:** Full manual complaint lifecycle operates end-to-end via REST API with passing tests.

---

### [ ] Phase 4: Flutter Frontend Scaffolding & Core UI
- **Branch:** `feature/phase-04-frontend`
- **Goal:** Build responsive Flutter multiplatform application consuming backend APIs.
- **Tasks:**
  - [ ] Setup feature-first folder architecture (`core/`, `features/`, `app/`)
  - [ ] Implement theme, typography, color palette, and reusable design system components
  - [ ] Setup state management (Riverpod or Bloc)
  - [ ] Setup networking layer with Dio, interceptors, and environment configuration
  - [ ] Setup declarative routing with `go_router`
  - [ ] Implement loading, error, empty, and retry UI states
  - [ ] Implement Student Screens (Dashboard, Complaint Filing Form with file picker, My Complaints, Case Detail, Confirmation/Reopen modal)
  - [ ] Implement Operator Screens (Triage Queue, Review Modal, Technician Assignment, Resolution Form)
  - [ ] Implement Technician Screens (Assigned Tasks, Checklist Inspection, Repair Logging with photo upload)
  - [ ] Implement Team Lead Screens (At-Risk Queue, Intervention Actions)
  - [ ] Implement Manager Screens (Overview KPI metrics)
  - [ ] Implement Admin Screens (Hostels, Categories, Teams management)
  - [ ] Write Flutter Widget and Unit Tests
- **Exit Criteria:** Core complaint lifecycle flows visually and interactively on Web, Desktop, and Mobile.

---

### [ ] Phase 5: Authentication & Role-Based Access Control (RBAC)
- **Branch:** `feature/phase-05-auth-rbac`
- **Goal:** Secure the backend and frontend with JWT authentication, refresh tokens, and strict role permissions.
- **Tasks:**
  - [ ] Implement BCrypt password hashing for credentials
  - [ ] Implement Signup API with verification code generation and storage
  - [ ] Implement Email Verification API (`POST /auth/verify`, `POST /auth/resend-code`)
  - [ ] Implement Signin API issuing short-lived JWT access token and long-lived refresh token
  - [ ] Implement Refresh Token Rotation (hashed storage, revocation, `/auth/refresh`)
  - [ ] Implement Password Reset workflow (`/auth/password-reset/request`, `confirm`)
  - [ ] Implement Logout API (token revocation)
  - [ ] Implement Authentication Rate Limiting on public endpoints
  - [ ] Configure Spring Security filter chain and JWT Authentication Filter
  - [ ] Enforce backend `@PreAuthorize` role checks across all protected endpoints
  - [ ] Implement Client-side Secure Storage (`flutter_secure_storage`) for tokens
  - [ ] Implement Role-aware Flutter route guards in `go_router`
  - [ ] Write security, authentication, and RBAC authorization tests
- **Exit Criteria:** Authentication and role-based permissions fully enforced on backend and respected in Flutter UI.

---

### [ ] Phase 6: AI Case Manager & Automation Subsystem
- **Branch:** `feature/phase-06-ai-automation`
- **Goal:** Integrate Anthropic Claude API for asynchronous complaint understanding, triage recommendations, and communication drafting with manual fallback.
- **Tasks:**
  - [ ] Implement Anthropic API client service with connection timeouts and retry strategies
  - [ ] Implement Mock AI service for local/offline testing without API keys
  - [ ] Configure asynchronous processing (`@Async`) to ensure AI never blocks HTTP requests
  - [ ] Implement Automatic Intake Classification (category, subcategory, severity, priority, team suggestion)
  - [ ] Implement Missing Information Detection & Question Generation
  - [ ] Implement Duplicate / Related Case Detection (combining `pg_trgm` and AI semantic matching)
  - [ ] Implement Dynamic Case Summarization (auto-updated as case timeline evolves)
  - [ ] Implement Smart Workload-aware Technician Assignment Recommendation
  - [ ] Implement AI Communication Drafting (clarification requests, progress updates, escalation summaries, resolution notes)
  - [ ] Implement AI Analysis Logging (`ai_analysis_log` table)
  - [ ] Implement UI Visual Distinction for AI suggestions vs confirmed data (badges, confidence indicators)
  - [ ] Implement Human Review Controls (mandatory accept/modify/reject checkpoints)
  - [ ] Implement Graceful Degradation (system remains 100% operational when AI is unavailable)
  - [ ] Write unit and integration tests for AI pipelines and fallback scenarios
- **Exit Criteria:** AI provides assistive intelligence without controlling or bypassing human approval checkpoints.

---

### [ ] Phase 7: Notifications & Real-Time Updates
- **Branch:** `feature/phase-07-notifications`
- **Goal:** Implement event-driven notifications across in-app, email, and real-time WebSocket channels.
- **Tasks:**
  - [ ] Implement Notification Domain Service and event listener architecture
  - [ ] Implement In-App Notification persistence (`notifications` table) and read/unread APIs
  - [ ] Implement Transactional Email Service (Resend in production, Mailpit in local Docker)
  - [ ] Configure WebSocket with STOMP message broker on backend (`/ws/notifications`)
  - [ ] Implement WebSocket authentication handshake using JWT
  - [ ] Broadcast real-time events (complaint created, assigned, at-risk, resolution proposed, closed)
  - [ ] Implement Flutter Real-time Notification Center (badge counter, dropdown, push-style alerts)
  - [ ] Implement WebSocket reconnection and polling fallback in Flutter client
  - [ ] Write notification delivery and WebSocket connection tests
- **Exit Criteria:** Key case events reliably notify targeted roles via in-app UI and email.

---

### [ ] Phase 8: Risk / SLA Monitoring & Escalation
- **Branch:** `feature/phase-08-risk-sla`
- **Goal:** Implement automated SLA tracking, background risk detection, and team lead intervention workflows.
- **Tasks:**
  - [ ] Implement SLA deadline calculation based on complaint category and priority
  - [ ] Configure Spring `@Scheduled` background engine for recurring condition evaluations
  - [ ] Implement Inactivity Detection (case idle past threshold)
  - [ ] Implement SLA Proximity Detection (deadline buffer warning)
  - [ ] Implement Repeated Follow-up & Reopen Flagging
  - [ ] Implement Automated `AT_RISK` state transition with detailed risk reasons
  - [ ] Implement Team Lead At-Risk Queue (`GET /api/v1/team-lead/at-risk`, `GET /{id}/context`)
  - [ ] Implement Team Lead Intervention actions (reassign technician, boost priority, add resources, escalate)
  - [ ] Record all interventions permanently in case status and assignment history
  - [ ] Write tests for scheduler routines, SLA breach calculations, and intervention actions
- **Exit Criteria:** At-risk complaints are proactively flagged and wardens/team leads can execute corrective interventions.

---

### [ ] Phase 9: Manager Analytics Dashboard
- **Branch:** `feature/phase-09-analytics`
- **Goal:** Deliver executive-level operational insights, recurring issue detection, and infrastructure hotspots.
- **Tasks:**
  - [ ] Implement Analytics backend queries and aggregation services
  - [ ] Implement Complaint Trends API (`GET /api/v1/analytics/trends`)
  - [ ] Implement Hotspots API by hostel, block, and floor (`GET /api/v1/analytics/hotspots`)
  - [ ] Implement Resolution Time API by team and category (`GET /api/v1/analytics/resolution-time`)
  - [ ] Implement AI-assisted Recurring Infrastructure Issues Detection API (`GET /api/v1/analytics/recurring-issues`)
  - [ ] Optimize database aggregation queries and indexes for fast reporting
  - [ ] Implement Flutter Manager Dashboard (interactive charts, KPI cards, date range & location filters)
  - [ ] Write analytics calculations and endpoint verification tests
- **Exit Criteria:** Chief wardens and management can monitor high-level facility performance and chronic failure points.

---

### [ ] Phase 10: Testing, Hardening & Production Release
- **Branch:** `feature/phase-10-testing-release`
- **Goal:** End-to-end security verification, performance tuning, and production deployment.
- **Tasks:**
  - [ ] Conduct comprehensive RBAC and endpoint security audit
  - [ ] Verify input sanitization and rate limiting under load
  - [ ] Audit Supabase Storage bucket access and signed URL enforcement
  - [ ] Verify zero hardcoded secrets across all repositories and configurations
  - [ ] Execute complete end-to-end test suite (Backend JUnit, Flutter integration tests)
  - [ ] Perform API load and latency benchmarking (p95 < 500ms target for non-AI endpoints)
  - [ ] Tune PostgreSQL connection pooling (HikariCP)
  - [ ] Deploy PostgreSQL migrations to Supabase Production
  - [ ] Deploy Spring Boot backend container to Render
  - [ ] Deploy Flutter Web application to Vercel
  - [ ] Build desktop and mobile release artifacts
  - [ ] Verify production environment variables, email delivery (Resend), and SSL
  - [ ] Final validation on `dev` branch
  - [ ] Create Pull Request and merge `dev` → `main` (Release `HFCMS v1.0`)
- **Exit Criteria:** HFCMS v1.0 is securely deployed, verified, and running in production.

---

## Core Development & Governance Rules

1. **Source of Truth:** PRD and SRS are authoritative. No arbitrary features or unapproved workflows.
2. **Database Schema:** Flyway migrations only. No manual schema modifications in any environment.
3. **API Contracts:** Standard `/api/v1` base path; JPA entities must never be exposed directly in controllers.
4. **Environment Isolation:** Secrets and URLs must reside in environment variables. Only `.env.example` is committed.
5. **Human-in-the-Loop:** AI suggests and drafts; humans approve assignments, merges, escalations, and closures.
6. **AI Resilience:** Asynchronous execution with graceful degradation; manual complaint operations must never stall if AI fails.
7. **Git Discipline:** Three-tier branching (`feature/phase-XX-*` → `dev` → `main`). No direct pushes to `dev` or `main`.
8. **Definition of Done:** Requirement met, code organized, Flyway migration included, server validation enforced, tests pass, documentation updated.

---

## Progress Log

| Date | Phase | Action / Event | Actor |
|---|---|---|---|
| 2026-09-17 | Initial Setup | Initialized `progress.md` tracking document based on PRD v1.3 and SRS v1.1. | AI Assistant |
| 2026-09-17 | Phase 1 | Initialized monorepo, Spring Boot backend, Flutter frontend, Docker Compose, CI workflow, and environment templates on branch `feature/phase-01-project-setup`. | AI Assistant |
| 2026-09-17 | Phase 2 | Implemented complete PostgreSQL 15+ schema with 7 Flyway migrations (`V1`..`V7`), pg_trgm trigram search, foreign keys, operational indexes, and reference seeds on branch `feature/phase-02-database`. | AI Assistant |
