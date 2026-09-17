package com.hfcms.common.controller;

import com.hfcms.categories.dto.CategoryDto;
import com.hfcms.common.dto.ApiResponse;
import com.hfcms.common.service.ReferenceDataService;
import com.hfcms.hostels.dto.HostelDto;
import com.hfcms.teams.dto.TeamDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@Tag(name = "Admin Operations", description = "Endpoints for managing categories, teams, and hostel physical infrastructure")
public class AdminController {

    private final ReferenceDataService referenceDataService;

    // Categories
    @GetMapping("/categories")
    @Operation(summary = "Get list of all active complaint categories")
    public ResponseEntity<ApiResponse<List<CategoryDto.Response>>> getCategories() {
        return ResponseEntity.ok(ApiResponse.success(referenceDataService.getActiveCategories()));
    }

    @PostMapping("/categories")
    @Operation(summary = "Create a new complaint category")
    public ResponseEntity<ApiResponse<CategoryDto.Response>> createCategory(@Valid @RequestBody CategoryDto.CreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Category created successfully", referenceDataService.createCategory(request)));
    }

    // Teams
    @GetMapping("/teams")
    @Operation(summary = "Get list of all maintenance teams")
    public ResponseEntity<ApiResponse<List<TeamDto.Response>>> getTeams() {
        return ResponseEntity.ok(ApiResponse.success(referenceDataService.getAllTeams()));
    }

    @PostMapping("/teams")
    @Operation(summary = "Create a new maintenance team")
    public ResponseEntity<ApiResponse<TeamDto.Response>> createTeam(@Valid @RequestBody TeamDto.CreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Team created successfully", referenceDataService.createTeam(request)));
    }

    // Hostels, Blocks, Rooms
    @GetMapping("/hostels")
    @Operation(summary = "Get list of all hostels")
    public ResponseEntity<ApiResponse<List<HostelDto.Response>>> getHostels() {
        return ResponseEntity.ok(ApiResponse.success(referenceDataService.getAllHostels()));
    }

    @PostMapping("/hostels")
    @Operation(summary = "Create a new hostel")
    public ResponseEntity<ApiResponse<HostelDto.Response>> createHostel(@Valid @RequestBody HostelDto.CreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Hostel created successfully", referenceDataService.createHostel(request)));
    }

    @GetMapping("/hostels/{hostelId}/blocks")
    @Operation(summary = "Get list of blocks within a hostel")
    public ResponseEntity<ApiResponse<List<HostelDto.BlockResponse>>> getBlocks(@PathVariable Long hostelId) {
        return ResponseEntity.ok(ApiResponse.success(referenceDataService.getBlocksByHostel(hostelId)));
    }

    @PostMapping("/blocks")
    @Operation(summary = "Create a new block within a hostel")
    public ResponseEntity<ApiResponse<HostelDto.BlockResponse>> createBlock(@Valid @RequestBody HostelDto.CreateBlockRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Block created successfully", referenceDataService.createBlock(request)));
    }

    @GetMapping("/blocks/{blockId}/rooms")
    @Operation(summary = "Get list of rooms within a block")
    public ResponseEntity<ApiResponse<List<HostelDto.RoomResponse>>> getRooms(@PathVariable Long blockId) {
        return ResponseEntity.ok(ApiResponse.success(referenceDataService.getRoomsByBlock(blockId)));
    }

    @PostMapping("/rooms")
    @Operation(summary = "Create a new room within a block")
    public ResponseEntity<ApiResponse<HostelDto.RoomResponse>> createRoom(@Valid @RequestBody HostelDto.CreateRoomRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Room created successfully", referenceDataService.createRoom(request)));
    }
}
