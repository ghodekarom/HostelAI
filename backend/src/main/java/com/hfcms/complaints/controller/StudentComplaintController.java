package com.hfcms.complaints.controller;

import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.common.dto.ApiResponse;
import com.hfcms.complaints.dto.ComplaintDetailResponse;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.dto.CreateComplaintRequest;
import com.hfcms.complaints.dto.ResolutionDecisionRequest;
import com.hfcms.complaints.dto.RespondMissingInfoRequest;
import com.hfcms.complaints.entity.EvidenceStage;
import com.hfcms.complaints.missinginfo.service.MissingInfoService;
import com.hfcms.complaints.resolution.service.ResolutionService;
import com.hfcms.complaints.service.ComplaintService;
import com.hfcms.storage.StorageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/v1/complaints")
@RequiredArgsConstructor
@Tag(name = "Student Complaints", description = "Endpoints for students reporting, tracking, and confirming complaints")
public class StudentComplaintController {

    private final ComplaintService complaintService;
    private final MissingInfoService missingInfoService;
    private final ResolutionService resolutionService;
    private final StorageService storageService;

    private Long resolveUserId(Long headerId) {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserPrincipal principal) {
            return principal.getId();
        }
        return headerId != null ? headerId : 1L;
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('STUDENT', 'ADMIN')")
    @Operation(summary = "Submit a new hostel facility complaint")
    public ResponseEntity<ApiResponse<ComplaintResponse>> createComplaint(
            @Valid @RequestBody CreateComplaintRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long studentId) {

        Long resolvedStudentId = resolveUserId(studentId);
        ComplaintResponse response = complaintService.createComplaint(request, resolvedStudentId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Complaint submitted successfully", response));
    }

    @GetMapping("/mine")
    @PreAuthorize("hasAnyRole('STUDENT', 'ADMIN')")
    @Operation(summary = "Get list of complaints filed by the current student")
    public ResponseEntity<ApiResponse<Page<ComplaintResponse>>> getMyComplaints(
            @RequestHeader(value = "X-User-Id", required = false) Long studentId,
            Pageable pageable) {

        Long resolvedStudentId = resolveUserId(studentId);
        Page<ComplaintResponse> complaints = complaintService.getStudentComplaints(resolvedStudentId, pageable);
        return ResponseEntity.ok(ApiResponse.success(complaints));
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get detailed view of a complaint with audit timeline and evidence")
    public ResponseEntity<ApiResponse<ComplaintDetailResponse>> getComplaintDetails(@PathVariable Long id) {
        ComplaintDetailResponse details = complaintService.getComplaintDetails(id);
        return ResponseEntity.ok(ApiResponse.success(details));
    }

    @PostMapping(value = "/{id}/evidence", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Upload photo or document evidence for a complaint")
    public ResponseEntity<ApiResponse<String>> uploadEvidence(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "stage", defaultValue = "INTAKE") EvidenceStage stage,
            @RequestHeader(value = "X-User-Id", required = false) Long uploaderId) throws IOException {

        Long resolvedUploaderId = resolveUserId(uploaderId);
        String fileUrl = storageService.uploadFile(file, "complaints/" + id);
        complaintService.addEvidence(id, resolvedUploaderId, fileUrl, file.getContentType(), file.getSize(), stage);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Evidence uploaded successfully", fileUrl));
    }

    @PostMapping("/{id}/missing-info/respond")
    @PreAuthorize("hasAnyRole('STUDENT', 'ADMIN')")
    @Operation(summary = "Respond to a missing-information request from maintenance operator")
    public ResponseEntity<ApiResponse<Void>> respondMissingInfo(
            @PathVariable Long id,
            @Valid @RequestBody RespondMissingInfoRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long studentId) {

        Long resolvedStudentId = resolveUserId(studentId);
        missingInfoService.respondMissingInfo(id, request, resolvedStudentId);
        return ResponseEntity.ok(ApiResponse.success("Response recorded successfully. Complaint returned to active status.", null));
    }

    @PostMapping("/{id}/resolution/decision")
    @PreAuthorize("hasAnyRole('STUDENT', 'ADMIN')")
    @Operation(summary = "Confirm or reject proposed resolution for a complaint")
    public ResponseEntity<ApiResponse<Void>> decideResolution(
            @PathVariable Long id,
            @Valid @RequestBody ResolutionDecisionRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long studentId) {

        Long resolvedStudentId = resolveUserId(studentId);
        resolutionService.decideResolution(id, request, resolvedStudentId);
        return ResponseEntity.ok(ApiResponse.success("Resolution decision recorded successfully", null));
    }
}
