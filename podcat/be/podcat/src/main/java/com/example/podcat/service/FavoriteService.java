package com.example.podcat.service;

import com.example.podcat.dto.PageResponse;
import com.example.podcat.dto.PodcastResponse;
import com.example.podcat.exception.ResourceNotFoundException;
import com.example.podcat.model.Favorite;
import com.example.podcat.model.Podcast;
import com.example.podcat.repository.CategoryRepository;
import com.example.podcat.repository.FavoriteRepository;
import com.example.podcat.repository.PodcastRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final PodcastRepository podcastRepository;
    private final CategoryRepository categoryRepository;

    public void toggleFavorite(String userId, String podcastId) {
        if (!podcastRepository.existsById(podcastId)) {
            throw new ResourceNotFoundException("Podcast not found");
        }
        
        var favorite = favoriteRepository.findByUserIdAndPodcastId(userId, podcastId);
        
        if (favorite.isPresent()) {
            favoriteRepository.delete(favorite.get());
            
            // Decrement like count
            Podcast podcast = podcastRepository.findById(podcastId).get();
            podcast.setLikeCount(Math.max(0, podcast.getLikeCount() - 1));
            podcastRepository.save(podcast);
        } else {
            Favorite newFavorite = Favorite.builder()
                    .userId(userId)
                    .podcastId(podcastId)
                    .createdAt(Instant.now())
                    .build();
            favoriteRepository.save(newFavorite);
            
            // Increment like count
            Podcast podcast = podcastRepository.findById(podcastId).get();
            podcast.setLikeCount(podcast.getLikeCount() + 1);
            podcastRepository.save(podcast);
        }
    }

    public boolean isFavorite(String userId, String podcastId) {
        return favoriteRepository.existsByUserIdAndPodcastId(userId, podcastId);
    }

    public PageResponse<PodcastResponse> getUserFavorites(String userId, Pageable pageable) {
        Page<Favorite> favoritesPage = favoriteRepository
                .findByUserIdOrderByCreatedAtDesc(userId, pageable);
        
        List<PodcastResponse> content = favoritesPage.getContent().stream()
                .map(favorite -> {
                    Podcast podcast = podcastRepository.findById(favorite.getPodcastId())
                            .orElseThrow(() -> new ResourceNotFoundException("Podcast not found"));
                    
                    String categoryName = null;
                    if (podcast.getCategoryId() != null) {
                        categoryName = categoryRepository.findById(podcast.getCategoryId())
                                .map(category -> category.getName())
                                .orElse(null);
                    }
                    
                    return PodcastResponse.builder()
                            .id(podcast.getId())
                            .title(podcast.getTitle())
                            .description(podcast.getDescription())
                            .audioUrl(podcast.getAudioUrl())
                            .imageUrl(podcast.getImageUrl())
                            .createdAt(podcast.getCreatedAt().toString())
                            .userId(podcast.getUserId())
                            .categoryId(podcast.getCategoryId())
                            .categoryName(categoryName)
                            .tags(podcast.getTags())
                            .viewCount(podcast.getViewCount())
                            .likeCount(podcast.getLikeCount())
                            .duration(podcast.getDuration())
                            .isLiked(true) // It's in favorites, so it's liked
                            .build();
                })
                .collect(Collectors.toList());
        
        return new PageResponse<>(
                content,
                favoritesPage.getNumber(),
                favoritesPage.getSize(),
                favoritesPage.getTotalElements(),
                favoritesPage.getTotalPages()
        );
    }
}
