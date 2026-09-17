package com.hfcms.complaints.missinginfo.service;

import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.complaints.dto.CreateMissingInfoRequestDto;
import com.hfcms.complaints.dto.RespondMissingInfoRequest;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.missinginfo.entity.MissingInfoRequest;
import com.hfcms.complaints.missinginfo.entity.MissingInfoStatus;
import com.hfcms.complaints.missinginfo.repository.MissingInfoRequestRepository;
import com.hfcms.complaints.service.ComplaintService;
import com.hfcms.users.entity.User;
import com.hfcms.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MissingInfoService {

    private static final Logger logger = LoggerFactory.getLogger(MissingInfoService.class);

    private final MissingInfoRequestRepository missingInfoRepository;
    private final ComplaintService complaintService;
    private final UserRepository userRepository;

    @Transactional
    public MissingInfoRequest requestMissingInfo(Long complaintId, CreateMissingInfoRequestDto requestDto, Long operatorId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User operator = userRepository.findById(operatorId)
                .orElseThrow(() -> new ResourceNotFoundException("Operator not found with ID: " + operatorId));

        MissingInfoRequest request = MissingInfoRequest.builder()
                .complaint(complaint)
                .requestedBy(operator)
                .isAiDrafted(Boolean.TRUE.equals(requestDto.getIsAiDrafted()))
                .questions(requestDto.getQuestions())
                .status(MissingInfoStatus.WAITING_FOR_RESPONSE)
                .build();

        MissingInfoRequest saved = missingInfoRepository.save(request);

        // Transition status to WAITING_FOR_INFORMATION per SRS lifecycle
        complaintService.recordStatusTransition(
                complaint,
                ComplaintStatus.WAITING_FOR_INFORMATION,
                operator,
                "Requested additional information from student: " + requestDto.getQuestions()
        );

        logger.info("Created missing info request for complaint ID: {}", complaintId);
        return saved;
    }

    @Transactional
    public void respondMissingInfo(Long complaintId, RespondMissingInfoRequest responseDto, Long studentId) {
        Complaint complaint = complaintService.getComplaintEntity(complaintId);
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + studentId));

        MissingInfoRequest pendingRequest = missingInfoRepository
                .findFirstByComplaintIdAndStatusOrderByRequestedAtDesc(complaintId, MissingInfoStatus.WAITING_FOR_RESPONSE)
                .orElseThrow(() -> new IllegalArgumentException("No pending missing information request found for complaint: " + complaintId));

        pendingRequest.setStudentResponse(responseDto.getResponse());
        pendingRequest.setStatus(MissingInfoStatus.RESPONDED);
        pendingRequest.setRespondedAt(Instant.now());
        missingInfoRepository.save(pendingRequest);

        // Transition back to ACTIVE per PRD 7.6 & SRS Section 12.1
        complaintService.recordStatusTransition(
                complaint,
                ComplaintStatus.ACTIVE,
                student,
                "Student provided requested details: " + responseDto.getResponse()
        );

        logger.info("Student responded to missing info request on complaint ID: {}", complaintId);
    }

    @Transactional(readOnly = true)
    public List<MissingInfoRequest> getRequestsForComplaint(Long complaintId) {
        return missingInfoRepository.findByComplaintIdOrderByRequestedAtDesc(complaintId);
    }
}
