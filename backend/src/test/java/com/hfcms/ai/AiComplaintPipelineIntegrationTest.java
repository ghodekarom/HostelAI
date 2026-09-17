package com.hfcms.ai;

import com.hfcms.ai.entity.AiAnalysisLog;
import com.hfcms.ai.repository.AiAnalysisLogRepository;
import com.hfcms.auth.security.JwtTokenProvider;
import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.dto.CreateComplaintRequest;
import com.hfcms.complaints.entity.AiStatus;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.investigation.entity.ChecklistItem;
import com.hfcms.complaints.investigation.entity.InvestigationChecklist;
import com.hfcms.complaints.investigation.repository.ChecklistItemRepository;
import com.hfcms.complaints.investigation.repository.InvestigationChecklistRepository;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.complaints.service.ComplaintService;
import com.hfcms.users.entity.UserStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class AiComplaintPipelineIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ComplaintService complaintService;

    @Autowired
    private ComplaintRepository complaintRepository;

    @Autowired
    private InvestigationChecklistRepository checklistRepository;

    @Autowired
    private ChecklistItemRepository checklistItemRepository;

    @Autowired
    private AiAnalysisLogRepository aiAnalysisLogRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Test
    void createComplaint_automaticallyRunsAiTriage_advancesToOperatorReview() {
        CreateComplaintRequest request = CreateComplaintRequest.builder()
                .hostelId(1L)
                .blockId(1L)
                .roomId(1L)
                .categoryId(1L) // Water supply / leakage
                .description("Bathroom tap is leaking continuously and overflowing into hallway")
                .build();

        // Student ID 1 exists in seeded database
        ComplaintResponse response = complaintService.createComplaint(request, 1L);

        assertThat(response).isNotNull();
        assertThat(response.getId()).isNotNull();
        assertThat(response.getCaseNumber()).startsWith("HFCMS-");
        assertThat(response.getStatus()).isEqualTo(ComplaintStatus.OPERATOR_REVIEW);
        assertThat(response.getAiStatus()).isEqualTo(AiStatus.COMPLETED);
        assertThat(response.getAiSummary()).isNotBlank();
        assertThat(response.getSeverity()).isNotNull();
        assertThat(response.getPriority()).isNotNull();

        // Verify Investigation Checklist was auto-generated
        Optional<InvestigationChecklist> checklistOpt = checklistRepository.findByComplaintId(response.getId());
        assertThat(checklistOpt).isPresent();
        List<ChecklistItem> items = checklistItemRepository.findByChecklistId(checklistOpt.get().getId());
        assertThat(items).isNotEmpty();

        // Verify AI Analysis Log was recorded
        List<AiAnalysisLog> logs = aiAnalysisLogRepository.findByComplaintIdOrderByCreatedAtDesc(response.getId());
        assertThat(logs).isNotEmpty();
        assertThat(logs.get(0).getActionType()).isEqualTo("COMPLAINT_TRIAGE");
    }

    @Test
    void manualAiAnalyzeEndpoint_withOperatorToken_succeeds() throws Exception {
        // Find or create complaint
        Complaint complaint = complaintRepository.findAll().stream().findFirst().orElse(null);
        assertThat(complaint).isNotNull();

        UserPrincipal operator = UserPrincipal.builder()
                .id(2L)
                .email("operator@hostel.edu")
                .fullName("Operator User")
                .roleName("ROLE_OPERATOR")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_OPERATOR")))
                .build();
        String token = jwtTokenProvider.generateAccessToken(operator);

        mockMvc.perform(post("/api/v1/complaints/" + complaint.getId() + "/ai/analyze")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.aiStatus").value("COMPLETED"));
    }

    @Test
    void manualAiAnalyzeEndpoint_withStudentToken_isForbidden() throws Exception {
        Complaint complaint = complaintRepository.findAll().stream().findFirst().orElse(null);
        assertThat(complaint).isNotNull();

        UserPrincipal student = UserPrincipal.builder()
                .id(1L)
                .email("student@hostel.edu")
                .fullName("Student User")
                .roleName("ROLE_STUDENT")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_STUDENT")))
                .build();
        String token = jwtTokenProvider.generateAccessToken(student);

        mockMvc.perform(post("/api/v1/complaints/" + complaint.getId() + "/ai/analyze")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }
}
