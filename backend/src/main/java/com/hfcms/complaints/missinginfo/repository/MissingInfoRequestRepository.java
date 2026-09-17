package com.hfcms.complaints.missinginfo.repository;

import com.hfcms.complaints.missinginfo.entity.MissingInfoRequest;
import com.hfcms.complaints.missinginfo.entity.MissingInfoStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MissingInfoRequestRepository extends JpaRepository<MissingInfoRequest, Long> {
    List<MissingInfoRequest> findByComplaintIdOrderByRequestedAtDesc(Long complaintId);
    Optional<MissingInfoRequest> findFirstByComplaintIdAndStatusOrderByRequestedAtDesc(Long complaintId, MissingInfoStatus status);
}
