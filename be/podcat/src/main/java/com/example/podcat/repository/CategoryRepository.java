package com.example.podcat.repository;

import com.example.podcat.model.Category;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface CategoryRepository extends MongoRepository<Category, String> {
    List<Category> findByNameContainingIgnoreCase(String keyword);
}
