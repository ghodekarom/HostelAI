package com.hfcms.ai.service;

import com.hfcms.ai.client.AiClient;
import com.hfcms.ai.client.anthropic.AnthropicAiClient;
import com.hfcms.ai.client.gemini.GeminiAiClient;
import com.hfcms.ai.client.mock.RuleBasedMockAiClient;
import com.hfcms.ai.dto.ComplaintAnalysisResult;
import com.hfcms.ai.entity.AiAnalysisLog;
import com.hfcms.ai.entity.AiLogStatus;
import com.hfcms.ai.repository.AiAnalysisLogRepository;
import com.hfcms.categories.entity.Category;
import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.complaints.audit.entity.CaseStatusHistory;
import com.hfcms.complaints.audit.repository.CaseStatusHistoryRepository;
import com.hfcms.complaints.dto.ComplaintMapper;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.entity.*;
import com.hfcms.complaints.investigation.entity.ChecklistItem;
import com.hfcms.complaints.investigation.entity.ChecklistStatus;
import com.hfcms.complaints.investigation.entity.InvestigationChecklist;
import com.hfcms.complaints.investigation.repository.ChecklistItemRepository;
import com.hfcms.complaints.investigation.repository.InvestigationChecklistRepository;
import com.hfcms.complaints.repository.ComplaintRelatedCaseRepository;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.teams.entity.Team;
import com.hfcms.teams.repository.TeamRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiComplaintService {

    private final ComplaintRepository complaintRepository;
    private final ComplaintRelatedCaseRepository complaintRelatedCaseRepository;
    private final InvestigationChecklistRepository investigationChecklistRepository;
    private final ChecklistItemRepository checklistItemRepository;
    private final CaseStatusHistoryRepository caseStatusHistoryRepository;
    private final AiAnalysisLogRepository aiAnalysisLogRepository;
    private final TeamRepository teamRepository;

    private final GeminiAiClient geminiAiClient;
    private final AnthropicAiClient anthropicAiClient;
    private final RuleBasedMockAiClient ruleBasedMockAiClient;

    @Value("${app.ai.provider:gemini}")
    private String configuredProvider;

    @Value("${app.ai.mock-enabled:true}")
    private boolean mockEnabled;

    @Transactional
    public ComplaintResponse processComplaint(Long complaintId) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResourceNotFoundException("Complaint not found with ID: " + complaintId));

        AiClient client = selectAiClient();
        log.info("Processing complaint {} using AI client: {}", complaint.getCaseNumber(), client.getModelName());

        long startTime = System.currentTimeMillis();
        ComplaintAnalysisResult result;
        AiLogStatus logStatus;
        String errorMessage = null;

        try {
            result = client.analyzeComplaint(complaint);
            logStatus = (client instanceof RuleBasedMockAiClient) ? AiLogStatus.SKIPPED_MOCK : AiLogStatus.SUCCESS;
        } catch (Exception ex) {
            log.warn("AI client {} failed on complaint {}: {}. Falling back to Rule-Based Engine.",
                    client.getModelName(), complaint.getCaseNumber(), ex.getMessage());
            errorMessage = ex.getMessage();
            result = ruleBasedMockAiClient.analyzeComplaint(complaint);
            logStatus = AiLogStatus.SKIPPED_MOCK;
        }

        long latency = System.currentTimeMillis() - startTime;

        // 1. Audit Log in ai_analysis_log
        try {
            AiAnalysisLog analysisLog = AiAnalysisLog.builder()
                    .complaint(complaint)
                    .actionType("COMPLAINT_TRIAGE")
                    .modelName(client.getModelName())
                    .rawPrompt(String.format("Complaint #%s: %s", complaint.getCaseNumber(), complaint.getDescription()))
                    .rawResponse(result.getAiSummary())
                    .latencyMs(latency)
                    .status(logStatus)
                    .errorMessage(errorMessage)
                    .build();
            aiAnalysisLogRepository.save(analysisLog);
        } catch (Exception ex) {
            log.error("Failed to save AI analysis log: {}", ex.getMessage());
        }

        // 2. Update AI metadata, suggested severity, priority & team
        complaint.setAiStatus(AiStatus.COMPLETED);
        complaint.setAiSummary(result.getAiSummary());
        if (complaint.getSubcategory() == null || complaint.getSubcategory().isBlank()) {
            complaint.setSubcategory(result.getSubcategory());
        }
        complaint.setSeverity(result.getSeverity());
        complaint.setPriority(result.getPriority());

        // Suggest team if not assigned yet
        if (complaint.getAssignedTeam() == null && result.getSuggestedTeamName() != null) {
            Optional<Team> teamOpt = teamRepository.findByName(result.getSuggestedTeamName());
            if (teamOpt.isPresent()) {
                complaint.setAssignedTeam(teamOpt.get());
            } else {
                teamRepository.findAll().stream().findFirst().ifPresent(complaint::setAssignedTeam);
            }
        }

        // Recalculate SLA deadline based on updated priority
        Category category = complaint.getCategory();
        if (category != null) {
            int slaHours = switch (result.getPriority()) {
                case P1 -> category.getSlaHoursP1();
                case P2 -> category.getSlaHoursP2();
                case P3 -> category.getSlaHoursP3();
                case P4 -> category.getSlaHoursP4();
            };
            Instant baseTime = complaint.getCreatedAt() != null ? complaint.getCreatedAt() : Instant.now();
            complaint.setSlaDeadline(baseTime.plus(Duration.ofHours(slaHours)));
        }

        // Transition: REPORTED -> UNDERSTOOD
        recordStatusHistory(complaint, ComplaintStatus.UNDERSTOOD, "AI Case Understanding completed");

        // 3. Duplicate & Related Cases Detection via pg_trgm similarity
        try {
            List<Complaint> similarComplaints = complaintRepository.findSimilarComplaintsByTrigram(
                    complaint.getId(),
                    complaint.getDescription(),
                    0.3,
                    5
            );

            for (Complaint similar : similarComplaints) {
                if (complaintRelatedCaseRepository.findByParentComplaintIdAndRelatedComplaintId(complaint.getId(), similar.getId()).isEmpty()) {
                    RelationshipType relType = RelationshipType.RELATED;
                    ComplaintRelatedCase relatedCase = ComplaintRelatedCase.builder()
                            .parentComplaint(complaint)
                            .relatedComplaint(similar)
                            .relationshipType(relType)
                            .similarityScore(BigDecimal.valueOf(0.6500))
                            .decision(RelationshipDecision.PENDING_REVIEW)
                            .notes("Identified by trigram similarity query")
                            .build();
                    complaintRelatedCaseRepository.save(relatedCase);
                }
            }
        } catch (Exception ex) {
            log.warn("Trigram similarity search on complaint {} skipped: {}", complaint.getId(), ex.getMessage());
        }

        // Transition: UNDERSTOOD -> RELATED_CASES_CHECKED
        recordStatusHistory(complaint, ComplaintStatus.RELATED_CASES_CHECKED, "Duplicate and related cases checked");

        // 4. Investigation Checklist Generation
        if (investigationChecklistRepository.findByComplaintId(complaint.getId()).isEmpty() && category != null) {
            InvestigationChecklist checklist = InvestigationChecklist.builder()
                    .complaint(complaint)
                    .category(category)
                    .isAiGenerated(true)
                    .status(ChecklistStatus.PENDING)
                    .build();
            InvestigationChecklist savedChecklist = investigationChecklistRepository.save(checklist);

            List<String> items = result.getDiagnosticChecklist();
            if (items != null && !items.isEmpty()) {
                for (String desc : items) {
                    ChecklistItem item = ChecklistItem.builder()
                            .checklist(savedChecklist)
                            .itemDescription(desc)
                            .isCompleted(false)
                            .build();
                    checklistItemRepository.save(item);
                }
            }
        }

        // Transition: RELATED_CASES_CHECKED -> OPERATOR_REVIEW
        recordStatusHistory(complaint, ComplaintStatus.OPERATOR_REVIEW, "Case ready for maintenance operator triage");

        Complaint saved = complaintRepository.save(complaint);
        log.info("Complaint {} successfully triaged by AI to status {}", saved.getCaseNumber(), saved.getStatus());
        return ComplaintMapper.toResponse(saved);
    }

    private AiClient selectAiClient() {
        if (mockEnabled) {
            return ruleBasedMockAiClient;
        }

        if ("gemini".equalsIgnoreCase(configuredProvider) && geminiAiClient.isConfigured()) {
            return geminiAiClient;
        }

        if ("anthropic".equalsIgnoreCase(configuredProvider) && anthropicAiClient.isConfigured()) {
            return anthropicAiClient;
        }

        return ruleBasedMockAiClient;
    }

    private void recordStatusHistory(Complaint complaint, ComplaintStatus newStatus, String reason) {
        ComplaintStatus previousStatus = complaint.getStatus();
        complaint.setStatus(newStatus);

        CaseStatusHistory history = CaseStatusHistory.builder()
                .complaint(complaint)
                .previousStatus(previousStatus)
                .newStatus(newStatus)
                .changedBy(null) // Automated System Actor
                .changeReason(reason)
                .build();
        caseStatusHistoryRepository.save(history);
    }
}
