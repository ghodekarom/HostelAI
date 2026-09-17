package com.hfcms.complaints.resolution.service;

import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.complaints.dto.ProposeResolutionRequest;
import com.hfcms.complaints.dto.ResolutionDecisionRequest;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.resolution.entity.Resolution;
import com.hfcms.complaints.resolution.entity.StudentDecision;
import com.hfcms.complaints.resolution.repository.ResolutionRepository;
import com.hfcms.complaints.service.ComplaintService;
import com.hfcms.users.entity.User;
import com.hfcms.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class ResolutionService {

    private static final Logger logger = LoggerFactory.getLogger(ResolutionService.class);

    private final ResolutionRepository resolutionRepository;
    private final ComplaintService complaintService;
    private final UserRepository userRepository;

    @Transactional
    public Resolution proposeResolution(Long complaintId, ProposeResolutionRequest request, Long operatorId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User operator = userRepository.findById(operatorId)
                .orElseThrow(() -> new ResourceNotFoundException("Operator not found: " + operatorId));

        Resolution resolution = resolutionRepository.findByComplaintId(complaintId)
                .orElse(Resolution.builder().complaint(complaint).build());

        resolution.setProposedBy(operator);
        resolution.setProblemDescription(request.getProblemDescription());
        resolution.setRootCause(request.getRootCause());
        resolution.setActionTaken(request.getActionTaken());
        resolution.setResultSummary(request.getResultSummary());
        resolution.setStudentDecision(StudentDecision.PENDING);
        resolution.setProposedAt(Instant.now());

        Resolution saved = resolutionRepository.save(resolution);

        // Transition status to RESOLUTION_PROPOSED
        complaintService.recordStatusTransition(
                complaint,
                ComplaintStatus.RESOLUTION_PROPOSED,
                operator,
                "Operator proposed resolution: " + request.getResultSummary()
        );

        logger.info("Resolution proposed for complaint ID: {}", complaintId);
        return saved;
    }

    @Transactional
    public void decideResolution(Long complaintId, ResolutionDecisionRequest request, Long studentId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + studentId));

        Resolution resolution = resolutionRepository.findByComplaintId(complaintId)
                .orElseThrow(() -> new IllegalArgumentException("No resolution proposal exists for complaint: " + complaintId));

        resolution.setStudentDecision(request.getDecision());
        resolution.setStudentFeedback(request.getFeedback());
        resolution.setDecidedAt(Instant.now());
        resolutionRepository.save(resolution);

        if (request.getDecision() == StudentDecision.CONFIRMED) {
            // CONFIRMED -> CLOSED
            complaintService.recordStatusTransition(
                    complaint,
                    ComplaintStatus.CONFIRMED,
                    student,
                    "Student confirmed resolution. Feedback: " + request.getFeedback()
            );
            complaintService.recordStatusTransition(
                    complaint,
                    ComplaintStatus.CLOSED,
                    student,
                    "Case successfully resolved and closed"
            );
            logger.info("Complaint {} confirmed and closed by student", complaint.getCaseNumber());
        } else if (request.getDecision() == StudentDecision.REJECTED) {
            // REOPENED -> ACTIVE
            complaintService.recordStatusTransition(
                    complaint,
                    ComplaintStatus.REOPENED,
                    student,
                    "Student rejected resolution. Reason: " + request.getFeedback()
            );
            complaintService.recordStatusTransition(
                    complaint,
                    ComplaintStatus.ACTIVE,
                    student,
                    "Reopened complaint returned to active investigation"
            );
            logger.info("Complaint {} rejected by student and reopened", complaint.getCaseNumber());
        }
    }
}
