package com.hfcms.teams.repository;

import com.hfcms.teams.entity.Technician;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TechnicianRepository extends JpaRepository<Technician, Long> {
    Optional<Technician> findByUserId(Long userId);
    List<Technician> findByTeamIdAndIsAvailableTrueOrderByActiveTasksCountAsc(Long teamId);
}
