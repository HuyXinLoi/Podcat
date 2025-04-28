package com.example.podcat.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ListeningHistoryResponse {
    private String id;
    private String podcastId;
    private String podcastTitle;
    private String podcastImageUrl;
    private String listenedAt;
    private int progress;
    private int duration;
}
