package com.hfcms.complaints.repository;

import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.Priority;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, Long> {

    Optional<Complaint> findByCaseNumber(String caseNumber);

    Page<Complaint> findByStudentIdOrderByCreatedAtDesc(Long studentId, Pageable pageable);

    Page<Complaint> findByStatusInOrderByCreatedAtDesc(Collection<ComplaintStatus> statuses, Pageable pageable);

    Page<Complaint> findByAssignedTechnicianIdOrderByCreatedAtDesc(Long technicianId, Pageable pageable);

    Page<Complaint> findByAssignedTeamIdOrderByCreatedAtDesc(Long teamId, Pageable pageable);

    List<Complaint> findByIsAtRiskTrueOrderByCreatedAtDesc();

    // Native query using PostgreSQL pg_trgm similarity search on description
    @Query(value = "SELECT * FROM complaints c " +
                   "WHERE c.id != :complaintId " +
                   "AND similarity(c.description, :description) > :threshold " +
                   "ORDER BY similarity(c.description, :description) DESC " +
                   "LIMIT :limitCount", nativeQuery = true)
    List<Complaint> findSimilarComplaintsByTrigram(
            @Param("complaintId") Long complaintId,
            @Param("description") String description,
            @Param("threshold") double threshold,
            @Param("limitCount") int limitCount);
}
