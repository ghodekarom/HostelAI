package com.hfcms.notifications.email;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Primary;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@Primary
@RequiredArgsConstructor
public class EmailDispatcherService implements EmailService {

    private final SmtpEmailService smtpEmailService;
    private final ResendEmailService resendEmailService;

    @Value("${app.email.provider:mailpit}")
    private String emailProvider;

    @Override
    @Async
    public void sendEmail(String to, String subject, String htmlContent, String textContent) {
        if (to == null || to.isBlank()) {
            return;
        }

        try {
            if ("resend".equalsIgnoreCase(emailProvider)) {
                boolean ok = resendEmailService.sendViaResend(to, subject, htmlContent);
                if (!ok) {
                    log.debug("[EMAIL FALLBACK] Falling back to SMTP for {}", to);
                    smtpEmailService.sendEmail(to, subject, htmlContent, textContent);
                }
            } else {
                smtpEmailService.sendEmail(to, subject, htmlContent, textContent);
            }
        } catch (Exception e) {
            log.error("[EMAIL DISPATCH ERROR] Non-blocking error dispatching email to {}: {}", to, e.getMessage());
        }
    }
}
