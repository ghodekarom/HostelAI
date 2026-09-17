package com.hfcms.hostels.repository;

import com.hfcms.hostels.entity.Block;
import com.hfcms.hostels.entity.Hostel;
import com.hfcms.hostels.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HostelRepository extends JpaRepository<Hostel, Long> {
    Optional<Hostel> findByCode(String code);
}
