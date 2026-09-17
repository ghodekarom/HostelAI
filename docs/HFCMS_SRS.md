# Software Requirements Specification (SRS)

## Hostel Facility Complaint Management System — AI Case Manager (HFCMS)

**Version:** 1.1  
**Status:** Draft — Stable v1 Build  
**Based on:** HFCMS PRD v1.3  
**Prepared for:** Stable v1 implementation

---

# Table of Contents

1. Introduction
2. Overall Description
3. Architectural Tech Stack
4. System Architecture & Hosting
5. Authentication & Account Security Design
6. Standard Folder Structure
7. Database Schema
8. API Contract
9. Functional Requirements
10. Non-Functional Requirements
11. External Interface Requirements
12. Appendices
13. Phase-by-Phase Implementation Plan
14. GitHub Branching & Development Workflow
15. Cross-Cutting Development Rules
16. Stable v1 Completion Definition

---

# 1. Introduction

## 1.1 Purpose

This SRS translates the HFCMS PRD v1.3 into an engineering-ready specification covering technology choices, architecture, database design, APIs, functional requirements, non-functional requirements, implementation phases, testing, and production release.

## 1.2 Intended Audience

- Backend developers
- Flutter developers
- DevOps
- QA/test engineers
- Technical reviewers
- Project owner

## 1.3 Scope

HFCMS is a multi-client hostel complaint-management system supporting:

- Web
- Desktop
- Mobile

A single Flutter codebase is used for all client platforms.

The system allows students to report hostel facility complaints while Operators, Technicians, Team Leads, Managers, and Admins manage complaints through their respective workflows.

An AI Case Manager assists with:

- Complaint understanding
- Classification
- Severity and priority suggestions
- Team suggestions
- Missing-information detection
- Related/duplicate case detection
- Risk/SLA monitoring
- Summarization and resolution assistance

Human approval remains mandatory for controlled decisions such as assignment, merging, escalation, and closure.

## 1.4 Definitions

| Term | Meaning |
|---|---|
| SRS | Software Requirements Specification |
| PRD | Product Requirements Document |
| FR | Functional Requirement |
| NFR | Non-Functional Requirement |
| JWT | JSON Web Token |
| RBAC | Role-Based Access Control |
| SLA | Service Level Agreement |
| ORM | Object-Relational Mapping |
| OTP | One-Time Password/Code |
| CRUD | Create, Read, Update, Delete |
| AI | Artificial Intelligence |

## 1.5 Reference

- HFCMS PRD v1.3

---

# 2. Overall Description

## 2.1 Product Perspective

HFCMS consists of:

- Flutter frontend for web, desktop, and mobile
- Java 21 + Spring Boot backend
- PostgreSQL database
- Flyway database migrations
- Spring Data JPA/Hibernate
- AI service integration
- Supabase Storage for evidence files
- WebSocket/STOMP for real-time updates
- Email notification service

## 2.2 User Classes

- Student
- Maintenance/Facility Operator
- Technician
- Hostel Warden/Team Lead
- Chief Warden/Manager
- Hostel/Campus Admin
- AI Case Manager

## 2.3 Operating Environment

### Local

- Docker PostgreSQL
- Spring Boot
- Flutter
- Mailpit/MailHog
- Optional MinIO
- AI mock/stub or real AI API

### Production

- Supabase PostgreSQL + Storage
- Render for Spring Boot backend
- Vercel for Flutter Web
- Mobile/desktop distributable builds
- Resend for transactional email

## 2.4 Key Constraints

- Human approval is mandatory for assignment, merging, escalation, and closure.
- AI must not be a hard dependency for manual complaint processing.
- AI processing should be asynchronous/non-blocking.
- v1 does not require a dedicated worker/queue platform.
- Spring `@Scheduled` jobs are used for periodic risk/SLA checks.

---

# 3. Architectural Tech Stack

