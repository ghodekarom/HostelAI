package com.hfcms.complaints.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecordRepairActionRequest {

    @NotNull(message = "Technician ID is mandatory")
    private Long technicianId;

    @NotBlank(message = "Action taken description is mandatory")
    private String actionTaken;

    private String evidenceUrl;

    private String partsReplaced;
}
