package com.CI_CD.demo;


import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Versioncontroller {
    @Value("${app.version:dev}")
    private String appVersion;

    @GetMapping("/version")
    public String version() {
        return "Hello from Spring Boot! VersionNew1: " + appVersion;
    }
}
