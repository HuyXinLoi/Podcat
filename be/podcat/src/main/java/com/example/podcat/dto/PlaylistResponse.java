package com.example.podcat.dto;

import lombok.Builder;
import lombok.Data;

import java.util.Set;

@Data
@Builder
public class PlaylistResponse {
    private String id;
    private String name;
    private String userId;
    private Set<String> podcastIds;
}
