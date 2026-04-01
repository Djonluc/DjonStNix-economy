<!-- ==============================================================================
👑 DJONSTNIX BRANDING
==============================================================================
DEVELOPED BY: DjonStNix (DjonLuc)
GITHUB: https://github.com/Djonluc
DISCORD: https://discord.gg/s7GPUHWrS7
LICENSE: MIT License (c) 2026 DjonStNix (DjonLuc)
============================================================================== -->

# 📈 djonstnix-economy [v2.5.0]

### Macro-Economic Simulator & Adaptive Engine for the DjonStNix Ecosystem

**djonstnix-economy** is the "analytical brain" of your server valuation. It monitors global wealth patterns, identifies inflation or recession states, and broadcasts dynamic price multipliers to ensure your server economy remains balanced and engaging.

[![FiveM Support](https://img.shields.io/badge/FiveM-QBCore-red?style=for-the-badge)](https://github.com/qbcore-framework)
[![Status](https://img.shields.io/badge/Status-v2.5.0--Market--Aware-green?style=for-the-badge)](#)
[![DjonStNix Premium](https://img.shields.io/badge/DjonStNix-Premium-gold?style=for-the-badge)](https://discord.gg/s7GPUHWrS7)

---

## 📖 Overview

The Economy Engine solves the classic problem of "infinite money" by dynamically adjusting the purchasing power of the server currency. By monitoring the total money supply in Banking, it automatically triggers state changes that make goods more expensive during inflation or cheaper during economic downturns, forcing players to adapt to a shifting market.

---

## ✨ New in v2.5.0

- 🛍️ **Advanced Sector Demand Engine:** Tracks individual sector popularity (Shops, Vehicles, Commodities, Luxury). As players buy more from a sector, its demand increases, driving up prices locally for that category.
- ⚡ **Price Caching (V2.1):** High-performance 5-minute TTL cache for adjusted prices, ensuring zero lag even with thousands of shop items.
- 🛠️ **Consistent Repair Check:** Automated database integrity checks on startup to ensure playtime and balancing tables are always healthy.
- 📊 **Enhanced Telemetry:** New dashboard exports for the Government and Banking resources to provide deep insights into sector-specific fiscal health.

---

## 🧠 Core Features

- ⚖️ **Unified Tiered Economy:** Link price multipliers directly to player earning tiers (Starter, Professional, Veteran, Executive).
- 🕒 **Playtime Tracking:** Precise monitoring of cumulative player activity with adaptive salary adjustments.
- 🔄 **Adaptive Ecosystem:** Dynamically scales prices in Shops, Vehicles, and Missions based on the player's personal economic progression.
- 🛡️ **Anti-Exploit Cap:** Hard ceilings on single paychecks to prevent runaway inflation from malicious cash injections.
- 📡 **Global EventBus:** Emits state changes via the Bridge for cross-script reactions.

---

## 🔗 Recommended Integrations

| Resource | Purpose |
| :--- | :--- |
| **[DjonStNix-Bridge](https://github.com/Djonluc/DjonStNix-Bridge)** | Required for player and framework abstraction. |
| **[DjonStNix-Banking](https://github.com/Djonluc/DjonStNix-Banking)** | Required as the data source for the global money supply. |
| **[DjonStNix-Shops](https://github.com/Djonluc/DjonStNix-Shops)** | Primary consumer of the economy's price multipliers. |
| **[DjonStNix-Government](file:///c:/fivem/Files/resources/[addons]/DjonStNix-Government)** | Links state fiscal policy with macro-economic cycles. |

---

## 📥 Installation

1. Place the `djonstnix-economy` folder in your `resources/[addons]/` directory.
2. Ensure it starts **after** `DjonStNix-Banking` in your `server.cfg`.
3. Import the SQL schema located at `sql/schema.sql`.
4. Configure your thresholds and tiers in `config.lua`.

```cfg
# DjonStNix Macro Engine
ensure DjonStNix-Bridge
ensure DjonStNix-Banking
ensure djonstnix-economy
```

---

## 💻 Commands

| Command | Description | Permission |
| :--- | :--- | :--- |
| `/economy` | Displays the Interactive Economic Telemetry Dashboard | Admin |
| `/seteconomystate` | Manually overrides the current economic state (Inflation/Deflation/Stable) | Admin |
| `/economy:admin` | `ox_lib` menu to adjust Weekly Targets, Cycle Days, and Playtime Goals | Admin |
| `/economytest` | Executes a diagnostic stress test of the pricing math | Admin |

---

## 🔌 Exports

```lua
-- Returns the price adjusted by current Tier + Macro State + Sector Demand
exports['djonstnix-economy']:GetAdjustedPrice(basePrice, category, citizenid)

-- Register a sale to influence sector demand for the CATEGORY: 'shop', 'vehicle', 'commodity', or 'luxury'
exports['djonstnix-economy']:RegisterSectorSale(category, amount)

-- Returns the full state snapshot (inflationWeight, moneySupply, state)
exports['djonstnix-economy']:GetEconomyPulse()
```

---

## 🛡️ License

MIT License © 2026 **DjonStNix Ecosystem**. All rights reserved.
