-- ==============================================================================
-- Flyway Migration V5: Notifications and AI Analysis Logs Tables
-- ==============================================================================

-- Notifications Table (In-App notifications for all roles)
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    reference_id VARCHAR(100),
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- AI Analysis Log Table (Audits all AI inference calls, latencies, and responses)
CREATE TABLE IF NOT EXISTS ai_analysis_log (
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT,
    action_type VARCHAR(100) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    raw_prompt TEXT,
    raw_response TEXT,
    latency_ms BIGINT,
    status VARCHAR(30) DEFAULT 'SUCCESS' NOT NULL,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_ai_log_complaint FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE SET NULL,
    CONSTRAINT chk_ai_log_status CHECK (status IN ('SUCCESS', 'FAILED', 'TIMEOUT', 'SKIPPED_MOCK'))
);
