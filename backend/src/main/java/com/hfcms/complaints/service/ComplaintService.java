package com.hfcms.complaints.service;

import com.hfcms.categories.entity.Category;
import com.hfcms.categories.repository.CategoryRepository;
import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.complaints.assignment.entity.AssignmentHistory;
import com.hfcms.complaints.assignment.repository.AssignmentHistoryRepository;
import com.hfcms.complaints.audit.entity.CaseStatusHistory;
import com.hfcms.complaints.audit.repository.CaseStatusHistoryRepository;
import com.hfcms.complaints.dto.ComplaintDetailResponse;
import com.hfcms.complaints.dto.ComplaintMapper;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.dto.CreateComplaintRequest;
import com.hfcms.complaints.entity.*;
import com.hfcms.complaints.repository.ComplaintEvidenceRepository;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.complaints.resolution.entity.Resolution;
import com.hfcms.complaints.resolution.repository.ResolutionRepository;
import com.hfcms.hostels.entity.Block;
import com.hfcms.hostels.entity.Hostel;
import com.hfcms.hostels.entity.Room;
import com.hfcms.hostels.repository.BlockRepository;
import com.hfcms.hostels.repository.HostelRepository;
import com.hfcms.hostels.repository.RoomRepository;
import com.hfcms.users.entity.User;
import com.hfcms.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.time.Year;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ComplaintService {

    private static final Logger logger = LoggerFactory.getLogger(ComplaintService.class);

    private final ComplaintRepository complaintRepository;
    private final ComplaintEvidenceRepository evidenceRepository;
    private final CaseStatusHistoryRepository statusHistoryRepository;
    private final AssignmentHistoryRepository assignmentHistoryRepository;
    private final ResolutionRepository resolutionRepository;
    private final UserRepository userRepository;
    private final HostelRepository hostelRepository;
    private final BlockRepository blockRepository;
    private final RoomRepository roomRepository;
    private final CategoryRepository categoryRepository;

    @Transactional
    public ComplaintResponse createComplaint(CreateComplaintRequest request, Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + studentId));

        Hostel hostel = hostelRepository.findById(request.getHostelId())
                .orElseThrow(() -> new ResourceNotFoundException("Hostel not found with ID: " + request.getHostelId()));

        Block block = blockRepository.findById(request.getBlockId())
                .orElseThrow(() -> new ResourceNotFoundException("Block not found with ID: " + request.getBlockId()));

        Room room = null;
        if (request.getRoomId() != null) {
            room = roomRepository.findById(request.getRoomId()).orElse(null);
        }

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with ID: " + request.getCategoryId()));

        // Generate unique case number format: HFCMS-YYYY-XXXXXX
        String caseNumber = String.format("HFCMS-%d-%s",
                Year.now().getValue(),
                UUID.randomUUID().toString().substring(0, 6).toUpperCase());

        // Default initial SLA based on Category Priority 3 (Standard)
        Instant slaDeadline = Instant.now().plus(Duration.ofHours(category.getSlaHoursP3()));

        Complaint complaint = Complaint.builder()
                .caseNumber(caseNumber)
                .student(student)
                .hostel(hostel)
                .block(block)
                .room(room)
                .category(category)
                .subcategory(request.getSubcategory())
                .description(request.getDescription())
                .status(ComplaintStatus.REPORTED)
                .severity(Severity.MEDIUM)
                .priority(Priority.P3)
                .aiStatus(AiStatus.PENDING)
                .slaDeadline(slaDeadline)
                .isAtRisk(false)
                .build();

        Complaint savedComplaint = complaintRepository.save(complaint);

        // Record initial status in tamper-proof audit history
        recordStatusTransition(savedComplaint, ComplaintStatus.REPORTED, student, "Complaint reported by student");

        // Attach initial evidence if provided
        if (request.getEvidenceUrls() != null) {
            for (String url : request.getEvidenceUrls()) {
                if (url != null && !url.trim().isEmpty()) {
                    ComplaintEvidence evidence = ComplaintEvidence.builder()
                            .complaint(savedComplaint)
                            .fileUrl(url)
                            .fileType("image/jpeg")
                            .uploader(student)
                            .evidenceStage(EvidenceStage.INTAKE)
                            .build();
                    evidenceRepository.save(evidence);
                }
            }
        }

        logger.info("New complaint created with case number: {}", caseNumber);
        return ComplaintMapper.toResponse(savedComplaint);
    }

    @Transactional(readOnly = true)
    public Complaint getComplaintEntity(Long id) {
        return complaintRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Complaint not found with ID: " + id));
    }

    @Transactional(readOnly = true)
    public ComplaintResponse getComplaintById(Long id) {
        return ComplaintMapper.toResponse(getComplaintEntity(id));
    }

    @Transactional(readOnly = true)
    public ComplaintDetailResponse getComplaintDetails(Long id) {
        Complaint complaint = getComplaintEntity(id);
        List<ComplaintEvidence> evidenceList = evidenceRepository.findByComplaintIdOrderByCreatedAtAsc(id);
        List<AssignmentHistory> assignmentList = assignmentHistoryRepository.findByComplaintIdOrderByCreatedAtDesc(id);
        List<CaseStatusHistory> statusList = statusHistoryRepository.findByComplaintIdOrderByCreatedAtAsc(id);
        Resolution resolution = resolutionRepository.findByComplaintId(id).orElse(null);

        return ComplaintMapper.toDetailResponse(complaint, evidenceList, assignmentList, statusList, resolution);
    }

    @Transactional(readOnly = true)
    public Page<ComplaintResponse> getStudentComplaints(Long studentId, Pageable pageable) {
        return complaintRepository.findByStudentIdOrderByCreatedAtDesc(studentId, pageable)
                .map(ComplaintMapper::toResponse);
    }

    @Transactional
    public void recordStatusTransition(Complaint complaint, ComplaintStatus newStatus, User changedBy, String reason) {
        ComplaintStatus previousStatus = complaint.getStatus();
        complaint.setStatus(newStatus);
        complaintRepository.save(complaint);

        CaseStatusHistory history = CaseStatusHistory.builder()
                .complaint(complaint)
                .previousStatus(previousStatus)
                .newStatus(newStatus)
                .changedBy(changedBy)
                .changeReason(reason)
                .build();

        statusHistoryRepository.save(history);
        logger.info("Complaint {} status transitioned from {} to {}", complaint.getCaseNumber(), previousStatus, newStatus);
    }

    @Transactional
    public void addEvidence(Long complaintId, Long uploaderId, String fileUrl, String fileType, Long size, EvidenceStage stage) {
        Complaint complaint = getComplaintEntity(complaintId);
        User uploader = userRepository.findById(uploaderId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + uploaderId));

        ComplaintEvidence evidence = ComplaintEvidence.builder()
                .complaint(complaint)
                .fileUrl(fileUrl)
                .fileType(fileType)
                .fileSizeBytes(size)
                .uploader(uploader)
                .evidenceStage(stage)
                .build();

        evidenceRepository.save(evidence);
    }
}