## 3.1 Core Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter + Dart |
| Backend | Java 21 + Spring Boot 3.x |
| Database | PostgreSQL 15+ |
| ORM | Spring Data JPA / Hibernate |
| Migration | Flyway |
| Authentication | Spring Security + JWT |
| Password Hashing | BCrypt |
| API Documentation | springdoc-openapi / Swagger |
| Storage | Supabase Storage |
| Backend Hosting | Render |
| Frontend Hosting | Vercel |
| Email | Resend |
| Local Email | Mailpit/MailHog |
| Real-Time | WebSocket/STOMP |
| AI | Anthropic API |
| Similarity Search | PostgreSQL `pg_trgm` |
| Logging | SLF4J + Logback |
| Monitoring | Spring Boot Actuator |
| Containerization | Docker + Docker Compose |
| CI/CD | GitHub Actions |
| Backend Testing | JUnit 5, Mockito, Testcontainers |
| Frontend Testing | flutter_test, mocktail/mockito |
| Flutter State | Riverpod or Bloc |
| Flutter HTTP | Dio |
| Flutter Routing | go_router |
| Secure Storage | flutter_secure_storage |
| Code Quality | Checkstyle/Spotless + flutter_lints |

## 3.2 Environment Configuration

Environment-specific values must be externalized.

Examples:

- Database credentials
- JWT secrets
- AI API keys
- Resend API keys
- Supabase credentials
- Production API URLs

Secrets must never be committed to Git.

---

# 4. System Architecture & Hosting

## 4.1 Local Architecture

```text
Flutter
   |
   v
Spring Boot API
   |
   +---- PostgreSQL
   |
   +---- Local Storage / MinIO
   |
   +---- Mailpit
   |
   +---- AI API / Mock
```

## 4.2 Production Architecture

```text
Flutter Web
    |
    v
  Vercel
    |
    v
Spring Boot API
  Render
    |
    +---- Supabase PostgreSQL
    |
    +---- Supabase Storage
    |
    +---- Anthropic API
    |
    +---- Resend
```

## 4.3 Environment Promotion

```text
Local
  ↓
Staging (optional)
  ↓
Production
```

Configuration must be separated for each environment.

---

# 5. Authentication & Account Security

## 5.1 Signup

1. User submits email and password.
2. Backend validates input.
3. Password is hashed using BCrypt.
4. User is created as `PENDING_VERIFICATION`.
5. Verification code is generated.
6. Code is stored securely with expiry.
7. Code is sent through email.
8. User submits the code.
9. Backend verifies the code.
10. Account becomes `ACTIVE`.
11. Access and refresh tokens are issued.

## 5.2 Sign In

- Validate email/password.
- Verify account status.
- Issue JWT access token.
- Issue refresh token.
- Apply authentication rate limiting.

## 5.3 Password Reset

- Request reset code.
- Send verification code.
- Validate code.
- Update password.
- Revoke existing refresh tokens.

## 5.4 Session Management

- Short-lived JWT access token
- Long-lived rotating refresh token
- Refresh tokens stored hashed
- Server-side token revocation
- Role-based authorization

## 5.5 Security

- BCrypt password hashing
- HTTPS/TLS
- JWT signing
- RBAC
- Input validation
- Authentication rate limiting
- Verification attempt limits

---

# 6. Standard Folder Structure

## 6.1 Backend

```text
hfcms-backend/
├── src/main/java/com/hfcms/
│   ├── config/
│   ├── common/
│   ├── auth/
│   ├── users/
│   ├── hostels/
│   ├── categories/
│   ├── teams/
│   ├── complaints/
│   │   ├── ai/
│   │   ├── assignment/
│   │   ├── missinginfo/
│   │   ├── investigation/
│   │   ├── repairaction/
│   │   ├── resolution/
│   │   └── audit/
│   ├── notifications/
│   ├── analytics/
│   └── storage/
├── src/main/resources/
│   ├── application.yml
│   ├── application-local.yml
│   ├── application-prod.yml
│   └── db/migration/
├── src/test/
├── Dockerfile
├── docker-compose.yml
├── pom.xml
└── README.md
```

