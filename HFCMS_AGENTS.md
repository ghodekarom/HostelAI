# AGENTS.md — HFCMS Development Rules

## 1. Source of Truth

- **PRD + SRS first:** Implement only requirements defined in the HFCMS PRD and SRS; do not invent business behavior without documenting the change.
- **Keep documents aligned:** When requirements, API contracts, schema, roles, or workflow change, update the PRD/SRS and relevant code together.

## 2. Architecture & Technology

- **Follow the approved stack:** Java 21 + Spring Boot 3.x, PostgreSQL 15+, Spring Data JPA, Flyway, Flutter/Dart, Riverpod/Bloc, Dio, go_router, and the services/tools specified by the SRS.
- **Respect the architecture:** Backend is a REST API and business-logic owner; Flutter is the client; PostgreSQL is the system of record; external services must be accessed through clear adapters/clients.
- **Feature-first structure:** Keep backend modules and Flutter features organized according to the SRS folder structure; avoid dumping unrelated code into generic folders.

## 3. Implementation Order

- **Dependency-first development:** Follow: Project Setup → Database & Schema → Backend → Frontend → Authentication & RBAC → Core Case Management → AI Automation → Notifications/Real-Time → Risk/SLA → Analytics → Testing/Production.
- **Complete each phase:** A phase must build, run, and pass its relevant tests before starting dependent work.

## 4. Database Rules

- **Flyway only:** Every schema change must be represented by a versioned Flyway migration; never modify production schema manually.
- **Integrity first:** Use proper primary keys, foreign keys, constraints, indexes, timestamps, and status values defined by the SRS.
- **Minimal seed data:** Seed only required reference data such as roles, teams, and required complaint categories; never add unnecessary demo data.
- **Auditability:** Preserve case status history, assignment history, AI analysis logs, and other required audit records.

## 5. Backend Rules

- **Layer separation:** Keep controllers thin; put business rules in services and persistence in repositories.
- **DTOs over entities:** Do not expose JPA entities directly through public APIs; use request/response DTOs and validation.
- **Validate server-side:** Never rely on frontend validation for security or business rules.
- **Centralized errors:** Use the standard error response and global exception handling defined by the SRS.
- **API contract:** Keep endpoints, HTTP methods, request/response models, authorization, and `/api/v1` base path consistent with the SRS.
- **Status lifecycle:** Validate every case transition against the approved complaint lifecycle; reject invalid transitions.

## 6. Authentication & RBAC

- **Security is backend-enforced:** Every protected endpoint must enforce authentication and role-based authorization server-side.
- **Secure credentials:** Hash passwords with BCrypt; never store plaintext passwords, verification codes, or refresh tokens.
- **Token security:** Use short-lived access JWTs and securely stored/hashed refresh tokens with rotation/revocation as specified.
- **Least privilege:** A user can access only resources and actions allowed for their role and ownership/scope.

## 7. Human-in-the-Loop AI

- **AI recommends, humans decide:** AI may classify, prioritize, detect related cases, identify missing information, monitor risk, and generate suggestions; humans retain final authority over assignment, linking/merging, escalation, and outcome-changing decisions.
- **Never silently auto-merge:** Related/duplicate suggestions require explicit human review before linking/duplicate decisions.
- **Show AI provenance:** Clearly distinguish AI-suggested values from confirmed human values.
- **Graceful degradation:** Core complaint creation, viewing, and manual actions must continue when the AI provider is unavailable; AI work must be asynchronous/non-blocking.
- **Log AI activity:** Record relevant AI analysis inputs/outputs and failures for traceability and debugging; do not log secrets or unnecessary sensitive data.

## 8. Case Workflow & Automation

- **Event/condition driven:** Implement lifecycle automation through defined events, conditions, thresholds, responses, and confirmations rather than arbitrary UI-only transitions.
- **Human checkpoints:** Preserve approval points required by the PRD/SRS before ownership, escalation, merging, or final outcome changes.
- **Evidence matters:** Store complaint, repair, and resolution evidence using the configured storage abstraction and access controls.
- **No hidden state:** Every meaningful status, assignment, intervention, and resolution action must be traceable in the case timeline/audit history.

## 9. Frontend Rules

- **API-driven UI:** Flutter must consume backend APIs; never duplicate authoritative business rules only in the client.
- **Responsive by default:** The same Flutter codebase must support web, desktop, and mobile with adaptive layouts.
- **Role-aware navigation:** Use authentication state and RBAC-aware routing to expose only appropriate screens/actions.
- **UX consistency:** Use reusable widgets, consistent loading/error/empty states, clear form validation, and explicit distinction between AI suggestions and confirmed data.
- **Secure storage:** Follow the SRS approach for client-side token/session storage; never hardcode secrets or API credentials.

