package com.example.podcat.service;

import com.example.podcat.dto.CategoryRequest;
import com.example.podcat.dto.CategoryResponse;
import com.example.podcat.exception.ResourceNotFoundException;
import com.example.podcat.model.Category;
import com.example.podcat.repository.CategoryRepository;
import com.example.podcat.repository.PodcastRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final PodcastRepository podcastRepository;

    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public CategoryResponse getCategoryById(String id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
        return mapToResponse(category);
    }

    public CategoryResponse createCategory(CategoryRequest request) {
        Category category = Category.builder()
                .name(request.getName())
                .description(request.getDescription())
                .imageUrl(request.getImageUrl())
                .build();
        
        categoryRepository.save(category);
        return mapToResponse(category);
    }

    public CategoryResponse updateCategory(String id, CategoryRequest request) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
        
        category.setName(request.getName());
        category.setDescription(request.getDescription());
        category.setImageUrl(request.getImageUrl());
        
        categoryRepository.save(category);
        return mapToResponse(category);
    }

    public void deleteCategory(String id) {
        categoryRepository.deleteById(id);
    }

    public List<CategoryResponse> searchCategories(String keyword) {
        return categoryRepository.findByNameContainingIgnoreCase(keyword).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private CategoryResponse mapToResponse(Category category) {
        // Count podcasts in this category
        // This is a placeholder - you'll need to modify the Podcast model to include categoryId
        int podcastCount = 0; // podcastRepository.countByCategoryId(category.getId());
        
        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .imageUrl(category.getImageUrl())
                .podcastCount(podcastCount)
                .build();
    }
}
