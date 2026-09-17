package com.hfcms.complaints.dto;

import com.hfcms.complaints.assignment.entity.AssignmentHistory;
import com.hfcms.complaints.audit.entity.CaseStatusHistory;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintEvidence;
import com.hfcms.complaints.resolution.entity.Resolution;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class ComplaintMapper {

    public static ComplaintResponse toResponse(Complaint complaint) {
        if (complaint == null) return null;

        return ComplaintResponse.builder()
                .id(complaint.getId())
                .caseNumber(complaint.getCaseNumber())
                .studentId(complaint.getStudent() != null ? complaint.getStudent().getId() : null)
                .studentName(complaint.getStudent() != null ? complaint.getStudent().getFullName() : null)
                .studentEmail(complaint.getStudent() != null ? complaint.getStudent().getEmail() : null)
                .hostelId(complaint.getHostel() != null ? complaint.getHostel().getId() : null)
                .hostelName(complaint.getHostel() != null ? complaint.getHostel().getName() : null)
                .blockId(complaint.getBlock() != null ? complaint.getBlock().getId() : null)
                .blockName(complaint.getBlock() != null ? complaint.getBlock().getName() : null)
                .roomId(complaint.getRoom() != null ? complaint.getRoom().getId() : null)
                .roomNumber(complaint.getRoom() != null ? complaint.getRoom().getRoomNumber() : null)
                .categoryId(complaint.getCategory() != null ? complaint.getCategory().getId() : null)
                .categoryName(complaint.getCategory() != null ? complaint.getCategory().getName() : null)
                .subcategory(complaint.getSubcategory())
                .description(complaint.getDescription())
                .status(complaint.getStatus())
                .severity(complaint.getSeverity())
                .priority(complaint.getPriority())
                .assignedTeamId(complaint.getAssignedTeam() != null ? complaint.getAssignedTeam().getId() : null)
                .assignedTeamName(complaint.getAssignedTeam() != null ? complaint.getAssignedTeam().getName() : null)
                .assignedTechnicianId(complaint.getAssignedTechnician() != null ? complaint.getAssignedTechnician().getId() : null)
                .assignedTechnicianName(complaint.getAssignedTechnician() != null && complaint.getAssignedTechnician().getUser() != null
                        ? complaint.getAssignedTechnician().getUser().getFullName() : null)
                .aiStatus(complaint.getAiStatus())
                .aiSummary(complaint.getAiSummary())
                .slaDeadline(complaint.getSlaDeadline())
                .isAtRisk(complaint.getIsAtRisk())
                .riskReasons(complaint.getRiskReasons())
                .createdAt(complaint.getCreatedAt())
                .updatedAt(complaint.getUpdatedAt())
                .build();
    }

    public static ComplaintDetailResponse toDetailResponse(
            Complaint complaint,
            List<ComplaintEvidence> evidenceList,
            List<AssignmentHistory> assignmentList,
            List<CaseStatusHistory> statusList,
            Resolution resolution) {

        List<ComplaintDetailResponse.EvidenceDetailDto> evidenceDtos = evidenceList != null
                ? evidenceList.stream().map(e -> ComplaintDetailResponse.EvidenceDetailDto.builder()
                        .id(e.getId())
                        .fileUrl(e.getFileUrl())
                        .fileType(e.getFileType())
                        .fileSizeBytes(e.getFileSizeBytes())
                        .uploaderId(e.getUploader() != null ? e.getUploader().getId() : null)
                        .uploaderName(e.getUploader() != null ? e.getUploader().getFullName() : null)
                        .evidenceStage(e.getEvidenceStage())
                        .createdAt(e.getCreatedAt())
                        .build()).collect(Collectors.toList())
                : Collections.emptyList();

        List<ComplaintDetailResponse.AssignmentHistoryDto> assignmentDtos = assignmentList != null
                ? assignmentList.stream().map(a -> ComplaintDetailResponse.AssignmentHistoryDto.builder()
                        .id(a.getId())
                        .previousTechnicianName(a.getPreviousTechnician() != null && a.getPreviousTechnician().getUser() != null
                                ? a.getPreviousTechnician().getUser().getFullName() : null)
                        .newTechnicianName(a.getNewTechnician() != null && a.getNewTechnician().getUser() != null
                                ? a.getNewTechnician().getUser().getFullName() : null)
                        .previousTeamName(a.getPreviousTeam() != null ? a.getPreviousTeam().getName() : null)
                        .newTeamName(a.getNewTeam() != null ? a.getNewTeam().getName() : null)
                        .assignedByName(a.getAssignedBy() != null ? a.getAssignedBy().getFullName() : null)
                        .assignmentReason(a.getAssignmentReason())
                        .createdAt(a.getCreatedAt())
                        .build()).collect(Collectors.toList())
                : Collections.emptyList();

        List<ComplaintDetailResponse.StatusHistoryDto> statusDtos = statusList != null
                ? statusList.stream().map(s -> ComplaintDetailResponse.StatusHistoryDto.builder()
                        .id(s.getId())
                        .previousStatus(s.getPreviousStatus() != null ? s.getPreviousStatus().name() : null)
                        .newStatus(s.getNewStatus() != null ? s.getNewStatus().name() : null)
                        .changedByName(s.getChangedBy() != null ? s.getChangedBy().getFullName() : "System")
                        .changeReason(s.getChangeReason())
                        .createdAt(s.getCreatedAt())
                        .build()).collect(Collectors.toList())
                : Collections.emptyList();

        ComplaintDetailResponse.ResolutionDetailDto resolutionDto = resolution != null
                ? ComplaintDetailResponse.ResolutionDetailDto.builder()
                        .id(resolution.getId())
                        .proposedByName(resolution.getProposedBy() != null ? resolution.getProposedBy().getFullName() : null)
                        .problemDescription(resolution.getProblemDescription())
                        .rootCause(resolution.getRootCause())
                        .actionTaken(resolution.getActionTaken())
                        .resultSummary(resolution.getResultSummary())
                        .studentDecision(resolution.getStudentDecision())
                        .studentFeedback(resolution.getStudentFeedback())
                        .proposedAt(resolution.getProposedAt())
                        .decidedAt(resolution.getDecidedAt())
                        .build()
                : null;

        return ComplaintDetailResponse.builder()
                .complaint(toResponse(complaint))
                .evidence(evidenceDtos)
                .assignmentHistory(assignmentDtos)
                .statusHistory(statusDtos)
                .resolution(resolutionDto)
                .build();
    }
}
