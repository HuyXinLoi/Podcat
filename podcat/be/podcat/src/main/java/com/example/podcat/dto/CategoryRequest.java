package com.example.podcat.dto;

import lombok.Data;

@Data
public class CategoryRequest {
    private String name;
    private String description;
    private String imageUrl;
}
