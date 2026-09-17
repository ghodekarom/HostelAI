-- ==============================================================================
-- Flyway Migration V2: Hostel Physical Infrastructure & Teams Tables
-- ==============================================================================

-- Hostels Table
CREATE TABLE IF NOT EXISTS hostels (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(30) NOT NULL UNIQUE,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Hostel Blocks Table
CREATE TABLE IF NOT EXISTS blocks (
    id BIGSERIAL PRIMARY KEY,
    hostel_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(30) NOT NULL,
    total_floors INT DEFAULT 1 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_blocks_hostel FOREIGN KEY (hostel_id) REFERENCES hostels (id) ON DELETE CASCADE,
    CONSTRAINT uq_block_hostel UNIQUE (hostel_id, code)
);

-- Rooms Table
CREATE TABLE IF NOT EXISTS rooms (
    id BIGSERIAL PRIMARY KEY,
    block_id BIGINT NOT NULL,
    room_number VARCHAR(30) NOT NULL,
    floor_number INT NOT NULL,
    capacity INT DEFAULT 2 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_rooms_block FOREIGN KEY (block_id) REFERENCES blocks (id) ON DELETE CASCADE,
    CONSTRAINT uq_room_block UNIQUE (block_id, room_number)
);

-- Complaint Categories Table
CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    sla_hours_p1 INT DEFAULT 4 NOT NULL,
    sla_hours_p2 INT DEFAULT 24 NOT NULL,
    sla_hours_p3 INT DEFAULT 48 NOT NULL,
    sla_hours_p4 INT DEFAULT 72 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Maintenance Teams Table
CREATE TABLE IF NOT EXISTS teams (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Technicians Table (Maps a user to a maintenance team)
CREATE TABLE IF NOT EXISTS technicians (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    team_id BIGINT NOT NULL,
    is_available BOOLEAN DEFAULT TRUE NOT NULL,
    active_tasks_count INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_technicians_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_technicians_team FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE RESTRICT
);

-- Operational Indexes
CREATE INDEX IF NOT EXISTS idx_blocks_hostel_id ON blocks (hostel_id);
CREATE INDEX IF NOT EXISTS idx_rooms_block_id ON rooms (block_id);
CREATE INDEX IF NOT EXISTS idx_technicians_team_id ON technicians (team_id);
CREATE INDEX IF NOT EXISTS idx_technicians_available ON technicians (is_available, active_tasks_count);
