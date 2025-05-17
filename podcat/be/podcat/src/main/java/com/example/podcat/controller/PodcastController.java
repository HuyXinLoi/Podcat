package com.example.podcat.controller;

import com.example.podcat.dto.*;
import com.example.podcat.security.JwtService;
import com.example.podcat.service.PodcastService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/podcasts")
@RequiredArgsConstructor
@Tag(name = "Podcasts", description = "Podcast management API")
public class PodcastController {

    private final PodcastService service;
    private final JwtService jwtService;

    @PostMapping
    @Operation(
        summary = "Create a new podcast",
        security = @SecurityRequirement(name = "bearer-key")
    )
    public ResponseEntity<PodcastResponse> create(
            @RequestBody PodcastRequest request,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        return ResponseEntity.ok(service.create(userId, request));
    }

    @GetMapping
    @Operation(summary = "Get all podcasts")
    public ResponseEntity<PageResponse<PodcastResponse>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestHeader(value = "Authorization", required = false) String auth) {
        String userId = null;
        if (auth != null && auth.startsWith("Bearer ")) {
            userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        }
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(service.getAll(userId, pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get podcast by ID")
    public ResponseEntity<PodcastResponse> getById(
            @PathVariable String id,
            @RequestHeader(value = "Authorization", required = false) String auth) {
        String userId = null;
        if (auth != null && auth.startsWith("Bearer ")) {
            userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        }
        return ResponseEntity.ok(service.getById(id, userId));
    }

    @GetMapping("/search")
    @Operation(summary = "Search podcasts")
    public ResponseEntity<PageResponse<PodcastResponse>> search(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestHeader(value = "Authorization", required = false) String auth) {
        String userId = null;
        if (auth != null && auth.startsWith("Bearer ")) {
            userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        }
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(service.search(keyword, userId, pageable));
    }

    @GetMapping("/category/{categoryId}")
    @Operation(summary = "Get podcasts by category")
    public ResponseEntity<PageResponse<PodcastResponse>> getByCategory(
            @PathVariable String categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestHeader(value = "Authorization", required = false) String auth) {
        String userId = null;
        if (auth != null && auth.startsWith("Bearer ")) {
            userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        }
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(service.getByCategory(categoryId, userId, pageable));
    }

    @DeleteMapping("/{id}")
    @Operation(
        summary = "Delete podcast",
        security = @SecurityRequirement(name = "bearer-key")
    )
    public ResponseEntity<Void> delete(
            @PathVariable String id,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        service.delete(id, userId);
        return ResponseEntity.noContent().build();
    }
}
