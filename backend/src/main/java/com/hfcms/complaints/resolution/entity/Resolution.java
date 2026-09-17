package com.hfcms.complaints.resolution.entity;

import com.hfcms.complaints.entity.Complaint;
import com.hfcms.users.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "resolutions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Resolution {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "complaint_id", nullable = false, unique = true)
    private Complaint complaint;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "proposed_by", nullable = false)
    private User proposedBy;

    @Column(name = "problem_description", nullable = false, columnDefinition = "TEXT")
    private String problemDescription;

    @Column(name = "root_cause", nullable = false, columnDefinition = "TEXT")
    private String rootCause;

    @Column(name = "action_taken", nullable = false, columnDefinition = "TEXT")
    private String actionTaken;

    @Column(name = "result_summary", nullable = false, columnDefinition = "TEXT")
    private String resultSummary;

    @Enumerated(EnumType.STRING)
    @Column(name = "student_decision", nullable = false, length = 30)
    @Builder.Default
    private StudentDecision studentDecision = StudentDecision.PENDING;

    @Column(name = "student_feedback", columnDefinition = "TEXT")
    private String studentFeedback;

    @CreationTimestamp
    @Column(name = "proposed_at", nullable = false, updatable = false)
    private Instant proposedAt;

    @Column(name = "decided_at")
    private Instant decidedAt;
}
