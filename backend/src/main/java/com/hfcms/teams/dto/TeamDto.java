package com.hfcms.teams.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

public class TeamDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private Long id;
        private String name;
        private String code;
        private String description;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateRequest {
        @NotBlank(message = "Team name is mandatory")
        private String name;

        @NotBlank(message = "Team code is mandatory")
        private String code;

        private String description;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TechnicianResponse {
        private Long id;
        private Long userId;
        private String technicianName;
        private String email;
        private String phoneNumber;
        private Long teamId;
        private String teamName;
        private Boolean isAvailable;
        private Integer activeTasksCount;
    }
}
