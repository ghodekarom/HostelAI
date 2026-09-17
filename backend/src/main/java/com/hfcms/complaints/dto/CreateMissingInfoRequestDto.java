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
public class CreateMissingInfoRequestDto {

    @NotBlank(message = "Question text cannot be blank")
    private String questions;

    @Builder.Default
    private Boolean isAiDrafted = false;
}
