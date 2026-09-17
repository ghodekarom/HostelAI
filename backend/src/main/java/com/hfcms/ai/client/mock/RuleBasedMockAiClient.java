package com.hfcms.ai.client.mock;

import com.hfcms.ai.client.AiClient;
import com.hfcms.ai.dto.ComplaintAnalysisResult;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class RuleBasedMockAiClient implements AiClient {

    private static final String MODEL_NAME = "rule-based-mock-engine";

    @Override
    public String getModelName() {
        return MODEL_NAME;
    }

    @Override
    public ComplaintAnalysisResult analyzeComplaint(Complaint complaint) {
        String description = complaint.getDescription() != null ? complaint.getDescription().toLowerCase().trim() : "";
        String categoryName = complaint.getCategory() != null ? complaint.getCategory().getName() : inferCategory(description);

        Severity severity = inferSeverity(description);
        Priority priority = inferPriority(severity, description);
        String suggestedTeam = inferTeam(categoryName, description);
        String subcategory = inferSubcategory(categoryName, description);
        boolean missingInfo = isInformationMissing(description);
        String draftQuestion = missingInfo ? generateDraftQuestion(categoryName) : null;
        List<String> checklist = generateDiagnosticChecklist(categoryName);

        String summary = generateAiSummary(complaint, categoryName, subcategory, severity);

        return ComplaintAnalysisResult.builder()
                .aiSummary(summary)
                .categoryName(categoryName)
                .subcategory(subcategory)
                .severity(severity)
                .priority(priority)
                .suggestedTeamName(suggestedTeam)
                .isMissingInfo(missingInfo)
                .missingInfoDraftQuestion(draftQuestion)
                .diagnosticChecklist(checklist)
                .build();
    }

    private String inferCategory(String desc) {
        if (containsAny(desc, "water", "leak", "tap", "pipe", "flush", "drain", "plumb", "tank", "sewage", "basin")) {
            return "Water supply / leakage";
        }
        if (containsAny(desc, "light", "fan", "switch", "socket", "power", "electric", "spark", "fuse", "voltage", "wire", "bulb")) {
            return "Electrical problems";
        }
        if (containsAny(desc, "bed", "table", "chair", "cupboard", "almirah", "furniture", "desk", "drawer", "mattress")) {
            return "Broken furniture";
        }
        if (containsAny(desc, "wifi", "wi-fi", "internet", "lan", "ethernet", "router", "network", "signal", "connection")) {
            return "Wi-Fi / Internet";
        }
        if (containsAny(desc, "dirty", "trash", "garbage", "clean", "dust", "sweep", "mop", "smell", "pest", "cockroach")) {
            return "Cleanliness";
        }
        if (containsAny(desc, "food", "mess", "canteen", "meal", "dinner", "lunch", "breakfast", "roti", "curry")) {
            return "Mess / Food complaints";
        }
        if (containsAny(desc, "door", "lock", "key", "handle", "latch", "hinge", "knob", "bolt")) {
            return "Doors / Locks";
        }
        if (containsAny(desc, "lift", "elevator", "stuck", "hoist")) {
            return "Lift / Elevator";
        }
        if (containsAny(desc, "geyser", "shower", "toilet", "commode", "bathroom", "mirror", "sink")) {
            return "Bathroom facilities";
        }
        return "Common-area maintenance";
    }

    private Severity inferSeverity(String desc) {
        if (containsAny(desc, "fire", "smoke", "spark", "burst", "flood", "gas", "electric shock", "explosion", "emergency", "shock")) {
            return Severity.CRITICAL;
        }
        if (containsAny(desc, "urgent", "no water", "blackout", "overflowing", "stuck", "broken lock", "cannot lock", "severe")) {
            return Severity.HIGH;
        }
        if (containsAny(desc, "slow", "flicker", "noisy", "minor", "loose", "scratch", "small")) {
            return Severity.LOW;
        }
        return Severity.MEDIUM;
    }

    private Priority inferPriority(Severity severity, String desc) {
        if (severity == Severity.CRITICAL || containsAny(desc, "entire block", "whole floor", "all rooms", "danger")) {
            return Priority.P1;
        }
        if (severity == Severity.HIGH) {
            return Priority.P2;
        }
        if (severity == Severity.LOW) {
            return Priority.P4;
        }
        return Priority.P3;
    }

    private String inferTeam(String categoryName, String desc) {
        String catLower = categoryName.toLowerCase();
        if (catLower.contains("water") || catLower.contains("leak") || catLower.contains("bathroom") || containsAny(desc, "pipe", "tap", "flush", "plumb")) {
            return "Plumbing Team";
        }
        if (catLower.contains("electric") || containsAny(desc, "fan", "light", "socket", "power", "switch", "wiring")) {
            return "Electrical Team";
        }
        if (catLower.contains("furniture") || catLower.contains("door") || catLower.contains("lock") || containsAny(desc, "bed", "chair", "table", "cupboard", "wood")) {
            return "Carpentry Team";
        }
        if (catLower.contains("wi-fi") || catLower.contains("internet") || containsAny(desc, "lan", "router", "network")) {
            return "IT / Network Team";
        }
        if (catLower.contains("clean") || containsAny(desc, "trash", "garbage", "sweep", "mop")) {
            return "Housekeeping Team";
        }
        if (catLower.contains("mess") || catLower.contains("food")) {
            return "Mess Management";
        }
        return "General Maintenance";
    }

    private String inferSubcategory(String categoryName, String desc) {
        if (containsAny(desc, "tap", "faucet")) return "Tap / Faucet Malfunction";
        if (containsAny(desc, "leak", "seepage")) return "Pipeline Leakage";
        if (containsAny(desc, "flush", "commode")) return "Flush Tank Failure";
        if (containsAny(desc, "fan", "regulator")) return "Ceiling Fan Issue";
        if (containsAny(desc, "light", "tube", "bulb")) return "Lighting Failure";
        if (containsAny(desc, "socket", "plug", "switch")) return "Burnt / Faulty Socket";
        if (containsAny(desc, "bed", "cot")) return "Bed Frame Defect";
        if (containsAny(desc, "chair", "desk")) return "Study Table / Chair Repair";
        if (containsAny(desc, "door", "lock", "latch")) return "Door Lock / Hinge Damage";
        if (containsAny(desc, "wifi", "internet")) return "No Internet Connectivity";
        return categoryName + " Issue";
    }

    private boolean isInformationMissing(String desc) {
        return desc.length() < 18 || desc.matches("^(it is |it's )?(not working|broken|damaged|help|problem|please fix|issue).*");
    }

    private String generateDraftQuestion(String categoryName) {
        return "Could you please clarify the exact location or equipment involved (e.g. study light, ceiling fan, washroom faucet) and describe what happens when you attempt to operate it?";
    }

    private List<String> generateDiagnosticChecklist(String categoryName) {
        String cat = categoryName.toLowerCase();
        if (cat.contains("water") || cat.contains("plumb")) {
            return List.of(
                    "Inspect supply isolation valve and test dynamic water pressure.",
                    "Check pipe joints, threaded fittings, and rubber washers for leaks or cracks.",
                    "Verify drain trap clearance and check wastewater flow rate.",
                    "Examine surrounding walls and floor for moisture seepage or dampness."
            );
        }
        if (cat.contains("electric")) {
            return List.of(
                    "Measure input supply voltage with digital multimeter and verify distribution MCB state.",
                    "Inspect terminal connections and junction box for thermal discoloration or arcing.",
                    "Conduct insulation resistance measurement across load circuit conductors.",
                    "Verify earthing continuity and confirm RCD leakage trip threshold."
            );
        }
        if (cat.contains("furniture") || cat.contains("door") || cat.contains("lock")) {
            return List.of(
                    "Inspect structural frame joints, fastener tightness, and weld integrity.",
                    "Test hinge alignment, drawer slides, and latch engagement with strike plate.",
                    "Check load-bearing surface deflection and stability level."
            );
        }
        if (cat.contains("wi-fi") || cat.contains("internet")) {
            return List.of(
                    "Verify link status and PoE power LED on the nearest floor access point (AP).",
                    "Measure round-trip gateway latency and packet loss via ICMP ping test.",
                    "Verify DHCP IP address lease assignment and internal DNS resolution.",
                    "Inspect localized RF signal strength (RSSI) in the student room."
            );
        }
        return List.of(
                "Conduct physical site inspection and photograph asset condition.",
                "Identify root cause of failure and check for structural or safety hazards.",
                "Verify required replacement components and log corrective maintenance plan."
        );
    }

    private String generateAiSummary(Complaint complaint, String category, String subcategory, Severity severity) {
        String location = (complaint.getBlock() != null ? complaint.getBlock().getName() : "") +
                (complaint.getRoom() != null ? ", Room " + complaint.getRoom().getRoomNumber() : "");
        return String.format("Identified %s issue (%s) at %s with %s severity. Action recommended for maintenance dispatch.",
                category, subcategory, location.isEmpty() ? "reported hostel location" : location, severity);
    }

    private boolean containsAny(String text, String... words) {
        for (String word : words) {
            if (text.contains(word)) return true;
        }
        return false;
    }
}
