package com.example.podcat.dto;

import lombok.Data;

@Data
public class S3ConfigRequest {
    private String accessKeyId;
    private String secretAccessKey;
    private String region;
    private String bucketName;
}
