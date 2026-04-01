-- ==============================================================================
-- 👑 DJONSTNIX BRANDING
-- ==============================================================================
-- DEVELOPED BY: DjonStNix (DjonLuc)
-- GITHUB: https://github.com/Djonluc
-- DISCORD: https://discord.gg/s7GPUHWrS7
-- YOUTUBE: https://www.youtube.com/@Djonluc
-- EMAIL: djonstnix@gmail.com
-- LICENSE: MIT License (c) 2026 DjonStNix (DjonLuc)
-- ==============================================================================

pcall(function() exports['DjonStNix-Branding']:PrintWatermark(GetCurrentResourceName(), '2.2.0') end)
local EconomyState = "Stable"
local LastStateChangeTime = 0

-- ==================================================
-- V2.5: ADVANCED SECTOR DEMAND ENGINE
-- ==================================================
local SectorDemand = {
    ['shop'] = 1.0,
    ['vehicle'] = 1.0,
    ['commodity'] = 1.0,
    ['luxury'] = 1.0
}

local SectorSalesCount = {
    ['shop'] = 0,
    ['vehicle'] = 0,
    ['commodity'] = 0,
    ['luxury'] = 0
}

-- Decay demand over time (Every 30 minutes)
lib.cron.new('*/30 * * * *', function()
    for sector, demand in pairs(SectorDemand) do
        if demand > 1.0 then
            SectorDemand[sector] = math.max(1.0, demand - 0.05)
        elseif demand < 1.0 then
            SectorDemand[sector] = math.min(1.0, demand + 0.05)
        end
    end
end)

exports('RegisterSectorSale', function(sector, amount)
    if not SectorDemand[sector] then return end
    amount = amount or 1
    SectorSalesCount[sector] = SectorSalesCount[sector] + amount
    
    -- Increase demand based on sales volume
    local increment = 0.01 * amount
    SectorDemand[sector] = math.min(2.5, SectorDemand[sector] + increment)
end)

-- ==================================================
-- V2.1: PRICE CACHE (5-minute TTL)
-- ==================================================
local PriceCache = {}
local PRICE_CACHE_TTL = 300 -- 5 minutes in seconds

local function GetCachedPrice(basePrice, category)
    local key = category .. ":" .. tostring(basePrice)
    local cached = PriceCache[key]
    if cached and (os.time() - cached.time) < PRICE_CACHE_TTL then
        return cached.result
    end
    return nil
end

local function SetCachedPrice(basePrice, category, result)
    local key = category .. ":" .. tostring(basePrice)
    PriceCache[key] = { result = result, time = os.time() }
end

-- Flush cache when economy state changes or demand shifts significantly
local function FlushPriceCache()
    PriceCache = {}
end

-- ==================================================
-- EXPORTS
-- ==================================================

exports('GetProfile', function()
    return currentProfile
end)

exports('GetMaxPaycheck', function()
    return Config.MaxAllowedPaycheck or 50000
end)

exports('GetSnapshotState', function()
    return EconomyState
end)

exports('SetSnapshotState', function(newState)
    EconomyState = newState
    LastStateChangeTime = os.time()
    FlushPriceCache()
    TriggerClientEvent("djonstnix-economy:client:StateUpdate", -1, EconomyState)
    return true
end)

-- V2.5: Advanced Price adjuster with Sector-Demand awareness
exports('GetAdjustedPrice', function(basePrice, category, citizenid)
    local tier = 'starter'
    
    -- If citizenid is provided, try to fetch their specific tier
    if citizenid then
        local econData = MySQL.Sync.fetchAll("SELECT profile_tier FROM djonstnix_player_playtime WHERE citizenid = ?", { citizenid })[1]
        tier = econData and econData.profile_tier or Config.EconomyBalance.ActiveTier
    else
        tier = Config.EconomyBalance.ActiveTier
    end

    local profile = Config.EconomyBalance.Tiers[tier]
    if not profile then return basePrice end

    -- Check cache (Tier + Category + Demand + MacroState)
    local demandKey = math.floor((SectorDemand[category] or 1.0) * 10) -- Normalize to 0.1 increments for cache efficiency
    local cacheKey = table.concat({tier, category, demandKey, EconomyState, tostring(basePrice)}, ":")
    local cached = GetCachedPrice(basePrice, cacheKey)
    if cached then return cached end
    
    local tierMultiplier = 1.0
    if category == 'shop' or category == 'commodity' then
        tierMultiplier = profile.shopMultiplier
    elseif category == 'vehicle' then
        tierMultiplier = profile.vehicleMultiplier
    elseif category == 'mission' or category == 'crime' then
        tierMultiplier = profile.missionMultiplier
    elseif category == 'paycheck' then
        tierMultiplier = profile.paycheckMultiplier
    end
    
    -- Macro-Economic State Modifiers
    local macroMultiplier = 1.0
    if EconomyState == "Inflation" then
        if category == 'shop' or category == 'commodity' then
            macroMultiplier = 1.25
        elseif category == 'vehicle' then
            macroMultiplier = 1.10
        elseif category == 'mission' or category == 'crime' then
            macroMultiplier = 0.75
        end
    elseif EconomyState == "Deflation" then
        if category == 'shop' or category == 'commodity' then
            macroMultiplier = 0.85
        elseif category == 'vehicle' then
            macroMultiplier = 0.90
        elseif category == 'mission' or category == 'crime' then
            macroMultiplier = 1.25
        end
    end
    
    -- Sector-Specific Demand Multiplier
    local demandMultiplier = SectorDemand[category] or 1.0
    
    -- Final Formula: Base * Tier * Macro * Demand
    local result = math.floor(basePrice * tierMultiplier * macroMultiplier * demandMultiplier)
    
    SetCachedPrice(basePrice, cacheKey, result)
    return result
end)

