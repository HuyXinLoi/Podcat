package com.example.podcat.controller;

import com.example.podcat.dto.*;
import com.example.podcat.security.JwtService;
import com.example.podcat.service.PlaylistService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/playlists")
@RequiredArgsConstructor
public class PlaylistController {

    private final PlaylistService playlistService;
    private final JwtService jwtService;

    @PostMapping
    public PlaylistResponse create(
            @RequestBody PlaylistRequest request,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUserId(auth.replace("Bearer ", ""));
        return playlistService.create(userId, request.getName());
    }

    @PostMapping("/{id}/add")
    public PlaylistResponse addPodcast(
            @PathVariable String id,
            @RequestBody AddPodcastToPlaylistRequest request) {
        return playlistService.addPodcast(id, request.getPodcastId());
    }

    @GetMapping("/my")
    public List<PlaylistResponse> getMyPlaylists(
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUserId(auth.replace("Bearer ", ""));
        return playlistService.getByUser(userId);
    }
}
