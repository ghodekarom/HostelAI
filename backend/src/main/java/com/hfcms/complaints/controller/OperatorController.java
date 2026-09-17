package com.hfcms.complaints.controller;

import com.hfcms.common.dto.ApiResponse;
import com.hfcms.complaints.dto.*;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.missinginfo.service.MissingInfoService;
import com.hfcms.complaints.resolution.service.ResolutionService;
import com.hfcms.complaints.service.OperatorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Tag(name = "Operator Operations", description = "Endpoints for maintenance operators reviewing, assigning, and resolving complaints")
public class OperatorController {

    private final OperatorService operatorService;
    private final MissingInfoService missingInfoService;
    private final ResolutionService resolutionService;

    @GetMapping("/api/v1/operator/queue")
    @Operation(summary = "Get the operator triage queue with status filtering")
    public ResponseEntity<ApiResponse<Page<ComplaintResponse>>> getOperatorQueue(
            @RequestParam(value = "status", required = false) List<ComplaintStatus> statuses,
            Pageable pageable) {

        Page<ComplaintResponse> queue = operatorService.getOperatorQueue(statuses, pageable);
        return ResponseEntity.ok(ApiResponse.success(queue));
    }

    @PostMapping("/api/v1/complaints/{id}/review")
    @Operation(summary = "Review AI classification, severity, priority, and team suggestion")
    public ResponseEntity<ApiResponse<ComplaintResponse>> reviewComplaint(
            @PathVariable Long id,
            @Valid @RequestBody ReviewComplaintRequest request,
            @RequestHeader(value = "X-User-Id", defaultValue = "2") Long operatorId) {

        ComplaintResponse response = operatorService.reviewComplaint(id, request, operatorId);
        return ResponseEntity.ok(ApiResponse.success("Complaint review recorded successfully", response));
    }

    @GetMapping("/api/v1/complaints/{id}/related-cases")
    @Operation(summary = "Get possible duplicate or related cases identified via trigram similarity")
    public ResponseEntity<ApiResponse<List<ComplaintResponse>>> getRelatedCases(@PathVariable Long id) {
        List<ComplaintResponse> related = operatorService.getRelatedCases(id);
        return ResponseEntity.ok(ApiResponse.success(related));
    }

    @PostMapping("/api/v1/complaints/{id}/related-cases/{relatedId}/decision")
    @Operation(summary = "Record operator decision on suspected duplicate/related case (LINKED, DUPLICATE, SEPARATE, IGNORED)")
    public ResponseEntity<ApiResponse<Void>> decideRelatedCase(
            @PathVariable Long id,
            @PathVariable Long relatedId,
            @Valid @RequestBody RelatedCaseDecisionRequest request,
            @RequestHeader(value = "X-User-Id", defaultValue = "2") Long operatorId) {

        operatorService.decideRelatedCase(id, relatedId, request, operatorId);
        return ResponseEntity.ok(ApiResponse.success("Relationship decision recorded successfully", null));
    }

    @PostMapping("/api/v1/complaints/{id}/assign")
    @Operation(summary = "Assign complaint to maintenance team and field technician")
    public ResponseEntity<ApiResponse<ComplaintResponse>> assignComplaint(
            @PathVariable Long id,
            @Valid @RequestBody AssignComplaintRequest request,
            @RequestHeader(value = "X-User-Id", defaultValue = "2") Long operatorId) {

        ComplaintResponse response = operatorService.assignComplaint(id, request, operatorId);
        return ResponseEntity.ok(ApiResponse.success("Complaint assigned successfully", response));
    }

    @PostMapping("/api/v1/complaints/{id}/missing-info/request")
    @Operation(summary = "Request missing details from student, updating status to WAITING_FOR_INFORMATION")
    public ResponseEntity<ApiResponse<Void>> requestMissingInfo(
            @PathVariable Long id,
            @Valid @RequestBody CreateMissingInfoRequestDto request,
            @RequestHeader(value = "X-User-Id", defaultValue = "2") Long operatorId) {

        missingInfoService.requestMissingInfo(id, request, operatorId);
        return ResponseEntity.ok(ApiResponse.success("Missing information request dispatched to student", null));
    }

    @PostMapping("/api/v1/complaints/{id}/resolution")
    @Operation(summary = "Submit structured resolution proposal to student for confirmation")
    public ResponseEntity<ApiResponse<Void>> proposeResolution(
            @PathVariable Long id,
            @Valid @RequestBody ProposeResolutionRequest request,
            @RequestHeader(value = "X-User-Id", defaultValue = "2") Long operatorId) {

        resolutionService.proposeResolution(id, request, operatorId);
        return ResponseEntity.ok(ApiResponse.success("Resolution proposed successfully. Pending student confirmation.", null));
    }
}
