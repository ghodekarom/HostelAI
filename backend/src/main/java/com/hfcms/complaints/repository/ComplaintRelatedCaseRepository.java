package com.hfcms.complaints.repository;

import com.hfcms.complaints.entity.ComplaintRelatedCase;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ComplaintRelatedCaseRepository extends JpaRepository<ComplaintRelatedCase, Long> {
    List<ComplaintRelatedCase> findByParentComplaintId(Long parentComplaintId);
    Optional<ComplaintRelatedCase> findByParentComplaintIdAndRelatedComplaintId(Long parentComplaintId, Long relatedComplaintId);
}
