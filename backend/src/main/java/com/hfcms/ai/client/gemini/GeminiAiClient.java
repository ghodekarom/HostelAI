package com.hfcms.ai.client.gemini;

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
public class GeminiAiClient implements AiClient {

    private final String apiKey;
    private final String model;
    private final RestClient restClient;
    private final ObjectMapper objectMapper;

    public GeminiAiClient(
            @Value("${app.ai.gemini.api-key:}") String apiKey,
            @Value("${app.ai.gemini.model:gemini-1.5-flash}") String model,
            @Value("${app.ai.timeout-ms:10000}") long timeoutMs,
            ObjectMapper objectMapper) {
        this.apiKey = apiKey != null ? apiKey.trim() : "";
        this.model = model != null ? model.trim() : "gemini-1.5-flash";
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
        return apiKey != null && !apiKey.isEmpty() && !apiKey.startsWith("your-");
    }

    @Override
    public ComplaintAnalysisResult analyzeComplaint(Complaint complaint) {
        if (!isConfigured()) {
            throw new IllegalStateException("Google Gemini API key is not configured.");
        }

        String url = String.format(
                "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
                model, apiKey
        );

        String prompt = buildPrompt(complaint);

        Map<String, Object> requestBody = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(Map.of("text", prompt)))
                ),
                "generationConfig", Map.of(
                        "responseMimeType", "application/json",
                        "temperature", 0.2
                )
        );

        try {
            String responseStr = restClient.post()
                    .uri(url)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(requestBody)
                    .retrieve()
                    .body(String.class);

            return parseGeminiResponse(responseStr);
        } catch (Exception e) {
            log.error("Gemini API invocation failed: {}", e.getMessage());
            throw new RuntimeException("Gemini API call failed: " + e.getMessage(), e);
        }
    }

    private String buildPrompt(Complaint complaint) {
        String location = (complaint.getBlock() != null ? complaint.getBlock().getName() : "Unknown Block") +
                (complaint.getRoom() != null ? ", Room " + complaint.getRoom().getRoomNumber() : "");

        return """
                You are an expert AI Facilities Case Manager for a university hostel facility management system (HFCMS).
                Analyze the following student complaint and return a strictly valid JSON response adhering to the exact schema specified.
                
                COMPLAINT DETAILS:
                - Case Number: %s
                - Category: %s
                - Location: %s
                - Description: "%s"
                
                STANDARD CATEGORIES:
                1. Water supply / leakage
                2. Electrical problems
                3. Broken furniture
                4. Wi-Fi / Internet
                5. Cleanliness
                6. Mess / Food complaints
                7. Doors / Locks
                8. Lift / Elevator
                9. Bathroom facilities
                10. Common-area maintenance
                
                STANDARD MAINTENANCE TEAMS:
                - Plumbing Team
                - Electrical Team
                - Carpentry Team
                - IT / Network Team
                - Housekeeping Team
                - Mess Management
                - General Maintenance
                
                RESPONSE JSON SCHEMA:
                {
                  "aiSummary": "1-2 sentence concise summary of the issue and location",
                  "categoryName": "One of the 10 standard categories above",
                  "subcategory": "Specific defect name (e.g., Faucet Leakage, Burnt MCB, WiFi Packet Loss)",
                  "severity": "LOW, MEDIUM, HIGH, or CRITICAL (CRITICAL for fire, flooding, sparks, shock hazard)",
                  "priority": "P1, P2, P3, or P4 (P1 for life-safety or entire-block outages)",
                  "suggestedTeamName": "One of the standard maintenance teams above",
                  "isMissingInfo": true or false (true if description is vague/insufficient to dispatch),
                  "missingInfoDraftQuestion": "Polite question asking student for missing details, or null",
                  "diagnosticChecklist": ["Step 1 for technician", "Step 2 for technician", "Step 3 for technician"]
                }
                """.formatted(
                complaint.getCaseNumber(),
                complaint.getCategory() != null ? complaint.getCategory().getName() : "Unassigned",
                location,
                complaint.getDescription()
        );
    }

    private ComplaintAnalysisResult parseGeminiResponse(String responseStr) {
        try {
            JsonNode root = objectMapper.readTree(responseStr);
            JsonNode candidates = root.path("candidates");
            if (candidates.isEmpty()) {
                throw new IllegalStateException("No candidate responses returned by Gemini API");
            }

            String contentJson = candidates.get(0).path("content").path("parts").get(0).path("text").asText();
            JsonNode data = objectMapper.readTree(contentJson);

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
            log.error("Failed to parse Gemini JSON payload: {}", e.getMessage());
            throw new RuntimeException("Failed to parse Gemini response: " + e.getMessage(), e);
        }
    }
}
