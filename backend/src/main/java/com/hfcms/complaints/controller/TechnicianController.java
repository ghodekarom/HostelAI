package com.hfcms.complaints.controller;

import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.common.dto.ApiResponse;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.dto.RecordFindingRequest;
import com.hfcms.complaints.dto.RecordRepairActionRequest;
import com.hfcms.complaints.service.TechnicianService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Tag(name = "Technician Operations", description = "Endpoints for technicians inspecting and repairing assigned complaints")
public class TechnicianController {

    private final TechnicianService technicianService;

    private Long resolveUserId(Long headerId) {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserPrincipal principal) {
            return principal.getId();
        }
        return headerId != null ? headerId : 3L;
    }

    @GetMapping("/api/v1/technician/assigned")
    @PreAuthorize("hasAnyRole('TECHNICIAN', 'ADMIN')")
    @Operation(summary = "Get list of tasks currently assigned to the technician")
    public ResponseEntity<ApiResponse<Page<ComplaintResponse>>> getAssignedTasks(
            @RequestHeader(value = "X-Technician-Id", defaultValue = "1") Long technicianId,
            Pageable pageable) {

        Page<ComplaintResponse> tasks = technicianService.getAssignedTasks(technicianId, pageable);
        return ResponseEntity.ok(ApiResponse.success(tasks));
    }

    @GetMapping("/api/v1/complaints/{id}/checklist")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get the diagnostic inspection checklist for a complaint")
    public ResponseEntity<ApiResponse<com.hfcms.complaints.dto.ChecklistResponse>> getChecklist(@PathVariable Long id) {
        com.hfcms.complaints.dto.ChecklistResponse checklist = technicianService.getChecklistForComplaint(id);
        return ResponseEntity.ok(ApiResponse.success(checklist));
    }

    @PostMapping("/api/v1/complaints/{id}/checklist/{itemId}/finding")
    @PreAuthorize("hasAnyRole('TECHNICIAN', 'ADMIN')")
    @Operation(summary = "Record diagnostic finding on a checklist item, updating complaint to INVESTIGATED")
    public ResponseEntity<ApiResponse<Void>> recordFinding(
            @PathVariable Long id,
            @PathVariable Long itemId,
            @Valid @RequestBody RecordFindingRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long technicianUserId) {

        Long resolvedUserId = resolveUserId(technicianUserId);
        technicianService.recordFinding(id, itemId, request, resolvedUserId);
        return ResponseEntity.ok(ApiResponse.success("Finding recorded successfully", null));
    }

    @PostMapping("/api/v1/complaints/{id}/repair-actions")
    @PreAuthorize("hasAnyRole('TECHNICIAN', 'ADMIN')")
    @Operation(summary = "Log completed repair work and evidence photo, updating complaint to ACTION_TAKEN")
    public ResponseEntity<ApiResponse<Void>> recordRepairAction(
            @PathVariable Long id,
            @Valid @RequestBody RecordRepairActionRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long technicianUserId) {

        Long resolvedUserId = resolveUserId(technicianUserId);
        technicianService.recordRepairAction(id, request, resolvedUserId);
        return ResponseEntity.ok(ApiResponse.success("Repair action recorded successfully", null));
    }
}
