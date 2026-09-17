package com.hfcms.ai.client.anthropic;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hfcms.ai.client.AiClient;
import com.hfcms.ai.dto.ComplaintAnalysisResult;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
public class AnthropicAiClient implements AiClient {

    private final String apiKey;
    private final String model;
    private final RestClient restClient;
    private final ObjectMapper objectMapper;

    public AnthropicAiClient(
            @Value("${app.ai.anthropic.api-key:}") String apiKey,
            @Value("${app.ai.anthropic.model:claude-3-5-sonnet-20241022}") String model,
            @Value("${app.ai.timeout-ms:10000}") long timeoutMs,
            ObjectMapper objectMapper) {
        this.apiKey = apiKey != null ? apiKey.trim() : "";
        this.model = model != null ? model.trim() : "claude-3-5-sonnet-20241022";
        this.objectMapper = objectMapper;

        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(Duration.ofMillis(timeoutMs));
        requestFactory.setReadTimeout(Duration.ofMillis(timeoutMs));

        this.restClient = RestClient.builder()
                .requestFactory(requestFactory)
                .build();
    }

    @Override
    public String getModelName() {
        return model;
    }

    public boolean isConfigured() {
        return apiKey != null && !apiKey.isEmpty() && !apiKey.startsWith("sk-ant-your");
    }

    @Override
    public ComplaintAnalysisResult analyzeComplaint(Complaint complaint) {
        if (!isConfigured()) {
            throw new IllegalStateException("Anthropic API key is not configured.");
        }

        String prompt = buildPrompt(complaint);

        Map<String, Object> requestBody = Map.of(
                "model", model,
                "max_tokens", 1024,
                "messages", List.of(
                        Map.of("role", "user", "content", prompt)
                )
        );

        try {
            String responseStr = restClient.post()
                    .uri("https://api.anthropic.com/v1/messages")
                    .header("x-api-key", apiKey)
                    .header("anthropic-version", "2023-06-01")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(requestBody)
                    .retrieve()
                    .body(String.class);

            return parseAnthropicResponse(responseStr);
        } catch (Exception e) {
            log.error("Anthropic API invocation failed: {}", e.getMessage());
            throw new RuntimeException("Anthropic API call failed: " + e.getMessage(), e);
        }
    }

    private String buildPrompt(Complaint complaint) {
        String location = (complaint.getBlock() != null ? complaint.getBlock().getName() : "Unknown Block") +
                (complaint.getRoom() != null ? ", Room " + complaint.getRoom().getRoomNumber() : "");

        return """
                You are an expert AI Facilities Case Manager for a university hostel facility management system (HFCMS).
                Analyze the following student complaint and return ONLY a raw valid JSON object without markdown code fences.
                
                COMPLAINT DETAILS:
                - Case Number: %s
                - Category: %s
                - Location: %s
                - Description: "%s"
                
                RESPONSE JSON SCHEMA:
                {
                  "aiSummary": "1-2 sentence concise summary",
                  "categoryName": "Water supply / leakage | Electrical problems | Broken furniture | Wi-Fi / Internet | Cleanliness | Mess / Food complaints | Doors / Locks | Lift / Elevator | Bathroom facilities | Common-area maintenance",
                  "subcategory": "Specific defect title",
                  "severity": "LOW | MEDIUM | HIGH | CRITICAL",
                  "priority": "P1 | P2 | P3 | P4",
                  "suggestedTeamName": "Plumbing Team | Electrical Team | Carpentry Team | IT / Network Team | Housekeeping Team | Mess Management | General Maintenance",
                  "isMissingInfo": true or false,
                  "missingInfoDraftQuestion": "Question string or null",
                  "diagnosticChecklist": ["Step 1", "Step 2", "Step 3"]
                }
                """.formatted(
                complaint.getCaseNumber(),
                complaint.getCategory() != null ? complaint.getCategory().getName() : "Unassigned",
                location,
                complaint.getDescription()
        );
    }

    private ComplaintAnalysisResult parseAnthropicResponse(String responseStr) {
        try {
            JsonNode root = objectMapper.readTree(responseStr);
            JsonNode contentArr = root.path("content");
            if (contentArr.isEmpty()) {
                throw new IllegalStateException("No content returned from Anthropic API");
            }

            String text = contentArr.get(0).path("text").asText().trim();
            if (text.startsWith("```json")) {
                text = text.substring(7);
            }
            if (text.endsWith("```")) {
                text = text.substring(0, text.length() - 3);
            }
            text = text.trim();

            JsonNode data = objectMapper.readTree(text);

            String summary = data.path("aiSummary").asText("AI analysis completed.");
            String category = data.path("categoryName").asText("Common-area maintenance");
            String subcategory = data.path("subcategory").asText("General Maintenance");
            String severityStr = data.path("severity").asText("MEDIUM").toUpperCase();
            String priorityStr = data.path("priority").asText("P3").toUpperCase();
            String team = data.path("suggestedTeamName").asText("General Maintenance");
            boolean missingInfo = data.path("isMissingInfo").asBoolean(false);
            String draftQuestion = data.path("missingInfoDraftQuestion").isTextual() ? data.path("missingInfoDraftQuestion").asText() : null;

            Severity severity;
            try {
                severity = Severity.valueOf(severityStr);
            } catch (Exception e) {
                severity = Severity.MEDIUM;
            }

            Priority priority;
            try {
                priority = Priority.valueOf(priorityStr);
            } catch (Exception e) {
                priority = Priority.P3;
            }

            List<String> checklist = new ArrayList<>();
            JsonNode checklistNode = data.path("diagnosticChecklist");
            if (checklistNode.isArray()) {
                for (JsonNode item : checklistNode) {
                    checklist.add(item.asText());
                }
            }

            return ComplaintAnalysisResult.builder()
                    .aiSummary(summary)
                    .categoryName(category)
                    .subcategory(subcategory)
                    .severity(severity)
                    .priority(priority)
                    .suggestedTeamName(team)
                    .isMissingInfo(missingInfo)
                    .missingInfoDraftQuestion(draftQuestion)
                    .diagnosticChecklist(checklist)
                    .build();
        } catch (Exception e) {
            log.error("Failed to parse Anthropic JSON payload: {}", e.getMessage());
            throw new RuntimeException("Failed to parse Anthropic response: " + e.getMessage(), e);
        }
    }
}
