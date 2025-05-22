package com.example.podcat.repository;

import com.example.podcat.model.ListeningHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface ListeningHistoryRepository extends MongoRepository<ListeningHistory, String> {
    Page<ListeningHistory> findByUserIdOrderByListenedAtDesc(String userId, Pageable pageable);
    Optional<ListeningHistory> findByUserIdAndPodcastId(String userId, String podcastId);
}
