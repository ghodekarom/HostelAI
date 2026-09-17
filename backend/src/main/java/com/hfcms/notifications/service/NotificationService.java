package com.hfcms.notifications.service;

import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.notifications.dto.NotificationResponse;
import com.hfcms.notifications.dto.UnreadCountResponse;
import com.hfcms.notifications.email.EmailService;
import com.hfcms.notifications.entity.Notification;
import com.hfcms.notifications.repository.NotificationRepository;
import com.hfcms.users.entity.User;
import com.hfcms.users.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final SimpMessagingTemplate messagingTemplate;

    @Autowired
    public NotificationService(
            NotificationRepository notificationRepository,
            UserRepository userRepository,
            EmailService emailService,
            @Autowired(required = false) SimpMessagingTemplate messagingTemplate) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.messagingTemplate = messagingTemplate;
    }

    @Transactional
    public NotificationResponse sendNotification(
            Long userId,
            String title,
            String message,
            String type,
            String referenceId,
            boolean sendEmail) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found for notification with id: " + userId));

        Notification notification = Notification.builder()
                .user(user)
                .title(title)
                .message(message)
                .type(type)
                .referenceId(referenceId)
                .isRead(false)
                .build();

        Notification saved = notificationRepository.save(notification);
        NotificationResponse response = NotificationResponse.fromEntity(saved);

        // 1. Dispatch Real-Time WebSocket Event
        dispatchWebSocketEvent(userId, response);

        // 2. Dispatch Asynchronous Transactional Email if requested
        if (sendEmail && user.getEmail() != null && !user.getEmail().isBlank()) {
            dispatchEmailNotification(user.getEmail(), title, message, referenceId);
        }

        return response;
    }

    @Transactional(readOnly = true)
    public Page<NotificationResponse> getUserNotifications(Long userId, Pageable pageable) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(NotificationResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public UnreadCountResponse getUnreadCount(Long userId) {
        long count = notificationRepository.countByUserIdAndIsReadFalse(userId);
        return UnreadCountResponse.builder().unreadCount(count).build();
    }

    @Transactional
    public void markAsRead(Long id, Long userId) {
        notificationRepository.markAsRead(id, userId);
        dispatchUnreadCountUpdate(userId);
    }

    @Transactional
    public void markAllAsRead(Long userId) {
        notificationRepository.markAllAsRead(userId);
        dispatchUnreadCountUpdate(userId);
    }

    private void dispatchWebSocketEvent(Long userId, NotificationResponse response) {
        if (messagingTemplate == null) {
            log.debug("[WS DISPATCH] SimpMessagingTemplate not available; skipping socket push");
            return;
        }

        try {
            // User-scoped destination
            String destination = "/topic/user." + userId + ".notifications";
            messagingTemplate.convertAndSend(destination, response);
            log.info("[WS DISPATCH] Pushed real-time notification to {}", destination);

            dispatchUnreadCountUpdate(userId);
        } catch (Exception e) {
            log.warn("[WS DISPATCH FAILED] Could not push notification via WebSocket to user {}: {}",
                    userId, e.getMessage());
        }
    }

    private void dispatchUnreadCountUpdate(Long userId) {
        if (messagingTemplate == null) return;
        try {
            long count = notificationRepository.countByUserIdAndIsReadFalse(userId);
            String unreadDestination = "/topic/user." + userId + ".unread-count";
            messagingTemplate.convertAndSend(unreadDestination, new UnreadCountResponse(count));
        } catch (Exception e) {
            log.debug("[WS DISPATCH] Could not push unread count update to user {}: {}", userId, e.getMessage());
        }
    }

    private void dispatchEmailNotification(String toEmail, String title, String message, String referenceId) {
        String subject = "[HFCMS] " + title;
        String htmlBody = """
                <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff;">
                    <div style="border-bottom: 2px solid #4f46e5; padding-bottom: 12px; margin-bottom: 20px;">
                        <h2 style="color: #1e1b4b; margin: 0; font-size: 20px;">HFCMS AI Case Manager</h2>
                        <span style="color: #6b7280; font-size: 13px;">Hostel Facility Complaint Management System</span>
                    </div>
                    <div style="margin-bottom: 20px;">
                        <h3 style="color: #111827; font-size: 16px; margin: 0 0 8px 0;">%s</h3>
                        <p style="color: #374151; font-size: 14px; line-height: 1.6; margin: 0 0 12px 0;">%s</p>
                        %s
                    </div>
                    <div style="border-top: 1px solid #f3f4f6; padding-top: 16px; font-size: 12px; color: #9ca3af; text-align: center;">
                        This is an automated operational notification. Please do not reply directly to this email.
                    </div>
                </div>
                """.formatted(
                title,
                message,
                referenceId != null ? "<p style=\"font-size: 13px; color: #4b5563; background: #f9fafb; padding: 8px 12px; border-radius: 4px;\"><strong>Case Reference:</strong> " + referenceId + "</p>" : ""
        );

        emailService.sendEmail(toEmail, subject, htmlBody, message);
    }
}
