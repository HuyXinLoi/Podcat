package com.example.podcat.controller;

import com.example.podcat.dto.CategoryRequest;
import com.example.podcat.dto.CategoryResponse;
import com.example.podcat.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
@Tag(name = "Categories", description = "Category management API")
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping
    @Operation(
        summary = "Get all categories",
        description = "Returns a list of all podcast categories",
        responses = {
            @ApiResponse(
                responseCode = "200", 
                description = "List of categories",
                content = @Content(schema = @Schema(implementation = CategoryResponse.class))
            )
        }
    )
    public ResponseEntity<List<CategoryResponse>> getAllCategories() {
        return ResponseEntity.ok(categoryService.getAllCategories());
    }

    @GetMapping("/{id}")
    @Operation(
        summary = "Get category by ID",
        description = "Returns a category by its ID",
        responses = {
            @ApiResponse(
                responseCode = "200", 
                description = "Category found",
                content = @Content(schema = @Schema(implementation = CategoryResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "Category not found")
        }
    )
    public ResponseEntity<CategoryResponse> getCategoryById(
            @Parameter(description = "Category ID") @PathVariable String id) {
        return ResponseEntity.ok(categoryService.getCategoryById(id));
    }

    @PostMapping
    @Operation(
        summary = "Create a new category",
        description = "Creates a new podcast category",
        security = @SecurityRequirement(name = "Bearer Authentication"),
        responses = {
            @ApiResponse(
                responseCode = "200", 
                description = "Category created successfully",
                content = @Content(schema = @Schema(implementation = CategoryResponse.class))
            ),
            @ApiResponse(responseCode = "401", description = "Unauthorized")
        }
    )
    public ResponseEntity<CategoryResponse> createCategory(@RequestBody CategoryRequest request) {
        return ResponseEntity.ok(categoryService.createCategory(request));
    }

    @PutMapping("/{id}")
    @Operation(
        summary = "Update category",
        description = "Updates an existing podcast category",
        security = @SecurityRequirement(name = "Bearer Authentication"),
        responses = {
            @ApiResponse(
                responseCode = "200", 
                description = "Category updated successfully",
                content = @Content(schema = @Schema(implementation = CategoryResponse.class))
            ),
            @ApiResponse(responseCode = "401", description = "Unauthorized"),
            @ApiResponse(responseCode = "404", description = "Category not found")
        }
    )
    public ResponseEntity<CategoryResponse> updateCategory(
            @Parameter(description = "Category ID") @PathVariable String id,
            @RequestBody CategoryRequest request) {
        return ResponseEntity.ok(categoryService.updateCategory(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(
        summary = "Delete category",
        description = "Deletes a podcast category",
        security = @SecurityRequirement(name = "Bearer Authentication"),
        responses = {
            @ApiResponse(responseCode = "204", description = "Category deleted successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized"),
            @ApiResponse(responseCode = "404", description = "Category not found")
        }
    )
    public ResponseEntity<Void> deleteCategory(
            @Parameter(description = "Category ID") @PathVariable String id) {
        categoryService.deleteCategory(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/search")
    @Operation(
        summary = "Search categories",
        description = "Returns a list of categories matching the search keyword",
        responses = {
            @ApiResponse(
                responseCode = "200", 
                description = "Search results",
                content = @Content(schema = @Schema(implementation = CategoryResponse.class))
            )
        }
    )
    public ResponseEntity<List<CategoryResponse>> searchCategories(
            @Parameter(description = "Search keyword") @RequestParam String keyword) {
        return ResponseEntity.ok(categoryService.searchCategories(keyword));
    }
}
