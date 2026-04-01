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

fx_version 'cerulean'
game 'gta5'

author 'DjonStNix'
description 'Master Economy Profile Engine (EPE) for the DjonStNix Ecosystem'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/admin.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/migration.lua',
    'server/playtime.lua',
    'server/balancing.lua',
    'server/commands.lua',
    'server/diagnose.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js'
}

dependencies {
    'oxmysql',
    'ox_lib',
    'DjonStNix-Bridge'
}
