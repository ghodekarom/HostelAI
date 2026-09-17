package com.hfcms.complaints.controller;

import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.common.dto.ApiResponse;
import com.hfcms.complaints.dto.CaseContextResponse;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.dto.InterventionRequest;
import com.hfcms.complaints.service.TeamLeadService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Tag(name = "Team Lead Operations", description = "Endpoints for Team Leads monitoring at-risk cases, context investigation, and interventions")
public class TeamLeadController {

    private final TeamLeadService teamLeadService;

    @GetMapping("/api/v1/team-lead/at-risk")
    @PreAuthorize("hasAnyRole('TEAM_LEAD', 'OPERATOR', 'ADMIN')")
    @Operation(summary = "Get at-risk and SLA-breached complaints queue")
    public ResponseEntity<ApiResponse<Page<ComplaintResponse>>> getAtRiskQueue(
            @RequestParam(value = "teamId", required = false) Long teamId,
            Pageable pageable) {

        Page<ComplaintResponse> queue = teamLeadService.getAtRiskQueue(teamId, pageable);
        return ResponseEntity.ok(ApiResponse.success(queue));
    }

    @GetMapping("/api/v1/complaints/{id}/context")
    @PreAuthorize("hasAnyRole('TEAM_LEAD', 'OPERATOR', 'ADMIN')")
    @Operation(summary = "Get deep investigative context including SLA analysis, audit trail, checklists, and related cases")
    public ResponseEntity<ApiResponse<CaseContextResponse>> getCaseContext(@PathVariable Long id) {
        CaseContextResponse context = teamLeadService.getCaseContext(id);
        return ResponseEntity.ok(ApiResponse.success(context));
    }

    @PostMapping("/api/v1/complaints/{id}/intervene")
    @PreAuthorize("hasAnyRole('TEAM_LEAD', 'ADMIN')")
    @Operation(summary = "Apply administrative intervention (reassign technician, escalate priority, extend SLA, add directives)")
    public ResponseEntity<ApiResponse<ComplaintResponse>> intervene(
            @PathVariable Long id,
            @Valid @RequestBody InterventionRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long headerUserId) {

        Long teamLeadUserId = resolveUserId(headerUserId);
        ComplaintResponse response = teamLeadService.intervene(id, request, teamLeadUserId);
        return ResponseEntity.ok(ApiResponse.success("Intervention recorded successfully", response));
    }

    private Long resolveUserId(Long headerUserId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserPrincipal principal) {
            return principal.getId();
        }
        return headerUserId != null ? headerUserId : 2L;
    }
}
