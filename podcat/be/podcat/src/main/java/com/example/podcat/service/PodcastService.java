package com.example.podcat.service;

import com.example.podcat.dto.*;
import com.example.podcat.exception.ResourceNotFoundException;
import com.example.podcat.exception.UnauthorizedException;
import com.example.podcat.model.Category;
import com.example.podcat.model.Comment;
import com.example.podcat.model.Podcast;
import com.example.podcat.model.Role;
import com.example.podcat.repository.CategoryRepository;
import com.example.podcat.repository.CommentRepository;
import com.example.podcat.repository.FavoriteRepository;
import com.example.podcat.repository.PodcastRepository;
import com.example.podcat.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PodcastService {

    private final PodcastRepository repository;
    private final CommentRepository commentRepository;
    private final CategoryRepository categoryRepository;
    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;

    public PodcastResponse create(String userId, PodcastRequest req) {
        Podcast podcast = Podcast.builder()
                .title(req.getTitle())
                .description(req.getDescription())
                .author(req.getAuthor())
                .audioUrl(req.getAudioUrl())
                .imageUrl(req.getImageUrl())
                .createdAt(Instant.now())
                .userId(userId)
                .categoryId(req.getCategoryId())
                .tags(req.getTags())
                .duration(req.getDuration())
                .build();

        repository.save(podcast);
        return toResponse(podcast, userId);
    }

    public PageResponse<PodcastResponse> getAll(String userId, Pageable pageable) {
        Page<Podcast> podcastPage = repository.findAll(pageable);
        
        List<PodcastResponse> content = podcastPage.getContent().stream()
                .map(podcast -> toResponse(podcast, userId))
                .collect(Collectors.toList());
        
        return new PageResponse<>(
                content,
                podcastPage.getNumber(),
                podcastPage.getSize(),
                podcastPage.getTotalElements(),
                podcastPage.getTotalPages()
        );
    }

    public PodcastResponse getById(String id, String userId) {
        Podcast podcast = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Podcast not found"));
        return toResponse(podcast, userId);
    }

    public PageResponse<PodcastResponse> search(String keyword, String userId, Pageable pageable) {
        Page<Podcast> podcastPage = repository.findByTitleContainingIgnoreCaseOrAuthorContainingIgnoreCase(keyword, keyword, pageable);
        
        List<PodcastResponse> content = podcastPage.getContent().stream()
                .map(podcast -> toResponse(podcast, userId))
                .collect(Collectors.toList());
        
        return new PageResponse<>(
                content,
                podcastPage.getNumber(),
                podcastPage.getSize(),
                podcastPage.getTotalElements(),
                podcastPage.getTotalPages()
        );
    }

    public PageResponse<PodcastResponse> getByCategory(String categoryId, String userId, Pageable pageable) {
        Page<Podcast> podcastPage = repository.findByCategoryId(categoryId, pageable);
        
        List<PodcastResponse> content = podcastPage.getContent().stream()
                .map(podcast -> toResponse(podcast, userId))
                .collect(Collectors.toList());
        
        return new PageResponse<>(
                content,
                podcastPage.getNumber(),
                podcastPage.getSize(),
                podcastPage.getTotalElements(),
                podcastPage.getTotalPages()
        );
    }

    public PageResponse<PodcastResponse> getByAuthor(String author, String userId, Pageable pageable) {
        Page<Podcast> podcastPage = repository.findByAuthorContainingIgnoreCase(author, pageable);
        
        List<PodcastResponse> content = podcastPage.getContent().stream()
                .map(podcast -> toResponse(podcast, userId))
                .collect(Collectors.toList());
        
        return new PageResponse<>(
                content,
                podcastPage.getNumber(),
                podcastPage.getSize(),
                podcastPage.getTotalElements(),
                podcastPage.getTotalPages()
        );
    }

    public void delete(String id, String userId) {
        Podcast podcast = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Podcast not found"));
        
        // Check if user is the creator or admin
        if (!podcast.getUserId().equals(userId) && !isAdmin(userId)) {
            throw new UnauthorizedException("You are not authorized to delete this podcast");
        }
        
        repository.deleteById(id);
    }

    public PodcastResponse update(String id, String userId, PodcastRequest req) {
        Podcast podcast = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Podcast not found"));
    
        // Check if user is the creator or admin
        if (!podcast.getUserId().equals(userId) && !isAdmin(userId)) {
            throw new UnauthorizedException("You are not authorized to update this podcast");
        }
    
        // Update fields
        podcast.setTitle(req.getTitle());
        podcast.setDescription(req.getDescription());
        podcast.setAuthor(req.getAuthor());
        podcast.setAudioUrl(req.getAudioUrl());
        podcast.setImageUrl(req.getImageUrl());
        podcast.setCategoryId(req.getCategoryId());
        podcast.setTags(req.getTags());
        podcast.setDuration(req.getDuration());
    
        repository.save(podcast);
        return toResponse(podcast, userId);
    }

    private boolean isAdmin(String userId) {
        return userRepository.findByUsername(userId)
                .map(user -> user.getRoles().contains(Role.ADMIN))
                .orElse(false);
    }

    private PodcastResponse toResponse(Podcast podcast, String userId) {
        String categoryName = null;
        if (podcast.getCategoryId() != null) {
            categoryName = categoryRepository.findById(podcast.getCategoryId())
                    .map(Category::getName)
                    .orElse(null);
        }
        
        boolean isLiked = false;
        if (userId != null) {
            isLiked = favoriteRepository.existsByUserIdAndPodcastId(userId, podcast.getId());
        }
        
        return PodcastResponse.builder()
                .id(podcast.getId())
                .title(podcast.getTitle())
                .description(podcast.getDescription())
                .author(podcast.getAuthor())
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
                .isLiked(isLiked)
                .build();
    }

    public CommentResponse addComment(String podcastId, String userId, String content) {
        if (!repository.existsById(podcastId)) {
            throw new ResourceNotFoundException("Podcast not found");
        }
        
        Comment comment = Comment.builder()
                .podcastId(podcastId)
                .userId(userId)
                .content(content)
                .createdAt(LocalDateTime.now())
                .build();
        
        commentRepository.save(comment);
        return mapCommentToResponse(comment);
    }

    public List<CommentResponse> getComments(String podcastId) {
        if (!repository.existsById(podcastId)) {
            throw new ResourceNotFoundException("Podcast not found");
        }
        
        return commentRepository.findByPodcastIdOrderByCreatedAtDesc(podcastId)
                .stream()
                .map(this::mapCommentToResponse)
                .toList();
    }
    
    public void deleteComment(String commentId, String userId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found"));
        
        // Check if user is the comment author or admin
        if (!comment.getUserId().equals(userId) && !isAdmin(userId)) {
            throw new UnauthorizedException("You are not authorized to delete this comment");
        }
        
        commentRepository.deleteById(commentId);
    }

    private CommentResponse mapCommentToResponse(Comment comment) {
        return CommentResponse.builder()
                .id(comment.getId())
                .userId(comment.getUserId())
                .content(comment.getContent())
                .createdAt(comment.getCreatedAt())
                .build();
    }
}
