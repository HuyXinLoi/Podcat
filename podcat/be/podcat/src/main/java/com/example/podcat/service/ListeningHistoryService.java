package com.example.podcat.service;

import com.example.podcat.dto.ListeningHistoryRequest;
import com.example.podcat.dto.ListeningHistoryResponse;
import com.example.podcat.dto.PageResponse;
import com.example.podcat.exception.ResourceNotFoundException;
import com.example.podcat.model.ListeningHistory;
import com.example.podcat.model.Podcast;
import com.example.podcat.repository.ListeningHistoryRepository;
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
public class ListeningHistoryService {

    private final ListeningHistoryRepository listeningHistoryRepository;
    private final PodcastRepository podcastRepository;

    public ListeningHistoryResponse saveProgress(String userId, ListeningHistoryRequest request) {
        Podcast podcast = podcastRepository.findById(request.getPodcastId())
                .orElseThrow(() -> new ResourceNotFoundException("Podcast not found"));
        
        ListeningHistory history = listeningHistoryRepository
                .findByUserIdAndPodcastId(userId, request.getPodcastId())
                .orElse(ListeningHistory.builder()
                        .userId(userId)
                        .podcastId(request.getPodcastId())
                        .build());
        
        history.setProgress(request.getProgress());
        history.setListenedAt(Instant.now());
        
        listeningHistoryRepository.save(history);
        
        // Increment view count if this is a new view
        if (history.getId() == null) {
            podcast.setViewCount(podcast.getViewCount() + 1);
            podcastRepository.save(podcast);
        }
        
        return mapToResponse(history, podcast);
    }

    public PageResponse<ListeningHistoryResponse> getUserHistory(String userId, Pageable pageable) {
        Page<ListeningHistory> historyPage = listeningHistoryRepository
                .findByUserIdOrderByListenedAtDesc(userId, pageable);
        
        List<ListeningHistoryResponse> content = historyPage.getContent().stream()
                .map(history -> {
                    Podcast podcast = podcastRepository.findById(history.getPodcastId())
                            .orElseThrow(() -> new ResourceNotFoundException("Podcast not found"));
                    return mapToResponse(history, podcast);
                })
                .collect(Collectors.toList());
        
        return new PageResponse<>(
                content,
                historyPage.getNumber(),
                historyPage.getSize(),
                historyPage.getTotalElements(),
                historyPage.getTotalPages()
        );
    }

    private ListeningHistoryResponse mapToResponse(ListeningHistory history, Podcast podcast) {
        return ListeningHistoryResponse.builder()
                .id(history.getId())
                .podcastId(history.getPodcastId())
                .podcastTitle(podcast.getTitle())
                .podcastImageUrl(podcast.getImageUrl())
                .listenedAt(history.getListenedAt().toString())
                .progress(history.getProgress())
                .duration(podcast.getDuration())
                .build();
    }
}
