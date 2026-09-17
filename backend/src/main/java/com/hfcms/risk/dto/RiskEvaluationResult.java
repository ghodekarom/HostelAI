package com.hfcms.risk.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RiskEvaluationResult {
    private boolean isAtRisk;
    private int riskScore;
    private List<RiskReason> riskReasons;
    private String recommendedAction;
}
