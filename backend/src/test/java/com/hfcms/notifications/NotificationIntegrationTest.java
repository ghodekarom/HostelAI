package com.hfcms.notifications;

import com.hfcms.auth.security.JwtTokenProvider;
import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.notifications.entity.Notification;
import com.hfcms.notifications.repository.NotificationRepository;
import com.hfcms.users.entity.Role;
import com.hfcms.users.entity.User;
import com.hfcms.users.entity.UserStatus;
import com.hfcms.users.repository.RoleRepository;
import com.hfcms.users.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;
import java.util.UUID;

import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class NotificationIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    private User testUser;
    private String studentToken;
    private Notification testNotification;

    @BeforeEach
    void setUp() {
        Role studentRole = roleRepository.findByName("ROLE_STUDENT")
                .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_STUDENT").description("Student").build()));

        String uniqueEmail = "notif-student-" + UUID.randomUUID().toString().substring(0, 8) + "@hostel.edu";
        testUser = userRepository.save(User.builder()
                .email(uniqueEmail)
                .passwordHash("hashed")
                .fullName("Test Notif Student")
                .role(studentRole)
                .status(UserStatus.ACTIVE)
                .build());

        UserPrincipal principal = UserPrincipal.builder()
                .id(testUser.getId())
                .email(testUser.getEmail())
                .fullName(testUser.getFullName())
                .roleName("ROLE_STUDENT")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_STUDENT")))
                .build();

        studentToken = jwtTokenProvider.generateAccessToken(principal);

        testNotification = notificationRepository.save(Notification.builder()
                .user(testUser)
                .title("Case Assigned")
                .message("Technician assigned to your case")
                .type("ASSIGNED")
                .referenceId("HFCMS-2026-TEST")
                .isRead(false)
                .build());
    }

    @Test
    void unauthenticatedAccess_toNotifications_isForbidden() throws Exception {
        mockMvc.perform(get("/api/v1/notifications"))
                .andExpect(status().isForbidden());
    }

    @Test
    void authenticatedStudent_canFetchNotifications() throws Exception {
        mockMvc.perform(get("/api/v1/notifications")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.content[0].title", is("Case Assigned")))
                .andExpect(jsonPath("$.data.content[0].referenceId", is("HFCMS-2026-TEST")));
    }

    @Test
    void authenticatedStudent_canGetUnreadCount() throws Exception {
        mockMvc.perform(get("/api/v1/notifications/unread-count")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.unreadCount", greaterThanOrEqualTo(1)));
    }

    @Test
    void authenticatedStudent_canMarkNotificationAsRead() throws Exception {
        mockMvc.perform(post("/api/v1/notifications/" + testNotification.getId() + "/read")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)));
    }

    @Test
    void authenticatedStudent_canMarkAllNotificationsAsRead() throws Exception {
        mockMvc.perform(post("/api/v1/notifications/read-all")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)));

        mockMvc.perform(get("/api/v1/notifications/unread-count")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.unreadCount", is(0)));
    }
}
