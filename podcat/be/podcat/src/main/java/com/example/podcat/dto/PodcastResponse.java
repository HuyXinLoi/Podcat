package com.example.podcat.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class PodcastResponse {
    @Schema(description = "Unique identifier", example = "60f1a5b3e8c7a12345678901")
    private String id;
    
    @Schema(description = "Title of the podcast", example = "The History of Rome")
    private String title;
    
    @Schema(description = "Description of the podcast")
    private String description;

    @Schema(description = "Author of the podcast", example = "Mike Duncan")
    private String author;
    
    @Schema(description = "URL to the audio file")
    private String audioUrl;
    
    @Schema(description = "URL to the podcast cover image")
    private String imageUrl;
    
    @Schema(description = "Creation timestamp", example = "2023-07-15T10:15:30Z")
    private String createdAt;
    
    @Schema(description = "User ID of the creator", example = "60f1a5b3e8c7a12345678902")
    private String userId;
    
    @Schema(description = "Category ID", example = "60f1a5b3e8c7a12345678903")
    private String categoryId;
    
    @Schema(description = "Category name", example = "History")
    private String categoryName;
    
    @Schema(description = "List of tags", example = "[\"history\", \"rome\", \"ancient\"]")
    private List<String> tags;
    
    @Schema(description = "Number of views", example = "1250")
    private int viewCount;
    
    @Schema(description = "Number of likes", example = "87")
    private int likeCount;
    
    @Schema(description = "Duration in seconds", example = "1800")
    private int duration;
    
    @Schema(description = "Whether the current user has liked this podcast", example = "true")
    private boolean isLiked;
}
