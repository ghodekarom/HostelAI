package com.hfcms.risk;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hfcms.complaints.audit.repository.CaseStatusHistoryRepository;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.hostels.entity.Block;
import com.hfcms.hostels.entity.Room;
import com.hfcms.notifications.service.NotificationService;
import com.hfcms.risk.dto.RiskEvaluationResult;
import com.hfcms.risk.service.RiskEvaluationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Duration;
import java.time.Instant;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RiskEvaluationServiceTest {

    @Mock
    private ComplaintRepository complaintRepository;

    @Mock
    private CaseStatusHistoryRepository statusHistoryRepository;

    @Mock
    private NotificationService notificationService;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private RiskEvaluationService riskEvaluationService;

    private Room testRoom;
    private Block testBlock;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(riskEvaluationService, "inactivityHours", 24L);
        ReflectionTestUtils.setField(riskEvaluationService, "imminentSlaHours", 4L);

        testBlock = Block.builder().id(10L).name("Block A").build();
        testRoom = Room.builder().id(101L).roomNumber("301").block(testBlock).build();
    }

    @Test
    void evaluateComplaint_whenSlaBreached_detectsCriticalBreach() {
        Complaint complaint = Complaint.builder()
                .id(1L)
                .caseNumber("HFCMS-2026-BREACH")
                .status(ComplaintStatus.ACTIVE)
                .severity(Severity.MEDIUM)
                .priority(Priority.P3)
                .slaDeadline(Instant.now().minus(Duration.ofHours(2)))
                .build();

        RiskEvaluationResult result = riskEvaluationService.evaluateComplaint(complaint);

        assertThat(result.isAtRisk()).isTrue();
        assertThat(result.getRiskScore()).isGreaterThanOrEqualTo(40);
        assertThat(result.getRiskReasons()).anyMatch(r -> "SLA_BREACHED".equals(r.getCode()));
    }

    @Test
    void evaluateComplaint_whenSlaImminent_detectsHighRisk() {
        Complaint complaint = Complaint.builder()
                .id(2L)
                .caseNumber("HFCMS-2026-IMMINENT")
                .status(ComplaintStatus.ACTIVE)
                .severity(Severity.MEDIUM)
                .priority(Priority.P3)
                .slaDeadline(Instant.now().plus(Duration.ofHours(2)))
                .build();

        RiskEvaluationResult result = riskEvaluationService.evaluateComplaint(complaint);

        assertThat(result.isAtRisk()).isTrue();
        assertThat(result.getRiskReasons()).anyMatch(r -> "SLA_IMMINENT".equals(r.getCode()));
    }

    @Test
    void evaluateComplaint_whenInactiveOver24Hours_detectsInactivity() {
        Complaint complaint = Complaint.builder()
                .id(3L)
                .caseNumber("HFCMS-2026-STAGNANT")
                .status(ComplaintStatus.ASSIGNED)
                .severity(Severity.MEDIUM)
                .priority(Priority.P3)
                .slaDeadline(Instant.now().plus(Duration.ofDays(2)))
                .updatedAt(Instant.now().minus(Duration.ofHours(30)))
                .build();

        RiskEvaluationResult result = riskEvaluationService.evaluateComplaint(complaint);

        assertThat(result.isAtRisk()).isTrue();
        assertThat(result.getRiskReasons()).anyMatch(r -> "INACTIVITY_DETECTED".equals(r.getCode()));
    }

    @Test
    void evaluateComplaint_whenRecurringRoomHotspot_detectsHotspot() {
        Complaint complaint = Complaint.builder()
                .id(4L)
                .caseNumber("HFCMS-2026-HOTSPOT")
                .status(ComplaintStatus.ACTIVE)
                .room(testRoom)
                .block(testBlock)
                .severity(Severity.LOW)
                .priority(Priority.P4)
                .slaDeadline(Instant.now().plus(Duration.ofDays(3)))
                .build();

        when(complaintRepository.countByRoomIdAndCreatedAtAfterAndIdNot(anyLong(), any(Instant.class), anyLong()))
                .thenReturn(2L);

        RiskEvaluationResult result = riskEvaluationService.evaluateComplaint(complaint);

        assertThat(result.getRiskReasons()).anyMatch(r -> "RECURRING_HOTSPOT".equals(r.getCode()));
    }

    @Test
    void evaluateComplaint_whenCriticalSafetyHazard_triggersImmediateEscalation() {
        Complaint complaint = Complaint.builder()
                .id(5L)
                .caseNumber("HFCMS-2026-HAZARD")
                .status(ComplaintStatus.REPORTED)
                .severity(Severity.CRITICAL)
                .priority(Priority.P1)
                .slaDeadline(Instant.now().plus(Duration.ofHours(6)))
                .build();

        RiskEvaluationResult result = riskEvaluationService.evaluateComplaint(complaint);

        assertThat(result.isAtRisk()).isTrue();
        assertThat(result.getRiskReasons()).anyMatch(r -> "CRITICAL_SAFETY_HAZARD".equals(r.getCode()));
    }

    @Test
    void evaluateComplaint_whenNormalAndOnTrack_returnsNotAtRisk() {
        Complaint complaint = Complaint.builder()
                .id(6L)
                .caseNumber("HFCMS-2026-HEALTHY")
                .status(ComplaintStatus.ACTIVE)
                .severity(Severity.LOW)
                .priority(Priority.P3)
                .slaDeadline(Instant.now().plus(Duration.ofDays(3)))
                .updatedAt(Instant.now().minus(Duration.ofHours(2)))
                .build();

        RiskEvaluationResult result = riskEvaluationService.evaluateComplaint(complaint);

        assertThat(result.isAtRisk()).isFalse();
        assertThat(result.getRiskScore()).isEqualTo(0);
        assertThat(result.getRiskReasons()).isEmpty();
    }
}
