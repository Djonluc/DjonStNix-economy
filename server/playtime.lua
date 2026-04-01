-- server/playtime.lua
-- Heartbeat loop to track player playtime.

CreateThread(function()
    while not MigrationsComplete do Wait(1000) end
    
    while true do
        Wait(60000) -- 1 minute
        local players = GetPlayers()
        for _, srcStr in ipairs(players) do
            local src = tonumber(srcStr)
            local citizenid = exports['DjonStNix-Bridge']:GetIdentifier(src)
            if citizenid then
                MySQL.Async.execute([[
                    INSERT INTO djonstnix_player_playtime (citizenid, cycle_minutes, daily_minutes)
                    VALUES (?, 1, 1)
                    ON DUPLICATE KEY UPDATE 
                    cycle_minutes = cycle_minutes + 1,
                    daily_minutes = daily_minutes + 1,
                    last_active = CURRENT_TIMESTAMP
                ]], { citizenid })
            end
        end
    end
end)
