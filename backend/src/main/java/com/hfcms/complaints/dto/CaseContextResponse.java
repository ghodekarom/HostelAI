package com.hfcms.complaints.dto;

import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import com.hfcms.risk.dto.RiskReason;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CaseContextResponse {
    private Long id;
    private String caseNumber;
    private Long studentId;
    private String studentName;
    private String studentEmail;
    private String studentPhone;
    private String hostelName;
    private String blockName;
    private String roomNumber;
    private String categoryName;
    private String subcategory;
    private String description;
    private ComplaintStatus status;
    private Severity severity;
    private Priority priority;
    private Long assignedTeamId;
    private String assignedTeamName;
    private Long assignedTechnicianId;
    private String assignedTechnicianName;
    private String aiSummary;
    private Instant slaDeadline;
    private Boolean isAtRisk;
    private List<RiskReason> riskReasons;
    private Long minutesToSlaBreach;
    private Boolean isSlaBreached;

    private List<ComplaintDetailResponse.StatusHistoryDto> statusHistory;
    private List<ComplaintDetailResponse.AssignmentHistoryDto> assignmentHistory;
    private List<ChecklistResponse.ItemResponse> checklistItems;
    private List<ComplaintResponse> relatedCases;
}
