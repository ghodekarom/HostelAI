package com.hfcms.complaints.assignment.repository;

import com.hfcms.complaints.assignment.entity.AssignmentHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AssignmentHistoryRepository extends JpaRepository<AssignmentHistory, Long> {
    List<AssignmentHistory> findByComplaintIdOrderByCreatedAtDesc(Long complaintId);
}
