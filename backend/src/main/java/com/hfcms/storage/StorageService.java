package com.hfcms.storage;

import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface StorageService {
    String uploadFile(MultipartFile file, String folder) throws IOException;
    String getFileUrl(String filename);
    void deleteFile(String filename);
}
