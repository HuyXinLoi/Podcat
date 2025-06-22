package com.example.podcat.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

@Data
public class PodcastRequest {
    @Schema(description = "Title of the podcast", example = "The History of Rome")
    private String title;
    
    @Schema(description = "Description of the podcast", 
            example = "A weekly podcast tracing the history of the Roman Empire...")
    private String description;

    @Schema(description = "Author of the podcast", example = "Mike Duncan")
    private String author;
    
    @Schema(description = "URL to the audio file", 
            example = "https://example.com/podcasts/rome-ep1.mp3")
    private String audioUrl;
    
    @Schema(description = "URL to the podcast cover image", 
            example = "https://example.com/images/rome-podcast.jpg")
    private String imageUrl;
    
    @Schema(description = "Category ID", example = "60f1a5b3e8c7a12345678901")
    private String categoryId;
    
    @Schema(description = "List of tags", example = "[\"history\", \"rome\", \"ancient\"]")
    private List<String> tags;
    
    @Schema(description = "Duration in seconds", example = "1800")
    private int duration;
}
