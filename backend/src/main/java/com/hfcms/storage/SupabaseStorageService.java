package com.hfcms.storage;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
@ConditionalOnProperty(name = "app.storage.provider", havingValue = "supabase")
public class SupabaseStorageService implements StorageService {

    private static final Logger logger = LoggerFactory.getLogger(SupabaseStorageService.class);

    @Value("${app.storage.supabase.url:}")
    private String supabaseUrl;

    @Value("${app.storage.supabase.key:}")
    private String supabaseKey;

    @Value("${app.storage.supabase.bucket:hfcms-evidence}")
    private String bucketName;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public String uploadFile(MultipartFile file, String folder) throws IOException {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("Cannot upload empty file");
        }

        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        String storedFilename = folder + "/" + UUID.randomUUID() + extension;
        String uploadUrl = String.format("%s/storage/v1/object/%s/%s", supabaseUrl, bucketName, storedFilename);

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + supabaseKey);
        headers.set("apikey", supabaseKey);
        headers.setContentType(MediaType.parseMediaType(file.getContentType() != null ? file.getContentType() : "application/octet-stream"));

        HttpEntity<byte[]> entity = new HttpEntity<>(file.getBytes(), headers);

        try {
            ResponseEntity<String> response = restTemplate.exchange(uploadUrl, HttpMethod.POST, entity, String.class);
            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("Successfully uploaded file to Supabase Storage: {}", storedFilename);
                return getFileUrl(storedFilename);
            } else {
                throw new IOException("Failed to upload to Supabase: HTTP " + response.getStatusCode());
            }
        } catch (Exception e) {
            logger.error("Error during Supabase Storage upload: {}", e.getMessage(), e);
            throw new IOException("Supabase Storage error: " + e.getMessage(), e);
        }
    }

    @Override
    public String getFileUrl(String filename) {
        return String.format("%s/storage/v1/object/public/%s/%s", supabaseUrl, bucketName, filename);
    }

    @Override
    public void deleteFile(String filename) {
        String deleteUrl = String.format("%s/storage/v1/object/%s/%s", supabaseUrl, bucketName, filename);
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + supabaseKey);
        headers.set("apikey", supabaseKey);
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        try {
            restTemplate.exchange(deleteUrl, HttpMethod.DELETE, entity, Void.class);
        } catch (Exception e) {
            logger.error("Failed to delete file from Supabase Storage: {}", filename, e);
        }
    }
}
