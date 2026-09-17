package com.hfcms.complaints.repository;

import com.hfcms.complaints.entity.ComplaintEvidence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComplaintEvidenceRepository extends JpaRepository<ComplaintEvidence, Long> {
    List<ComplaintEvidence> findByComplaintIdOrderByCreatedAtAsc(Long complaintId);
}