## 6.2 Frontend

```text
hfcms-frontend/
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── core/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── constants/
│   │   ├── errors/
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/
│   │   ├── complaints/
│   │   ├── operator/
│   │   ├── technician/
│   │   ├── team_lead/
│   │   ├── manager/
│   │   ├── admin/
│   │   └── notifications/
│   └── generated/
├── test/
├── web/
├── android/
├── ios/
├── linux/
├── macos/
├── windows/
├── pubspec.yaml
└── README.md
```

---

# 7. Database Schema

PostgreSQL is the primary relational database.

Flyway must manage all schema changes.

Core tables:

```text
roles
users
verification_codes
refresh_tokens

hostels
blocks
rooms
categories
teams
technicians

complaints
complaint_evidence
complaint_related_cases
assignment_history
missing_info_requests
investigation_checklists
checklist_items
repair_actions
resolutions
case_status_history

notifications
ai_analysis_log
```

## 7.1 Core Complaint Status

```text
REPORTED
→ UNDERSTOOD
→ RELATED_CASES_CHECKED
→ OPERATOR_REVIEW
→ ASSIGNED
→ WAITING_FOR_INFORMATION
→ ACTIVE
→ INVESTIGATED
→ ACTION_TAKEN
→ AT_RISK
→ RESOLUTION_PROPOSED
→ CONFIRMED
→ CLOSED
```

Reopening:

```text
CLOSED
→ REOPENED
→ ACTIVE
```

## 7.2 Required Indexes

Minimum indexes:

- `complaints(status)`
- `complaints(student_id)`
- `complaints(assigned_team_id)`
- `complaints(created_at)`
- GIN trigram index on complaint description
- `notifications(user_id, read_at)`

## 7.3 Seed Data

Only required reference data should be seeded.

Examples:

- Roles
- Required teams
- Required v1 complaint categories

Unnecessary sample/demo data must not be added.

---

# 8. API Contract

## 8.1 API Base Path

```text
/api/v1
```

Authenticated APIs use:

```http
Authorization: Bearer <access_token>
```

## 8.2 Authentication APIs

```text
POST /auth/signup
POST /auth/verify
POST /auth/resend-code
POST /auth/signin
POST /auth/refresh
POST /auth/password-reset/request
POST /auth/password-reset/confirm
POST /auth/logout
```

## 8.3 Student APIs

```text
POST /complaints
GET  /complaints/mine
GET  /complaints/{id}
POST /complaints/{id}/missing-info/respond
POST /complaints/{id}/resolution/decision
POST /complaints/{id}/evidence
```

## 8.4 Operator APIs

```text
GET  /operator/queue
POST /complaints/{id}/review
GET  /complaints/{id}/related-cases
POST /complaints/{id}/related-cases/{relatedId}/decision
POST /complaints/{id}/assign
POST /complaints/{id}/missing-info/request
POST /complaints/{id}/resolution
```

## 8.5 Technician APIs

```text
GET  /technician/assigned
GET  /complaints/{id}/checklist
POST /complaints/{id}/checklist/{itemId}/finding
POST /complaints/{id}/repair-actions
```

## 8.6 Team Lead APIs

```text
GET  /team-lead/at-risk
GET  /complaints/{id}/context
POST /complaints/{id}/intervene
```

## 8.7 Analytics APIs

```text
GET /analytics/trends
GET /analytics/hotspots
GET /analytics/resolution-time
GET /analytics/recurring-issues
```

## 8.8 Admin APIs

```text
GET/POST/PUT/DELETE /admin/categories
GET/POST/PUT/DELETE /admin/teams
GET/POST/PUT /admin/users
GET/POST /admin/hostels
GET/POST /admin/blocks
GET/POST /admin/rooms
```

## 8.9 Notification APIs

```text
GET  /notifications
POST /notifications/{id}/read
WS   /ws/notifications
```

