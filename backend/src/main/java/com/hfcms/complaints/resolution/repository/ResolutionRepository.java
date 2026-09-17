package com.hfcms.complaints.resolution.repository;

import com.hfcms.complaints.resolution.entity.Resolution;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ResolutionRepository extends JpaRepository<Resolution, Long> {
    Optional<Resolution> findByComplaintId(Long complaintId);
}
