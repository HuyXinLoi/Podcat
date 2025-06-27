package com.example.podcat.repository;

import com.example.podcat.model.Podcast;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface PodcastRepository extends MongoRepository<Podcast, String> {
    Page<Podcast> findByTitleContainingIgnoreCase(String keyword, Pageable pageable);
    Page<Podcast> findByAuthorContainingIgnoreCase(String author, Pageable pageable);
    Page<Podcast> findByTitleContainingIgnoreCaseOrAuthorContainingIgnoreCase(String title, String author, Pageable pageable);
    Page<Podcast> findByCategoryId(String categoryId, Pageable pageable);
    Page<Podcast> findByUserId(String userId, Pageable pageable);
    List<Podcast> findTop10ByOrderByViewCountDesc();
    List<Podcast> findTop10ByOrderByCreatedAtDesc();
}
