package com.hfcms.categories.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

public class CategoryDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private Long id;
        private String name;
        private String code;
        private String description;
        private Integer slaHoursP1;
        private Integer slaHoursP2;
        private Integer slaHoursP3;
        private Integer slaHoursP4;
        private Boolean isActive;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateRequest {
        @NotBlank(message = "Name is mandatory")
        private String name;

        @NotBlank(message = "Code is mandatory")
        private String code;

        private String description;
        private Integer slaHoursP1;
        private Integer slaHoursP2;
        private Integer slaHoursP3;
        private Integer slaHoursP4;
    }
}
