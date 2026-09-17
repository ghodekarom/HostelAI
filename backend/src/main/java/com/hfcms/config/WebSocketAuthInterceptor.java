package com.hfcms.config;

import com.hfcms.auth.security.JwtTokenProvider;
import com.hfcms.auth.security.UserPrincipal;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtTokenProvider tokenProvider;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String token = extractToken(accessor);

            if (token != null && tokenProvider.validateToken(token)) {
                try {
                    Claims claims = tokenProvider.getClaimsFromToken(token);
                    Long userId = Long.parseLong(claims.getSubject());
                    String email = claims.get("email", String.class);
                    String fullName = claims.get("fullName", String.class);
                    String role = claims.get("role", String.class);

                    UserPrincipal principal = UserPrincipal.createFromClaims(userId, email, fullName, role);
                    UsernamePasswordAuthenticationToken auth =
                            new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());

                    accessor.setUser(auth);
                    log.info("[WS AUTH] Authenticated WebSocket connection for user: {} (Role: {})",
                            principal.getEmail(), principal.getRoleName());
                } catch (Exception e) {
                    log.warn("[WS AUTH] Failed to construct principal from JWT token: {}", e.getMessage());
                }
            } else {
                log.debug("[WS AUTH] Unauthenticated STOMP CONNECT frame received");
            }
        }

        return message;
    }

    private String extractToken(StompHeaderAccessor accessor) {
        // 1. Try 'Authorization' header: Bearer <token>
        List<String> authHeaders = accessor.getNativeHeader("Authorization");
        if (authHeaders != null && !authHeaders.isEmpty()) {
            String header = authHeaders.get(0);
            if (header.startsWith("Bearer ")) {
                return header.substring(7).trim();
            }
            return header.trim();
        }

        // 2. Try 'passcode' native header
        List<String> passcodeHeaders = accessor.getNativeHeader("passcode");
        if (passcodeHeaders != null && !passcodeHeaders.isEmpty()) {
            return passcodeHeaders.get(0).trim();
        }

        // 3. Try 'token' native header
        List<String> tokenHeaders = accessor.getNativeHeader("token");
        if (tokenHeaders != null && !tokenHeaders.isEmpty()) {
            return tokenHeaders.get(0).trim();
        }

        return null;
    }
}
