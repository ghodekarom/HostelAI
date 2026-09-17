-- ==============================================================================
-- Flyway Migration V7: Minimal Required Reference Data Seeding
-- ==============================================================================

-- 1. System Roles (SRS Section 2.2 / PRD Section 4)
INSERT INTO roles (name, description) VALUES
    ('ROLE_STUDENT', 'Hostel resident reporting and confirming complaints'),
    ('ROLE_OPERATOR', 'Maintenance facility operator reviewing and assigning complaints'),
    ('ROLE_TECHNICIAN', 'Field technician performing inspections and repairs'),
    ('ROLE_TEAM_LEAD', 'Hostel warden or maintenance supervisor monitoring SLAs and at-risk cases'),
    ('ROLE_MANAGER', 'Chief warden or dean viewing facility analytics and hotspots'),
    ('ROLE_ADMIN', 'Campus administrator configuring categories, hostels, teams and users')
ON CONFLICT (name) DO NOTHING;

-- 2. Standard Maintenance Teams (PRD Section 10 / SRS Section 7.3)
INSERT INTO teams (name, code, description) VALUES
    ('Plumbing', 'TEAM_PLUMBING', 'Water supply, pipe leakages, bathroom fixtures, and drainage'),
    ('Electrical', 'TEAM_ELECTRICAL', 'Power supply, wiring, lighting, fans, switches, and appliances'),
    ('IT & Internet', 'TEAM_IT_NET', 'Hostel Wi-Fi, LAN connectivity, and network infrastructure'),
    ('Carpentry & Furniture', 'TEAM_CARPENTRY', 'Beds, study tables, chairs, cupboards, doors, and locks'),
    ('Housekeeping & Cleanliness', 'TEAM_HOUSEKEEPING', 'Room hygiene, corridor cleaning, waste management, and pest control'),
    ('Mess & Dining', 'TEAM_MESS', 'Hostel mess, food quality, water coolers, and dining hall facilities')
ON CONFLICT (name) DO NOTHING;

-- 3. Predefined v1 Complaint Categories with Default SLA Targets (PRD Section 9 / SRS Section 7.3)
INSERT INTO categories (name, code, description, sla_hours_p1, sla_hours_p2, sla_hours_p3, sla_hours_p4, is_active) VALUES
    ('Water supply / leakage', 'CAT_WATER', 'Water shortage, pipe bursts, tap leakages, and overhead tank issues', 4, 12, 24, 48, TRUE),
    ('Electrical problems', 'CAT_ELECTRICAL', 'Power outage, sparking, faulty sockets, non-functional fans or lights', 4, 12, 24, 48, TRUE),
    ('Broken furniture', 'CAT_FURNITURE', 'Damaged bed, chair, study table, wardrobe hinges, or shelves', 12, 24, 48, 72, TRUE),
    ('Wi-Fi / Internet', 'CAT_WIFI', 'Access point down, high packet loss, DNS issues, or slow internet', 6, 12, 24, 48, TRUE),
    ('Cleanliness', 'CAT_CLEANLINESS', 'Uncleaned corridors, washroom sanitation, or garbage accumulation', 6, 12, 24, 48, TRUE),
    ('Mess / Food complaints', 'CAT_MESS', 'Dining hall hygiene, drinking water purifier, or food quality issue', 4, 12, 24, 48, TRUE),
    ('Doors / Locks', 'CAT_LOCKS', 'Key stuck, broken latch, door alignment issue, or handle damaged', 4, 12, 24, 48, TRUE),
    ('Lift / Elevator', 'CAT_ELEVATOR', 'Elevator stopped, sensor malfunction, strange noise, or door stuck', 2, 6, 12, 24, TRUE),
    ('Bathroom facilities', 'CAT_BATHROOM', 'Geyser not working, flush malfunction, mirror broken, or clogged drain', 4, 12, 24, 48, TRUE),
    ('Common-area maintenance', 'CAT_COMMON_AREA', 'Gym equipment, study room AC, TV room, corridor lighting, or roof leakage', 8, 24, 48, 72, TRUE)
ON CONFLICT (name) DO NOTHING;
