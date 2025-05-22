package com.example.podcat.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

@Data
public class AuthRequest {
    @Schema(description = "Username for authentication", example = "johndoe")
    private String username;
    
    @Schema(description = "Password for authentication", example = "password123")
    private String password;
}
