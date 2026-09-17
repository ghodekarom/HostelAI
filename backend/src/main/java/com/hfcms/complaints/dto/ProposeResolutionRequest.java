package com.hfcms.complaints.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProposeResolutionRequest {

    @NotBlank(message = "Problem description is mandatory")
    private String problemDescription;

    @NotBlank(message = "Root cause is mandatory")
    private String rootCause;

    @NotBlank(message = "Action taken is mandatory")
    private String actionTaken;

    @NotBlank(message = "Result summary is mandatory")
    private String resultSummary;
}
