package com.example.podcat.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class CommentResponse {
    private String id;
    private String userId;
    private String content;
    private LocalDateTime createdAt;
}
