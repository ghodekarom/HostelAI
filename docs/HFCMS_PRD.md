# Product Requirements Document
## Hostel Facility Complaint Management System — AI Case Manager

---

## 1. Overview

The Hostel Facility Complaint Management System is an AI-powered case-management application that lets students report facility issues (water, electrical, furniture, Wi-Fi, cleanliness, etc.) and lets hostel staff track each complaint through to resolution.

The product is built on a generic case-management architecture, adapted specifically for hostel facility complaints. AI assists at every stage — understanding, classifying, routing, and monitoring cases — but a human always makes the decisions that matter: accepting recommendations, assigning technicians, escalating, and confirming resolutions. This keeps the system fast and consistent without removing human judgment from the loop.

---

## 2. Problem Statement

Hostel facility complaints today are typically logged informally (WhatsApp groups, paper registers, phone calls), which leads to:

- Lost or duplicate complaints
- No visibility into complaint status for students or staff
- No prioritization — urgent issues (e.g., no water for an entire block) get the same treatment as minor ones
- No way to detect that many students are reporting the *same* underlying issue
- No data for hostel management to see recurring problems or measure resolution performance

This product replaces that ad-hoc process with a structured, trackable, AI-assisted workflow.

---

## 3. Goals & Objectives

| Goal | Description |
|---|---|
| Faster resolution | Reduce time from complaint submission to confirmed resolution |
| Reduce duplicate effort | Detect and link related complaints instead of handling each in isolation |
| Consistent triage | Use AI to classify, prioritize, and route every complaint the same way |
| Transparency | Give students visibility into their complaint's status |
| Accountability | Maintain a full audit trail of every action taken on a case |
| Actionable insights | Give hostel management data on complaint volume, categories, and recurring infrastructure issues |

---

## 4. Personas / Roles

| Role | Description |
|---|---|
| **Student** | Reports complaints, provides missing information when asked, confirms or rejects resolutions |
| **Maintenance / Facility Operator** | Reviews AI recommendations, assigns technicians, investigates, repairs, proposes resolutions |
| **Technician** | Executes investigation and repair tasks assigned by the operator or team lead |
| **Hostel Warden / Maintenance Supervisor (Team Lead)** | Intervenes on at-risk cases, reassigns, escalates, adds resources |
| **Chief Warden / Dean of Student Affairs (Manager)** | Views hostel-level analytics and recurring-problem insights |
| **Hostel / Campus Admin (Administrator)** | Manages system configuration — teams, categories, users |
| **AI Case Manager** | Automated system actor — understands, classifies, prioritizes, detects duplicates, recommends actions, monitors risk |

---

## 5. Scope

### 5.1 In Scope (v1)

- Complaint creation by students, with location, category, and evidence
- AI-driven complaint understanding: classification, severity, priority, suggested team, missing-information detection
- Duplicate / related-case detection with human review before merging
- Operator review and accept/modify/reject workflow for AI recommendations
- Team and technician assignment, with ownership history
- Missing-information request/response loop between AI/operator and student
- Investigation task checklists and findings capture
- AI-based SLA and risk monitoring, with automatic team-lead notification
- Team lead intervention actions (reassign, escalate, increase priority, add resources)
- Repair/action logging with evidence upload
- Resolution proposal and student confirmation (confirm → close, or reject → reopen)
- Full case history/audit trail
- Manager-level analytics dashboard (trends, category breakdowns, recurring infrastructure issues, and AI-powered operational insights)
- AI-generated communication drafts for information requests, progress updates, resolution messages, and escalation summaries
- Automated notifications for key case events across configured in-app, push, SMS, and other supported channels
- Automatic case timeline and audit logging for important case and AI events
- Predefined complaint categories, extensible by admin
- Access to the system across web, desktop, and mobile clients, with a consistent experience for each role on any of these
- In-app notifications (including in-app SMS-style messages) to students, operators, and team leads for status updates, missing-information requests, risk alerts, and resolution confirmations
- Push and SMS notifications via external channels, for students, operators, and team leads, for the same events as above

### 5.2 Out of Scope (v1)

- Billing, budgeting, or cost-tracking for repairs
- Vendor/external-contractor management
- Inventory or spare-parts management
- Automated technician dispatch/routing based on real-time location

---

