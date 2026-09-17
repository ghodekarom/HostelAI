package com.hfcms.complaints.dto;

import com.hfcms.complaints.entity.EvidenceStage;
import com.hfcms.complaints.resolution.entity.StudentDecision;
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
public class ComplaintDetailResponse {

    private ComplaintResponse complaint;
    private List<EvidenceDetailDto> evidence;
    private List<AssignmentHistoryDto> assignmentHistory;
    private List<StatusHistoryDto> statusHistory;
    private ResolutionDetailDto resolution;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EvidenceDetailDto {
        private Long id;
        private String fileUrl;
        private String fileType;
        private Long fileSizeBytes;
        private Long uploaderId;
        private String uploaderName;
        private EvidenceStage evidenceStage;
        private Instant createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AssignmentHistoryDto {
        private Long id;
        private String previousTechnicianName;
        private String newTechnicianName;
        private String previousTeamName;
        private String newTeamName;
        private String assignedByName;
        private String assignmentReason;
        private Instant createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StatusHistoryDto {
        private Long id;
        private String previousStatus;
        private String newStatus;
        private String changedByName;
        private String changeReason;
        private Instant createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ResolutionDetailDto {
        private Long id;
        private String proposedByName;
        private String problemDescription;
        private String rootCause;
        private String actionTaken;
        private String resultSummary;
        private StudentDecision studentDecision;
        private String studentFeedback;
        private Instant proposedAt;
        private Instant decidedAt;
    }
}
