package com.example.podcat.controller;

import com.example.podcat.dto.S3ConfigRequest;
import com.example.podcat.dto.S3PresignedUrlRequest;
import com.example.podcat.dto.S3PresignedUrlResponse;
import com.example.podcat.security.JwtService;
import com.example.podcat.service.S3Service;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/upload/s3")
@RequiredArgsConstructor
@Tag(name = "S3 Upload", description = "AWS S3 file upload API")
public class S3UploadController {

    private final S3Service s3Service;
    private final JwtService jwtService;

    @PostMapping("/config")
    @Operation(
        summary = "Save S3 configuration",
        description = "Save AWS S3 credentials and configuration",
        security = @SecurityRequirement(name = "bearer-key")
    )
    public ResponseEntity<String> saveS3Config(
            @RequestBody S3ConfigRequest request,
            @RequestHeader("Authorization") String auth) {
        try {
            String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
            s3Service.saveS3Configuration(userId, request);
            return ResponseEntity.ok("S3 configuration saved successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to save S3 configuration: " + e.getMessage());
        }
    }

    @PostMapping("/presigned")
    @Operation(
        summary = "Generate presigned URL",
        description = "Generate a presigned URL for uploading files to S3",
        security = @SecurityRequirement(name = "bearer-key")
    )
    public ResponseEntity<S3PresignedUrlResponse> generatePresignedUrl(
            @RequestBody S3PresignedUrlRequest request,
            @RequestHeader("Authorization") String auth) {
        try {
            String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
            S3PresignedUrlResponse response = s3Service.generatePresignedUrl(userId, request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
}
