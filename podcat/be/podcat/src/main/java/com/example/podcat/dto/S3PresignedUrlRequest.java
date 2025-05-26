package com.example.podcat.dto;

import lombok.Data;

@Data
public class S3PresignedUrlRequest {
    private String fileName;
    private String fileType;
    private String uploadType;
}
