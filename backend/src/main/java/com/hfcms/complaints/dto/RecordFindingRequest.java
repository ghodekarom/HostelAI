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
public class RecordFindingRequest {

    @NotBlank(message = "Findings content cannot be blank")
    private String findings;
}
