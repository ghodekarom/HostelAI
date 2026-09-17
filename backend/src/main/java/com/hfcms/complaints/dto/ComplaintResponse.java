package com.hfcms.complaints.dto;

import com.hfcms.complaints.entity.AiStatus;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ComplaintResponse {
    private Long id;
    private String caseNumber;
    private Long studentId;
    private String studentName;
    private String studentEmail;
    private Long hostelId;
    private String hostelName;
    private Long blockId;
    private String blockName;
    private Long roomId;
    private String roomNumber;
    private Long categoryId;
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
    private AiStatus aiStatus;
    private String aiSummary;
    private Instant slaDeadline;
    private Boolean isAtRisk;
    private String riskReasons;
    private Instant createdAt;
    private Instant updatedAt;
}
