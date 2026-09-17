package com.hfcms.complaints.service;

import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.complaints.dto.ComplaintMapper;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.dto.RecordFindingRequest;
import com.hfcms.complaints.dto.RecordRepairActionRequest;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.EvidenceStage;
import com.hfcms.complaints.investigation.entity.ChecklistItem;
import com.hfcms.complaints.investigation.entity.ChecklistStatus;
import com.hfcms.complaints.investigation.entity.InvestigationChecklist;
import com.hfcms.complaints.investigation.repository.ChecklistItemRepository;
import com.hfcms.complaints.investigation.repository.InvestigationChecklistRepository;
import com.hfcms.complaints.repairaction.entity.RepairAction;
import com.hfcms.complaints.repairaction.repository.RepairActionRepository;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.teams.entity.Technician;
import com.hfcms.teams.repository.TechnicianRepository;
import com.hfcms.users.entity.User;
import com.hfcms.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TechnicianService {

    private static final Logger logger = LoggerFactory.getLogger(TechnicianService.class);

    private final ComplaintRepository complaintRepository;
    private final ComplaintService complaintService;
    private final InvestigationChecklistRepository checklistRepository;
    private final ChecklistItemRepository checklistItemRepository;
    private final RepairActionRepository repairActionRepository;
    private final TechnicianRepository technicianRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public Page<ComplaintResponse> getAssignedTasks(Long technicianId, Pageable pageable) {
        return complaintRepository.findByAssignedTechnicianIdOrderByCreatedAtDesc(technicianId, pageable)
                .map(ComplaintMapper::toResponse);
    }

    @Transactional(readOnly = true)
    public com.hfcms.complaints.dto.ChecklistResponse getChecklistForComplaint(Long complaintId) {
        InvestigationChecklist checklist = checklistRepository.findByComplaintId(complaintId)
                .orElseThrow(() -> new ResourceNotFoundException("No checklist found for complaint: " + complaintId));
        return mapToChecklistResponse(checklist);
    }

    private com.hfcms.complaints.dto.ChecklistResponse mapToChecklistResponse(InvestigationChecklist c) {
        java.util.List<com.hfcms.complaints.dto.ChecklistResponse.ItemResponse> items = c.getItems() != null ? c.getItems().stream()
                .map(item -> com.hfcms.complaints.dto.ChecklistResponse.ItemResponse.builder()
                        .id(item.getId())
                        .itemDescription(item.getItemDescription())
                        .isCompleted(item.getIsCompleted())
                        .findings(item.getFindings())
                        .recordedById(item.getRecordedBy() != null ? item.getRecordedBy().getId() : null)
                        .recordedByName(item.getRecordedBy() != null ? item.getRecordedBy().getFullName() : null)
                        .recordedAt(item.getRecordedAt())
                        .build())
                .toList() : java.util.List.of();

        return com.hfcms.complaints.dto.ChecklistResponse.builder()
                .id(c.getId())
                .complaintId(c.getComplaint().getId())
                .categoryId(c.getCategory().getId())
                .categoryName(c.getCategory().getName())
                .isAiGenerated(c.getIsAiGenerated())
                .status(c.getStatus())
                .items(items)
                .createdAt(c.getCreatedAt())
                .completedAt(c.getCompletedAt())
                .build();
    }

    @Transactional
    public void recordFinding(Long complaintId, Long itemId, RecordFindingRequest request, Long technicianUserId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User technicianUser = userRepository.findById(technicianUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + technicianUserId));

        ChecklistItem item = checklistItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("Checklist item not found: " + itemId));

        item.setIsCompleted(true);
        item.setFindings(request.getFindings());
        item.setRecordedBy(technicianUser);
        item.setRecordedAt(Instant.now());
        checklistItemRepository.save(item);

        InvestigationChecklist checklist = item.getChecklist();
        checklist.setStatus(ChecklistStatus.IN_PROGRESS);

        // Transition complaint status to INVESTIGATED
        complaintService.recordStatusTransition(
                complaint,
                ComplaintStatus.INVESTIGATED,
                technicianUser,
                "Checklist item completed with findings: " + request.getFindings()
        );

        logger.info("Recorded investigation finding on item ID: {}", itemId);
    }

    @Transactional
    public void recordRepairAction(Long complaintId, RecordRepairActionRequest request, Long technicianUserId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User technicianUser = userRepository.findById(technicianUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + technicianUserId));

        Technician technician = technicianRepository.findById(request.getTechnicianId())
                .orElseThrow(() -> new ResourceNotFoundException("Technician not found: " + request.getTechnicianId()));

        RepairAction action = RepairAction.builder()
                .complaint(complaint)
                .technician(technician)
                .actionTaken(request.getActionTaken())
                .evidenceUrl(request.getEvidenceUrl())
                .partsReplaced(request.getPartsReplaced())
                .build();
        repairActionRepository.save(action);

        // Attach evidence if provided
        if (request.getEvidenceUrl() != null && !request.getEvidenceUrl().trim().isEmpty()) {
            complaintService.addEvidence(
                    complaintId,
                    technicianUserId,
                    request.getEvidenceUrl(),
                    "image/jpeg",
                    null,
                    EvidenceStage.REPAIR
            );
        }

        // Transition complaint status to ACTION_TAKEN
        complaintService.recordStatusTransition(
                complaint,
                ComplaintStatus.ACTION_TAKEN,
                technicianUser,
                "Repair action executed: " + request.getActionTaken()
        );

        logger.info("Logged repair action on complaint ID: {}", complaintId);
    }
}