## 8.10 Standard Error Response

```json
{
  "timestamp": "...",
  "status": 400,
  "error": "Bad Request",
  "message": "...",
  "path": "...",
  "fieldErrors": []
}
```

---

# 9. Functional Requirements

| ID | Requirement |
|---|---|
| FR-1.1 | Student can create a complaint with description, location, category and optional evidence |
| FR-1.2 | System generates a unique case number |
| FR-2.1 | AI analyzes new complaints |
| FR-2.2 | AI suggestions and confirmed values are clearly distinguished |
| FR-3.1 | Related/duplicate cases are shown for review |
| FR-3.2 | Cases cannot be automatically merged |
| FR-4.1 | Operator can accept, modify or reject AI recommendations |
| FR-5.1 | Assignment history is recorded |
| FR-6.1 | Missing information can be requested from students |
| FR-7.1 | Technicians receive investigation checklists |
| FR-8.1 | Active cases are evaluated for risk/SLA conditions |
| FR-9.1 | Team Leads can intervene in at-risk cases |
| FR-10.1 | Repair actions can be recorded with evidence |
| FR-11.1 | Structured resolutions can be submitted |
| FR-12.1 | Students can confirm or reject resolutions |
| FR-13.1 | Closed/reopened cases retain complete history |
| FR-14.1 | Managers receive analytics |
| FR-15.1 | Admin manages complaint categories |
| FR-16.1 | System sends applicable notifications |
| FR-17.1 | System supports signup, verification, signin and password reset |
| FR-18.1 | Manual complaint processing continues if AI is unavailable |

---

# 10. Non-Functional Requirements

| Category | Requirement |
|---|---|
| Performance | Non-AI API p95 target < 500ms under expected v1 load |
| Scalability | Stateless backend suitable for horizontal scaling |
| Availability | Production API target 99.5% uptime |
| Security | BCrypt, JWT, HTTPS, RBAC, validation and rate limiting |
| Data Integrity | Foreign keys and server-side lifecycle validation |
| Auditability | Status, assignment and intervention history recorded |
| Usability | Responsive Flutter UI across web, desktop and mobile |
| Maintainability | Feature-based architecture and documented APIs |
| Portability | Docker backend and cross-platform Flutter client |
| Privacy | PII and evidence protected through access control |
| Observability | Structured logs, health checks and AI analysis logs |

---

# 11. External Interface Requirements

## 11.1 User Interface

Role-specific Flutter interfaces:

- Student
- Operator
- Technician
- Team Lead
- Manager
- Admin

Responsive layouts must support:

- Mobile
- Desktop
- Web

## 11.2 External Services

```text
Flutter
   ↓
Spring Boot REST API
   ↓
PostgreSQL / Supabase
   ↓
Supabase Storage
   ↓
Anthropic API
   ↓
Resend
```

WebSocket/STOMP provides real-time updates.

---

# 12. Appendices

## 12.1 Case Lifecycle

```text
REPORTED
   ↓
UNDERSTOOD
   ↓
RELATED_CASES_CHECKED
   ↓
OPERATOR_REVIEW
   ↓
ASSIGNED
   ↓
WAITING_FOR_INFORMATION ──→ ACTIVE
   ↓
ACTIVE
   ↓
INVESTIGATED
   ↓
ACTION_TAKEN
   ↓
RESOLUTION_PROPOSED
   ↓
CONFIRMED
   ↓
CLOSED
```

Possible risk state:

```text
ACTIVE → AT_RISK
```

Possible reopening:

```text
CLOSED → REOPENED → ACTIVE
```

## 12.2 Human-in-the-Loop

Human approval is mandatory for:

- Assignment
- Case merging
- Escalation
- Closure

AI recommendations must not bypass these controls.

## 12.3 Out of Scope for v1

- Billing/cost tracking
- Vendor/contractor management
- Spare-parts inventory
- Real-time technician location dispatch

