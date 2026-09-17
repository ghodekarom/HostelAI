package com.hfcms;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

@SpringBootApplication
@EnableScheduling
@EnableAsync
public class HfcmsApplication {

    private static final Logger log = LoggerFactory.getLogger(HfcmsApplication.class);

    public static void main(String[] args) {
        loadDotenv();
        SpringApplication.run(HfcmsApplication.class, args);
    }

    private static void loadDotenv() {
        Path[] candidates = new Path[]{
                Path.of(".env"),
                Path.of("backend", ".env"),
                Path.of("..", ".env"),
                Path.of("..", "backend", ".env")
        };

        for (Path candidate : candidates) {
            File file = candidate.toFile();
            if (file.exists() && file.isFile()) {
                log.info("Loading environment variables from .env file: {}", file.getAbsolutePath());
                try {
                    List<String> lines = Files.readAllLines(candidate);
                    for (String line : lines) {
                        String trimmed = line.trim();
                        if (trimmed.isEmpty() || trimmed.startsWith("#")) {
                            continue;
                        }
                        int eqIdx = trimmed.indexOf('=');
                        if (eqIdx > 0) {
                            String key = trimmed.substring(0, eqIdx).trim();
                            String value = trimmed.substring(eqIdx + 1).trim();
                            if ((value.startsWith("\"") && value.endsWith("\"")) ||
                                (value.startsWith("'") && value.endsWith("'"))) {
                                value = value.substring(1, value.length() - 1);
                            }
                            if (System.getProperty(key) == null && System.getenv(key) == null) {
                                System.setProperty(key, value);
                            }
                        }
                    }
                } catch (Exception e) {
                    log.warn("Failed to load .env from {}: {}", file.getAbsolutePath(), e.getMessage());
                }
                break;
            }
        }
    }
}

