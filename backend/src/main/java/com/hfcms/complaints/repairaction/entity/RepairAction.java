package com.hfcms.complaints.repairaction.entity;

import com.hfcms.complaints.entity.Complaint;
import com.hfcms.teams.entity.Technician;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "repair_actions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RepairAction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "complaint_id", nullable = false)
    private Complaint complaint;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "technician_id", nullable = false)
    private Technician technician;

    @Column(name = "action_taken", nullable = false, columnDefinition = "TEXT")
    private String actionTaken;

    @Column(name = "evidence_url", length = 500)
    private String evidenceUrl;

    @Column(name = "parts_replaced", columnDefinition = "TEXT")
    private String partsReplaced;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
