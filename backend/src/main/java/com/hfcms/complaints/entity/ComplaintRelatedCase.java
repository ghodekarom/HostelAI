package com.hfcms.complaints.entity;

import com.hfcms.users.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "complaint_related_cases", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"parent_complaint_id", "related_complaint_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ComplaintRelatedCase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "parent_complaint_id", nullable = false)
    private Complaint parentComplaint;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "related_complaint_id", nullable = false)
    private Complaint relatedComplaint;

    @Enumerated(EnumType.STRING)
    @Column(name = "relationship_type", nullable = false, length = 30)
    @Builder.Default
    private RelationshipType relationshipType = RelationshipType.RELATED;

    @Column(name = "similarity_score", precision = 5, scale = 4)
    private BigDecimal similarityScore;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private RelationshipDecision decision = RelationshipDecision.PENDING_REVIEW;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by")
    private User reviewedBy;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "reviewed_at")
    private Instant reviewedAt;
}
