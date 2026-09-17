package com.hfcms.ai.repository;

import com.hfcms.ai.entity.AiAnalysisLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AiAnalysisLogRepository extends JpaRepository<AiAnalysisLog, Long> {
    List<AiAnalysisLog> findByComplaintIdOrderByCreatedAtDesc(Long complaintId);
}
