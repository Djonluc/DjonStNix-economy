local Core = exports['DjonStNix-Bridge']:GetCore()
local EconomyResource = GetCurrentResourceName()

-- [[ Economic Telemetry Dashboard ]] --
-- Allows administrators to query the exact macroeconomic state of the server at any given time.
Core.Security.RegisterCommand('economy', { "admin", "god", "superadmin" }, function(source, args)
    local src = source
    if GetResourceState('DjonStNix-Banking') ~= 'started' then
        Core.Notify(src, "Error: Central Banking link offline. Telemetry unavailable.", "error")
        return
    end

    local moneySupply = exports['DjonStNix-Banking']:GetMoneySupply()
    local characters = exports['DjonStNix-Banking']:GetTotalCharacters() or 1
    
    local state = exports[EconomyResource]:GetSnapshotState()
    local profile = exports[EconomyResource]:GetProfile()
    
    local avgWealth = math.floor(moneySupply / characters)
    local targetWealth = Config.InflationControl.Thresholds.DeflationPerPlayer

    -- Calculate Inflation Pressure (100+ means severe inflation)
    local inflationIndex = math.floor((avgWealth / Config.InflationControl.Thresholds.InflationPerPlayer) * 100)
    local indexColor = inflationIndex > 85 and "^1" or (inflationIndex < 30 and "^2" or "^5")

    local payload = {
        state = state,
        profile = profile.name,
        moneySupply = moneySupply,
        characters = characters,
        avgWealth = avgWealth,
        inflationIndex = inflationIndex
    }

    TriggerClientEvent('djonstnix-economy:client:openMonitor', src, payload)
end, "Open Economic Telemetry Dashboard", {})

-- Handle force state changes from the ox_lib UI
RegisterNetEvent('djonstnix-economy:server:forceState', function(newState)
    local src = source
    if not Core.Player.HasPermission(src, { "admin", "god", "superadmin" }) then return end
    
    exports[EconomyResource]:SetSnapshotState(newState)
    Core.Notify(src, "Economy state forcefully set to " .. newState, "success")
    Core.Log('admin', ('%s forcefully changed economy state to %s'):format(GetPlayerName(src), newState))
end)

-- [[ Economy Balancing (Admin) ]] --
Core.Security.RegisterCommand('economy:admin', { "admin", "god", "superadmin" }, function(source, args)
    local src = source
    local config = exports[EconomyResource]:GetBalancingConfig()
    
    TriggerClientEvent('djonstnix:economy:client:openAdmin', src, {
        profiles = config.Profiles,
        cycleDays = config.CycleDays,
        standardHours = config.StandardPlaytimeHours
    })
end, "Open Economy Balancing & Targets", {})
