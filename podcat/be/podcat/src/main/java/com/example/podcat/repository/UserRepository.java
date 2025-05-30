package com.example.podcat.repository;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.example.podcat.model.User;

import java.util.Optional;

public interface UserRepository extends MongoRepository<User, String> {
    Optional<User> findByUsername(String username);

    boolean existsByUsername(String username);
}