## 6. Core Case Lifecycle

```
REPORTED
   ↓
UNDERSTOOD
   ↓
RELATED CASES CHECKED
   ↓
OPERATOR REVIEW
   ↓
ASSIGNED
   ↓
WAITING FOR INFORMATION (if required)
   ↓
INVESTIGATED
   ↓
ACTION TAKEN
   ↓
AI RISK MONITORING
   ↓
TEAM LEAD INTERVENTION (if required)
   ↓
RESOLUTION PROPOSED
   ↓
STUDENT CONFIRMATION
   ↓
CONFIRMED ─────→ CLOSED
   │
   └────────────→ REOPENED → INVESTIGATION
```

**Core product principle:** Student reports the problem → AI understands and recommends → automation helps route and monitor the case → humans make important decisions → issue is repaired → student confirms → case is closed → management receives AI-powered insights.

---

## 7. Functional Requirements & User Stories

### 7.1 Complaint Creation

**Requirements**
- Student must be able to log in and report a complaint.
- Complaint capture fields: description, hostel/block, floor/room, category, photo/video evidence (optional), additional details (optional).
- On submission, system generates a case ID and sets status to `Reported`.

**User Stories**
- As a student, I want to report a facility complaint with location and category details, so that staff can address it without me having to explain it in person.
- As a student, I want to attach a photo or video to my complaint, so that staff understand the issue without a site visit.

---

### 7.2 AI Case Understanding

**Requirements**
- On case creation, AI must analyze the complaint and produce: category, subcategory, location, severity, priority, suggested team, missing information (if any), related cases, and a recommended action.
- AI-generated fields must be visually distinguishable from confirmed/human-entered information.
- Case status updates to `Understood` once analysis is complete.

**User Stories**
- As an operator, I want the AI to pre-classify and prioritize every incoming complaint, so that I don't have to manually triage each one from scratch.
- As an operator, I want to clearly see which fields are AI-suggested versus confirmed, so that I don't mistake a recommendation for verified fact.

---

### 7.2a AI Case Summarization

**Requirements**
- The system must automatically maintain an AI-generated summary of each case that updates as the case history grows (new comments, investigation findings, actions taken, student responses, etc.).
- The summary must cover: what was originally reported, what has happened since, what has been confirmed, and what remains unresolved.
- The summary must be visible to operators and team leads on the case view, and must always reflect the current state of the case rather than a one-time snapshot.

**User Stories**
- As an operator, I want an up-to-date summary of a case, so that I can understand its full context in seconds without reading the entire history.
- As a team lead, I want a current summary when I'm called in to intervene, so that I don't have to reconstruct the case from scratch.

---

### 7.3 Duplicate / Related Case Detection

**Requirements**
- AI must search existing complaints for similar issues (same category/location/timeframe) and surface a "may be related" suggestion.
- Operator must be able to: link cases, mark as duplicate, keep separate, or ignore the suggestion.
- System must never auto-merge cases without human review.

**User Stories**
- As an operator, I want the system to flag complaints that look related, so that I can address one root cause instead of five separate tickets.
- As an operator, I want the final say on whether cases are actually related, so that unrelated issues aren't incorrectly merged.

---

### 7.4 Operator Review

**Requirements**
- Operator must be able to view the case summary with all AI-generated fields and related-case count.
- Operator must be able to accept, modify, or reject the AI recommendation.
- Case status updates to `Assigned` once a decision is made.

**User Stories**
- As an operator, I want to review and adjust the AI's recommendation before it becomes official, so that the system stays accurate even when AI gets something wrong.

---

### 7.5 Assignment & Smart Assignment Recommendation

**Requirements**
- AI must recommend the appropriate team and/or technician by analyzing the issue type, team responsibility, current workload, availability, location, and the student's/case's previous history.
- The recommendation is a suggestion only; the operator makes the final assignment decision and may accept it as-is or choose a different team/technician.
- System must record previous owner, new owner, assignment time, and assignment reason for every reassignment.
- Case status updates to `Assigned` with recorded owner and team.

**User Stories**
- As an operator, I want the system to recommend the right team and technician based on workload and availability, so that I can assign complaints faster without checking each team's status manually.
- As an operator, I want to assign a complaint to the right team and technician, so that the correct person is accountable for resolving it.
- As a team lead, I want to see the full assignment history of a case, so that I understand how ownership has changed over time.

