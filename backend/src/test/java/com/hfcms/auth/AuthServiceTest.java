package com.hfcms.auth;

import com.hfcms.auth.dto.*;
import com.hfcms.auth.entity.RefreshToken;
import com.hfcms.auth.entity.VerificationCode;
import com.hfcms.auth.entity.VerificationType;
import com.hfcms.auth.repository.RefreshTokenRepository;
import com.hfcms.auth.repository.VerificationCodeRepository;
import com.hfcms.auth.security.JwtTokenProvider;
import com.hfcms.auth.service.AuthService;
import com.hfcms.common.exception.BadRequestException;
import com.hfcms.common.exception.UnauthorizedException;
import com.hfcms.users.entity.Role;
import com.hfcms.users.entity.User;
import com.hfcms.users.entity.UserStatus;
import com.hfcms.users.repository.RoleRepository;
import com.hfcms.users.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private RoleRepository roleRepository;

    @Mock
    private VerificationCodeRepository verificationCodeRepository;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtTokenProvider jwtTokenProvider;

    @Mock
    private com.hfcms.notifications.email.EmailService emailService;

    @InjectMocks
    private AuthService authService;

    private User testUser;
    private Role studentRole;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(authService, "refreshTokenExpirationDays", 7L);

        studentRole = Role.builder()
                .id(1L)
                .name("ROLE_STUDENT")
                .description("Student role")
                .build();

        testUser = User.builder()
                .id(10L)
                .email("student@hostel.edu")
                .passwordHash("hashed_pwd")
                .fullName("Test Student")
                .role(studentRole)
                .status(UserStatus.ACTIVE)
                .build();
    }

    private String sha256(String raw) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(raw.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test
    void signup_success_createsUserPendingVerification() {
        SignUpRequest request = SignUpRequest.builder()
                .email("new.student@hostel.edu")
                .password("Password123!")
                .fullName("New Student")
                .build();

        when(userRepository.existsByEmail("new.student@hostel.edu")).thenReturn(false);
        when(roleRepository.findByName("ROLE_STUDENT")).thenReturn(Optional.of(studentRole));
        when(passwordEncoder.encode("Password123!")).thenReturn("hashed_Password123!");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User u = invocation.getArgument(0);
            u.setId(11L);
            return u;
        });

        MessageResponse response = authService.signup(request);

        assertThat(response.getMessage()).contains("Registration successful");
        verify(userRepository).save(argThat(u ->
                u.getStatus() == UserStatus.PENDING_VERIFICATION &&
                u.getEmail().equals("new.student@hostel.edu")));
        verify(verificationCodeRepository).save(any(VerificationCode.class));
    }

    @Test
    void signup_duplicateEmail_throwsBadRequestException() {
        SignUpRequest request = SignUpRequest.builder()
                .email("student@hostel.edu")
                .password("Password123!")
                .fullName("Duplicate")
                .build();

        when(userRepository.existsByEmail("student@hostel.edu")).thenReturn(true);

        assertThatThrownBy(() -> authService.signup(request))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("already registered");
    }

    @Test
    void verify_validCode_activatesAccountAndReturnsTokens() {
        testUser.setStatus(UserStatus.PENDING_VERIFICATION);
        String rawCode = "123456";

        VerificationCode code = VerificationCode.builder()
                .id(1L)
                .user(testUser)
                .codeHash(sha256(rawCode))
                .type(VerificationType.SIGNUP_VERIFICATION)
                .expiresAt(Instant.now().plus(Duration.ofMinutes(10)))
                .attempts(0)
                .build();

        when(userRepository.findByEmail("student@hostel.edu")).thenReturn(Optional.of(testUser));
        when(verificationCodeRepository.findFirstByUserIdAndTypeAndUsedAtIsNullOrderByCreatedAtDesc(
                10L, VerificationType.SIGNUP_VERIFICATION)).thenReturn(Optional.of(code));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(jwtTokenProvider.generateAccessToken(any())).thenReturn("jwt_access_token");
        when(jwtTokenProvider.getExpirationMs()).thenReturn(900000L);

        AuthResponse authResponse = authService.verify(
                VerifyCodeRequest.builder().email("student@hostel.edu").code("123456").build());

        assertThat(authResponse.getAccessToken()).isEqualTo("jwt_access_token");
        assertThat(authResponse.getRefreshToken()).isNotNull();
        assertThat(testUser.getStatus()).isEqualTo(UserStatus.ACTIVE);
        verify(refreshTokenRepository).save(any(RefreshToken.class));
    }

    @Test
    void verify_invalidCode_incrementsAttemptsAndThrows() {
        testUser.setStatus(UserStatus.PENDING_VERIFICATION);
        VerificationCode code = VerificationCode.builder()
                .id(1L)
                .user(testUser)
                .codeHash(sha256("123456"))
                .type(VerificationType.SIGNUP_VERIFICATION)
                .expiresAt(Instant.now().plus(Duration.ofMinutes(10)))
                .attempts(0)
                .build();

        when(userRepository.findByEmail("student@hostel.edu")).thenReturn(Optional.of(testUser));
        when(verificationCodeRepository.findFirstByUserIdAndTypeAndUsedAtIsNullOrderByCreatedAtDesc(
                10L, VerificationType.SIGNUP_VERIFICATION)).thenReturn(Optional.of(code));

        assertThatThrownBy(() -> authService.verify(
                VerifyCodeRequest.builder().email("student@hostel.edu").code("999999").build()))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("Invalid verification code");

        assertThat(code.getAttempts()).isEqualTo(1);
        verify(verificationCodeRepository).save(code);
    }

    @Test
    void signin_validCredentials_returnsTokens() {
        when(userRepository.findByEmail("student@hostel.edu")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("Password123!", "hashed_pwd")).thenReturn(true);
        when(jwtTokenProvider.generateAccessToken(any())).thenReturn("jwt_access_token");
        when(jwtTokenProvider.getExpirationMs()).thenReturn(900000L);

        AuthResponse response = authService.signin(
                SignInRequest.builder().email("student@hostel.edu").password("Password123!").build());

        assertThat(response.getAccessToken()).isEqualTo("jwt_access_token");
        assertThat(response.getRole()).isEqualTo("ROLE_STUDENT");
        verify(refreshTokenRepository).save(any(RefreshToken.class));
    }

    @Test
    void signin_wrongPassword_throwsUnauthorizedException() {
        when(userRepository.findByEmail("student@hostel.edu")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("wrong_pwd", "hashed_pwd")).thenReturn(false);

        assertThatThrownBy(() -> authService.signin(
                SignInRequest.builder().email("student@hostel.edu").password("wrong_pwd").build()))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessageContaining("Invalid email or password");
    }

    @Test
    void signin_pendingVerification_throwsBadRequestException() {
        testUser.setStatus(UserStatus.PENDING_VERIFICATION);
        when(userRepository.findByEmail("student@hostel.edu")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("Password123!", "hashed_pwd")).thenReturn(true);

        assertThatThrownBy(() -> authService.signin(
                SignInRequest.builder().email("student@hostel.edu").password("Password123!").build()))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("Account verification pending");
    }

    @Test
    void refresh_validToken_rotatesTokenAndReturnsNewPair() {
        String rawToken = "valid_refresh_token";
        String tokenHash = sha256(rawToken);

        RefreshToken token = RefreshToken.builder()
                .id(1L)
                .user(testUser)
                .tokenHash(tokenHash)
                .expiresAt(Instant.now().plus(Duration.ofDays(5)))
                .build();

        when(refreshTokenRepository.findByTokenHash(tokenHash)).thenReturn(Optional.of(token));
        when(jwtTokenProvider.generateAccessToken(any())).thenReturn("new_jwt_access");
        when(jwtTokenProvider.getExpirationMs()).thenReturn(900000L);

        AuthResponse response = authService.refresh(
                RefreshTokenRequest.builder().refreshToken(rawToken).build());

        assertThat(response.getAccessToken()).isEqualTo("new_jwt_access");
        assertThat(token.isRevoked()).isTrue();
        verify(refreshTokenRepository, times(2)).save(any(RefreshToken.class));
    }

    @Test
    void logout_validToken_marksRevoked() {
        String rawToken = "logout_refresh_token";
        String tokenHash = sha256(rawToken);

        RefreshToken token = RefreshToken.builder()
                .id(1L)
                .user(testUser)
                .tokenHash(tokenHash)
                .expiresAt(Instant.now().plus(Duration.ofDays(5)))
                .build();

        when(refreshTokenRepository.findByTokenHash(tokenHash)).thenReturn(Optional.of(token));

        MessageResponse response = authService.logout(
                RefreshTokenRequest.builder().refreshToken(rawToken).build());

        assertThat(response.getMessage()).contains("Logged out successfully");
        assertThat(token.isRevoked()).isTrue();
        verify(refreshTokenRepository).save(token);
    }
}
