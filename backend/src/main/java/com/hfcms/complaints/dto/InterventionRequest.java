package com.hfcms.complaints.dto;

import com.hfcms.complaints.entity.Priority;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InterventionRequest {

    public enum ActionType {
        REASSIGN_TECHNICIAN,
        REASSIGN_TEAM,
        ESCALATE_PRIORITY,
        EXTEND_SLA,
        ADD_INSTRUCTIONS,
        FORCE_STATUS_CHANGE
    }

    private ActionType actionType;

    private Long newTechnicianId;

    private Long newTeamId;

    private Priority newPriority;

    private Integer extendedSlaHours;

    private String instructions;

    @NotBlank(message = "Intervention justification reason is mandatory for audit logging")
    private String reason;
}
