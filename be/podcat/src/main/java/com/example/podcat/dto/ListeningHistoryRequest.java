package com.example.podcat.dto;

import lombok.Data;

@Data
public class ListeningHistoryRequest {
    private String podcastId;
    private int progress;
}
