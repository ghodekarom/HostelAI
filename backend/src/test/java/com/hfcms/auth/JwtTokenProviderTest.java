package com.hfcms.auth;

import com.hfcms.auth.security.JwtTokenProvider;
import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.users.entity.UserStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collections;

import static org.assertj.core.api.Assertions.assertThat;

class JwtTokenProviderTest {

    private JwtTokenProvider jwtTokenProvider;

    @BeforeEach
    void setUp() {
        String secret = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
        jwtTokenProvider = new JwtTokenProvider(secret, 15L);
    }

    @Test
    void generateAndValidateToken_success() {
        UserPrincipal principal = UserPrincipal.builder()
                .id(42L)
                .email("test.student@hostel.edu")
                .fullName("Test Student")
                .roleName("ROLE_STUDENT")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_STUDENT")))
                .build();

        String token = jwtTokenProvider.generateAccessToken(principal);

        assertThat(token).isNotBlank();
        assertThat(jwtTokenProvider.validateToken(token)).isTrue();
        assertThat(jwtTokenProvider.getUserIdFromToken(token)).isEqualTo(42L);
    }

    @Test
    void validateToken_tamperedToken_returnsFalse() {
        UserPrincipal principal = UserPrincipal.builder()
                .id(42L)
                .email("test.student@hostel.edu")
                .fullName("Test Student")
                .roleName("ROLE_STUDENT")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_STUDENT")))
                .build();

        String token = jwtTokenProvider.generateAccessToken(principal);
        String tamperedToken = token + "xyz";

        assertThat(jwtTokenProvider.validateToken(tamperedToken)).isFalse();
    }
}
