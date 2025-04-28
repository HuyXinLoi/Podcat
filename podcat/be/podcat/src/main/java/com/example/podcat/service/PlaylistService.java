package com.example.podcat.service;

import com.example.podcat.dto.*;
import com.example.podcat.model.Playlist;
import com.example.podcat.repository.PlaylistRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlaylistService {

    private final PlaylistRepository playlistRepository;

    public PlaylistResponse create(String userId, String name) {
        Playlist playlist = Playlist.builder()
                .userId(userId)
                .name(name)
                .build();
        playlistRepository.save(playlist);
        return mapToResponse(playlist);
    }

    public PlaylistResponse addPodcast(String playlistId, String podcastId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist không tồn tại"));
        playlist.getPodcastIds().add(podcastId);
        playlistRepository.save(playlist);
        return mapToResponse(playlist);
    }

    public List<PlaylistResponse> getByUser(String userId) {
        return playlistRepository.findByUserId(userId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private PlaylistResponse mapToResponse(Playlist p) {
        return PlaylistResponse.builder()
                .id(p.getId())
                .name(p.getName())
                .userId(p.getUserId())
                .podcastIds(p.getPodcastIds())
                .build();
    }
}
