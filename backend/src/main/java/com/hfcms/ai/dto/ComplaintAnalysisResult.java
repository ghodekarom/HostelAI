package com.hfcms.ai.dto;

import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ComplaintAnalysisResult {

    private String aiSummary;
    private String categoryName;
    private String subcategory;
    private Severity severity;
    private Priority priority;
    private String suggestedTeamName;
    private boolean isMissingInfo;
    private String missingInfoDraftQuestion;

    @Builder.Default
    private List<String> diagnosticChecklist = new ArrayList<>();
}
