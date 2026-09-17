package com.hfcms.auth.repository;

import com.hfcms.auth.entity.VerificationCode;
import com.hfcms.auth.entity.VerificationType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;

@Repository
public interface VerificationCodeRepository extends JpaRepository<VerificationCode, Long> {

    Optional<VerificationCode> findFirstByUserIdAndTypeAndUsedAtIsNullOrderByCreatedAtDesc(Long userId, VerificationType type);

    @Modifying
    @Query("UPDATE VerificationCode v SET v.usedAt = :now WHERE v.user.id = :userId AND v.type = :type AND v.usedAt IS NULL")
    void invalidateExistingCodes(@Param("userId") Long userId, @Param("type") VerificationType type, @Param("now") Instant now);
}
