Config = {}

-- [[ Economy Balancing & Macro-Engine ]] --
-- This system calculates dynamic paychecks to meet weekly income targets
-- and provides global price multipliers (Inflation/Recession) for the ecosystem.

Config.EconomyBalance = {
    Enabled = true,
    ActiveTier = 'starter',        -- Default tier for new players if not set in DB
    CycleDays = 7,                 -- Default to weekly (7 days)
    StandardPlaytimeHours = 6,     -- Hours per day expected to reach targets
    
    -- [[ TIERED PROFILES ]] --
    -- Weekly Target: What the player should earn in a cycle
    -- Multipliers: How much the economy (Shops/Vehicles/Jobs) scales for this tier
    Tiers = {
        ['starter'] = {
            label = "Starter",
            weeklyTarget = 100000,
            shopMultiplier = 1.0,     -- 100% commodity costs
            vehicleMultiplier = 1.0,  -- 100% vehicle costs
            missionMultiplier = 1.0,  -- 100% crime/mission payouts
            paycheckMultiplier = 1.0, -- Standard salary baseline
            taxRate = 0.05            -- 5% income tax
        },
        ['professional'] = {
            label = "Professional",
            weeklyTarget = 180000,
            shopMultiplier = 1.25,     -- Slightly higher costs for commodities
            vehicleMultiplier = 1.0,  -- Stable vehicle costs
            missionMultiplier = 1.0,  -- Stable income scaling
            taxRate = 0.08
        },
        ['veteran'] = {
            label = "Veteran",
            weeklyTarget = 200000,
            shopMultiplier = 1.5,
            vehicleMultiplier = 1.0,
            missionMultiplier = 1.0,
            taxRate = 0.12
        },
        ['executive'] = {
            label = "Executive",
            weeklyTarget = 300000,
            shopMultiplier = 2.0,
            vehicleMultiplier = 1.0, -- Normalized to avoid punishing heavy investors
            missionMultiplier = 1.0, -- Normalized 
            taxRate = 0.15
        }
    }
}

-- [[ Advanced Autonomous Inflation Control ]] --
-- If enabled, the engine will check DjonStNix-Banking's money supply.
Config.InflationControl = {
    Enabled = true,
    CheckInterval = 30, -- Minutes (Syncs with Banking GetMoneySupply)
    StateCooldown = 90, -- Minutes (Minimum time before the state can flip again to prevent oscillation)
    Thresholds = {
        -- Scaling: Threshold * Total Character Count
        DeflationPerPlayer = 200000, -- $200k average wealth triggers Stimulus
        InflationPerPlayer = 5000000 -- $5M average wealth triggers Inflation Correction
    }
}

-- [[ Anti-Exploit Guardrails ]] --
-- Hard ceiling on any single QBCore paycheck to prevent rogue scripts/exploits.
Config.MaxAllowedPaycheck = 50000 -- Hard cap per 15 mins
