package com.hfcms.complaints.assignment.entity;

import com.hfcms.complaints.entity.Complaint;
import com.hfcms.teams.entity.Team;
import com.hfcms.teams.entity.Technician;
import com.hfcms.users.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "assignment_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AssignmentHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "complaint_id", nullable = false)
    private Complaint complaint;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "previous_technician_id")
    private Technician previousTechnician;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "new_technician_id")
    private Technician newTechnician;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "previous_team_id")
    private Team previousTeam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "new_team_id")
    private Team newTeam;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "assigned_by", nullable = false)
    private User assignedBy;

    @Column(name = "assignment_reason", columnDefinition = "TEXT")
    private String assignmentReason;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
