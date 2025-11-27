package com.petvetai.app.config;

import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.openai.OpenAiChatModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

/**
 * LangChain4j 配置类
 * 
 * 配置 LangChain4j 的 ChatLanguageModel
 * 支持多种 AI 提供商：OpenAI、DeepSeek、xAI Grok 等
 * 
 * DeepSeek 和 xAI Grok 都使用 OpenAI 兼容的 API，可以通过设置 baseUrl 来使用
 */
@Configuration
public class LangChainConfig {

    @Value("${spring.ai.provider.type:deepseek}")
    private String providerType;

    @Value("${spring.ai.openai.api-key:}")
    private String openAiApiKey;

    @Value("${spring.ai.openai.chat.options.model:gpt-4o}")
    private String openAiModel;

    @Value("${spring.ai.openai.chat.options.temperature:0.7}")
    private Double temperature;

    @Value("${spring.ai.deepseek.api-key:}")
    private String deepSeekApiKey;

    @Value("${spring.ai.deepseek.base-url:https://api.deepseek.com}")
    private String deepSeekBaseUrl;

    @Value("${spring.ai.deepseek.chat.options.model:deepseek-chat}")
    private String deepSeekModel;

    @Value("${spring.ai.deepseek.chat.options.temperature:0.7}")
    private Double deepSeekTemperature;

    @Value("${spring.ai.grok.api-key:}")
    private String grokApiKey;

    @Value("${spring.ai.grok.base-url:https://api.x.ai/v1}")
    private String grokBaseUrl;

    @Value("${spring.ai.grok.chat.options.model:grok-2-latest}")
    private String grokModel;

    @Value("${spring.ai.grok.chat.options.temperature:0.7}")
    private Double grokTemperature;

    /**
     * 创建 ChatLanguageModel
     * 根据配置自动选择 OpenAI、DeepSeek 或 Grok
     * 
     * @return ChatLanguageModel 实例
     */
    @Bean
    @Primary
    public ChatLanguageModel chatLanguageModel() {
        if ("grok".equalsIgnoreCase(providerType)) {
            return createGrokModel();
        } else if ("deepseek".equalsIgnoreCase(providerType)) {
            return createDeepSeekModel();
        } else {
            return createOpenAiModel();
        }
    }

    /**
     * 创建 DeepSeek ChatLanguageModel
     * DeepSeek 使用 OpenAI 兼容的 API
     */
    private ChatLanguageModel createDeepSeekModel() {
        return OpenAiChatModel.builder()
                .apiKey(deepSeekApiKey)
                .baseUrl(deepSeekBaseUrl)
                .modelName(deepSeekModel)
                .temperature(deepSeekTemperature)
                .build();
    }

    /**
     * 创建 OpenAI ChatLanguageModel
     */
    private ChatLanguageModel createOpenAiModel() {
        return OpenAiChatModel.builder()
                .apiKey(openAiApiKey)
                .modelName(openAiModel)
                .temperature(temperature)
                .build();
    }

    /**
     * 创建 xAI Grok ChatLanguageModel
     * Grok 使用 OpenAI 兼容的 API
     */
    private ChatLanguageModel createGrokModel() {
        return OpenAiChatModel.builder()
                .apiKey(grokApiKey)
                .baseUrl(grokBaseUrl)
                .modelName(grokModel)
                .temperature(grokTemperature)
                .build();
    }
}