---

### 7.6 Missing Information Handling

**Requirements**
- AI must check whether the complaint has sufficient information to proceed and detect what is missing.
- When information is missing, AI drafts one or more specific candidate questions for the student (see 7.6a AI-Generated Communication).
- Operator reviews and sends the question (as drafted or edited) to the student; on send, case status updates to `Waiting for Information`.
- On student response, case status updates to `Active` and investigation continues.

**User Stories**
- As a student, I want to be asked specific follow-up questions when my complaint is missing detail, so that I don't have to guess what staff need to know.
- As an operator, I want the system to draft the missing-information request for me, so that I don't have to chase students manually or write the message from scratch.

---

### 7.6a AI-Generated Communication

**Requirements**
- AI must generate draft messages for the recurring communication moments in a case: missing-information requests, progress updates, resolution messages, and escalation summaries.
- Every AI-drafted message must be reviewed by the operator (or team lead, for escalation summaries) before it is sent — the operator can edit the draft or send it as-is.
- Sent messages, and who sent them, become part of the case's audit trail.

**User Stories**
- As an operator, I want the system to draft routine updates to students, so that I spend less time writing repetitive messages.
- As an operator, I want to review and edit any AI-drafted message before it goes out, so that I stay in control of what's communicated to a student.
- As a team lead, I want a drafted escalation summary when I raise a case to the warden, so that I don't have to write the context up from scratch under time pressure.

---

### 7.7 Investigation

**Requirements**
- System must generate an investigation checklist relevant to the complaint category.
- Technician must be able to record findings against the checklist.
- Case status updates to `Investigated` once findings are recorded.
- Investigation findings become part of the permanent case history.

**User Stories**
- As a technician, I want a standard checklist for the type of issue I'm investigating, so that I don't miss any diagnostic steps.
- As a technician, I want to record my findings directly on the case, so that there's a permanent record of what I discovered.

---

### 7.8 AI Risk and SLA Monitoring

**Requirements**
- AI must continuously monitor each active case for signals including: inactivity, SLA proximity, repeated follow-ups, reassignment, missing information, approaching deadlines, repeated reopening, case complexity, and number of affected students.
- If thresholds are breached, system flags the case `At Risk` with the reason(s) and notifies the team lead.
- Normal cases continue without interruption.

**User Stories**
- As a team lead, I want to be automatically notified when a case is at risk of breaching SLA, so that I can intervene before it escalates further.

---

### 7.8a Escalation Automation

**Requirements**
- The system must automatically identify situations that call for higher-level attention, including: an approaching or missed SLA deadline, a case marked high severity/serious, a complaint that has been repeatedly reopened or unresolved, or an operator/team lead explicitly requesting managerial help.
- When one of these situations is detected, the system notifies the appropriate higher-level role (team lead or chief warden/dean, depending on severity) and drafts an escalation summary (see 7.6a).
- Escalation itself — i.e., actually raising a case to the next level and changing its ownership/priority — remains a human decision; the system's role is to detect the situation, notify, and prepare the summary.

**User Stories**
- As a team lead, I want to be automatically alerted when a case meets escalation criteria, so that serious issues don't sit unnoticed.
- As a chief warden, I want a ready-made summary when a case is escalated to me, so that I can act quickly instead of reading the entire case history first.

---

### 7.9 Team Lead Intervention

**Requirements**
- Team lead must be able to view full case context: details, affected students, related complaints, current technician, investigation status, SLA, AI risk reason, previous actions, and recommended next action.
- Team lead must be able to: reassign technician, increase priority, add resources, escalate, or change assignment.
- All interventions must be recorded in the case timeline.

**User Stories**
- As a team lead, I want full visibility into a case before intervening, so that I make an informed decision rather than reacting blindly to an alert.
- As a team lead, I want every intervention I make to be logged, so that there's accountability for escalation decisions.

---

### 7.10 Repair / Action Taken

**Requirements**
- Technician/operator must be able to record repair/corrective action, verify the fix, and upload evidence (photo, inspection report, completion evidence).
- Case status updates to `Action Taken`.

**User Stories**
- As a technician, I want to log the repair I performed along with supporting evidence, so that there's proof the issue was addressed.

