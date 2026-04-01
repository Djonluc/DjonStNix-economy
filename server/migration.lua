-- server/migration.lua
-- Runs early in script startup to ensure schema structure is aligned.

MigrationsComplete = false

CreateThread(function()
    print("^3[DjonStNix-Economy] ^7Checking Database Schema...")
    
    -- Ensure schema history table exists
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS djonstnix_economy_schema_migrations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            version INT NOT NULL,
            applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY (version)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    
    local currentDbVersion = tonumber(MySQL.Sync.fetchScalar('SELECT MAX(version) FROM djonstnix_economy_schema_migrations')) or 0
    local targetVersion = 1

    if currentDbVersion < targetVersion then
        print("^3[DjonStNix-Economy] ^7Updates available! Running incremental migrations (" .. currentDbVersion .. " -> " .. targetVersion .. ")")
        
        -- Migration 1: Economy Balancing & Playtime
        if currentDbVersion < 1 then
            -- Determine the correct parent table for foreign keys
            local parentTable = "players"
            local tableCheck = MySQL.Sync.fetchScalar("SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'djonstnix_citizens'")
            if tableCheck then
                parentTable = "djonstnix_citizens"
            end
            print("^4[DjonStNix-Economy]^7 Using ^5" .. parentTable .. "^7 as master identity table.")

            -- Global Balancing Settings
            MySQL.Sync.execute([[
                CREATE TABLE IF NOT EXISTS `djonstnix_economy_balancing` (
                    `key_name` VARCHAR(64) PRIMARY KEY,
                    `data_value` JSON NOT NULL,
                    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            ]])

            -- Player Playtime Stats per Cycle
            MySQL.Sync.execute([[
                CREATE TABLE IF NOT EXISTS `djonstnix_player_playtime` (
                    `citizenid` VARCHAR(50) PRIMARY KEY,
                    `profile_tier` VARCHAR(32) DEFAULT 'starter',
                    `cycle_minutes` INT DEFAULT 0,
                    `daily_minutes` INT DEFAULT 0,
                    `last_active` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    `cycle_start` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            ]])

            MySQL.Sync.execute('INSERT IGNORE INTO djonstnix_economy_schema_migrations (version) VALUES (1)')
        end
        
        print("^2[DjonStNix-Economy] ^7Migrations applied successfully.")
    end
    
    -- V2.2: Consistent Repair Check (Ensures table exists even if migration skipped)
    local hasTable = MySQL.Sync.fetchScalar("SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'djonstnix_player_playtime'")
    if not hasTable then
        print("^3[DjonStNix-Economy] ^7Playtime table missing! Triggering emergency repair...")
        
        local parentTable = "players"
        local tableCheck = MySQL.Sync.fetchScalar("SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'djonstnix_citizens'")
        if tableCheck then parentTable = "djonstnix_citizens" end

        MySQL.Sync.execute([[
            CREATE TABLE IF NOT EXISTS `djonstnix_player_playtime` (
                `citizenid` VARCHAR(50) PRIMARY KEY,
                `profile_tier` VARCHAR(32) DEFAULT 'starter',
                `cycle_minutes` INT DEFAULT 0,
                `daily_minutes` INT DEFAULT 0,
                `last_active` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                `cycle_start` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]])
        print("^2[DjonStNix-Economy] ^7Repair successful.")
    end

    MigrationsComplete = true
end)
