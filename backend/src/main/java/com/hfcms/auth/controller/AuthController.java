package com.hfcms.auth.controller;

import com.hfcms.auth.dto.*;
import com.hfcms.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication & Security", description = "Endpoints for user registration, verification, sign-in, token rotation, and password reset")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    @Operation(summary = "Register new user account", description = "Creates a user account in PENDING_VERIFICATION status and dispatches a 6-digit email OTP.")
    public ResponseEntity<MessageResponse> signup(@Valid @RequestBody SignUpRequest request) {
        MessageResponse response = authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/verify")
    @Operation(summary = "Verify email with 6-digit code", description = "Validates the OTP code, activates the account, and returns access and refresh tokens.")
    public ResponseEntity<AuthResponse> verify(@Valid @RequestBody VerifyCodeRequest request) {
        AuthResponse response = authService.verify(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/resend-code")
    @Operation(summary = "Resend verification code", description = "Dispatches a new 6-digit verification code to the registered email.")
    public ResponseEntity<MessageResponse> resendCode(@Valid @RequestBody ResendCodeRequest request) {
        MessageResponse response = authService.resendCode(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/signin")
    @Operation(summary = "User sign in", description = "Authenticates credentials and returns access and rotating refresh tokens.")
    public ResponseEntity<AuthResponse> signin(@Valid @RequestBody SignInRequest request) {
        AuthResponse response = authService.signin(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    @Operation(summary = "Rotate refresh token", description = "Validates existing refresh token, revokes it, and issues a new access and refresh token pair.")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refresh(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/password-reset/request")
    @Operation(summary = "Request password reset", description = "Dispatches a password reset verification code if the email is registered.")
    public ResponseEntity<MessageResponse> requestPasswordReset(@Valid @RequestBody PasswordResetRequestDto request) {
        MessageResponse response = authService.requestPasswordReset(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/password-reset/confirm")
    @Operation(summary = "Confirm password reset", description = "Validates reset code, updates password, and revokes active sessions.")
    public ResponseEntity<MessageResponse> confirmPasswordReset(@Valid @RequestBody PasswordResetConfirmDto request) {
        MessageResponse response = authService.confirmPasswordReset(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    @Operation(summary = "User logout", description = "Revokes the active refresh token.")
    public ResponseEntity<MessageResponse> logout(@RequestBody(required = false) RefreshTokenRequest request) {
        if (request == null) {
            request = RefreshTokenRequest.builder().build();
        }
        MessageResponse response = authService.logout(request);
        return ResponseEntity.ok(response);
    }
}
