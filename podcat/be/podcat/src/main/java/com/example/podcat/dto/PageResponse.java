package com.example.podcat.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Paginated response wrapper")
public class PageResponse<T> {
    @Schema(description = "List of items in the current page")
    private List<T> content;
    
    @Schema(description = "Current page number (0-based)", example = "0")
    private int page;
    
    @Schema(description = "Number of items per page", example = "20")
    private int size;
    
    @Schema(description = "Total number of items across all pages", example = "100")
    private long totalElements;
    
    @Schema(description = "Total number of pages", example = "5")
    private int totalPages;
}
