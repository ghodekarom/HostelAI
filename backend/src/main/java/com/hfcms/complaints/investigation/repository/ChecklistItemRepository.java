package com.hfcms.complaints.investigation.repository;

import com.hfcms.complaints.investigation.entity.ChecklistItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChecklistItemRepository extends JpaRepository<ChecklistItem, Long> {
    List<ChecklistItem> findByChecklistId(Long checklistId);
}
