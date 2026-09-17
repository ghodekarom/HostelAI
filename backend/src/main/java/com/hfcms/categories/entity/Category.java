package com.hfcms.categories.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;

@Entity
@Table(name = "categories")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(nullable = false, unique = true, length = 50)
    private String code;

    @Column(length = 255)
    private String description;

    @Column(name = "sla_hours_p1", nullable = false)
    @Builder.Default
    private Integer slaHoursP1 = 4;

    @Column(name = "sla_hours_p2", nullable = false)
    @Builder.Default
    private Integer slaHoursP2 = 24;

    @Column(name = "sla_hours_p3", nullable = false)
    @Builder.Default
    private Integer slaHoursP3 = 48;

    @Column(name = "sla_hours_p4", nullable = false)
    @Builder.Default
    private Integer slaHoursP4 = 72;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
