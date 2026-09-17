-- ==============================================================================
-- Flyway Migration V4: Lifecycle, Investigation, Repair & Audit Tables
-- ==============================================================================

-- Assignment History Table (Tracks ownership transitions & reassignments)
CREATE TABLE IF NOT EXISTS assignment_history (
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    previous_technician_id BIGINT,
    new_technician_id BIGINT,
    previous_team_id BIGINT,
    new_team_id BIGINT,
    assigned_by BIGINT NOT NULL,
    assignment_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_assignment_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_assignment_prev_tech FOREIGN KEY (previous_technician_id) REFERENCES technicians (id) ON DELETE SET NULL,
    CONSTRAINT fk_assignment_new_tech FOREIGN KEY (new_technician_id) REFERENCES technicians (id) ON DELETE SET NULL,
    CONSTRAINT fk_assignment_prev_team FOREIGN KEY (previous_team_id) REFERENCES teams (id) ON DELETE SET NULL,
    CONSTRAINT fk_assignment_new_team FOREIGN KEY (new_team_id) REFERENCES teams (id) ON DELETE SET NULL,
    CONSTRAINT fk_assignment_assigner FOREIGN KEY (assigned_by) REFERENCES users (id) ON DELETE RESTRICT
);

-- Missing Information Requests Table
CREATE TABLE IF NOT EXISTS missing_info_requests (
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    requested_by BIGINT NOT NULL,
    is_ai_drafted BOOLEAN DEFAULT FALSE NOT NULL,
    questions TEXT NOT NULL,
    student_response TEXT,
    status VARCHAR(30) DEFAULT 'WAITING_FOR_RESPONSE' NOT NULL,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    responded_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_missing_info_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_missing_info_requester FOREIGN KEY (requested_by) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_missing_info_status CHECK (status IN ('WAITING_FOR_RESPONSE', 'RESPONDED', 'CANCELLED'))
);

-- Investigation Checklists Table
CREATE TABLE IF NOT EXISTS investigation_checklists (
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    is_ai_generated BOOLEAN DEFAULT TRUE NOT NULL,
    status VARCHAR(30) DEFAULT 'PENDING' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_checklist_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_checklist_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT,
    CONSTRAINT chk_checklist_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED'))
);

-- Investigation Checklist Items Table
CREATE TABLE IF NOT EXISTS checklist_items (
    id BIGSERIAL PRIMARY KEY,
    checklist_id BIGINT NOT NULL,
    item_description VARCHAR(255) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE NOT NULL,
    findings TEXT,
    recorded_by BIGINT,
    recorded_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_item_checklist FOREIGN KEY (checklist_id) REFERENCES investigation_checklists (id) ON DELETE CASCADE,
    CONSTRAINT fk_item_technician FOREIGN KEY (recorded_by) REFERENCES users (id) ON DELETE SET NULL
);

-- Repair Actions Table
CREATE TABLE IF NOT EXISTS repair_actions (
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    technician_id BIGINT NOT NULL,
    action_taken TEXT NOT NULL,
    evidence_url VARCHAR(500),
    parts_replaced TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_repair_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_repair_technician FOREIGN KEY (technician_id) REFERENCES technicians (id) ON DELETE RESTRICT
);

-- Structured Resolutions Table
CREATE TABLE IF NOT EXISTS resolutions (
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT NOT NULL UNIQUE,
    proposed_by BIGINT NOT NULL,
    problem_description TEXT NOT NULL,
    root_cause TEXT NOT NULL,
    action_taken TEXT NOT NULL,
    result_summary TEXT NOT NULL,
    student_decision VARCHAR(30) DEFAULT 'PENDING' NOT NULL,
    student_feedback TEXT,
    proposed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    decided_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_resolution_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_resolution_proposer FOREIGN KEY (proposed_by) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_student_decision CHECK (student_decision IN ('PENDING', 'CONFIRMED', 'REJECTED'))
);

-- Case Status History (Permanent Tamper-Proof Audit Trail)
CREATE TABLE IF NOT EXISTS case_status_history (
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    previous_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by BIGINT,
    change_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_history_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_history_user FOREIGN KEY (changed_by) REFERENCES users (id) ON DELETE SET NULL
);
