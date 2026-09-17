package com.hfcms.notifications.email;

import jakarta.mail.internet.MimeMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class SmtpEmailService implements EmailService {

    private final JavaMailSender mailSender;

    @Value("${app.email.from:no-reply@hfcms.internal}")
    private String fromAddress;

    @Autowired(required = false)
    public SmtpEmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    @Override
    public void sendEmail(String to, String subject, String htmlContent, String textContent) {
        if (mailSender == null) {
            log.warn("[EMAIL MOCK] JavaMailSender not configured. Email to {} with subject '{}' suppressed. Body: {}",
                    to, subject, textContent);
            return;
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(fromAddress, "HFCMS Case Manager");
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(textContent != null ? textContent : "", htmlContent != null ? htmlContent : textContent);

            mailSender.send(message);
            log.info("[EMAIL SENT] Successfully sent email to {} with subject '{}'", to, subject);
        } catch (Exception e) {
            log.warn("[EMAIL FAILED] Non-blocking failure to send email to {} with subject '{}': {}",
                    to, subject, e.getMessage());
        }
    }
}
