package com.example.podcat.controller;

import com.example.podcat.dto.CommentRequest;
import com.example.podcat.dto.CommentResponse;
import com.example.podcat.security.JwtService;
import com.example.podcat.service.PodcastService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/podcasts/{podcastId}/comments")
@RequiredArgsConstructor
public class CommentController {

    private final PodcastService podcastService;
    private final JwtService jwtService;

    @PostMapping
    public ResponseEntity<CommentResponse> addComment(
            @PathVariable String podcastId,
            @RequestBody CommentRequest request,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        CommentResponse comment = podcastService.addComment(podcastId, userId, request.getContent());
        return ResponseEntity.ok(comment);
    }

    @GetMapping
    public ResponseEntity<List<CommentResponse>> getComments(@PathVariable String podcastId) {
        List<CommentResponse> comments = podcastService.getComments(podcastId);
        return ResponseEntity.ok(comments);
    }
    
    @DeleteMapping("/{commentId}")
    public ResponseEntity<Void> deleteComment(
            @PathVariable String podcastId,
            @PathVariable String commentId,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        podcastService.deleteComment(commentId, userId);
        return ResponseEntity.noContent().build();
    }
}
