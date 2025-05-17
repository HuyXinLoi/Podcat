package com.example.podcat.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Document(collection = "listening_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ListeningHistory {
    @Id
    private String id;
    
    private String userId;
    private String podcastId;
    private Instant listenedAt;
    private int progress; // in seconds
}
