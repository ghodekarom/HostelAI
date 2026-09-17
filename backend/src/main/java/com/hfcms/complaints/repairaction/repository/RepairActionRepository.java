package com.hfcms.complaints.repairaction.repository;

import com.hfcms.complaints.repairaction.entity.RepairAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RepairActionRepository extends JpaRepository<RepairAction, Long> {
    List<RepairAction> findByComplaintIdOrderByCreatedAtDesc(Long complaintId);
}
