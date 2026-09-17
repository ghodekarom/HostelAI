package com.hfcms.hostels.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

public class HostelDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private Long id;
        private String name;
        private String code;
        private String address;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateRequest {
        @NotBlank(message = "Hostel name is mandatory")
        private String name;

        @NotBlank(message = "Hostel code is mandatory")
        private String code;

        private String address;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BlockResponse {
        private Long id;
        private Long hostelId;
        private String hostelName;
        private String name;
        private String code;
        private Integer totalFloors;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RoomResponse {
        private Long id;
        private Long blockId;
        private String blockName;
        private String roomNumber;
        private Integer floorNumber;
        private Integer capacity;
    }
}
