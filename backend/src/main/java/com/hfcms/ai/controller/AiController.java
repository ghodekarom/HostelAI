package com.hfcms.ai.controller;

import com.hfcms.ai.service.AiComplaintService;
import com.hfcms.common.dto.ApiResponse;
import com.hfcms.complaints.dto.ComplaintResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "AI Case Manager", description = "Endpoints for AI complaint triage, classification, duplicate check, and diagnostic checklists")
public class AiController {

    private final AiComplaintService aiComplaintService;

    @PostMapping("/api/v1/complaints/{id}/ai/analyze")
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
    @Operation(summary = "Trigger or re-run AI triage analysis on a complaint")
    public ResponseEntity<ApiResponse<ComplaintResponse>> analyzeComplaint(@PathVariable Long id) {
        ComplaintResponse response = aiComplaintService.processComplaint(id);
        return ResponseEntity.ok(ApiResponse.success("AI complaint triage completed successfully", response));
    }
}