## 10. API, Configuration & Secrets

- **Everything must be environment-driven:** All environment-specific values must come from environment variables or configuration. Never hardcode URLs, ports, credentials, API keys, tokens, JWT secrets, database credentials, or service configuration in source code.
- **Separate environment files:** Maintain separate environment configuration for frontend and backend:
  - Backend: `backend/.env` and `backend/.env.example`
  - Frontend: `frontend/.env` and `frontend/.env.example`
- **`.env` is local-only:** Real secrets and environment-specific values belong in `.env` files and deployment-platform environment variables. Never commit `.env` files containing secrets.
- **`.env.example` is safe:** Keep `.env.example` files committed to Git with variable names and placeholder/example values only. Never put real credentials or secrets in them.
- **Frontend variables:** Only expose variables that are intentionally public to the frontend. Never expose database credentials, private API keys, JWT secrets, or other backend secrets through frontend environment variables.
- **Backend variables:** Database URLs, authentication secrets, API keys, external-service credentials, storage credentials, and other sensitive configuration must be read from backend environment variables.
- **No hardcoded configuration:** Do not hardcode development, staging, or production URLs, API endpoints, ports, credentials, or service settings. Configuration must be changeable without modifying application source code.
- **Environment validation:** Validate required environment variables at application startup and fail with a clear configuration error when required values are missing or invalid.
- **Deployment configuration:** Production environment variables must be configured through the deployment platform's secret/environment-variable management system rather than committed to the repository.
- **Consistent environments:** Local development should mirror production architecture as closely as practical using Docker/Compose and environment profiles.
- **Secret-safe logging:** Never log passwords, tokens, API keys, database credentials, JWT secrets, or other sensitive environment values.
- **Git protection:** `.gitignore` must exclude `.env` and other files containing secrets or private credentials. If a secret is accidentally committed, rotate it immediately rather than merely deleting it from the latest commit.

## 11. Testing & Quality

- **Test business-critical behavior:** Cover authentication, RBAC, validation, database operations, case transitions, assignment, AI fallback, audit logging, and resolution flows.
- **Backend tests:** Use JUnit 5, Mockito, and Testcontainers/PostgreSQL where appropriate.
- **Frontend tests:** Use Flutter testing tools and mocks for important widgets/state/API behavior.
- **Quality gates:** Code must pass formatting/linting, compilation/build, and relevant automated tests before merge.
- **Regression first:** Do not remove or weaken existing tests merely to make a new change pass.

## 12. Git & Change Management

- **Small, logical commits:** Commit completed units of work with clear messages; avoid mixing unrelated features/refactors.
- **Review before merge:** Verify tests, migrations, API contracts, security, and documentation before pushing/merging.
- **No destructive shortcuts:** Do not use force pushes, destructive database changes, or bypass checks unless explicitly approved.
- **Document breaking changes:** Any breaking API/schema/workflow change must be clearly documented and versioned.

## 13. Observability & Production Safety

- **Structured logging:** Log useful operational information without exposing passwords, tokens, secrets, or unnecessary PII.
- **Health checks:** Maintain application health/metrics endpoints and monitor scheduled/background jobs.
- **Failure isolation:** AI, notification, scheduled, and external-service failures must not crash the core application.
- **Secure storage:** Evidence must not be publicly accessible by default; use controlled/signed access as specified.

## 14. Definition of Done

A change is done only when:

1. Requirement and affected workflow are understood.
2. Code follows the SRS architecture and folder conventions.
3. Database changes have Flyway migrations where required.
4. Server-side validation/security/RBAC is implemented.
5. Relevant tests pass.
6. API/UI behavior is verified.
7. Logs/errors are safe and useful.
8. Documentation is updated when behavior/contracts change.
9. Configuration is environment-driven and no secrets are hardcoded or committed.
10. The change is ready for a clean Git commit and deployment pipeline.

## 15. Prohibited Practices

- Do not bypass backend authorization with frontend-only checks.
- Do not hardcode secrets, credentials, URLs, API keys, tokens, or environment-specific configuration.
- Do not commit `.env` files containing secrets.
- Do not expose backend secrets through frontend environment variables.
- Do not expose database entities directly as API contracts.
- Do not manually change schema outside Flyway.
- Do not auto-merge cases or bypass required human approval.
- Do not make AI a single point of failure for core case operations.
- Do not add libraries, services, features, or infrastructure without a clear project requirement or documented technical justification.