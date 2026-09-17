package com.hfcms.complaints.entity;

import com.hfcms.categories.entity.Category;
import com.hfcms.hostels.entity.Block;
import com.hfcms.hostels.entity.Hostel;
import com.hfcms.hostels.entity.Room;
import com.hfcms.teams.entity.Team;
import com.hfcms.teams.entity.Technician;
import com.hfcms.users.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;

@Entity
@Table(name = "complaints")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Complaint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "case_number", nullable = false, unique = true, length = 50)
    private String caseNumber;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "hostel_id", nullable = false)
    private Hostel hostel;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "block_id", nullable = false)
    private Block block;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id")
    private Room room;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(length = 100)
    private String subcategory;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    @Builder.Default
    private ComplaintStatus status = ComplaintStatus.REPORTED;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private Severity severity = Severity.MEDIUM;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private Priority priority = Priority.P3;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_team_id")
    private Team assignedTeam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_technician_id")
    private Technician assignedTechnician;

    @Enumerated(EnumType.STRING)
    @Column(name = "ai_status", nullable = false, length = 30)
    @Builder.Default
    private AiStatus aiStatus = AiStatus.PENDING;

    @Column(name = "ai_summary", columnDefinition = "TEXT")
    private String aiSummary;

    @Column(name = "sla_deadline")
    private Instant slaDeadline;

    @Column(name = "is_at_risk", nullable = false)
    @Builder.Default
    private Boolean isAtRisk = false;

    @Column(name = "risk_reasons", columnDefinition = "TEXT")
    private String riskReasons;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
