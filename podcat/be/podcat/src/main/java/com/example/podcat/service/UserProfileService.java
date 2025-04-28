package com.example.podcat.service;

import com.example.podcat.dto.UserProfileRequest;
import com.example.podcat.dto.UserProfileResponse;
import com.example.podcat.exception.ResourceNotFoundException;
import com.example.podcat.model.UserProfile;
import com.example.podcat.repository.PlaylistRepository;
import com.example.podcat.repository.PodcastRepository;
import com.example.podcat.repository.UserProfileRepository;
import com.example.podcat.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final UserProfileRepository userProfileRepository;
    private final UserRepository userRepository;
    private final PlaylistRepository playlistRepository;
    private final PodcastRepository podcastRepository;

    public UserProfileResponse getProfile(String userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId)
                .orElse(UserProfile.builder().userId(userId).build());
        
        String username = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"))
                .getUsername();
        
        int playlistCount = playlistRepository.findByUserId(userId).size();
        
        return UserProfileResponse.builder()
                .id(profile.getId())
                .userId(userId)
                .username(username)
                .name(profile.getName())
                .bio(profile.getBio())
                .avatarUrl(profile.getAvatarUrl())
                .playlistCount(playlistCount)
                .build();
    }

    public UserProfileResponse updateProfile(String userId, UserProfileRequest request) {
        UserProfile profile = userProfileRepository.findByUserId(userId)
                .orElse(UserProfile.builder().userId(userId).build());
        
        profile.setName(request.getName());
        profile.setBio(request.getBio());
        profile.setAvatarUrl(request.getAvatarUrl());
        
        userProfileRepository.save(profile);
        
        return getProfile(userId);
    }
}
