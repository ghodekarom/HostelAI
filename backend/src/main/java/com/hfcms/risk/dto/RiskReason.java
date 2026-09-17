package com.hfcms.risk.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RiskReason {
    private String code;
    private String message;
    private String severity;
    private Instant detectedAt;
}
