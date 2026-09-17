package com.hfcms.complaints.dto;

import com.hfcms.complaints.investigation.entity.ChecklistStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChecklistResponse {
    private Long id;
    private Long complaintId;
    private Long categoryId;
    private String categoryName;
    private Boolean isAiGenerated;
    private ChecklistStatus status;
    private List<ItemResponse> items;
    private Instant createdAt;
    private Instant completedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ItemResponse {
        private Long id;
        private String itemDescription;
        private Boolean isCompleted;
        private String findings;
        private Long recordedById;
        private String recordedByName;
        private Instant recordedAt;
    }
}
