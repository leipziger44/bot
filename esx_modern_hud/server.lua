local ESX = exports['es_extended']:getSharedObject()

-- Server restart system
local restartTimer = nil
local restartWarnings = {}

-- Initialize restart warnings
for i, time in ipairs(Config.ServerRestart.warningTimes) do
    restartWarnings[time] = false
end

-- Commands
RegisterCommand('restart', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Check if player has admin permission (adjust as needed)
    if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
        local minutes = tonumber(args[1]) or 10
        
        if minutes > 0 then
            StartRestartTimer(minutes)
            TriggerClientEvent('chat:addMessage', -1, {
                color = {255, 0, 0},
                multiline = true,
                args = {'SYSTEM', 'Server Neustart in ' .. minutes .. ' Minuten geplant!'}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {'SYSTEM', 'Du hast keine Berechtigung für diesen Befehl!'}
        })
    end
end, true)

RegisterCommand('cancelrestart', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
        if restartTimer then
            CancelRestartTimer()
            TriggerClientEvent('chat:addMessage', -1, {
                color = {0, 255, 0},
                multiline = true,
                args = {'SYSTEM', 'Server Neustart wurde abgebrochen!'}
            })
        end
    end
end, true)

-- Restart timer functions
function StartRestartTimer(minutes)
    if restartTimer then
        CancelRestartTimer()
    end
    
    -- Reset warnings
    for time, _ in pairs(restartWarnings) do
        restartWarnings[time] = false
    end
    
    local totalSeconds = minutes * 60
    
    restartTimer = CreateThread(function()
        while totalSeconds > 0 do
            local remainingMinutes = math.ceil(totalSeconds / 60)
            
            -- Check if we should send a warning
            if restartWarnings[remainingMinutes] ~= nil and not restartWarnings[remainingMinutes] then
                restartWarnings[remainingMinutes] = true
                TriggerClientEvent('esx_modern_hud:serverRestart', -1, remainingMinutes)
                
                -- Also send chat message
                TriggerClientEvent('chat:addMessage', -1, {
                    color = {255, 165, 0},
                    multiline = true,
                    args = {'RESTART', 'Server startet in ' .. remainingMinutes .. ' Minute(n) neu!'}
                })
            end
            
            totalSeconds = totalSeconds - 1
            Wait(1000)
        end
        
        -- Final restart
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 0, 0},
            multiline = true,
            args = {'SYSTEM', 'Server startet JETZT neu!'}
        })
        
        Wait(5000)
        ExecuteCommand('quit')
    end)
end

function CancelRestartTimer()
    if restartTimer then
        restartTimer = nil
    end
end

-- Global notification command
RegisterCommand('announce', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'moderator' or xPlayer.getGroup() == 'superadmin' then
        local message = table.concat(args, ' ')
        if message and message ~= '' then
            TriggerClientEvent('esx_modern_hud:showNotification', -1, message, 'announcement', 10000)
            
            TriggerClientEvent('chat:addMessage', -1, {
                color = {139, 92, 246},
                multiline = true,
                args = {'ANKÜNDIGUNG', message}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {'SYSTEM', 'Du hast keine Berechtigung für diesen Befehl!'}
        })
    end
end, true)

-- Notification events
RegisterNetEvent('esx_modern_hud:sendNotification')
AddEventHandler('esx_modern_hud:sendNotification', function(target, message, type, duration)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Only allow certain groups to send notifications to others
    if target ~= source and (xPlayer.getGroup() ~= 'admin' and xPlayer.getGroup() ~= 'superadmin') then
        return
    end
    
    if target == -1 then
        -- Send to all players
        TriggerClientEvent('esx_modern_hud:showNotification', -1, message, type, duration)
    else
        -- Send to specific player
        TriggerClientEvent('esx_modern_hud:showNotification', target, message, type, duration)
    end
end)

-- Player connection messages
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local playerName = GetPlayerName(playerId)
    if playerName then
        TriggerClientEvent('esx_modern_hud:showNotification', -1, playerName .. ' ist dem Server beigetreten', 'info', 5000)
    end
end)

RegisterNetEvent('esx:playerDropped')
AddEventHandler('esx:playerDropped', function(playerId, reason)
    local playerName = GetPlayerName(playerId)
    if playerName then
        TriggerClientEvent('esx_modern_hud:showNotification', -1, playerName .. ' hat den Server verlassen', 'info', 5000)
    end
end)

-- Export functions for other resources
exports('ShowNotification', function(playerId, message, type, duration)
    TriggerClientEvent('esx_modern_hud:showNotification', playerId, message, type, duration)
end)

exports('ShowGlobalNotification', function(message, type, duration)
    TriggerClientEvent('esx_modern_hud:showNotification', -1, message, type, duration)
end)