## 12.4 Future Scope

- Predictive maintenance
- Vendor management
- Repair cost tracking

---

# 13. Phase-by-Phase Implementation Plan

The project follows a dependency-first implementation sequence:

```text
Phase 1
Project Setup
      ↓
Phase 2
Database
      ↓
Phase 3
Backend
      ↓
Phase 4
Frontend
      ↓
Phase 5
Authentication & RBAC
      ↓
Phase 6
AI Case Manager
      ↓
Phase 7
Notifications & Real-Time
      ↓
Phase 8
Risk/SLA & Escalation
      ↓
Phase 9
Manager Analytics
      ↓
Phase 10
Testing, Hardening & Release
```

Each phase must be completed, tested and merged into `dev` before the next phase begins.

## Phase 1 — Project Setup

**Goal:** Create the development foundation.

### Tasks

- Create repository/monorepo
- Create Spring Boot backend
- Create Flutter frontend
- Configure Git
- Configure `.gitignore`
- Configure environment templates
- Configure README
- Configure Checkstyle/Spotless
- Configure Flutter linting
- Configure GitHub Actions
- Configure Docker Compose
- Configure local profiles

### Exit Criteria

Backend and frontend run successfully and CI passes.

---

## Phase 2 — Database

**Goal:** Create the complete PostgreSQL/Flyway foundation.

### Tasks

- Configure local PostgreSQL
- Configure Supabase PostgreSQL
- Configure Flyway
- Create all required tables
- Create constraints
- Create indexes
- Configure `pg_trgm`
- Add required reference/seed data
- Test clean database migration

### Exit Criteria

A clean database can be completely created using Flyway.

---

## Phase 3 — Backend

**Goal:** Implement the core Spring Boot backend.

### Tasks

- Spring configuration
- JPA/Hibernate
- Flyway
- Validation
- DTOs
- Exception handling
- OpenAPI
- Logging
- Actuator
- Storage abstraction
- Reference-data APIs
- Complaint APIs
- Assignment
- Missing information
- Investigation
- Repair actions
- Resolution
- Audit history
- Backend tests

### Exit Criteria

Complete manual complaint lifecycle works through the backend.

---

## Phase 4 — Frontend

**Goal:** Build the Flutter application and connect it to backend APIs.

### Tasks

- Flutter architecture
- Theme
- Responsive UI
- Routing
- State management
- Dio
- API integration
- Error/loading states
- Student screens
- Operator screens
- Technician screens
- Team Lead screens
- Manager screens
- Admin screens
- Widget/unit tests

### Exit Criteria

Core complaint-management workflow works through Flutter.

---

## Phase 5 — Authentication & RBAC

**Goal:** Secure the application.

### Tasks

- Signup
- Email verification
- Signin
- JWT
- Refresh tokens
- Logout
- Password reset
- Rate limiting
- Spring Security
- `@PreAuthorize`
- Role-aware Flutter routing
- Protected screens

### Exit Criteria

Authentication and role-based access work correctly.

---

## Phase 6 — AI Case Manager

**Goal:** Add AI-assisted complaint processing.

### Tasks

- Anthropic integration
- AI timeout/retry
- Mock AI mode
- Async AI processing
- Classification
- Severity
- Priority
- Team suggestion
- Missing information
- Related/duplicate cases
- AI investigation checklist
- AI analysis logging
- Human review controls
- Manual fallback

### Exit Criteria

AI assists the complaint workflow without blocking or controlling mandatory human decisions.

---

## Phase 7 — Notifications & Real-Time Updates

**Goal:** Notify users of important case events.

### Tasks

- Notification service
- In-app notifications
- Email notifications
- Mailpit local setup
- Resend production setup
- WebSocket/STOMP
- Authentication
- Flutter notification UI
- Reconnection/polling fallback

### Exit Criteria

Users receive relevant notifications and real-time updates.

---

## Phase 8 — Risk/SLA & Escalation

