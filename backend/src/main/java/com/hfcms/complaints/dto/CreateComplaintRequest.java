package com.hfcms.complaints.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateComplaintRequest {

    @NotNull(message = "Hostel ID is mandatory")
    private Long hostelId;

    @NotNull(message = "Block ID is mandatory")
    private Long blockId;

    private Long roomId;

    @NotNull(message = "Category ID is mandatory")
    private Long categoryId;

    private String subcategory;

    @NotBlank(message = "Complaint description is mandatory")
    @Size(min = 10, max = 2000, message = "Description must be between 10 and 2000 characters")
    private String description;

    private List<String> evidenceUrls;
}
