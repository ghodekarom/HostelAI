package com.hfcms.risk.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hfcms.complaints.audit.entity.CaseStatusHistory;
import com.hfcms.complaints.audit.repository.CaseStatusHistoryRepository;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.notifications.service.NotificationService;
import com.hfcms.risk.dto.RiskEvaluationResult;
import com.hfcms.risk.dto.RiskReason;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RiskEvaluationService {

    private final ComplaintRepository complaintRepository;
    private final CaseStatusHistoryRepository statusHistoryRepository;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;

    @Value("${app.risk.inactivity-hours:24}")
    private long inactivityHours;

    @Value("${app.risk.imminent-sla-hours:4}")
    private long imminentSlaHours;

    public RiskEvaluationResult evaluateComplaint(Complaint complaint) {
        List<RiskReason> reasons = new ArrayList<>();
        int score = 0;
        Instant now = Instant.now();

        // 1. Vector: SLA Proximity & Breach Detection
        if (complaint.getSlaDeadline() != null) {
            if (now.isAfter(complaint.getSlaDeadline())) {
                score += 40;
                reasons.add(RiskReason.builder()
                        .code("SLA_BREACHED")
                        .severity("CRITICAL")
                        .message("SLA target deadline has passed without resolution.")
                        .detectedAt(now)
                        .build());
            } else if (now.plus(Duration.ofHours(imminentSlaHours)).isAfter(complaint.getSlaDeadline())) {
                score += 25;
                reasons.add(RiskReason.builder()
                        .code("SLA_IMMINENT")
                        .severity("HIGH")
                        .message("SLA target deadline is within " + imminentSlaHours + " hours of breach.")
                        .detectedAt(now)
                        .build());
            }
        }

        // 2. Vector: Operational Inactivity Detection
        Instant lastActivity = complaint.getUpdatedAt() != null ? complaint.getUpdatedAt() : complaint.getCreatedAt();
        if (lastActivity != null && now.minus(Duration.ofHours(inactivityHours)).isAfter(lastActivity)) {
            ComplaintStatus st = complaint.getStatus();
            if (st == ComplaintStatus.ASSIGNED || st == ComplaintStatus.ACTIVE || st == ComplaintStatus.INVESTIGATED) {
                score += 25;
                reasons.add(RiskReason.builder()
                        .code("INACTIVITY_DETECTED")
                        .severity("MEDIUM")
                        .message("No status update or progress notes recorded in over " + inactivityHours + " hours.")
                        .detectedAt(now)
                        .build());
            }
        }

        // 3. Vector: Recurring Issue / Location Hotspot Detection
        Instant sevenDaysAgo = now.minus(Duration.ofDays(7));
        if (complaint.getRoom() != null) {
            long recentRoomCount = complaintRepository.countByRoomIdAndCreatedAtAfterAndIdNot(
                    complaint.getRoom().getId(), sevenDaysAgo, complaint.getId() != null ? complaint.getId() : 0L);
            if (recentRoomCount >= 1) {
                score += 20;
                reasons.add(RiskReason.builder()
                        .code("RECURRING_HOTSPOT")
                        .severity("HIGH")
                        .message("Recurring issues detected in Room " + complaint.getRoom().getRoomNumber() + " (" + (recentRoomCount + 1) + " complaints in 7 days).")
                        .detectedAt(now)
                        .build());
            }
        } else if (complaint.getBlock() != null) {
            long recentBlockCount = complaintRepository.countByBlockIdAndCreatedAtAfterAndIdNot(
                    complaint.getBlock().getId(), sevenDaysAgo, complaint.getId() != null ? complaint.getId() : 0L);
            if (recentBlockCount >= 3) {
                score += 15;
                reasons.add(RiskReason.builder()
                        .code("RECURRING_HOTSPOT")
                        .severity("MEDIUM")
                        .message("High volume of infrastructure complaints in " + complaint.getBlock().getName() + ".")
                        .detectedAt(now)
                        .build());
            }
        }

        // 4. Vector: Critical Safety Hazard & Priority P1 Escalation
        if (complaint.getSeverity() == Severity.CRITICAL || complaint.getPriority() == Priority.P1) {
            score += 30;
            reasons.add(RiskReason.builder()
                    .code("CRITICAL_SAFETY_HAZARD")
                    .severity("CRITICAL")
                    .message("Emergency or life-safety issue marked as Priority P1 / Critical Severity.")
                    .detectedAt(now)
                    .build());
        }

        // 5. Vector: Stalled Missing Information Request
        if (complaint.getStatus() == ComplaintStatus.WAITING_FOR_INFORMATION) {
            if (lastActivity != null && now.minus(Duration.ofHours(48)).isAfter(lastActivity)) {
                score += 20;
                reasons.add(RiskReason.builder()
                        .code("STALLED_MISSING_INFO")
                        .severity("MEDIUM")
                        .message("Clarification request pending student response for over 48 hours.")
                        .detectedAt(now)
                        .build());
            }
        }

        boolean atRisk = score >= 25 || reasons.stream().anyMatch(r -> "SLA_BREACHED".equals(r.getCode()) || "CRITICAL_SAFETY_HAZARD".equals(r.getCode()));

        String recommendedAction;
        if (reasons.stream().anyMatch(r -> "SLA_BREACHED".equals(r.getCode()))) {
            recommendedAction = "Immediate Team Lead reassignment or emergency priority escalation required.";
        } else if (reasons.stream().anyMatch(r -> "CRITICAL_SAFETY_HAZARD".equals(r.getCode()))) {
            recommendedAction = "Dispatch emergency specialist technician and alert hostel warden.";
        } else if (reasons.stream().anyMatch(r -> "INACTIVITY_DETECTED".equals(r.getCode()))) {
            recommendedAction = "Check technician status and prompt field update or reassign.";
        } else if (reasons.stream().anyMatch(r -> "RECURRING_HOTSPOT".equals(r.getCode()))) {
            recommendedAction = "Conduct root-cause infrastructure inspection for systemic defect.";
        } else if (atRisk) {
            recommendedAction = "Monitor closely and consider proactive intervention.";
        } else {
            recommendedAction = "Routine maintenance in progress.";
        }

        return RiskEvaluationResult.builder()
                .isAtRisk(atRisk)
                .riskScore(Math.min(100, score))
                .riskReasons(reasons)
                .recommendedAction(recommendedAction)
                .build();
    }

    @Scheduled(cron = "${app.risk.evaluation-cron:0 */15 * * * *}")
    @Transactional
    public void evaluateAllActiveComplaints() {
        log.info("[RISK ENGINE] Starting scheduled risk and SLA evaluation sweep...");

        List<ComplaintStatus> nonActiveStatuses = List.of(
                ComplaintStatus.CLOSED,
                ComplaintStatus.CONFIRMED,
                ComplaintStatus.RESOLUTION_PROPOSED
        );

        List<Complaint> activeComplaints = complaintRepository.findByStatusNotIn(nonActiveStatuses);
        int evaluatedCount = 0;
        int atRiskCount = 0;

        for (Complaint complaint : activeComplaints) {
            try {
                evaluatedCount++;
                RiskEvaluationResult result = evaluateComplaint(complaint);

                if (result.isAtRisk()) {
                    atRiskCount++;
                    complaint.setIsAtRisk(true);
                    complaint.setRiskReasons(objectMapper.writeValueAsString(result.getRiskReasons()));

                    // If SLA breached and complaint is ACTIVE, transition status to AT_RISK
                    if (result.getRiskReasons().stream().anyMatch(r -> "SLA_BREACHED".equals(r.getCode()))
                            && complaint.getStatus() == ComplaintStatus.ACTIVE) {
                        ComplaintStatus oldStatus = complaint.getStatus();
                        complaint.setStatus(ComplaintStatus.AT_RISK);

                        CaseStatusHistory history = CaseStatusHistory.builder()
                                .complaint(complaint)
                                .previousStatus(oldStatus)
                                .newStatus(ComplaintStatus.AT_RISK)
                                .changedBy(null) // Automated System transition
                                .changeReason("Automated Risk Engine: SLA target deadline breached")
                                .build();
                        statusHistoryRepository.save(history);

                        log.warn("[RISK ENGINE] Complaint {} transitioned to AT_RISK due to SLA breach", complaint.getCaseNumber());
                    }

                    complaintRepository.save(complaint);
                } else if (Boolean.TRUE.equals(complaint.getIsAtRisk())) {
                    // Risk resolved
                    complaint.setIsAtRisk(false);
                    complaint.setRiskReasons(null);
                    complaintRepository.save(complaint);
                }
            } catch (Exception e) {
                log.error("[RISK ENGINE] Error evaluating complaint {}: {}", complaint.getCaseNumber(), e.getMessage());
            }
        }

        log.info("[RISK ENGINE] Sweep complete. Evaluated: {}, At-Risk: {}", evaluatedCount, atRiskCount);
    }
}
