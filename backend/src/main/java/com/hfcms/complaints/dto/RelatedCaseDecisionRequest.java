package com.hfcms.complaints.dto;

import com.hfcms.complaints.entity.RelationshipDecision;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RelatedCaseDecisionRequest {

    @NotNull(message = "Decision is mandatory")
    private RelationshipDecision decision;

    private String notes;
}
