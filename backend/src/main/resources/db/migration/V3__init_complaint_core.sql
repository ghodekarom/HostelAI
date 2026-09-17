-- ==============================================================================
-- Flyway Migration V3: Core Complaint Tables & Relationships
-- ==============================================================================

-- Core Complaints Table
CREATE TABLE IF NOT EXISTS complaints (
    id BIGSERIAL PRIMARY KEY,
    case_number VARCHAR(50) NOT NULL UNIQUE,
    student_id BIGINT NOT NULL,
    hostel_id BIGINT NOT NULL,
    block_id BIGINT NOT NULL,
    room_id BIGINT,
    category_id BIGINT NOT NULL,
    subcategory VARCHAR(100),
    description TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'REPORTED' NOT NULL,
    severity VARCHAR(30) DEFAULT 'MEDIUM' NOT NULL,
    priority VARCHAR(30) DEFAULT 'P3' NOT NULL,
    assigned_team_id BIGINT,
    assigned_technician_id BIGINT,
    ai_status VARCHAR(30) DEFAULT 'PENDING' NOT NULL,
    ai_summary TEXT,
    sla_deadline TIMESTAMP WITH TIME ZONE,
    is_at_risk BOOLEAN DEFAULT FALSE NOT NULL,
    risk_reasons JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_complaints_student FOREIGN KEY (student_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_complaints_hostel FOREIGN KEY (hostel_id) REFERENCES hostels (id) ON DELETE RESTRICT,
    CONSTRAINT fk_complaints_block FOREIGN KEY (block_id) REFERENCES blocks (id) ON DELETE RESTRICT,
    CONSTRAINT fk_complaints_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE SET NULL,
    CONSTRAINT fk_complaints_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT,
    CONSTRAINT fk_complaints_team FOREIGN KEY (assigned_team_id) REFERENCES teams (id) ON DELETE SET NULL,
    CONSTRAINT fk_complaints_technician FOREIGN KEY (assigned_technician_id) REFERENCES technicians (id) ON DELETE SET NULL,
    CONSTRAINT chk_complaint_status CHECK (
        status IN (
            'REPORTED',
            'UNDERSTOOD',
            'RELATED_CASES_CHECKED',
            'OPERATOR_REVIEW',
            'ASSIGNED',
            'WAITING_FOR_INFORMATION',
            'ACTIVE',
            'INVESTIGATED',
            'ACTION_TAKEN',
            'AT_RISK',
            'RESOLUTION_PROPOSED',
            'CONFIRMED',
            'CLOSED',
            'REOPENED'
        )
    ),
    CONSTRAINT chk_complaint_severity CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_complaint_priority CHECK (priority IN ('P1', 'P2', 'P3', 'P4')),
    CONSTRAINT chk_complaint_ai_status CHECK (ai_status IN ('PENDING', 'COMPLETED', 'FAILED', 'UNAVAILABLE'))
);

-- Complaint Evidence / Attachments Table (Photos, Videos, Documents)
CREATE TABLE IF NOT EXISTS complaint_evidence (
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT,
    uploader_id BIGINT NOT NULL,
    evidence_stage VARCHAR(50) DEFAULT 'INTAKE' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_evidence_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_evidence_uploader FOREIGN KEY (uploader_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_evidence_stage CHECK (evidence_stage IN ('INTAKE', 'INVESTIGATION', 'REPAIR', 'RESOLUTION'))
);

-- Related / Duplicate Cases Table
CREATE TABLE IF NOT EXISTS complaint_related_cases (
    id BIGSERIAL PRIMARY KEY,
    parent_complaint_id BIGINT NOT NULL,
    related_complaint_id BIGINT NOT NULL,
    relationship_type VARCHAR(30) DEFAULT 'RELATED' NOT NULL,
    similarity_score NUMERIC(5, 4),
    decision VARCHAR(30) DEFAULT 'PENDING_REVIEW' NOT NULL,
    reviewed_by BIGINT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_related_parent FOREIGN KEY (parent_complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_related_target FOREIGN KEY (related_complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT fk_related_reviewer FOREIGN KEY (reviewed_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT uq_related_pair UNIQUE (parent_complaint_id, related_complaint_id),
    CONSTRAINT chk_relationship_type CHECK (relationship_type IN ('RELATED', 'DUPLICATE')),
    CONSTRAINT chk_relationship_decision CHECK (decision IN ('PENDING_REVIEW', 'LINKED', 'DUPLICATE', 'SEPARATE', 'IGNORED'))
);
