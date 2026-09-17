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

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateBlockRequest {
        @jakarta.validation.constraints.NotNull(message = "Hostel ID is mandatory")
        private Long hostelId;

        @NotBlank(message = "Block name is mandatory")
        private String name;

        @NotBlank(message = "Block code is mandatory")
        private String code;

        private Integer totalFloors;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateRoomRequest {
        @jakarta.validation.constraints.NotNull(message = "Block ID is mandatory")
        private Long blockId;

        @NotBlank(message = "Room number is mandatory")
        private String roomNumber;

        @jakarta.validation.constraints.NotNull(message = "Floor number is mandatory")
        private Integer floorNumber;

        private Integer capacity;
    }
}
