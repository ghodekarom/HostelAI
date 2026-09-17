package com.hfcms.complaints.service;

import com.hfcms.categories.entity.Category;
import com.hfcms.categories.repository.CategoryRepository;
import com.hfcms.complaints.assignment.repository.AssignmentHistoryRepository;
import com.hfcms.complaints.audit.repository.CaseStatusHistoryRepository;
import com.hfcms.complaints.dto.ComplaintResponse;
import com.hfcms.complaints.dto.CreateComplaintRequest;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import com.hfcms.complaints.repository.ComplaintEvidenceRepository;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.complaints.resolution.repository.ResolutionRepository;
import com.hfcms.hostels.entity.Block;
import com.hfcms.hostels.entity.Hostel;
import com.hfcms.hostels.repository.BlockRepository;
import com.hfcms.hostels.repository.HostelRepository;
import com.hfcms.hostels.repository.RoomRepository;
import com.hfcms.users.entity.Role;
import com.hfcms.users.entity.User;
import com.hfcms.users.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ComplaintServiceTest {

    @Mock
    private ComplaintRepository complaintRepository;
    @Mock
    private ComplaintEvidenceRepository evidenceRepository;
    @Mock
    private CaseStatusHistoryRepository statusHistoryRepository;
    @Mock
    private AssignmentHistoryRepository assignmentHistoryRepository;
    @Mock
    private ResolutionRepository resolutionRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private HostelRepository hostelRepository;
    @Mock
    private BlockRepository blockRepository;
    @Mock
    private RoomRepository roomRepository;
    @Mock
    private CategoryRepository categoryRepository;
    @Mock
    private com.hfcms.ai.service.AiComplaintService aiComplaintService;
    @Mock
    private com.hfcms.notifications.service.NotificationService notificationService;

    @InjectMocks
    private ComplaintService complaintService;

    private User testStudent;
    private Hostel testHostel;
    private Block testBlock;
    private Category testCategory;

    @BeforeEach
    void setUp() {
        Role studentRole = Role.builder().id(1L).name("ROLE_STUDENT").build();
        testStudent = User.builder().id(1L).email("student@test.com").fullName("John Doe").role(studentRole).build();
        testHostel = Hostel.builder().id(10L).name("Hostel Alpha").code("H-A").build();
        testBlock = Block.builder().id(20L).hostel(testHostel).name("Block 1").code("B1").build();
        testCategory = Category.builder().id(30L).name("Water supply").code("CAT_WATER").slaHoursP3(48).build();
    }

    @Test
    void testCreateComplaint_Success() {
        CreateComplaintRequest request = CreateComplaintRequest.builder()
                .hostelId(10L)
                .blockId(20L)
                .categoryId(30L)
                .description("Continuous water leakage in common washroom")
                .build();

        when(userRepository.findById(1L)).thenReturn(Optional.of(testStudent));
        when(hostelRepository.findById(10L)).thenReturn(Optional.of(testHostel));
        when(blockRepository.findById(20L)).thenReturn(Optional.of(testBlock));
        when(categoryRepository.findById(30L)).thenReturn(Optional.of(testCategory));

        when(complaintRepository.save(any(Complaint.class))).thenAnswer(invocation -> {
            Complaint c = invocation.getArgument(0);
            c.setId(100L);
            return c;
        });

        when(aiComplaintService.processComplaint(100L)).thenReturn(
                ComplaintResponse.builder()
                        .id(100L)
                        .caseNumber("HFCMS-2026-123456")
                        .status(ComplaintStatus.OPERATOR_REVIEW)
                        .priority(Priority.P3)
                        .severity(Severity.MEDIUM)
                        .slaDeadline(java.time.Instant.now())
                        .build()
        );

        ComplaintResponse response = complaintService.createComplaint(request, 1L);

        assertNotNull(response);
        assertEquals(100L, response.getId());
        assertTrue(response.getCaseNumber().startsWith("HFCMS-"));
        assertEquals(ComplaintStatus.OPERATOR_REVIEW, response.getStatus());
        assertEquals(Priority.P3, response.getPriority());
        assertEquals(Severity.MEDIUM, response.getSeverity());
        assertNotNull(response.getSlaDeadline());

        verify(statusHistoryRepository, times(1)).save(any());
        verify(aiComplaintService, times(1)).processComplaint(100L);
    }
}
