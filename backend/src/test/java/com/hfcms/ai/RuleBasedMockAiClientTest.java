package com.hfcms.ai;

import com.hfcms.ai.client.mock.RuleBasedMockAiClient;
import com.hfcms.ai.dto.ComplaintAnalysisResult;
import com.hfcms.categories.entity.Category;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import com.hfcms.hostels.entity.Block;
import com.hfcms.hostels.entity.Room;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class RuleBasedMockAiClientTest {

    private RuleBasedMockAiClient aiClient;

    @BeforeEach
    void setUp() {
        aiClient = new RuleBasedMockAiClient();
    }

    @Test
    void analyzeComplaint_waterLeakage_infersCategoryAndPlumbingTeam() {
        Complaint complaint = Complaint.builder()
                .caseNumber("HFCMS-2026-TEST01")
                .description("Continuous water leakage from washroom tap, floor is getting flooded")
                .block(Block.builder().name("Block A").build())
                .room(Room.builder().roomNumber("102").build())
                .build();

        ComplaintAnalysisResult result = aiClient.analyzeComplaint(complaint);

        assertThat(result).isNotNull();
        assertThat(result.getCategoryName()).isEqualTo("Water supply / leakage");
        assertThat(result.getSuggestedTeamName()).isEqualTo("Plumbing Team");
        assertThat(result.getSeverity()).isEqualTo(Severity.CRITICAL); // due to "flooded"
        assertThat(result.getPriority()).isEqualTo(Priority.P1);
        assertThat(result.getAiSummary()).contains("Block A");
        assertThat(result.getDiagnosticChecklist()).isNotEmpty();
        assertThat(result.getDiagnosticChecklist().size()).isGreaterThanOrEqualTo(3);
    }

    @Test
    void analyzeComplaint_electricalHazard_infersCriticalAndP1() {
        Complaint complaint = Complaint.builder()
                .caseNumber("HFCMS-2026-TEST02")
                .description("Sparking and smoke coming from the power switch board near bed")
                .block(Block.builder().name("Block C").build())
                .room(Room.builder().roomNumber("305").build())
                .build();

        ComplaintAnalysisResult result = aiClient.analyzeComplaint(complaint);

        assertThat(result).isNotNull();
        assertThat(result.getCategoryName()).isEqualTo("Electrical problems");
        assertThat(result.getSuggestedTeamName()).isEqualTo("Electrical Team");
        assertThat(result.getSeverity()).isEqualTo(Severity.CRITICAL);
        assertThat(result.getPriority()).isEqualTo(Priority.P1);
        assertThat(result.getDiagnosticChecklist()).anyMatch(step -> step.contains("voltage") || step.contains("multimeter"));
    }

    @Test
    void analyzeComplaint_vagueShortDescription_flagsMissingInfo() {
        Complaint complaint = Complaint.builder()
                .caseNumber("HFCMS-2026-TEST03")
                .description("not working")
                .build();

        ComplaintAnalysisResult result = aiClient.analyzeComplaint(complaint);

        assertThat(result).isNotNull();
        assertThat(result.isMissingInfo()).isTrue();
        assertThat(result.getMissingInfoDraftQuestion()).isNotBlank();
    }

    @Test
    void analyzeComplaint_wifiIssue_infersItTeam() {
        Complaint complaint = Complaint.builder()
                .caseNumber("HFCMS-2026-TEST04")
                .description("Wi-Fi router on 2nd floor corridor has no internet connection since yesterday")
                .build();

        ComplaintAnalysisResult result = aiClient.analyzeComplaint(complaint);

        assertThat(result).isNotNull();
        assertThat(result.getCategoryName()).isEqualTo("Wi-Fi / Internet");
        assertThat(result.getSuggestedTeamName()).isEqualTo("IT / Network Team");
        assertThat(result.getDiagnosticChecklist()).anyMatch(step -> step.contains("AP") || step.contains("access point"));
    }

    @Test
    void analyzeComplaint_withExistingCategory_honorsCategory() {
        Category category = Category.builder()
                .name("Cleanliness")
                .build();

        Complaint complaint = Complaint.builder()
                .caseNumber("HFCMS-2026-TEST05")
                .category(category)
                .description("Corridor has not been swept and dustbin is overflowing")
                .build();

        ComplaintAnalysisResult result = aiClient.analyzeComplaint(complaint);

        assertThat(result.getCategoryName()).isEqualTo("Cleanliness");
        assertThat(result.getSuggestedTeamName()).isEqualTo("Housekeeping Team");
    }
}
