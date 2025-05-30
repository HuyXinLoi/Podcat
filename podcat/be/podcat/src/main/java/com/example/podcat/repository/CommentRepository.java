package com.example.podcat.repository;

import com.example.podcat.model.Comment;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface CommentRepository extends MongoRepository<Comment, String> {
    List<Comment> findByPodcastIdOrderByCreatedAtDesc(String podcastId);
}
