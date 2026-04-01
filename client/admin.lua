-- client/admin.lua
-- Admin menu for economy balancing.

RegisterNetEvent('djonstnix:economy:client:openAdmin', function(data)
    lib.registerContext({
        id = 'economy_admin_menu',
        title = 'Economy Management',
        options = {
            {
                title = 'Earning Profiles',
                description = 'Adjust weekly targets for different tiers',
                icon = 'hand-holding-dollar',
                onSelect = function()
                    local options = {}
                    for tier, data in pairs(data.profiles or {}) do
                        table.insert(options, {
                            title = data.label or (tier:sub(1,1):upper()..tier:sub(2)),
                            description = 'Current Target: $' .. (data.weeklyTarget or data),
                            icon = 'chart-line',
                            onSelect = function()
                                local currentTarget = data.weeklyTarget or data
                                local input = lib.inputDialog('Adjust ' .. tier .. ' tier', {
                                    {type = 'number', label = 'Weekly Target ($)', default = currentTarget, min = 0, icon = 'dollar-sign'}
                                })
                                if input then
                                    TriggerServerEvent('djonstnix:economy:server:updateProfile', tier, input[1])
                                end
                            end
                        })
                    end
                    lib.registerContext({
                        id = 'economy_profiles_menu',
                        title = 'Earning Profiles',
                        menu = 'economy_admin_menu',
                        options = options
                    })
                    lib.showContext('economy_profiles_menu')
                end
            },
            {
                title = 'Cycle Settings',
                description = 'Configure measurement days and target hours',
                icon = 'calendar-check',
                onSelect = function()
                    lib.registerContext({
                        id = 'economy_cycle_menu',
                        title = 'Cycle Settings',
                        menu = 'economy_admin_menu',
                        options = {
                            {
                                title = 'Measurement Cycle',
                                description = 'Current: ' .. (data.cycleDays or 7) .. ' days',
                                icon = 'calendar-day',
                                onSelect = function()
                                    local input = lib.inputDialog('Update Cycle', {
                                        {type = 'number', label = 'Days per Cycle', default = data.cycleDays, min = 1, max = 31, icon = 'calendar-day'}
                                    })
                                    if input then
                                        TriggerServerEvent('djonstnix:economy:server:updateCycle', input[1])
                                    end
                                end
                            },
                            {
                                title = 'Target Playtime',
                                description = 'Current: ' .. (data.standardHours or 6) .. ' hours/day',
                                icon = 'hourglass-half',
                                onSelect = function()
                                    local input = lib.inputDialog('Update Target Playtime', {
                                        {type = 'number', label = 'Hours per Day', default = data.standardHours, min = 1, max = 24, icon = 'clock'}
                                    })
                                    if input then
                                        TriggerServerEvent('djonstnix:economy:server:updateHours', input[1])
                                    end
                                end
                            }
                        }
                    })
                    lib.showContext('economy_cycle_menu')
                end
            }
        }
    })
    lib.showContext('economy_admin_menu')
end)
