package com.hfcms.complaints.dto;

import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReviewComplaintRequest {
    private Long categoryId;
    private String subcategory;
    private Severity severity;
    private Priority priority;
    private Long assignedTeamId;
    private String reviewNotes;
}
