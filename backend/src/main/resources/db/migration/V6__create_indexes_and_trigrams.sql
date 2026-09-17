-- ==============================================================================
-- Flyway Migration V6: Operational Indexes & Trigram Similarity Index
-- ==============================================================================

-- GIN Trigram Index for Full-Text and Substring Similarity Search on Complaints
-- Powers duplicate/related case discovery
CREATE INDEX IF NOT EXISTS idx_complaints_description_trgm 
ON complaints USING gin (description gin_trgm_ops);

-- Core Operational Indexes for High-Frequency Filters
CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints (status);
CREATE INDEX IF NOT EXISTS idx_complaints_student_id ON complaints (student_id);
CREATE INDEX IF NOT EXISTS idx_complaints_assigned_team_id ON complaints (assigned_team_id);
CREATE INDEX IF NOT EXISTS idx_complaints_assigned_technician_id ON complaints (assigned_technician_id);
CREATE INDEX IF NOT EXISTS idx_complaints_created_at ON complaints (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_complaints_is_at_risk ON complaints (is_at_risk) WHERE is_at_risk = TRUE;
CREATE INDEX IF NOT EXISTS idx_complaints_sla_deadline ON complaints (sla_deadline);
CREATE INDEX IF NOT EXISTS idx_complaints_location ON complaints (hostel_id, block_id, room_id);

-- Composite Index for Location and Analytics
CREATE INDEX IF NOT EXISTS idx_complaints_hostel_block_cat ON complaints (hostel_id, block_id, category_id, created_at);

-- Notification Index for User Unread Counter
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications (user_id, is_read);

-- Audit History Indexes
CREATE INDEX IF NOT EXISTS idx_case_history_complaint ON case_status_history (complaint_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_assignment_history_complaint ON assignment_history (complaint_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_log_complaint ON ai_analysis_log (complaint_id, created_at DESC);
