package com.example.podcat.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CategoryResponse {
    private String id;
    private String name;
    private String description;
    private String imageUrl;
    private int podcastCount;
}
