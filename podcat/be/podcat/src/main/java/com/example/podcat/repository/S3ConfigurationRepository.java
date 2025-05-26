package com.example.podcat.repository;

import com.example.podcat.model.S3Configuration;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface S3ConfigurationRepository extends MongoRepository<S3Configuration, String> {
    Optional<S3Configuration> findByUserIdAndIsActiveTrue(String userId);
    Optional<S3Configuration> findFirstByIsActiveTrueOrderByIdDesc();
}
