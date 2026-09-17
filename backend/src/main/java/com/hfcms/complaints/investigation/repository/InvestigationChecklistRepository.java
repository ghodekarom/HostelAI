package com.hfcms.complaints.investigation.repository;

import com.hfcms.complaints.investigation.entity.InvestigationChecklist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface InvestigationChecklistRepository extends JpaRepository<InvestigationChecklist, Long> {
    Optional<InvestigationChecklist> findByComplaintId(Long complaintId);
}
