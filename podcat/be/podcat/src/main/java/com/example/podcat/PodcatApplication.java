package com.example.podcat;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import io.github.cdimascio.dotenv.Dotenv;

@SpringBootApplication
public class PodcatApplication {

	public static void main(String[] args) {
		// Load .env
        Dotenv dotenv = Dotenv.configure()
                .directory("./be/podcat")
                .filename(".env")
                .load();

        // Set ENV
        System.setProperty("MONGODB_URI", dotenv.get("MONGODB_URI"));
        System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));
        System.setProperty("JWT_EXPIRATION", dotenv.get("JWT_EXPIRATION"));
        System.setProperty("CLOUDINARY_CLOUD_NAME", dotenv.get("CLOUDINARY_CLOUD_NAME"));
        System.setProperty("CLOUDINARY_API_KEY", dotenv.get("CLOUDINARY_API_KEY"));
        System.setProperty("CLOUDINARY_API_SECRET", dotenv.get("CLOUDINARY_API_SECRET"));
		SpringApplication.run(PodcatApplication.class, args);
	}

}
