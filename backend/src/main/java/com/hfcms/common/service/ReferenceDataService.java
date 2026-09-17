package com.hfcms.common.service;

import com.hfcms.categories.dto.CategoryDto;
import com.hfcms.categories.entity.Category;
import com.hfcms.categories.repository.CategoryRepository;
import com.hfcms.common.exception.ResourceNotFoundException;
import com.hfcms.hostels.dto.HostelDto;
import com.hfcms.hostels.entity.Block;
import com.hfcms.hostels.entity.Hostel;
import com.hfcms.hostels.entity.Room;
import com.hfcms.hostels.repository.BlockRepository;
import com.hfcms.hostels.repository.HostelRepository;
import com.hfcms.hostels.repository.RoomRepository;
import com.hfcms.teams.dto.TeamDto;
import com.hfcms.teams.entity.Team;
import com.hfcms.teams.repository.TeamRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReferenceDataService {

    private final CategoryRepository categoryRepository;
    private final TeamRepository teamRepository;
    private final HostelRepository hostelRepository;
    private final BlockRepository blockRepository;
    private final RoomRepository roomRepository;

    // Categories
    @Transactional(readOnly = true)
    public List<CategoryDto.Response> getActiveCategories() {
        return categoryRepository.findByIsActiveTrue().stream()
                .map(this::mapToCategoryResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public CategoryDto.Response createCategory(CategoryDto.CreateRequest request) {
        Category category = Category.builder()
                .name(request.getName())
                .code(request.getCode())
                .description(request.getDescription())
                .slaHoursP1(request.getSlaHoursP1() != null ? request.getSlaHoursP1() : 4)
                .slaHoursP2(request.getSlaHoursP2() != null ? request.getSlaHoursP2() : 24)
                .slaHoursP3(request.getSlaHoursP3() != null ? request.getSlaHoursP3() : 48)
                .slaHoursP4(request.getSlaHoursP4() != null ? request.getSlaHoursP4() : 72)
                .isActive(true)
                .build();
        return mapToCategoryResponse(categoryRepository.save(category));
    }

    // Teams
    @Transactional(readOnly = true)
    public List<TeamDto.Response> getAllTeams() {
        return teamRepository.findAll().stream()
                .map(t -> TeamDto.Response.builder()
                        .id(t.getId())
                        .name(t.getName())
                        .code(t.getCode())
                        .description(t.getDescription())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public TeamDto.Response createTeam(TeamDto.CreateRequest request) {
        Team team = Team.builder()
                .name(request.getName())
                .code(request.getCode())
                .description(request.getDescription())
                .build();
        Team saved = teamRepository.save(team);
        return TeamDto.Response.builder()
                .id(saved.getId())
                .name(saved.getName())
                .code(saved.getCode())
                .description(saved.getDescription())
                .build();
    }

    // Hostels, Blocks, Rooms
    @Transactional(readOnly = true)
    public List<HostelDto.Response> getAllHostels() {
        return hostelRepository.findAll().stream()
                .map(h -> HostelDto.Response.builder()
                        .id(h.getId())
                        .name(h.getName())
                        .code(h.getCode())
                        .address(h.getAddress())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<HostelDto.BlockResponse> getBlocksByHostel(Long hostelId) {
        return blockRepository.findByHostelId(hostelId).stream()
                .map(b -> HostelDto.BlockResponse.builder()
                        .id(b.getId())
                        .hostelId(b.getHostel().getId())
                        .hostelName(b.getHostel().getName())
                        .name(b.getName())
                        .code(b.getCode())
                        .totalFloors(b.getTotalFloors())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<HostelDto.RoomResponse> getRoomsByBlock(Long blockId) {
        return roomRepository.findByBlockId(blockId).stream()
                .map(r -> HostelDto.RoomResponse.builder()
                        .id(r.getId())
                        .blockId(r.getBlock().getId())
                        .blockName(r.getBlock().getName())
                        .roomNumber(r.getRoomNumber())
                        .floorNumber(r.getFloorNumber())
                        .capacity(r.getCapacity())
                        .build())
                .collect(Collectors.toList());
    }

    private CategoryDto.Response mapToCategoryResponse(Category c) {
        return CategoryDto.Response.builder()
                .id(c.getId())
                .name(c.getName())
                .code(c.getCode())
                .description(c.getDescription())
                .slaHoursP1(c.getSlaHoursP1())
                .slaHoursP2(c.getSlaHoursP2())
                .slaHoursP3(c.getSlaHoursP3())
                .slaHoursP4(c.getSlaHoursP4())
                .isActive(c.getIsActive())
                .build();
    }
}
