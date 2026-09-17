package com.hfcms.complaints.audit.repository;

import com.hfcms.complaints.audit.entity.CaseStatusHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CaseStatusHistoryRepository extends JpaRepository<CaseStatusHistory, Long> {
    List<CaseStatusHistory> findByComplaintIdOrderByCreatedAtAsc(Long complaintId);
}
