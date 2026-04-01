-- Local config mirror for persistence (Synchronized with config.lua)
local BalancingConfig = Config.EconomyBalance

---
--- Initialization: Load settings from DB
---
CreateThread(function()
    while not MigrationsComplete do Wait(1000) end
    
    local settings = MySQL.Sync.fetchAll("SELECT * FROM djonstnix_economy_balancing")
    for _, s in ipairs(settings) do
        local data = json.decode(s.data_value)
        if s.key_name == 'tiers' then
            BalancingConfig.Tiers = data
        elseif s.key_name == 'cycle_days' then
            BalancingConfig.CycleDays = tonumber(data)
        elseif s.key_name == 'standard_playtime' then
            BalancingConfig.StandardPlaytimeHours = tonumber(data)
        end
    end
end)

---
--- EXPORTS
---

exports('GetEconomyBalanceEnabled', function()
    return BalancingConfig.Enabled
end)

exports('GetBalancingConfig', function()
    return BalancingConfig
end)

exports('GetBalancedPayRate', function(citizenid)
    -- Fetch player profile
    local econData = MySQL.Sync.fetchAll("SELECT profile_tier FROM djonstnix_player_playtime WHERE citizenid = ?", { citizenid })[1]
    local tier = econData and econData.profile_tier or BalancingConfig.ActiveTier
    
    local profileData = BalancingConfig.Tiers[tier] or BalancingConfig.Tiers[BalancingConfig.ActiveTier]
    local targetWeekly = profileData.weeklyTarget
    
    -- Sync with Banking frequency
    local intervalMins = 15
    local bankState = GetResourceState('DjonStNix-Banking')
    if bankState == 'started' then
        local snapshot = exports['DjonStNix-Banking']:GetEconomySnapshot()
        intervalMins = snapshot.paycheckInterval or 15
    end
    
    -- Math: Weekly Target / (Days in Cycle * Target Playtime Hours * Intervals per Hour)
    -- We divide by 1.0 for floating point precision before floor
    local intervalsPerHour = 60 / intervalMins
    local totalPeriodsInCycle = BalancingConfig.CycleDays * BalancingConfig.StandardPlaytimeHours * intervalsPerHour
    local amountPerPeriod = targetWeekly / totalPeriodsInCycle
    
    return math.floor(amountPerPeriod * 100) -- Return as integer cents
end)

---
--- Admin Persistence
---
function SaveEconomySetting(key, value)
    MySQL.Async.execute("INSERT INTO djonstnix_economy_balancing (key_name, data_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE data_value = ?", {
        key, json.encode(value), json.encode(value)
    })
end

---
--- ox_lib Handlers
---

RegisterNetEvent('djonstnix:economy:server:updateProfile', function(tier, newTarget)
    local src = source
    if not exports['DjonStNix-Bridge']:IsAdmin(src) then return end
    
    newTarget = tonumber(newTarget)
    if not newTarget or newTarget < 0 then return end
    
    if BalancingConfig.Tiers[tier] then
        BalancingConfig.Tiers[tier].weeklyTarget = newTarget
        SaveEconomySetting('tiers', BalancingConfig.Tiers)
        exports['DjonStNix-Bridge']:Notify(src, "Updated " .. tier .. " weekly target to $" .. newTarget, "success")
    end
end)

RegisterNetEvent('djonstnix:economy:server:updateCycle', function(newCycle)
    local src = source
    if not exports['DjonStNix-Bridge']:IsAdmin(src) then return end
    
    newCycle = tonumber(newCycle)
    if not newCycle or newCycle < 1 then return end
    
    BalancingConfig.CycleDays = newCycle
    SaveEconomySetting('cycle_days', newCycle)
    
    exports['DjonStNix-Bridge']:Notify(src, "Updated measurement cycle to " .. newCycle .. " days", "success")
end)

RegisterNetEvent('djonstnix:economy:server:updateHours', function(newHours)
    local src = source
    if not exports['DjonStNix-Bridge']:IsAdmin(src) then return end
    
    newHours = tonumber(newHours)
    if not newHours or newHours < 1 then return end
    
    BalancingConfig.StandardPlaytimeHours = newHours
    SaveEconomySetting('standard_playtime', newHours)
    
    exports['DjonStNix-Bridge']:Notify(src, "Updated daily target hours to " .. newHours, "success")
end)
