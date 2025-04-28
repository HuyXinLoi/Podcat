package com.example.podcat.controller;

import com.example.podcat.dto.ListeningHistoryRequest;
import com.example.podcat.dto.ListeningHistoryResponse;
import com.example.podcat.dto.PageResponse;
import com.example.podcat.security.JwtService;
import com.example.podcat.service.ListeningHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/history")
@RequiredArgsConstructor
public class ListeningHistoryController {

    private final ListeningHistoryService listeningHistoryService;
    private final JwtService jwtService;

    @PostMapping
    public ResponseEntity<ListeningHistoryResponse> saveProgress(
            @RequestBody ListeningHistoryRequest request,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        return ResponseEntity.ok(listeningHistoryService.saveProgress(userId, request));
    }

    @GetMapping
    public ResponseEntity<PageResponse<ListeningHistoryResponse>> getMyHistory(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(listeningHistoryService.getUserHistory(userId, pageable));
    }
}