**Goal:** Identify cases requiring intervention.

### Tasks

- SLA calculation
- Scheduled risk checks
- Inactivity detection
- SLA proximity
- Follow-up detection
- Complexity assessment
- Affected-student count
- Risk flags
- Risk reasons
- Team Lead queue
- Reassignment
- Escalation
- Prioritization
- Resource addition
- Intervention audit

### Exit Criteria

At-risk cases are identified and Team Leads can intervene.

---

## Phase 9 — Manager Analytics

**Goal:** Provide management visibility.

### Tasks

- Complaint trends
- Category analysis
- Location hotspots
- Resolution-time analysis
- Recurring issues
- Aggregation queries
- Performance optimization where required
- Manager dashboard
- Filters
- Charts
- Summary metrics

### Exit Criteria

Managers can view required v1 analytics.

---

## Phase 10 — Testing, Hardening & Production Release

**Goal:** Prepare stable v1.

### Security

- RBAC audit
- Endpoint authorization audit
- Input validation audit
- JWT security verification
- Rate-limit verification
- Secret management verification
- Supabase Storage security

### Testing

- Backend unit tests
- Backend integration tests
- Flutter tests
- Authentication tests
- RBAC tests
- Complaint lifecycle tests
- AI failure tests
- Notification tests
- WebSocket tests
- End-to-end testing

### Performance

- API performance testing
- Database query optimization
- Connection pool tuning
- Scheduled job verification
- AI failure verification

### Deployment

```text
Flyway
   ↓
Supabase
   ↓
Render Backend
   ↓
Vercel Flutter Web
```

Also:

- Build mobile artifacts
- Build desktop artifacts
- Configure production environment variables
- Configure Resend
- Configure Supabase Storage
- Document rollback/recovery

### Exit Criteria

The complete system passes required tests and is ready for stable v1 release.

---

# 14. GitHub Branching & Development Workflow

## 14.1 Branch Strategy

HFCMS uses a strict three-level workflow:

```text
feature/* → dev → main
```

### Permanent Branches

| Branch | Purpose |
|---|---|
| `main` | Stable, production/release-ready code only |
| `dev` | Integration, testing and completed-phase code |

### Temporary Feature Branches

```text
feature/phase-01-project-setup
feature/phase-02-database
feature/phase-03-backend
feature/phase-04-frontend
feature/phase-05-auth-rbac
feature/phase-06-ai-automation
feature/phase-07-notifications
feature/phase-08-risk-sla
feature/phase-09-analytics
feature/phase-10-testing-release
```

## 14.2 Mandatory Branch Flow

```text
feature/phase-XX
       ↓
      PR
       ↓
      dev
       ↓
 final validation
       ↓
      PR
       ↓
     main
```

### Prohibited

```text
feature → main        ❌
direct push → main    ❌
direct push → dev     ❌
```

## 14.3 Starting a New Phase

Every phase starts from the latest `dev`.

```bash
git checkout dev
git pull origin dev

git checkout -b feature/phase-XX-name
```

## 14.4 Development Rules

During the phase:

```text
Develop
   ↓
Test
   ↓
Review
   ↓
Commit
   ↓
Push feature branch
```

Example:

```bash
git add .
git commit -m "phase-01: project setup and development foundation"
git push -u origin feature/phase-01-project-setup
```

## 14.5 Pull Request: Feature → Dev

After the phase is complete:

1. Push the feature branch.
2. Open a Pull Request.
3. Target branch must be `dev`.
4. CI checks must pass.
5. Review the changes.
6. Verify tests.
7. Merge the PR into `dev`.
8. Delete the feature branch.

## 14.6 Verify Dev Before Next Phase

```bash
git checkout dev
git pull origin dev
```

Verify:

- Application starts
- Tests pass
- CI passes
- Previous functionality still works
- Documentation is updated where required

Only after verification should the next phase branch be created.

## 14.7 Phase Commit Naming

