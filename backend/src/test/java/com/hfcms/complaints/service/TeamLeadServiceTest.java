package com.hfcms.complaints.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hfcms.complaints.assignment.repository.AssignmentHistoryRepository;
import com.hfcms.complaints.audit.repository.CaseStatusHistoryRepository;
import com.hfcms.complaints.dto.CaseContextResponse;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.dto.InterventionRequest;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import com.hfcms.complaints.investigation.repository.InvestigationChecklistRepository;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.notifications.service.NotificationService;
import com.hfcms.teams.entity.Team;
import com.hfcms.teams.entity.Technician;
import com.hfcms.teams.repository.TeamRepository;
import com.hfcms.teams.repository.TechnicianRepository;
import com.hfcms.users.entity.Role;
import com.hfcms.users.entity.User;
import com.hfcms.users.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TeamLeadServiceTest {

    @Mock
    private ComplaintRepository complaintRepository;

    @Mock
    private ComplaintService complaintService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private TeamRepository teamRepository;

    @Mock
    private TechnicianRepository technicianRepository;

    @Mock
    private AssignmentHistoryRepository assignmentHistoryRepository;

    @Mock
    private CaseStatusHistoryRepository statusHistoryRepository;

    @Mock
    private InvestigationChecklistRepository investigationChecklistRepository;

    @Mock
    private NotificationService notificationService;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private TeamLeadService teamLeadService;

    private User testTeamLead;
    private Technician tech1;
    private Technician tech2;
    private Team plumbingTeam;
    private Complaint atRiskComplaint;

    @BeforeEach
    void setUp() {
        Role leadRole = Role.builder().id(3L).name("ROLE_TEAM_LEAD").build();
        testTeamLead = User.builder().id(30L).fullName("Lead Sharma").email("lead@hostel.edu").role(leadRole).build();

        plumbingTeam = Team.builder().id(10L).name("Plumbing Team").build();

        User userTech1 = User.builder().id(40L).fullName("Tech Suresh").build();
        tech1 = Technician.builder().id(1L).user(userTech1).team(plumbingTeam).build();

        User userTech2 = User.builder().id(41L).fullName("Tech Ramesh").build();
        tech2 = Technician.builder().id(2L).user(userTech2).team(plumbingTeam).build();

        atRiskComplaint = Complaint.builder()
                .id(100L)
                .caseNumber("HFCMS-2026-ATRISK")
                .status(ComplaintStatus.AT_RISK)
                .severity(Severity.HIGH)
                .priority(Priority.P3)
                .isAtRisk(true)
                .assignedTeam(plumbingTeam)
                .assignedTechnician(tech1)
                .slaDeadline(Instant.now().minus(Duration.ofHours(1)))
                .build();
    }

    @Test
    void getAtRiskQueue_returnsPaginatedAtRiskCases() {
        PageRequest pageRequest = PageRequest.of(0, 10);
        when(complaintRepository.findByIsAtRiskTrueOrStatusOrderByCreatedAtDesc(ComplaintStatus.AT_RISK, pageRequest))
                .thenReturn(new PageImpl<>(List.of(atRiskComplaint), pageRequest, 1));

        Page<ComplaintResponse> queue = teamLeadService.getAtRiskQueue(null, pageRequest);

        assertThat(queue.getContent()).hasSize(1);
        assertThat(queue.getContent().get(0).getCaseNumber()).isEqualTo("HFCMS-2026-ATRISK");
    }

    @Test
    void getCaseContext_returnsAggregatedInvestigationDetails() {
        when(complaintService.getComplaintEntity(100L)).thenReturn(atRiskComplaint);
        when(statusHistoryRepository.findByComplaintIdOrderByCreatedAtAsc(100L)).thenReturn(List.of());
        when(assignmentHistoryRepository.findByComplaintIdOrderByCreatedAtDesc(100L)).thenReturn(List.of());
        when(investigationChecklistRepository.findByComplaintId(100L)).thenReturn(Optional.empty());
        when(complaintRepository.findSimilarComplaintsByTrigram(any(), any(), anyDouble(), anyInt())).thenReturn(List.of());

        CaseContextResponse context = teamLeadService.getCaseContext(100L);

        assertThat(context).isNotNull();
        assertThat(context.getCaseNumber()).isEqualTo("HFCMS-2026-ATRISK");
        assertThat(context.getIsSlaBreached()).isTrue();
        assertThat(context.getAssignedTechnicianName()).isEqualTo("Tech Suresh");
    }

    @Test
    void intervene_reassignTechnician_recordsHistoryAndRestoresActiveStatus() {
        when(complaintService.getComplaintEntity(100L)).thenReturn(atRiskComplaint);
        when(userRepository.findById(30L)).thenReturn(Optional.of(testTeamLead));
        when(technicianRepository.findById(2L)).thenReturn(Optional.of(tech2));
        when(complaintRepository.save(any(Complaint.class))).thenAnswer(inv -> inv.getArgument(0));

        InterventionRequest request = InterventionRequest.builder()
                .actionType(InterventionRequest.ActionType.REASSIGN_TECHNICIAN)
                .newTechnicianId(2L)
                .reason("Primary technician unavailable; reassigned to Ramesh")
                .build();

        ComplaintResponse response = teamLeadService.intervene(100L, request, 30L);

        assertThat(response).isNotNull();
        assertThat(atRiskComplaint.getAssignedTechnician()).isEqualTo(tech2);
        assertThat(atRiskComplaint.getStatus()).isEqualTo(ComplaintStatus.ACTIVE);
        assertThat(atRiskComplaint.getIsAtRisk()).isFalse();

        verify(assignmentHistoryRepository).save(any());
        verify(statusHistoryRepository).save(any());
    }

    @Test
    void intervene_escalatePriority_updatesPriorityToP1() {
        when(complaintService.getComplaintEntity(100L)).thenReturn(atRiskComplaint);
        when(userRepository.findById(30L)).thenReturn(Optional.of(testTeamLead));
        when(complaintRepository.save(any(Complaint.class))).thenAnswer(inv -> inv.getArgument(0));

        InterventionRequest request = InterventionRequest.builder()
                .actionType(InterventionRequest.ActionType.ESCALATE_PRIORITY)
                .newPriority(Priority.P1)
                .reason("Escalated to P1 due to high water overflow")
                .build();

        ComplaintResponse response = teamLeadService.intervene(100L, request, 30L);

        assertThat(atRiskComplaint.getPriority()).isEqualTo(Priority.P1);
    }

    @Test
    void intervene_extendSla_extendsDeadlineByRequestedHours() {
        when(complaintService.getComplaintEntity(100L)).thenReturn(atRiskComplaint);
        when(userRepository.findById(30L)).thenReturn(Optional.of(testTeamLead));
        when(complaintRepository.save(any(Complaint.class))).thenAnswer(inv -> inv.getArgument(0));

        Instant before = atRiskComplaint.getSlaDeadline();

        InterventionRequest request = InterventionRequest.builder()
                .actionType(InterventionRequest.ActionType.EXTEND_SLA)
                .extendedSlaHours(24)
                .reason("Awaiting custom replacement valve")
                .build();

        teamLeadService.intervene(100L, request, 30L);

        assertThat(atRiskComplaint.getSlaDeadline()).isAfter(before);
    }
}
