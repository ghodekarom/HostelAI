package com.hfcms.notifications;

import com.hfcms.notifications.email.EmailDispatcherService;
import com.hfcms.notifications.email.ResendEmailService;
import com.hfcms.notifications.email.SmtpEmailService;
import jakarta.mail.Session;
import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class EmailServiceTest {

    @Mock
    private JavaMailSender mailSender;

    @Mock
    private SmtpEmailService smtpEmailService;

    @Mock
    private ResendEmailService resendEmailService;

    private SmtpEmailService realSmtpService;
    private EmailDispatcherService dispatcherService;

    @BeforeEach
    void setUp() {
        realSmtpService = new SmtpEmailService(mailSender);
        ReflectionTestUtils.setField(realSmtpService, "fromAddress", "no-reply@hfcms.internal");

        dispatcherService = new EmailDispatcherService(smtpEmailService, resendEmailService);
    }

    @Test
    void smtpService_whenMailSenderNull_handlesGracefullyWithoutException() {
        SmtpEmailService nullSenderService = new SmtpEmailService(null);
        assertDoesNotThrow(() ->
                nullSenderService.sendEmail("test@example.com", "Test", "<b>Hello</b>", "Hello")
        );
    }

    @Test
    void smtpService_whenMailSenderPresent_constructsAndSendsMessage() {
        when(mailSender.createMimeMessage()).thenReturn(new MimeMessage((Session) null));

        assertDoesNotThrow(() ->
                realSmtpService.sendEmail("student@test.com", "Status Update", "<p>Resolved</p>", "Resolved")
        );

        verify(mailSender).send(any(MimeMessage.class));
    }

    @Test
    void dispatcherService_withMailpitProvider_delegatesToSmtp() {
        ReflectionTestUtils.setField(dispatcherService, "emailProvider", "mailpit");

        dispatcherService.sendEmail("student@test.com", "Subject", "<h1>Hi</h1>", "Hi");

        verify(smtpEmailService).sendEmail("student@test.com", "Subject", "<h1>Hi</h1>", "Hi");
        verifyNoInteractions(resendEmailService);
    }

    @Test
    void dispatcherService_withResendProvider_callsResendAndFallsBackOnFailure() {
        ReflectionTestUtils.setField(dispatcherService, "emailProvider", "resend");
        when(resendEmailService.sendViaResend("student@test.com", "Subject", "<h1>Hi</h1>")).thenReturn(false);

        dispatcherService.sendEmail("student@test.com", "Subject", "<h1>Hi</h1>", "Hi");

        verify(resendEmailService).sendViaResend("student@test.com", "Subject", "<h1>Hi</h1>");
        verify(smtpEmailService).sendEmail("student@test.com", "Subject", "<h1>Hi</h1>", "Hi");
    }
}
