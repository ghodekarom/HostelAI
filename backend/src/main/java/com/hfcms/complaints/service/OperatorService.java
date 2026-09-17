package com.hfcms.complaints.service;

import com.hfcms.categories.entity.Category;
import com.hfcms.categories.repository.CategoryRepository;
import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.complaints.assignment.entity.AssignmentHistory;
import com.hfcms.complaints.assignment.repository.AssignmentHistoryRepository;
import com.hfcms.complaints.dto.*;
import com.hfcms.complaints.entity.*;
import com.hfcms.complaints.investigation.entity.ChecklistItem;
import com.hfcms.complaints.investigation.entity.ChecklistStatus;
import com.hfcms.complaints.investigation.entity.InvestigationChecklist;
import com.hfcms.complaints.investigation.repository.InvestigationChecklistRepository;
import com.hfcms.complaints.repository.ComplaintRelatedCaseRepository;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.teams.entity.Team;
import com.hfcms.teams.entity.Technician;
import com.hfcms.teams.repository.TeamRepository;
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

import java.time.Duration;
import java.time.Instant;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OperatorService {

    private static final Logger logger = LoggerFactory.getLogger(OperatorService.class);

    private final ComplaintRepository complaintRepository;
    private final ComplaintService complaintService;
    private final ComplaintRelatedCaseRepository relatedCaseRepository;
    private final AssignmentHistoryRepository assignmentHistoryRepository;
    private final InvestigationChecklistRepository checklistRepository;
    private final TeamRepository teamRepository;
    private final TechnicianRepository technicianRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public Page<ComplaintResponse> getOperatorQueue(Collection<ComplaintStatus> statuses, Pageable pageable) {
        if (statuses == null || statuses.isEmpty()) {
            statuses = Arrays.asList(
                    ComplaintStatus.REPORTED,
                    ComplaintStatus.UNDERSTOOD,
                    ComplaintStatus.RELATED_CASES_CHECKED,
                    ComplaintStatus.OPERATOR_REVIEW,
                    ComplaintStatus.WAITING_FOR_INFORMATION,
                    ComplaintStatus.ACTIVE,
                    ComplaintStatus.AT_RISK
            );
        }
        return complaintRepository.findByStatusInOrderByCreatedAtDesc(statuses, pageable)
                .map(ComplaintMapper::toResponse);
    }

    @Transactional
    public ComplaintResponse reviewComplaint(Long complaintId, ReviewComplaintRequest request, Long operatorId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User operator = userRepository.findById(operatorId)
                .orElseThrow(() -> new ResourceNotFoundException("Operator not found with ID: " + operatorId));

        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + request.getCategoryId()));
            complaint.setCategory(category);
        }

        if (request.getSubcategory() != null) {
            complaint.setSubcategory(request.getSubcategory());
        }

        if (request.getSeverity() != null) {
            complaint.setSeverity(request.getSeverity());
        }

        if (request.getPriority() != null) {
            complaint.setPriority(request.getPriority());

            // Recalculate SLA based on updated priority
            int slaHours = switch (request.getPriority()) {
                case P1 -> complaint.getCategory().getSlaHoursP1();
                case P2 -> complaint.getCategory().getSlaHoursP2();
                case P3 -> complaint.getCategory().getSlaHoursP3();
                case P4 -> complaint.getCategory().getSlaHoursP4();
            };
            complaint.setSlaDeadline(Instant.now().plus(Duration.ofHours(slaHours)));
        }

        if (request.getAssignedTeamId() != null) {
            Team team = teamRepository.findById(request.getAssignedTeamId())
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found: " + request.getAssignedTeamId()));
            complaint.setAssignedTeam(team);
        }

        String notes = request.getReviewNotes() != null ? request.getReviewNotes() : "Operator completed triage review";
        complaintService.recordStatusTransition(complaint, ComplaintStatus.OPERATOR_REVIEW, operator, notes);

        return ComplaintMapper.toResponse(complaint);
    }

    @Transactional(readOnly = true)
    public List<ComplaintResponse> getRelatedCases(Long complaintId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        // Trigram similarity threshold 0.20
        List<Complaint> candidates = complaintRepository.findSimilarComplaintsByTrigram(
                complaint.getId(), complaint.getDescription(), 0.20, 10);

        return candidates.stream().map(ComplaintMapper::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public void decideRelatedCase(Long complaintId, Long relatedId, RelatedCaseDecisionRequest request, Long operatorId) {
        Complaint parent = complaintService.getComplaintEntity(complaintId);
        Complaint related = complaintService.getComplaintEntity(relatedId);
        User operator = userRepository.findById(operatorId)
                .orElseThrow(() -> new ResourceNotFoundException("Operator not found with ID: " + operatorId));

        ComplaintRelatedCase link = relatedCaseRepository
                .findByParentComplaintIdAndRelatedComplaintId(complaintId, relatedId)
                .orElse(ComplaintRelatedCase.builder()
                        .parentComplaint(parent)
                        .relatedComplaint(related)
                        .relationshipType(RelationshipType.RELATED)
                        .build());

        link.setDecision(request.getDecision());
        link.setReviewedBy(operator);
        link.setNotes(request.getNotes());
        link.setReviewedAt(Instant.now());

        relatedCaseRepository.save(link);
        logger.info("Operator {} recorded decision {} for related cases ({} <-> {})",
                operatorId, request.getDecision(), parent.getCaseNumber(), related.getCaseNumber());
    }

    @Transactional
    public ComplaintResponse assignComplaint(Long complaintId, AssignComplaintRequest request, Long operatorId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User operator = userRepository.findById(operatorId)
                .orElseThrow(() -> new ResourceNotFoundException("Operator not found with ID: " + operatorId));

        Team team = teamRepository.findById(request.getTeamId())
                .orElseThrow(() -> new ResourceNotFoundException("Team not found: " + request.getTeamId()));

        Technician previousTechnician = complaint.getAssignedTechnician();
        Team previousTeam = complaint.getAssignedTeam();

        Technician newTechnician = null;
        if (request.getTechnicianId() != null) {
            newTechnician = technicianRepository.findById(request.getTechnicianId())
                    .orElseThrow(() -> new ResourceNotFoundException("Technician not found: " + request.getTechnicianId()));
            newTechnician.setActiveTasksCount(newTechnician.getActiveTasksCount() + 1);
            technicianRepository.save(newTechnician);
        }

        complaint.setAssignedTeam(team);
        complaint.setAssignedTechnician(newTechnician);

        // Record in assignment history
        AssignmentHistory history = AssignmentHistory.builder()
                .complaint(complaint)
                .previousTeam(previousTeam)
                .newTeam(team)
                .previousTechnician(previousTechnician)
                .newTechnician(newTechnician)
                .assignedBy(operator)
                .assignmentReason(request.getAssignmentReason() != null ? request.getAssignmentReason() : "Assigned by operator")
                .build();
        assignmentHistoryRepository.save(history);

        // Initialize investigation checklist if not already present
        if (checklistRepository.findByComplaintId(complaintId).isEmpty()) {
            InvestigationChecklist checklist = InvestigationChecklist.builder()
                    .complaint(complaint)
                    .category(complaint.getCategory())
                    .isAiGenerated(false)
                    .status(ChecklistStatus.PENDING)
                    .build();

            // Add standard diagnostic items based on complaint category
            ChecklistItem item1 = ChecklistItem.builder()
                    .checklist(checklist)
                    .itemDescription("Verify physical location and inspect reported fixture/equipment")
                    .isCompleted(false)
                    .build();
            ChecklistItem item2 = ChecklistItem.builder()
                    .checklist(checklist)
                    .itemDescription("Diagnose root cause and test supply lines / electrical / hardware connectivity")
                    .isCompleted(false)
                    .build();
            checklist.getItems().add(item1);
            checklist.getItems().add(item2);

            checklistRepository.save(checklist);
        }

        complaintService.recordStatusTransition(complaint, ComplaintStatus.ASSIGNED, operator, "Complaint assigned to team " + team.getName());
        return ComplaintMapper.toResponse(complaint);
    }
}
