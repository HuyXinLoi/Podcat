package com.example.podcat.repository;

import com.example.podcat.model.Favorite;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface FavoriteRepository extends MongoRepository<Favorite, String> {
    Page<Favorite> findByUserIdOrderByCreatedAtDesc(String userId, Pageable pageable);
    Optional<Favorite> findByUserIdAndPodcastId(String userId, String podcastId);
    boolean existsByUserIdAndPodcastId(String userId, String podcastId);
    void deleteByUserIdAndPodcastId(String userId, String podcastId);
}