---

### 7.11 Resolution Proposal

**Requirements**
- Operator must submit a structured resolution: problem, root cause, action taken, result.
- Case status updates to `Resolution Proposed`.

**User Stories**
- As an operator, I want to submit a clear root-cause-and-fix summary, so that the student and management understand exactly what was wrong and how it was fixed.

---

### 7.12 Student Confirmation

**Requirements**
- Student must receive a resolution notification with a confirm/reject option.
- If confirmed → case status becomes `Confirmed`, then `Closed`.
- If rejected → case status becomes `Reopened` and investigation continues.

**User Stories**
- As a student, I want to confirm whether my issue is actually fixed, so that the case isn't closed prematurely.
- As a student, I want to reopen my complaint if the problem still exists, so that I don't have to file a brand-new complaint for the same issue.

---

### 7.13 Case Closure

**Requirements**
- Confirmed cases move to `Closed` and remain in the system with complete history for future analysis.
- Rejected cases move to `Reopened` and re-enter the investigation stage.

---

### 7.14 Manager-Level Analytics

**Requirements**
- Manager dashboard must surface hostel-level insights, including (but not limited to):
  - Trend changes in complaint volume by category (e.g., "Water complaints increased 35% this month")
  - Complaint hotspots by block/location
  - Average resolution time by category
  - Complaints traced back to a single underlying infrastructure issue

**User Stories**
- As a chief warden, I want to see which category and block generate the most complaints, so that I can prioritize infrastructure investment.
- As a dean of student affairs, I want to see resolution-time trends by category, so that I can identify which teams need more support.

---

### 7.15 Automated Notifications

**Requirements**
- The system must automatically notify the relevant users whenever an important event occurs on a case. At minimum, this covers: new case created, assignment made, requester (student) response received, new task created, SLA warning raised, escalation triggered, resolution proposed/confirmed, and case reopened.
- Each event notifies only the roles relevant to it (e.g., a new task notifies the assigned technician; an SLA warning notifies the team lead; a resolution notifies the student).
- Notifications are delivered in-app, and via push/SMS for the same events (see Section 5.1 and 13).

**User Stories**
- As a student, I want to be notified when my complaint is assigned or resolved, so that I stay informed without checking the app constantly.
- As a technician, I want to be notified when a new task is assigned to me, so that I don't miss work waiting in my queue.

---

### 7.16 Case Timeline and Audit Logging

**Requirements**
- The system must automatically record important actions in each case's history as they happen, without requiring a manual log entry.
- Logged actions include, at minimum: assignments and reassignments, status changes, AI recommendations (and whether accepted/modified/rejected), escalations, resolutions, reopening, and closure.
- The timeline must be visible to operators, team leads, and managers, and must be permanent (not editable or deletable) to preserve accountability.

**User Stories**
- As a team lead, I want a complete, tamper-proof timeline of everything that happened on a case, so that I can review decisions after the fact.
- As an administrator, I want every AI recommendation and the human decision on it recorded, so that we can audit how well AI suggestions are being used.

---

## 8. AI Workflow Automation

AI workflow automation is a core pillar of this product, not a bolt-on feature. Rather than staff manually pushing every case from one stage to the next, the system automatically evaluates each case against a set of conditions and triggers the next step, a notification, or an escalation — while keeping humans in control of any decision that changes the outcome for a student or a team.

### 8.1 What the automation layer does

| Lifecycle Stage | AI / Automation Function |
|---|---|
| Complaint creation | Extract issue and location |
| Classification | Detect category/subcategory |
| Priority | Suggest severity and priority |
| Case summarization | Continuously maintain an up-to-date summary as the case progresses |
| Duplicate detection | Find similar/related complaints |
| Assignment | Recommend responsible team/person based on workload, availability, location, and history |
| Missing information | Identify missing details and suggest questions to ask |
| Communication | Draft clarification requests, progress updates, resolution messages, and escalation summaries |
| Investigation | Suggest investigation checklist |
| SLA monitoring | Detect inactivity, follow-ups, and approaching deadlines |
| Risk detection | Flag likely delayed or problematic cases |
| Escalation | Detect situations needing higher-level attention and trigger notification |
| Notifications | Notify the right users on key events (new case, assignment, response, new task, SLA warning, escalation, resolution, reopening) |
| Timeline/audit logging | Automatically record key actions in the case history |
| Resolution | Analyze resolution information/evidence |
| Reopening | Identify recurring/repeated complaints |
| Manager insights | Detect recurring hostel problems and trends across cases |

