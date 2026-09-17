package com.hfcms.complaints.investigation.entity;

import com.hfcms.users.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(name = "checklist_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChecklistItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "checklist_id", nullable = false)
    private InvestigationChecklist checklist;

    @Column(name = "item_description", nullable = false, length = 255)
    private String itemDescription;

    @Column(name = "is_completed", nullable = false)
    @Builder.Default
    private Boolean isCompleted = false;

    @Column(columnDefinition = "TEXT")
    private String findings;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recorded_by")
    private User recordedBy;

    @Column(name = "recorded_at")
    private Instant recordedAt;
}
