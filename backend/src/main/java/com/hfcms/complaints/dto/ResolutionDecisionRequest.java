package com.hfcms.complaints.dto;

import com.hfcms.complaints.resolution.entity.StudentDecision;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResolutionDecisionRequest {

    @NotNull(message = "Decision (CONFIRMED or REJECTED) is mandatory")
    private StudentDecision decision;

    private String feedback;
}
