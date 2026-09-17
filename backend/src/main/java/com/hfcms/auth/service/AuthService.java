package com.hfcms.auth.service;

import com.hfcms.auth.dto.*;
import com.hfcms.auth.entity.RefreshToken;
import com.hfcms.auth.entity.VerificationCode;
import com.hfcms.auth.entity.VerificationType;
import com.hfcms.auth.repository.RefreshTokenRepository;
import com.hfcms.auth.repository.VerificationCodeRepository;
import com.hfcms.auth.security.JwtTokenProvider;
import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.common.exception.BadRequestException;
import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.common.exception.UnauthorizedException;
import com.hfcms.users.entity.Role;
import com.hfcms.users.entity.User;
import com.hfcms.users.entity.UserStatus;
import com.hfcms.users.repository.RoleRepository;
import com.hfcms.users.repository.UserRepository;
import com.hfcms.notifications.email.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final VerificationCodeRepository verificationCodeRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final EmailService emailService;

    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.jwt.refresh-token-expiration-days:7}")
    private long refreshTokenExpirationDays;

    @Transactional
    public MessageResponse signup(SignUpRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        if (userRepository.existsByEmail(email)) {
            throw new BadRequestException("Email is already registered: " + email);
        }

        String roleName = request.getRole() != null && !request.getRole().isBlank()
                ? request.getRole().trim().toUpperCase()
                : "ROLE_STUDENT";

        if (!roleName.startsWith("ROLE_")) {
            roleName = "ROLE_" + roleName;
        }

        final String targetRole = roleName;
        Role role = roleRepository.findByName(targetRole)
                .orElseGet(() -> roleRepository.findByName("ROLE_STUDENT")
                        .orElseThrow(() -> new ResourceNotFoundException("Default role ROLE_STUDENT not found")));

        User user = User.builder()
                .email(email)
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName().trim())
                .phoneNumber(request.getPhoneNumber() != null ? request.getPhoneNumber().trim() : null)
                .role(role)
                .status(UserStatus.PENDING_VERIFICATION)
                .build();

        user = userRepository.save(user);

        // Generate and dispatch 6-digit verification code
        generateAndDispatchCode(user, VerificationType.SIGNUP_VERIFICATION);

        return MessageResponse.builder()
                .message("Registration successful. Please verify the 6-digit code sent to " + email)
                .build();
    }

    @Transactional
    public AuthResponse verify(VerifyCodeRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found with email: " + email));

        VerificationCode code = verificationCodeRepository
                .findFirstByUserIdAndTypeAndUsedAtIsNullOrderByCreatedAtDesc(user.getId(), VerificationType.SIGNUP_VERIFICATION)
                .orElseThrow(() -> new BadRequestException("No active verification code found for this account."));

        if (code.isExpired()) {
            throw new BadRequestException("Verification code has expired. Please request a new code.");
        }

        if (code.getAttempts() >= 5) {
            throw new BadRequestException("Maximum verification attempts exceeded. Please request a new code.");
        }

        code.setAttempts(code.getAttempts() + 1);

        String inputHash = hashSha256(request.getCode().trim());
        if (!inputHash.equals(code.getCodeHash())) {
            verificationCodeRepository.save(code);
            throw new BadRequestException("Invalid verification code. " + (5 - code.getAttempts()) + " attempts remaining.");
        }

        code.setUsedAt(Instant.now());
        verificationCodeRepository.save(code);

        user.setStatus(UserStatus.ACTIVE);
        user = userRepository.save(user);

        return createAuthResponse(user);
    }

    @Transactional
    public MessageResponse resendCode(ResendCodeRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found with email: " + email));

        VerificationType type = "PASSWORD_RESET".equalsIgnoreCase(request.getType())
                ? VerificationType.PASSWORD_RESET
                : VerificationType.SIGNUP_VERIFICATION;

        if (type == VerificationType.SIGNUP_VERIFICATION && user.getStatus() == UserStatus.ACTIVE) {
            throw new BadRequestException("Account is already verified and active. Please sign in.");
        }

        generateAndDispatchCode(user, type);

        return MessageResponse.builder()
                .message("A new 6-digit verification code has been dispatched to " + email)
                .build();
    }

    @Transactional
    public AuthResponse signin(SignInRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password."));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid email or password.");
        }

        if (user.getStatus() == UserStatus.PENDING_VERIFICATION) {
            throw new BadRequestException("Account verification pending. Please verify your email before signing in.");
        }

        if (user.getStatus() == UserStatus.SUSPENDED) {
            throw new UnauthorizedException("Account is suspended. Please contact hostel administration.");
        }

        return createAuthResponse(user);
    }

    @Transactional
    public AuthResponse refresh(RefreshTokenRequest request) {
        String rawToken = request.getRefreshToken().trim();
        String tokenHash = hashSha256(rawToken);

        RefreshToken token = refreshTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new UnauthorizedException("Invalid or expired refresh token."));

        if (!token.isValid()) {
            throw new UnauthorizedException("Refresh token is expired or revoked. Please sign in again.");
        }

        // Token rotation: Revoke old token
        token.setRevokedAt(Instant.now());
        refreshTokenRepository.save(token);

        // Issue new token pair
        return createAuthResponse(token.getUser());
    }

    @Transactional
    public MessageResponse logout(RefreshTokenRequest request) {
        if (request.getRefreshToken() != null && !request.getRefreshToken().isBlank()) {
            String tokenHash = hashSha256(request.getRefreshToken().trim());
            refreshTokenRepository.findByTokenHash(tokenHash).ifPresent(token -> {
                token.setRevokedAt(Instant.now());
                refreshTokenRepository.save(token);
            });
        }
        return MessageResponse.builder().message("Logged out successfully.").build();
    }

    @Transactional
    public MessageResponse requestPasswordReset(PasswordResetRequestDto request) {
        String email = request.getEmail().trim().toLowerCase();
        userRepository.findByEmail(email).ifPresent(user -> {
            generateAndDispatchCode(user, VerificationType.PASSWORD_RESET);
        });

        // Always return generic confirmation for privacy & security
        return MessageResponse.builder()
                .message("If this email address is registered, a password reset code has been sent.")
                .build();
    }

    @Transactional
    public MessageResponse confirmPasswordReset(PasswordResetConfirmDto request) {
        String email = request.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("Invalid password reset request."));

        VerificationCode code = verificationCodeRepository
                .findFirstByUserIdAndTypeAndUsedAtIsNullOrderByCreatedAtDesc(user.getId(), VerificationType.PASSWORD_RESET)
                .orElseThrow(() -> new BadRequestException("No active password reset code found for this account."));

        if (code.isExpired()) {
            throw new BadRequestException("Password reset code has expired. Please request a new code.");
        }

        if (code.getAttempts() >= 5) {
            throw new BadRequestException("Maximum attempts exceeded. Please request a new reset code.");
        }

        code.setAttempts(code.getAttempts() + 1);

        String inputHash = hashSha256(request.getCode().trim());
        if (!inputHash.equals(code.getCodeHash())) {
            verificationCodeRepository.save(code);
            throw new BadRequestException("Invalid reset code. " + (5 - code.getAttempts()) + " attempts remaining.");
        }

        code.setUsedAt(Instant.now());
        verificationCodeRepository.save(code);

        // Update password
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // Revoke all active refresh tokens
        refreshTokenRepository.revokeAllByUserId(user.getId(), Instant.now());

        return MessageResponse.builder()
                .message("Password updated successfully. Please sign in with your new password.")
                .build();
    }

    private void generateAndDispatchCode(User user, VerificationType type) {
        // Invalidate previous unused codes
        verificationCodeRepository.invalidateExistingCodes(user.getId(), type, Instant.now());

        String rawCode = String.format("%06d", secureRandom.nextInt(1000000));
        String codeHash = hashSha256(rawCode);

        VerificationCode code = VerificationCode.builder()
                .user(user)
                .codeHash(codeHash)
                .type(type)
                .expiresAt(Instant.now().plus(Duration.ofMinutes(15)))
                .attempts(0)
                .build();

        verificationCodeRepository.save(code);

        // Dispatch email notification to user
        String title = type == VerificationType.SIGNUP_VERIFICATION
                ? "Verify Your HFCMS Account"
                : "Reset Your HFCMS Password";
        String htmlBody = """
                <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 500px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 8px;">
                    <h2 style="color: #4f46e5; margin-top: 0;">%s</h2>
                    <p style="color: #4b5563; font-size: 14px;">Your 6-digit verification code is:</p>
                    <div style="background: #f3f4f6; font-size: 28px; font-weight: bold; letter-spacing: 6px; color: #111827; text-align: center; padding: 14px; border-radius: 6px; margin: 16px 0;">
                        %s
                    </div>
                    <p style="color: #6b7280; font-size: 13px;">This code will expire in 15 minutes. If you did not request this code, please ignore this email.</p>
                </div>
                """.formatted(title, rawCode);

        emailService.sendEmail(user.getEmail(), "[HFCMS] " + title, htmlBody, "Your HFCMS verification code is: " + rawCode);

        // Log code dispatch for local testing and observability
        log.info("[HFCMS AUTH] Dispatched 6-digit {} code to {}: {}", type, user.getEmail(), rawCode);
    }

    private AuthResponse createAuthResponse(User user) {
        UserPrincipal principal = UserPrincipal.create(user);
        String accessToken = jwtTokenProvider.generateAccessToken(principal);

        String rawRefreshToken = UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID().toString().replace("-", "");
        String refreshHash = hashSha256(rawRefreshToken);

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .tokenHash(refreshHash)
                .expiresAt(Instant.now().plus(Duration.ofDays(refreshTokenExpirationDays)))
                .build();

        refreshTokenRepository.save(refreshToken);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(rawRefreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtTokenProvider.getExpirationMs() / 1000)
                .userId(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .role(user.getRole().getName())
                .build();
    }

    private String hashSha256(String raw) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(raw.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}
