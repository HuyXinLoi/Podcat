package com.example.podcat.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserProfileResponse {
    private String id;
    private String userId;
    private String username;
    private String name;
    private String bio;
    private String avatarUrl;
    private int podcastCount;
    private int playlistCount;
}
