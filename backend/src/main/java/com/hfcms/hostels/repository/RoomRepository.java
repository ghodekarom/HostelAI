package com.hfcms.hostels.repository;

import com.hfcms.hostels.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RoomRepository extends JpaRepository<Room, Long> {
    List<Room> findByBlockId(Long blockId);
    Optional<Room> findByBlockIdAndRoomNumber(Long blockId, String roomNumber);
}
