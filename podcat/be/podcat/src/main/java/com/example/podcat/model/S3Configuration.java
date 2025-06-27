package com.example.podcat.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "s3_configurations")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class S3Configuration {
    @Id
    private String id;
    
    private String userId;
    private String accessKeyId;
    private String secretAccessKey;
    private String region;
    private String bucketName;
    private boolean isActive;
}
