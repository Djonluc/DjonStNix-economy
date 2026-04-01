-- server/diagnose.lua
-- Diagnostic tool for DjonStNix-Economy database state.

RegisterCommand('dsn-econ-repair', function(source, args, rawCommand)
    if source ~= 0 and not exports['DjonStNix-Bridge']:GetCore().Player.IsAdmin(source) then 
        print("^1[DjonStNix-Economy] ^7Unauthorized access to repair command.")
        return 
    end

    print("^4--- DjonStNix-Economy Diagnostic Report ---^7")
    
    local hasTable = MySQL.Sync.fetchScalar("SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'djonstnix_player_playtime'")
    if hasTable then
        print("^2[✓]^7 Table 'djonstnix_player_playtime' exists.")
        local cols = MySQL.Sync.fetchAll("DESCRIBE djonstnix_player_playtime")
        for _, col in ipairs(cols) do
            print(("- Field: ^5%-15s^7 Type: ^3%-15s^7"):format(col.Field, col.Type))
        end
    else
        print("^1[✗]^7 Table 'djonstnix_player_playtime' is missing! Attempting manual creation...")
        
        local parentTable = "players"
        local tableCheck = MySQL.Sync.fetchScalar("SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'djonstnix_citizens'")
        if tableCheck then parentTable = "djonstnix_citizens" end
        print("^4[DjonStNix-Economy]^7 Using ^5" .. parentTable .. "^7 as master identity table.")

        local status, err = pcall(function()
            MySQL.Sync.execute(string.format([[
                CREATE TABLE IF NOT EXISTS `djonstnix_player_playtime` (
                    `citizenid` VARCHAR(50) PRIMARY KEY,
                    `profile_tier` VARCHAR(32) DEFAULT 'starter',
                    `cycle_minutes` INT DEFAULT 0,
                    `daily_minutes` INT DEFAULT 0,
                    `last_active` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    `cycle_start` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (`citizenid`) REFERENCES `%s`(`citizenid`) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            ]], parentTable))
        end)

        if status then
            print("^2[✓] Manual creation successful.")
        else
            print("^1[✗] Manual creation failed: " .. tostring(err))
            print("^3[TIP] ^7Check if the parent table '" .. parentTable .. "' actually exists and has a 'citizenid' column.")
        end
    end
    print("^4------------------------------------------^7")
end, false)
