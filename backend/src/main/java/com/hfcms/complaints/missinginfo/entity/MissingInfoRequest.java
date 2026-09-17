package com.hfcms.complaints.missinginfo.entity;

import com.hfcms.complaints.entity.Complaint;
import com.hfcms.users.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "missing_info_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MissingInfoRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "complaint_id", nullable = false)
    private Complaint complaint;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requested_by", nullable = false)
    private User requestedBy;

    @Column(name = "is_ai_drafted", nullable = false)
    @Builder.Default
    private Boolean isAiDrafted = false;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String questions;

    @Column(name = "student_response", columnDefinition = "TEXT")
    private String studentResponse;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private MissingInfoStatus status = MissingInfoStatus.WAITING_FOR_RESPONSE;

    @CreationTimestamp
    @Column(name = "requested_at", nullable = false, updatable = false)
    private Instant requestedAt;

    @Column(name = "responded_at")
    private Instant respondedAt;
}