### 8.2 How automation is triggered

Each stage transition in the case lifecycle (Section 6) is driven by either an event or a condition being met, rather than a person manually clicking "next stage":

| Trigger Type | Example |
|---|---|
| **Event-based** | A complaint is submitted → AI analysis runs automatically and the case moves to `Understood` |
| **Condition-based** | A case has had no activity for a defined period → automatically flagged `At Risk` and the team lead is notified |
| **Threshold-based** | SLA time remaining drops below a defined buffer → automatic notification escalates from operator to team lead |
| **Response-based** | Student submits requested missing information → case automatically moves from `Waiting for Information` back to active investigation |
| **Confirmation-based** | Student confirms or rejects a resolution → case automatically moves to `Closed` or `Reopened` accordingly |

### 8.3 What stays automatic vs. what requires a human decision

| Automatic (no approval needed) | Requires human approval |
|---|---|
| Classifying and prioritizing a new complaint | Accepting/modifying/rejecting the AI's classification |
| Surfacing related/duplicate complaints | Actually linking or merging cases |
| Flagging a case as at-risk and notifying the team lead | Reassigning, escalating, or changing priority |
| Requesting missing information from the student | — |
| Moving a case to `Waiting for Information` or back to active | — |
| Generating an investigation checklist | Recording findings against it |
| Detecting recurring/repeated complaints | Reopening a case based on student rejection is automatic; any follow-on escalation is human-approved |

**Principle:** AI recommends, monitors, and automatically advances routine case-state changes; it does not make final decisions on assignment, merging, escalation, or closure. Every AI output that changes ownership, priority, or outcome for a student must pass through a human checkpoint.

### 8.4 Implementation Approach for v1

- The v1 automation layer is implemented inside the core application. The target architecture is:

```text
Flutter / Web Clients
        ↓
   Spring Boot API
        ↓
PostgreSQL / Supabase
        ↕
     AI APIs
        ↓
Notification / Email / SMS / Push Services
```

- The automation features listed in this PRD do **not** require a separate Worker, message queue, or n8n workflow engine for v1.
- Event-driven automation — such as new-case analysis, summary refreshes, duplicate/related-case checks, missing-information detection, communication drafting, notifications, and response/confirmation handling — may run through the Spring Boot application as part of normal application workflows.
- Time-based automation — especially SLA checks, inactivity detection, risk checks, deadline warnings, and scheduled escalation checks — can be implemented using a **Spring Boot Scheduler** with a configurable recurring interval.
- Automation must be designed so that core case operations remain reliable even when an AI call is slow, fails, times out, or is temporarily unavailable. AI work must therefore be treated as an assistive capability rather than a hard dependency for core case-state changes.
- A separate Worker, message queue, or n8n may be introduced in a later version only if real workload characteristics justify it, such as heavy/long-running AI processing, high event volume, retry requirements, independent scaling, or other background workloads that should no longer run in the core application.
- **AI service resilience:** the application must remain usable even if the AI service is temporarily unavailable. Core actions — reporting a complaint, manually classifying and assigning it, recording investigation findings, proposing a resolution, and confirming/closing a case — must all be possible without the AI. AI-generated fields should be marked `Pending`, `Unavailable`, or left blank according to the UI design, and the system should retry or allow re-triggering AI analysis when the service becomes available.
- **Human-in-the-loop rule:** AI may analyze, recommend, detect, draft, summarize, and notify automatically, but decisions that materially affect ownership, merging/linking, escalation, priority, or final case outcome remain subject to the human approval rules defined in this PRD.

---

## 9. Complaint Categories (v1)

- Water supply / leakage
- Electrical problems
- Broken furniture
- Wi-Fi / Internet
- Cleanliness
- Mess / Food complaints
- Doors / Locks
- Lift / Elevator
- Bathroom facilities
- Common-area maintenance

Categories should be configurable by the Administrator (add/edit/deactivate) rather than hardcoded, so the list can evolve without a code change.

---

