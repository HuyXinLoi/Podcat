package com.example.podcat.dto;

import lombok.Data;

@Data
public class UserProfileRequest {
    private String name;
    private String bio;
    private String avatarUrl;
}