-- ==================================================
-- MACRO-ECONOMY AUTONOMOUS OVERRIDES
-- V2.1: Uses Banking.GetEconomySnapshot() instead of direct queries
-- ==================================================
if Config.InflationControl.Enabled then
    lib.cron.new('*/'..Config.InflationControl.CheckInterval..' * * * *', function()
        if GetResourceState('DjonStNix-Banking') ~= 'started' then return end
        
        -- V2.1: Read from shared snapshot cache instead of triggering DB queries
        local snapshot = exports['DjonStNix-Banking']:GetEconomySnapshot()
        local currentWealth = snapshot and snapshot.moneySupply or 0
        local totalCharacters = snapshot and snapshot.characterCount or 1
        local newState = "Stable"
        
        local DynamicInflationThreshold = Config.InflationControl.Thresholds.InflationPerPlayer * totalCharacters
        local DynamicDeflationThreshold = Config.InflationControl.Thresholds.DeflationPerPlayer * totalCharacters
        
        if currentWealth > DynamicInflationThreshold then
            newState = "Inflation"
        elseif currentWealth < DynamicDeflationThreshold then
            newState = "Deflation"
        else
            newState = "Stable"
        end
        
        if EconomyState ~= newState then
            local timeSinceLastChange = os.time() - LastStateChangeTime
            local cooldownSeconds = Config.InflationControl.StateCooldown * 60
            
            if timeSinceLastChange >= cooldownSeconds then
                EconomyState = newState
                LastStateChangeTime = os.time()
                FlushPriceCache()
                
                -- V2.2: Centralized broadcast via Bridge
                exports['DjonStNix-Bridge']:BroadcastEvent('economy:stateUpdate', EconomyState)
                
                if EconomyState == "Inflation" then
                    exports['DjonStNix-Bridge']:GetCore().UI.Broadcast("Los Santos News: Federal Reserve announces Market Inflation. Prices rising.", "error")
                    print("^1[DjonStNix-Economy]^7 [ALERT] High Wealth detected. Engaging Inflation Correction.")
                elseif EconomyState == "Deflation" then
                    exports['DjonStNix-Bridge']:GetCore().UI.Broadcast("Los Santos News: Federal Reserve announces Market Deflation. Stimulus active.", "success")
                    print("^2[DjonStNix-Economy]^7 [ALERT] Low Wealth detected. Engaging Deflation Stimulus.")
                else
                    exports['DjonStNix-Bridge']:GetCore().UI.Broadcast("Los Santos News: Economy officially stabilized.", "info")
                    print("^5[DjonStNix-Economy]^7 [ALERT] Wealth per capita stabilized. Returning to Stable Economy.")
                end
            else
                local remainMins = math.ceil((cooldownSeconds - timeSinceLastChange) / 60)
            end
        end
    end)
end

-- ==================================================
-- ECOSYSTEM TELEMETRY (Phase 2 Alignment)
-- ==================================================

function GetEconomyPulse()
    local sectors = {}
    for name, demand in pairs(SectorDemand) do
        table.insert(sectors, {
            name = name,
            label = name:gsub("_", " "):gsub("^%l", string.upper),
            demand = demand
        })
    end

    local totalWealth = 0
    local charCount = 1
    if GetResourceState('DjonStNix-Banking') == 'started' then
        local snapshot = exports['DjonStNix-Banking']:GetEconomySnapshot()
        totalWealth = snapshot and snapshot.moneySupply or 0
        charCount = snapshot and snapshot.characterCount or 1
    end

    local stateLabel = EconomyState:lower()
    local eventType = "neutral"
    if EconomyState == "Inflation" then eventType = "negative"
    elseif EconomyState == "Deflation" then eventType = "positive" end

    return {
        inflationRate = (EconomyState == "Inflation" and 0.25 or (EconomyState == "Deflation" and -0.15 or 0.0)),
        globalMoneySupply = totalWealth,
        characterCount = charCount,
        state = stateLabel,
        sectors = sectors,
        recentEvents = {
            { id = 1, text = "Federal Reserve market audit complete.", time = os.date("%H:%M"), type = "neutral" },
            { id = 2, text = ("Market environment identified as %s."):format(EconomyState), time = os.date("%H:%M"), type = eventType }
        }
    }
end

exports('GetEconomyPulse', GetEconomyPulse)

RegisterCommand('economy', function(source, args, rawCommand)
    local src = source
    local player = exports['DjonStNix-Bridge']:GetCore().Player.GetPlayer(src)
    if not player then return end

    local pulse = GetEconomyPulse()
    TriggerClientEvent('djonstnix-economy:client:OpenDashboard', src, pulse)
end, false)