## 10. Role Mapping (Generic → Hostel-Specific)

| Generic PRD Role | Hostel System Role |
|---|---|
| Requester | Student |
| Operator | Maintenance / Facility Staff |
| Team Lead | Hostel Warden / Maintenance Supervisor |
| Manager | Chief Warden / Dean of Student Affairs |
| Administrator | Hostel / Campus Admin |
| Case | Hostel Complaint |
| Team | Plumbing / Electrical / IT / Cleaning / Mess |
| Evidence | Photos / Videos / Documents |
| Location | Hostel → Block → Floor → Room |
| Resolution | Repair / Fix / Action Taken |

---

## 11. Example End-to-End Scenario

**Student submits:** "There is no water in Block B since 7 AM."

**AI automatically identifies:**
- Category: Water Supply
- Location: Block B
- Priority: High
- Possible related cases: 6
- Suggested team: Plumbing
- Risk: High
- Next action: Check main water supply

**Automation Engine then:**
1. Surfaces the related complaints and possible duplicate/incident relationship for operator review
2. Prepares the recommended common-issue context without automatically merging cases
3. Generates the relevant assignment recommendation and notification
4. Creates the recommended inspection task/checklist
5. Starts the SLA timer and monitoring rules

**If no action within 1 hour:** case flagged "At Risk."
**If SLA deadline approaches:** team lead notified.
**If SLA deadline is breached:** escalated to warden.

**After repair:** operator submits evidence → AI checks resolution completeness → student receives confirmation request → student confirms → case closed.

---

---

## 12. Architecture & Automation Implementation Requirements

### 12.1 v1 Application Architecture

The v1 system must use a simple application-centered architecture:

| Layer | v1 Responsibility |
|---|---|
| **Flutter / Web Clients** | Student, operator, technician, team lead, manager, and administrator interfaces |
| **Spring Boot Application** | REST APIs, authentication/authorization, case lifecycle, business rules, automation orchestration, scheduled SLA/risk checks |
| **PostgreSQL / Supabase** | Users, cases, case history, assignments, tasks, notifications, AI outputs, audit records, analytics data |
| **AI APIs** | Case analysis, summarization, missing-information detection, related/duplicate detection, assignment recommendation, risk analysis, communication drafting, operational insights |
| **Notification / Email / SMS / Push Services** | Delivery of important case notifications through configured channels |

### 12.2 Automation Execution Model

The automation implementation must support three categories of triggers:

1. **Event-driven:** run when an application event occurs, such as case creation, assignment, new comment, student response, task creation, resolution proposal, confirmation, or reopening.
2. **Condition-driven:** evaluate case data when relevant case activity occurs and trigger actions such as missing-information detection, risk detection, or escalation notification.
3. **Scheduled:** use Spring Boot Scheduler for time-based checks such as inactivity, approaching SLA deadlines, missed SLAs, repeated follow-ups, and scheduled risk evaluation.

### 12.3 Automation Feature Requirements

The v1 automation layer must cover all of the following:

| Automation Capability | Required v1 Behavior |
|---|---|
| **Automatic AI Case Analysis** | Analyze new cases and identify likely category, severity, priority, missing information, related cases, suggested team, and recommended next action |
| **Automatic Case Summarization** | Maintain a current AI-generated summary as case history grows |
| **Missing Information Detection** | Detect missing information and generate candidate questions for the requester |
| **Related / Duplicate Detection** | Compare against existing cases and surface possible relationships; human review is required before linking/merging decisions |
| **Smart Assignment Recommendation** | Recommend team/person using issue type, responsibility, workload, availability, location, and previous case history |
| **SLA / Risk Detection** | Detect inactivity, repeated follow-ups, reassignment, missing information, approaching deadlines, repeated reopening, complexity, and affected-student signals |
| **Escalation Automation** | Detect escalation conditions, notify the appropriate higher-level role, and prepare an escalation summary; the actual escalation decision remains human-controlled |
| **AI-Generated Communication** | Draft information requests, progress updates, resolution messages, and escalation summaries; required human review before sending |
| **Automated Notifications** | Notify relevant users for new cases, assignments, responses, tasks, SLA warnings, escalations, resolutions, and reopenings |
| **Automatic Timeline / Audit Logging** | Record important case events, AI recommendations, human decisions, assignments, status changes, escalations, resolutions, reopening, and closure |
| **AI-Powered Operational Insights** | Analyze multiple cases for trends, hotspots, recurring issues, category changes, and other operational patterns |

