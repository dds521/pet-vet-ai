package com.example.spring_ai_app.controller;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class DemoController {

    private final ChatClient chatClient;
    private final Environment environment;

    @Autowired
    public DemoController(ChatClient chatClient, Environment environment) {
        this.chatClient = chatClient;
        this.environment = environment;
    }

    @GetMapping("/ping")
    public String ping() {
        return "pong";
    }

    @GetMapping("/ai/quick")
    public String quick(@RequestParam("q") String question) {
        String apiKey = environment.getProperty("spring.ai.openai.api-key");
        if (apiKey == null || apiKey.isBlank() || "dummy-key".equals(apiKey)) {
            return "OPENAI_API_KEY 未配置，已跳过调用。请在环境变量中设置 OPENAI_API_KEY 后重试。";
        }
        return chatClient
                .prompt()
                .user(question)
                .call()
                .content();
    }
}