package com.hfcms.complaints.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AssignComplaintRequest {

    @NotNull(message = "Assigned Team ID is mandatory")
    private Long teamId;

    private Long technicianId;

    private String assignmentReason;
}