```text
phase-01: project setup and development foundation
phase-02: database setup and schema
phase-03: backend setup and core implementation
phase-04: frontend setup and core implementation
phase-05: authentication and RBAC
phase-06: AI case manager and automation
phase-07: notifications and real-time updates
phase-08: risk SLA monitoring and escalation
phase-09: manager analytics
phase-10: testing hardening and production release
```

## 14.8 Main Branch Rules

`main` contains only stable/release-ready code.

Direct pushes are prohibited.

Required flow:

```text
dev
 ↓
Pull Request
 ↓
main
```

Before merging `dev → main`:

- All tests pass
- CI passes
- No known blocking bugs
- Documentation is updated
- Deployment configuration is verified
- Production readiness is confirmed

## 14.9 Branch Protection

### `main`

Enable:

- Pull Request required
- CI checks required
- Branch must be up to date before merge
- Direct pushes disabled

### `dev`

Enable:

- Pull Request required
- CI checks required
- Direct pushes disabled

Even with a single developer, the workflow should simulate a team environment:

```text
Developer
    ↓
Feature Branch
    ↓
Pull Request
    ↓
CI + Testing
    ↓
dev
    ↓
Final Validation
    ↓
Pull Request
    ↓
main
```

## 14.10 Complete Development Workflow

```text
1. Checkout dev
       ↓
2. Pull latest dev
       ↓
3. Create phase feature branch
       ↓
4. Implement phase
       ↓
5. Run tests
       ↓
6. Review changes
       ↓
7. Commit phase
       ↓
8. Push feature branch
       ↓
9. Create PR → dev
       ↓
10. CI validation
       ↓
11. Merge → dev
       ↓
12. Delete feature branch
       ↓
13. Verify dev
       ↓
14. Start next phase
```

## 14.11 Release Workflow

After Phase 10:

```text
feature/phase-10-testing-release
              ↓
             dev
              ↓
      Final validation
              ↓
         Pull Request
              ↓
             main
              ↓
          HFCMS v1.0
```

`main` is the release-ready branch.

---

# 15. Cross-Cutting Development Rules

These rules apply to every phase:

1. Every phase must leave the project runnable.
2. Database changes must use Flyway.
3. Production schema must never be modified manually.
4. Backend validation is mandatory.
5. Frontend validation is not a security boundary.
6. OpenAPI must be updated when APIs change.
7. Tests must be added with features.
8. Human approval remains mandatory for assignment, merging, escalation and closure.
9. AI must remain an assistive/automated layer.
10. Manual complaint processing must work without AI.
11. Secrets must never be committed to Git.
12. Only required seed/reference data should be added.
13. Flutter must continue supporting web, desktop and mobile.
14. Each phase must be independently demonstrable.
15. Feature branches must originate from the latest `dev`.
16. Feature branches must merge only into `dev`.
17. Direct pushes to `dev` and `main` are prohibited.
18. `main` receives changes only through the approved `dev → main` PR flow.
19. A phase must be verified on `dev` before the next phase starts.
20. Completed feature branches should be deleted after merging.

---

# 16. Stable v1 Completion Definition

HFCMS v1 is considered ready when:

- All 10 implementation phases are complete.
- Backend and frontend builds pass.
- Database migrations execute successfully.
- Authentication and RBAC are verified.
- Complaint lifecycle works end-to-end.
- AI functionality works with graceful degradation.
- Notifications and real-time updates work.
- Risk/SLA monitoring works.
- Manager analytics work.
- Security requirements are verified.
- Required tests pass.
- Production deployment is verified.
- Documentation is complete.
- `dev` has passed final validation.
- Stable release is merged into `main`.

## Final Release Path

```text
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
    → Phase 6 → Phase 7 → Phase 8 → Phase 9 → Phase 10
                                      ↓
                                     dev
                                      ↓
                                  Validation
                                      ↓
                                    main
                                      ↓
                                  HFCMS v1.0
```

---

**End of HFCMS SRS v1.1**
