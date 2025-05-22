package com.example.podcat.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "podcasts")
public class Podcast {
    @Id
    private String id;

    private String title;
    private String description;
    private String audioUrl;
    private String imageUrl;
    private Instant createdAt;
    
    // New fields
    private String userId; // Creator of the podcast
    private String categoryId;
    private List<String> tags = new ArrayList<>();
    private int viewCount = 0;
    private int likeCount = 0;
    private int duration = 0; // in seconds
}
