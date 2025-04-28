package com.example.podcat.controller;

import com.example.podcat.dto.PageResponse;
import com.example.podcat.dto.PodcastResponse;
import com.example.podcat.security.JwtService;
import com.example.podcat.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;
    private final JwtService jwtService;

    @PostMapping("/{podcastId}")
    public ResponseEntity<Void> toggleFavorite(
            @PathVariable String podcastId,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        favoriteService.toggleFavorite(userId, podcastId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{podcastId}")
    public ResponseEntity<Boolean> isFavorite(
            @PathVariable String podcastId,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        return ResponseEntity.ok(favoriteService.isFavorite(userId, podcastId));
    }

    @GetMapping
    public ResponseEntity<PageResponse<PodcastResponse>> getMyFavorites(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(favoriteService.getUserFavorites(userId, pageable));
    }
}
