package com.example.podcat.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class S3PresignedUrlResponse {
    private String presignedUrl;
    private String fileUrl;
}
