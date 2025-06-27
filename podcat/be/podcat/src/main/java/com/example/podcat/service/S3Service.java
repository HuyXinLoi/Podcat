package com.example.podcat.service;

import com.amazonaws.HttpMethod;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.GeneratePresignedUrlRequest;
import com.example.podcat.dto.S3ConfigRequest;
import com.example.podcat.dto.S3PresignedUrlRequest;
import com.example.podcat.dto.S3PresignedUrlResponse;
import com.example.podcat.model.S3Configuration;
import com.example.podcat.repository.S3ConfigurationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.net.URL;
import java.util.Date;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class S3Service {

    private final S3ConfigurationRepository s3ConfigRepository;
    private final AmazonS3 amazonS3;

    public void saveS3Configuration(String userId, S3ConfigRequest request) {
        // Deactivate existing configurations
        s3ConfigRepository.findByUserIdAndIsActiveTrue(userId)
                .ifPresent(config -> {
                    config.setActive(false);
                    s3ConfigRepository.save(config);
                });

        // Save new configuration
        S3Configuration config = S3Configuration.builder()
                .userId(userId)
                .accessKeyId(request.getAccessKeyId())
                .secretAccessKey(request.getSecretAccessKey())
                .region(request.getRegion())
                .bucketName(request.getBucketName())
                .isActive(true)
                .build();

        s3ConfigRepository.save(config);
    }

    public S3PresignedUrlResponse generatePresignedUrl(String userId, S3PresignedUrlRequest request) {
        S3Configuration config = s3ConfigRepository.findByUserIdAndIsActiveTrue(userId)
                .or(() -> s3ConfigRepository.findFirstByIsActiveTrueOrderByIdDesc())
                .orElseThrow(() -> new RuntimeException("S3 configuration not found"));

        if (amazonS3 == null) {
            throw new RuntimeException("S3 client not configured");
        }

        // Generate unique file name
        String fileExtension = getFileExtension(request.getFileName());
        String uniqueFileName = request.getUploadType() + "/" + UUID.randomUUID().toString() + fileExtension;

        // Generate presigned URL (valid for 15 minutes)
        Date expiration = new Date();
        long expTimeMillis = expiration.getTime();
        expTimeMillis += 1000 * 60 * 15; // 15 minutes
        expiration.setTime(expTimeMillis);

        GeneratePresignedUrlRequest generatePresignedUrlRequest = new GeneratePresignedUrlRequest(
                config.getBucketName(), uniqueFileName)
                .withMethod(HttpMethod.PUT)
                .withExpiration(expiration);

        generatePresignedUrlRequest.addRequestParameter("Content-Type", request.getFileType());

        URL presignedUrl = amazonS3.generatePresignedUrl(generatePresignedUrlRequest);
        String fileUrl = String.format("https://%s.s3.%s.amazonaws.com/%s", 
                config.getBucketName(), config.getRegion(), uniqueFileName);

        return new S3PresignedUrlResponse(presignedUrl.toString(), fileUrl);
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf('.') == -1) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf('.'));
    }
}
