local currentEconomyState = "Stable"

RegisterNetEvent('djonstnix-economy:client:StateUpdate')
AddEventHandler('djonstnix-economy:client:StateUpdate', function(state)
    -- Prevent duplicate notifications if a late-joiner is synced
    if currentEconomyState == state then return end
    currentEconomyState = state

    if state == "Inflation" then
        lib.notify({
            title = 'Macro-Economy Alert',
            description = 'City Economy: Inflationary Pressure 📈\nPrices have risen at shops as wealth circulates at high levels.',
            type = 'error',
            duration = 15000,
            icon = 'arrow-trend-up'
        })
    elseif state == "Deflation" then
        lib.notify({
            title = 'Macro-Economy Alert',
            description = 'City Economy: Stimulus active �\nPrices have dropped and social payouts have surged to boost the economy!',
            type = 'success',
            duration = 15000,
            icon = 'arrow-trend-down'
        })
    elseif state == "Stable" then
        lib.notify({
            title = 'Macro-Economy Alert',
            description = 'City Economy: Stable 🟡\nThe market has naturally corrected to baseline.',
            type = 'info',
            duration = 15000,
            icon = 'scale-balanced'
        })
    end
end)

RegisterNetEvent('djonstnix-economy:client:openMonitor', function(data)
    local options = {
        {
            title = 'Current State: ' .. data.state,
            description = ('Profile: %s\nMoney Supply: $%s\nCharacters: %s\nAvg Wealth: $%s\nInflation Pressure: %s%%'):format(
                data.profile, 
                math.floor(data.moneySupply), 
                data.characters, 
                data.avgWealth, 
                data.inflationIndex
            ),
            icon = 'chart-line',
            readOnly = true
        },
        {
            title = 'Force Inflation (High Prices)',
            description = 'Simulate hyper-inflation and market markup.',
            icon = 'arrow-trend-up',
            iconColor = '#ff4d4d',
            serverEvent = 'djonstnix-economy:server:forceState',
            args = 'Inflation'
        },
        {
            title = 'Force Deflation (Low Prices)',
            description = 'Simulate economic stimulus and price drops.',
            icon = 'arrow-trend-down',
            iconColor = '#4dff4d',
            serverEvent = 'djonstnix-economy:server:forceState',
            args = 'Deflation'
        },
        {
            title = 'Force Stable (Baseline)',
            description = 'Return market to natural equilibrium.',
            icon = 'scale-balanced',
            iconColor = '#4da6ff',
            serverEvent = 'djonstnix-economy:server:forceState',
            args = 'Stable'
        }
    }

    lib.registerContext({
        id = 'economy_dashboard',
        title = '📊 Economic Telemetry',
        options = options
    })

    lib.showContext('economy_dashboard')
end)

-- ==================================================
-- NUI COMMUNICATION (Phase 2 Alignment)
-- ==================================================

RegisterNetEvent('djonstnix-economy:client:OpenDashboard', function(payload)
    SendNUIMessage({
        action = "openEconomyDashboard",
        payload = payload
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
