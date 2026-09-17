package com.hfcms.complaints.audit.entity;

import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.users.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "case_status_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CaseStatusHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "complaint_id", nullable = false)
    private Complaint complaint;

    @Enumerated(EnumType.STRING)
    @Column(name = "previous_status", length = 50)
    private ComplaintStatus previousStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "new_status", nullable = false, length = 50)
    private ComplaintStatus newStatus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by")
    private User changedBy;

    @Column(name = "change_reason", columnDefinition = "TEXT")
    private String changeReason;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
