package com.example.podcat.controller;

import com.example.podcat.dto.*;
import com.example.podcat.model.*;
import com.example.podcat.repository.UserRepository;
import com.example.podcat.security.JwtService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Set;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Authentication API")
public class AuthController {

    private final AuthenticationManager authManager;
    private final UserRepository userRepo;
    private final PasswordEncoder encoder;
    private final JwtService jwtService;

    @PostMapping("/register")
    @Operation(summary = "Register a new user")
    public ResponseEntity<?> register(@RequestBody AuthRequest req) {
        if (userRepo.existsByUsername(req.getUsername())) {
            return ResponseEntity.badRequest().body("Username already exists");
        }

        var user = User.builder()
                .username(req.getUsername())
                .password(encoder.encode(req.getPassword()))
                .roles(Set.of(Role.USER))
                .build();

        userRepo.save(user);
        var token = jwtService.generateToken(user.getId(),user.getUsername(), user.getRoles());

        return ResponseEntity.ok(new AuthResponse(token));
    }

    @PostMapping("/login")
    @Operation(summary = "Login user")
    public ResponseEntity<?> login(@RequestBody AuthRequest req) {
        authManager.authenticate(
                new UsernamePasswordAuthenticationToken(req.getUsername(), req.getPassword())
        );

        var user = userRepo.findByUsername(req.getUsername()).get();
        var token = jwtService.generateToken(user.getId(),user.getUsername(), user.getRoles());

        return ResponseEntity.ok(new AuthResponse(token));
    }
}
