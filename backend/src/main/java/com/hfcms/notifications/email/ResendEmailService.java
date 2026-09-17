package com.hfcms.notifications.email;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class ResendEmailService {

    @Value("${app.email.resend-api-key:}")
    private String resendApiKey;

    @Value("${app.email.from:no-reply@hfcms.internal}")
    private String fromAddress;

    private final RestClient restClient = RestClient.builder()
            .baseUrl("https://api.resend.com")
            .build();

    public boolean sendViaResend(String to, String subject, String htmlContent) {
        if (resendApiKey == null || resendApiKey.isBlank()) {
            log.debug("[RESEND] Resend API key not configured, skipping Resend dispatch.");
            return false;
        }

        try {
            Map<String, Object> body = Map.of(
                    "from", fromAddress,
                    "to", List.of(to),
                    "subject", subject,
                    "html", htmlContent
            );

            restClient.post()
                    .uri("/emails")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + resendApiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .toBodilessEntity();

            log.info("[RESEND SENT] Successfully dispatched email via Resend to {}", to);
            return true;
        } catch (Exception e) {
            log.warn("[RESEND FAILED] Failed to send email via Resend to {}: {}", to, e.getMessage());
            return false;
        }
    }
}
