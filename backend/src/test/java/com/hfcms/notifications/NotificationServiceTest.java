package com.hfcms.notifications;

import com.hfcms.notifications.dto.NotificationResponse;
import com.hfcms.notifications.dto.UnreadCountResponse;
import com.hfcms.notifications.email.EmailService;
import com.hfcms.notifications.entity.Notification;
import com.hfcms.notifications.repository.NotificationRepository;
import com.hfcms.notifications.service.NotificationService;
import com.hfcms.users.entity.Role;
import com.hfcms.users.entity.User;
import com.hfcms.users.entity.UserStatus;
import com.hfcms.users.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailService emailService;

    @Mock
    private SimpMessagingTemplate messagingTemplate;

    @InjectMocks
    private NotificationService notificationService;

    private User testUser;

    @BeforeEach
    void setUp() {
        Role role = Role.builder().id(1L).name("ROLE_STUDENT").build();
        testUser = User.builder()
                .id(10L)
                .email("student@test.com")
                .fullName("Alex Morgan")
                .role(role)
                .status(UserStatus.ACTIVE)
                .build();
    }

    @Test
    void sendNotification_savesNotification_pushesWebSocket_andSendsEmail() {
        when(userRepository.findById(10L)).thenReturn(Optional.of(testUser));
        when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> {
            Notification n = inv.getArgument(0);
            n.setId(100L);
            n.setCreatedAt(Instant.now());
            return n;
        });
        when(notificationRepository.countByUserIdAndIsReadFalse(10L)).thenReturn(1L);

        NotificationResponse response = notificationService.sendNotification(
                10L,
                "Technician Dispatched",
                "A technician has been dispatched to your room.",
                "ASSIGNED",
                "HFCMS-2026-001",
                true
        );

        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(100L);
        assertThat(response.getTitle()).isEqualTo("Technician Dispatched");
        assertThat(response.getReferenceId()).isEqualTo("HFCMS-2026-001");
        assertThat(response.isRead()).isFalse();

        // Verify WebSocket push
        verify(messagingTemplate).convertAndSend(eq("/topic/user.10.notifications"), any(NotificationResponse.class));
        verify(messagingTemplate).convertAndSend(eq("/topic/user.10.unread-count"), any(UnreadCountResponse.class));

        // Verify transactional email dispatch
        verify(emailService).sendEmail(eq("student@test.com"), eq("[HFCMS] Technician Dispatched"), anyString(), anyString());
    }

    @Test
    void sendNotification_withoutEmail_skipsEmailDispatch() {
        when(userRepository.findById(10L)).thenReturn(Optional.of(testUser));
        when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> {
            Notification n = inv.getArgument(0);
            n.setId(101L);
            return n;
        });

        NotificationResponse response = notificationService.sendNotification(
                10L,
                "Task Progress",
                "Work is ongoing",
                "STATUS_CHANGED",
                "HFCMS-2026-001",
                false
        );

        assertThat(response).isNotNull();
        verifyNoInteractions(emailService);
    }

    @Test
    void getUserNotifications_returnsPaginatedFeed() {
        Notification n1 = Notification.builder()
                .id(1L)
                .user(testUser)
                .title("Note 1")
                .message("Message 1")
                .type("STATUS_CHANGED")
                .isRead(false)
                .createdAt(Instant.now())
                .build();

        PageRequest pageRequest = PageRequest.of(0, 10);
        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(10L, pageRequest))
                .thenReturn(new PageImpl<>(List.of(n1), pageRequest, 1));

        Page<NotificationResponse> result = notificationService.getUserNotifications(10L, pageRequest);

        assertThat(result.getContent()).hasSize(1);
        assertThat(result.getContent().get(0).getTitle()).isEqualTo("Note 1");
    }

    @Test
    void getUnreadCount_returnsAccurateCount() {
        when(notificationRepository.countByUserIdAndIsReadFalse(10L)).thenReturn(5L);

        UnreadCountResponse count = notificationService.getUnreadCount(10L);

        assertThat(count.getUnreadCount()).isEqualTo(5L);
    }

    @Test
    void markAsRead_updatesDatabase_andDispatchesUnreadCount() {
        when(notificationRepository.countByUserIdAndIsReadFalse(10L)).thenReturn(2L);

        notificationService.markAsRead(100L, 10L);

        verify(notificationRepository).markAsRead(100L, 10L);
        verify(messagingTemplate).convertAndSend(eq("/topic/user.10.unread-count"), any(UnreadCountResponse.class));
    }

    @Test
    void markAllAsRead_updatesDatabase_andDispatchesUnreadCount() {
        when(notificationRepository.countByUserIdAndIsReadFalse(10L)).thenReturn(0L);

        notificationService.markAllAsRead(10L);

        verify(notificationRepository).markAllAsRead(10L);
        verify(messagingTemplate).convertAndSend(eq("/topic/user.10.unread-count"), any(UnreadCountResponse.class));
    }
}