### 12.4 Automation vs Human Decision Boundary

Automation must never be interpreted as unrestricted autonomous case management.

**May happen automatically:**
- AI analysis and classification suggestions
- Summary generation/update
- Missing-information detection and draft questions
- Related/duplicate detection suggestions
- Assignment recommendations
- Risk/SLA detection and notifications
- Escalation detection and notification
- Draft communication generation
- Routine notifications
- Audit/timeline event creation
- Scheduled SLA/risk checks

**Requires human decision where applicable:**
- Accepting, modifying, or rejecting AI recommendations
- Linking/merging cases
- Final team/technician assignment
- Changing priority because of an AI recommendation
- Actual escalation/ownership change
- Sending AI-generated communication
- Recording investigation findings
- Confirming the validity of a proposed resolution

Student confirmation/rejection of a resolution remains an explicit student action and controls the `Closed` versus `Reopened` outcome.

### 12.5 AI Failure and Degraded-Mode Requirements

The system must continue to provide the core case-management workflow when AI services are unavailable.

When an AI request fails:
- The case must not be lost or blocked.
- The relevant AI result must be marked pending/unavailable.
- The operator must be able to perform the affected action manually.
- AI analysis should be retryable.
- AI failures/timeouts should be logged for operational monitoring.
- Existing case data and audit history must remain available.
- Scheduled SLA/risk monitoring must continue independently of AI availability wherever the required rule can be evaluated using application data.

This requirement ensures that AI improves the workflow without becoming a single point of failure.

### 12.6 Future Scalability Boundary

The following are **not v1 requirements**:
- Separate Worker service
- Message broker / queue
- n8n or another workflow automation platform
- Dedicated distributed job-processing infrastructure

These may be introduced later if measurable workload, reliability, latency, retry, or scaling requirements justify the additional architecture.


## 13. Success Metrics

| Metric | Why it matters |
|---|---|
| Average time from `Reported` to `Closed` | Measures overall resolution speed |
| % of cases correctly auto-classified (no operator correction) | Measures AI classification quality |
| % of cases flagged "At Risk" that breach SLA anyway | Measures whether risk monitoring actually prevents delays |
| % of complaints identified as duplicate/related before resolution | Measures effectiveness of duplicate detection |
| % of resolutions confirmed on first attempt (not reopened) | Measures resolution quality |
| Student satisfaction with complaint process (survey) | Measures perceived usefulness |

---

## 14. Assumptions & Risks

**Assumptions**
- Students and staff have accounts and can log in to the system.
- The system provides its own in-app and push/SMS notifications to alert students, operators, and team leads — no dependency on a separate external notification system.
- Teams (Plumbing, Electrical, IT, Cleaning, Mess) are pre-defined and technicians are mapped to them.
- v1 automation runs within the Spring Boot core application using event/condition-driven handling plus Spring Boot Scheduler for time-based checks; a separate Worker, queue, or n8n is not assumed to be needed at launch.
- AI providers may be temporarily unavailable, so manual fallback paths are required for core case operations.

**Risks**
- Over-reliance on AI recommendations if operators habitually "accept" without review, undermining the human-in-the-loop model.
- Poor-quality AI classification early on could reduce operator trust in the system — needs a feedback loop to improve accuracy over time.
- Incorrect duplicate merging, if operators approve suggestions too quickly, could hide distinct issues.
- Temporary AI service outages could disrupt automation-dependent steps if resilience is not implemented carefully — the application must degrade to manual workflows rather than blocking users.
- AI calls may be slow, expensive, or intermittently unavailable; timeout, retry, pending-state, and manual-fallback behavior must prevent these calls from blocking the core case lifecycle.
- Introducing a Worker, queue, or n8n prematurely could add operational complexity without a demonstrated v1 need; the architecture should remain application-centered until workload evidence justifies separation.

---

## 15. Future Scope

- Predictive maintenance (flagging infrastructure likely to fail based on historical complaint patterns)
- Vendor/contractor management for issues beyond in-house team capability
- Cost tracking per repair/case
