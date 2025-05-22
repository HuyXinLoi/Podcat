package com.example.podcat.controller;

import com.example.podcat.dto.UserProfileRequest;
import com.example.podcat.dto.UserProfileResponse;
import com.example.podcat.security.JwtService;
import com.example.podcat.service.UserProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserProfileService userProfileService;
    private final JwtService jwtService;

    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getMyProfile(
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        return ResponseEntity.ok(userProfileService.getProfile(userId));
    }

    @PutMapping("/me")
    public ResponseEntity<UserProfileResponse> updateMyProfile(
            @RequestBody UserProfileRequest request,
            @RequestHeader("Authorization") String auth) {
        String userId = jwtService.extractUsername(auth.replace("Bearer ", ""));
        return ResponseEntity.ok(userProfileService.updateProfile(userId, request));
    }
    
    @GetMapping("/{userId}")
    public ResponseEntity<UserProfileResponse> getUserProfile(@PathVariable String userId) {
        return ResponseEntity.ok(userProfileService.getProfile(userId));
    }
}
