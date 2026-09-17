package com.hfcms.complaints.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hfcms.common.exception.BadRequestException;
import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.complaints.assignment.entity.AssignmentHistory;
import com.hfcms.complaints.assignment.repository.AssignmentHistoryRepository;
import com.hfcms.complaints.audit.entity.CaseStatusHistory;
import com.hfcms.complaints.audit.repository.CaseStatusHistoryRepository;
import com.hfcms.complaints.dto.*;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.investigation.entity.InvestigationChecklist;
import com.hfcms.complaints.investigation.repository.InvestigationChecklistRepository;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.notifications.service.NotificationService;
import com.hfcms.risk.dto.RiskReason;
import com.hfcms.teams.entity.Team;
import com.hfcms.teams.entity.Technician;
import com.hfcms.teams.repository.TeamRepository;
import com.hfcms.teams.repository.TechnicianRepository;
import com.hfcms.users.entity.User;
import com.hfcms.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class TeamLeadService {

    private final ComplaintRepository complaintRepository;
    private final ComplaintService complaintService;
    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final TechnicianRepository technicianRepository;
    private final AssignmentHistoryRepository assignmentHistoryRepository;
    private final CaseStatusHistoryRepository statusHistoryRepository;
    private final InvestigationChecklistRepository investigationChecklistRepository;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;

    @Transactional(readOnly = true)
    public Page<ComplaintResponse> getAtRiskQueue(Long teamId, Pageable pageable) {
        if (teamId != null) {
            return complaintRepository.findByAssignedTeamIdAndIsAtRiskTrueOrderByCreatedAtDesc(teamId, pageable)
                    .map(ComplaintMapper::toResponse);
        }
        return complaintRepository.findByIsAtRiskTrueOrStatusOrderByCreatedAtDesc(ComplaintStatus.AT_RISK, pageable)
                .map(ComplaintMapper::toResponse);
    }

    @Transactional(readOnly = true)
    public CaseContextResponse getCaseContext(Long complaintId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        Instant now = Instant.now();

        // 1. Calculate SLA metrics
        Long minutesToSlaBreach = null;
        boolean isSlaBreached = false;
        if (complaint.getSlaDeadline() != null) {
            minutesToSlaBreach = Duration.between(now, complaint.getSlaDeadline()).toMinutes();
            isSlaBreached = now.isAfter(complaint.getSlaDeadline());
        }

        // 2. Parse Risk Reasons
        List<RiskReason> riskReasons = new ArrayList<>();
        if (complaint.getRiskReasons() != null && !complaint.getRiskReasons().isBlank()) {
            try {
                riskReasons = objectMapper.readValue(complaint.getRiskReasons(), new TypeReference<List<RiskReason>>() {});
            } catch (Exception e) {
                log.warn("Could not parse risk reasons JSON for complaint {}: {}", complaint.getCaseNumber(), e.getMessage());
            }
        }

        // 3. Status History
        List<CaseStatusHistory> statusList = statusHistoryRepository.findByComplaintIdOrderByCreatedAtAsc(complaintId);
        List<ComplaintDetailResponse.StatusHistoryDto> statusDtos = statusList != null ? statusList.stream()
                .map(s -> ComplaintDetailResponse.StatusHistoryDto.builder()
                        .id(s.getId())
                        .previousStatus(s.getPreviousStatus() != null ? s.getPreviousStatus().name() : null)
                        .newStatus(s.getNewStatus().name())
                        .changedByName(s.getChangedBy() != null ? s.getChangedBy().getFullName() : "System Automation")
                        .changeReason(s.getChangeReason())
                        .createdAt(s.getCreatedAt())
                        .build())
                .toList() : List.of();

        // 4. Assignment History
        List<AssignmentHistory> assignList = assignmentHistoryRepository.findByComplaintIdOrderByCreatedAtDesc(complaintId);
        List<ComplaintDetailResponse.AssignmentHistoryDto> assignDtos = assignList != null ? assignList.stream()
                .map(a -> ComplaintDetailResponse.AssignmentHistoryDto.builder()
                        .id(a.getId())
                        .previousTechnicianName(a.getPreviousTechnician() != null && a.getPreviousTechnician().getUser() != null
                                ? a.getPreviousTechnician().getUser().getFullName() : null)
                        .newTechnicianName(a.getNewTechnician() != null && a.getNewTechnician().getUser() != null
                                ? a.getNewTechnician().getUser().getFullName() : null)
                        .previousTeamName(a.getPreviousTeam() != null ? a.getPreviousTeam().getName() : null)
                        .newTeamName(a.getNewTeam() != null ? a.getNewTeam().getName() : null)
                        .assignedByName(a.getAssignedBy() != null ? a.getAssignedBy().getFullName() : null)
                        .assignmentReason(a.getAssignmentReason())
                        .createdAt(a.getCreatedAt())
                        .build())
                .toList() : List.of();

        // 5. Checklist Items
        List<ChecklistResponse.ItemResponse> checklistItemDtos = new ArrayList<>();
        investigationChecklistRepository.findByComplaintId(complaintId).ifPresent(cl -> {
            if (cl.getItems() != null) {
                cl.getItems().forEach(item -> checklistItemDtos.add(ChecklistResponse.ItemResponse.builder()
                        .id(item.getId())
                        .itemDescription(item.getItemDescription())
                        .isCompleted(item.getIsCompleted())
                        .findings(item.getFindings())
                        .recordedByName(item.getRecordedBy() != null ? item.getRecordedBy().getFullName() : null)
                        .recordedAt(item.getRecordedAt())
                        .build()));
            }
        });

        // 6. Related Cases via Trigram Similarity
        List<Complaint> candidates = complaintRepository.findSimilarComplaintsByTrigram(
                complaint.getId(), complaint.getDescription(), 0.20, 5);
        List<ComplaintResponse> relatedDtos = candidates != null ? candidates.stream()
                .map(ComplaintMapper::toResponse)
                .toList() : List.of();

        return CaseContextResponse.builder()
                .id(complaint.getId())
                .caseNumber(complaint.getCaseNumber())
                .studentId(complaint.getStudent() != null ? complaint.getStudent().getId() : null)
                .studentName(complaint.getStudent() != null ? complaint.getStudent().getFullName() : null)
                .studentEmail(complaint.getStudent() != null ? complaint.getStudent().getEmail() : null)
                .studentPhone(complaint.getStudent() != null ? complaint.getStudent().getPhoneNumber() : null)
                .hostelName(complaint.getHostel() != null ? complaint.getHostel().getName() : null)
                .blockName(complaint.getBlock() != null ? complaint.getBlock().getName() : null)
                .roomNumber(complaint.getRoom() != null ? complaint.getRoom().getRoomNumber() : null)
                .categoryName(complaint.getCategory() != null ? complaint.getCategory().getName() : null)
                .subcategory(complaint.getSubcategory())
                .description(complaint.getDescription())
                .status(complaint.getStatus())
                .severity(complaint.getSeverity())
                .priority(complaint.getPriority())
                .assignedTeamId(complaint.getAssignedTeam() != null ? complaint.getAssignedTeam().getId() : null)
                .assignedTeamName(complaint.getAssignedTeam() != null ? complaint.getAssignedTeam().getName() : null)
                .assignedTechnicianId(complaint.getAssignedTechnician() != null ? complaint.getAssignedTechnician().getId() : null)
                .assignedTechnicianName(complaint.getAssignedTechnician() != null && complaint.getAssignedTechnician().getUser() != null
                        ? complaint.getAssignedTechnician().getUser().getFullName() : null)
                .aiSummary(complaint.getAiSummary())
                .slaDeadline(complaint.getSlaDeadline())
                .isAtRisk(complaint.getIsAtRisk())
                .riskReasons(riskReasons)
                .minutesToSlaBreach(minutesToSlaBreach)
                .isSlaBreached(isSlaBreached)
                .statusHistory(statusDtos)
                .assignmentHistory(assignDtos)
                .checklistItems(checklistItemDtos)
                .relatedCases(relatedDtos)
                .build();
    }

    @Transactional
    public ComplaintResponse intervene(Long complaintId, InterventionRequest request, Long teamLeadUserId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User teamLead = userRepository.findById(teamLeadUserId)
                .orElseThrow(() -> new ResourceNotFoundException("Team Lead user not found with ID: " + teamLeadUserId));

        if (request.getActionType() == null) {
            throw new BadRequestException("Intervention action type is required");
        }

        ComplaintStatus previousStatus = complaint.getStatus();
        Technician previousTech = complaint.getAssignedTechnician();
        Team previousTeam = complaint.getAssignedTeam();

        switch (request.getActionType()) {
            case REASSIGN_TECHNICIAN -> {
                if (request.getNewTechnicianId() == null) {
                    throw new BadRequestException("New technician ID is required for REASSIGN_TECHNICIAN");
                }
                Technician newTech = technicianRepository.findById(request.getNewTechnicianId())
                        .orElseThrow(() -> new ResourceNotFoundException("Technician not found: " + request.getNewTechnicianId()));

                complaint.setAssignedTechnician(newTech);

                AssignmentHistory history = AssignmentHistory.builder()
                        .complaint(complaint)
                        .previousTeam(previousTeam)
                        .newTeam(complaint.getAssignedTeam())
                        .previousTechnician(previousTech)
                        .newTechnician(newTech)
                        .assignedBy(teamLead)
                        .assignmentReason("Team Lead Intervention (Reassignment): " + request.getReason())
                        .build();
                assignmentHistoryRepository.save(history);

                log.info("[INTERVENTION] Reassigned complaint {} from tech {} to tech {}",
                        complaint.getCaseNumber(),
                        previousTech != null ? previousTech.getId() : "none",
                        newTech.getId());
            }
            case REASSIGN_TEAM -> {
                if (request.getNewTeamId() == null) {
                    throw new BadRequestException("New team ID is required for REASSIGN_TEAM");
                }
                Team newTeam = teamRepository.findById(request.getNewTeamId())
                        .orElseThrow(() -> new ResourceNotFoundException("Team not found: " + request.getNewTeamId()));

                complaint.setAssignedTeam(newTeam);
                complaint.setAssignedTechnician(null);

                AssignmentHistory history = AssignmentHistory.builder()
                        .complaint(complaint)
                        .previousTeam(previousTeam)
                        .newTeam(newTeam)
                        .previousTechnician(previousTech)
                        .newTechnician(null)
                        .assignedBy(teamLead)
                        .assignmentReason("Team Lead Intervention (Team Transfer): " + request.getReason())
                        .build();
                assignmentHistoryRepository.save(history);
            }
            case ESCALATE_PRIORITY -> {
                if (request.getNewPriority() == null) {
                    throw new BadRequestException("New priority is required for ESCALATE_PRIORITY");
                }
                complaint.setPriority(request.getNewPriority());
                log.info("[INTERVENTION] Escalated priority of complaint {} to {}", complaint.getCaseNumber(), request.getNewPriority());
            }
            case EXTEND_SLA -> {
                if (request.getExtendedSlaHours() == null || request.getExtendedSlaHours() <= 0) {
                    throw new BadRequestException("Valid extended SLA hours required for EXTEND_SLA");
                }
                Instant base = complaint.getSlaDeadline() != null && complaint.getSlaDeadline().isAfter(Instant.now())
                        ? complaint.getSlaDeadline()
                        : Instant.now();
                complaint.setSlaDeadline(base.plus(Duration.ofHours(request.getExtendedSlaHours())));
                log.info("[INTERVENTION] Extended SLA of complaint {} by {} hours", complaint.getCaseNumber(), request.getExtendedSlaHours());
            }
            case FORCE_STATUS_CHANGE, ADD_INSTRUCTIONS -> {
                log.info("[INTERVENTION] Applied directive for complaint {}: {}", complaint.getCaseNumber(), request.getReason());
            }
        }

        // If the case was AT_RISK, transition it back to ACTIVE under intervention supervision
        if (complaint.getStatus() == ComplaintStatus.AT_RISK) {
            complaint.setStatus(ComplaintStatus.ACTIVE);
            complaint.setIsAtRisk(false);
        }

        // Record in Case Status History audit
        CaseStatusHistory statusHistory = CaseStatusHistory.builder()
                .complaint(complaint)
                .previousStatus(previousStatus)
                .newStatus(complaint.getStatus())
                .changedBy(teamLead)
                .changeReason("Team Lead Intervention [" + request.getActionType() + "]: " + request.getReason())
                .build();
        statusHistoryRepository.save(statusHistory);

        Complaint saved = complaintRepository.save(complaint);

        // Notify Student and Technician of the intervention
        try {
            if (saved.getStudent() != null) {
                notificationService.sendNotification(
                        saved.getStudent().getId(),
                        "Case Escalation Update: " + saved.getCaseNumber(),
                        "Team Lead intervention applied (" + request.getActionType() + "): " + request.getReason(),
                        "STATUS_CHANGED",
                        saved.getCaseNumber(),
                        true
                );
            }
            if (saved.getAssignedTechnician() != null && saved.getAssignedTechnician().getUser() != null) {
                notificationService.sendNotification(
                        saved.getAssignedTechnician().getUser().getId(),
                        "Team Lead Directive: " + saved.getCaseNumber(),
                        "Intervention directive applied: " + request.getReason(),
                        "ASSIGNED",
                        saved.getCaseNumber(),
                        false
                );
            }
        } catch (Exception ex) {
            log.debug("Non-blocking notification error on intervention: {}", ex.getMessage());
        }

        return ComplaintMapper.toResponse(saved);
    }
}
