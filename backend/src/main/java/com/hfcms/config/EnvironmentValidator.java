package com.hfcms.config;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * Component responsible for validating that all required environment variables
 * and properties are properly configured according to active profile rules.
 * Fails fast with clear error logging if any essential configuration is missing.
 */
@Component
public class EnvironmentValidator {

    private static final Logger logger = LoggerFactory.getLogger(EnvironmentValidator.class);

    private final Environment environment;

    @Value("${spring.profiles.active:local}")
    private String activeProfile;

    public EnvironmentValidator(Environment environment) {
        this.environment = environment;
    }

    @PostConstruct
    public void validate() {
        logger.info("Initializing HFCMS Backend with active profile: '{}'", activeProfile);

        List<String> missingProperties = new ArrayList<>();

        // Core properties required across all environments
        checkProperty("spring.datasource.url", missingProperties);
        checkProperty("app.jwt.secret", missingProperties);

        // Production-specific mandatory checks
        if ("prod".equalsIgnoreCase(activeProfile) || "production".equalsIgnoreCase(activeProfile)) {
            checkProperty("spring.datasource.username", missingProperties);
            checkProperty("spring.datasource.password", missingProperties);
            checkProperty("app.jwt.secret", missingProperties);

            String jwtSecret = environment.getProperty("app.jwt.secret");
            if (jwtSecret != null && jwtSecret.length() < 32) {
                throw new IllegalStateException("FATAL: In production, SECURITY_JWT_SECRET must be at least 32 characters long.");
            }

            String aiProvider = environment.getProperty("app.ai.provider");
            if ("anthropic".equalsIgnoreCase(aiProvider)) {
                String apiKey = environment.getProperty("app.ai.api-key");
                if (apiKey == null || apiKey.trim().isEmpty() || apiKey.startsWith("sk-ant-your")) {
                    logger.warn("WARNING: AI_ANTHROPIC_API_KEY is missing or using placeholder in production profile.");
                }
            }
        }

        if (!missingProperties.isEmpty()) {
            String errorMsg = String.format("FATAL: Missing mandatory configuration properties: %s. " +
                    "Ensure your .env file or environment variables are correctly populated.", missingProperties);
            logger.error(errorMsg);
            throw new IllegalStateException(errorMsg);
        }

        logger.info("Environment configuration validation successful for profile '{}'", activeProfile);
    }

    private void checkProperty(String propertyKey, List<String> missingProperties) {
        String value = environment.getProperty(propertyKey);
        if (value == null || value.trim().isEmpty()) {
            missingProperties.add(propertyKey);
        }
    }
}
