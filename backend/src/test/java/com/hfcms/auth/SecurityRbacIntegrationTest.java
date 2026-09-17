package com.hfcms.auth;

import com.hfcms.auth.security.JwtTokenProvider;
import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.users.entity.UserStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class SecurityRbacIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Test
    void unauthenticatedRequest_toProtectedEndpoint_isRejected() throws Exception {
        mockMvc.perform(get("/api/v1/operator/queue"))
                .andExpect(status().isForbidden());
    }

    @Test
    void publicAuthEndpoint_isAccessibleWithoutToken() throws Exception {
        mockMvc.perform(post("/api/v1/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"invalid-format\",\"password\":\"pwd\",\"fullName\":\"\"}"))
                // Returns 400 Bad Request (validation failure), NOT 401/403 (security filter passes)
                .andExpect(status().isBadRequest());
    }

    @Test
    void studentToken_accessingOperatorQueue_isForbidden() throws Exception {
        UserPrincipal student = UserPrincipal.builder()
                .id(101L)
                .email("student101@hostel.edu")
                .fullName("Student 101")
                .roleName("ROLE_STUDENT")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_STUDENT")))
                .build();

        String token = jwtTokenProvider.generateAccessToken(student);

        mockMvc.perform(get("/api/v1/operator/queue")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    @Test
    void operatorToken_accessingOperatorQueue_isAllowed() throws Exception {
        UserPrincipal operator = UserPrincipal.builder()
                .id(202L)
                .email("operator202@hostel.edu")
                .fullName("Operator 202")
                .roleName("ROLE_OPERATOR")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_OPERATOR")))
                .build();

        String token = jwtTokenProvider.generateAccessToken(operator);

        mockMvc.perform(get("/api/v1/operator/queue")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());
    }
}
