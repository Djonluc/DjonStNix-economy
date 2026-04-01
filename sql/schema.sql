-- ==============================================================================
-- 📈 DJONSTNIX ECONOMY - CORE SCHEMA [v2.5.0]
-- ==============================================================================

-- 1. Schema Version Tracking
-- Used by server/migration.lua to track incremental updates.
CREATE TABLE IF NOT EXISTS `djonstnix_economy_schema_migrations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `version` INT NOT NULL,
    `applied_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Global Balancing Settings
-- Stores dynamic configuration data like tier targets and cycle durations.
CREATE TABLE IF NOT EXISTS `djonstnix_economy_balancing` (
    `key_name` VARCHAR(64) PRIMARY KEY,
    `data_value` JSON NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Player Playtime Stats per Cycle
-- Monitors cumulative player activity to determine economic tier progression.
CREATE TABLE IF NOT EXISTS `djonstnix_player_playtime` (
    `citizenid` VARCHAR(50) PRIMARY KEY,
    `profile_tier` VARCHAR(32) DEFAULT 'starter',
    `cycle_minutes` INT DEFAULT 0,
    `daily_minutes` INT DEFAULT 0,
    `last_active` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `cycle_start` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
