-- Server-side script for txAdmin integration and restart warnings
local restartTimes = Config.RestartWarnings.restartTimes
local warningTimes = Config.RestartWarnings.times

-- txAdmin Integration Events
if Config.TxAdmin.enabled then
    -- Handle txAdmin announcements
    RegisterNetEvent('txAdmin:receiveAnnouncement', function(message, author)
        TriggerClientEvent('hud:txAdminNotification', -1, {
            title = '📢 Server-Ankündigung',
            message = message,
            type = 'info',
            duration = 10000
        })
    end)
    
    -- Handle txAdmin direct messages
    RegisterNetEvent('txAdmin:receiveDirectMessage', function(target, message, author)
        TriggerClientEvent('hud:txAdminNotification', target, {
            title = '💌 Direkte Nachricht',
            message = message,
            type = 'info',
            duration = 8000
        })
    end)
    
    -- Handle txAdmin warnings
    RegisterNetEvent('txAdmin:receiveWarning', function(target, message, author)
        TriggerClientEvent('hud:txAdminNotification', target, {
            title = '⚠️ Admin-Warnung',
            message = message,
            type = 'warning',
            duration = 12000
        })
    end)
    
    -- Server status updates
    RegisterNetEvent('txAdmin:serverStatusChange', function(status, message)
        local title = '🖥️ Server-Status'
        local type = 'info'
        
        if status == 'restarting' then
            title = '🔄 Server wird neu gestartet'
            type = 'warning'
        elseif status == 'maintenance' then
            title = '🔧 Wartungsmodus'
            type = 'warning'
        elseif status == 'online' then
            title = '✅ Server Online'
            type = 'success'
        end
        
        TriggerClientEvent('hud:txAdminNotification', -1, {
            title = title,
            message = message or 'Status-Update',
            type = type,
            duration = 8000
        })
    end)
end

-- Auto-Restart Warning System
if Config.RestartWarnings.enabled then
    Citizen.CreateThread(function()
        while true do
            local currentTime = os.date("*t")
            
            for _, restartTime in pairs(restartTimes) do
                for _, warningMinutes in pairs(warningTimes) do
                    local warningTime = {
                        hour = restartTime.hour,
                        min = restartTime.minute - warningMinutes
                    }
                    
                    -- Handle negative minutes (previous hour)
                    if warningTime.min < 0 then
                        warningTime.min = warningTime.min + 60
                        warningTime.hour = warningTime.hour - 1
                    end
                    
                    -- Handle negative hours (previous day)
                    if warningTime.hour < 0 then
                        warningTime.hour = warningTime.hour + 24
                    end
                    
                    -- Check if current time matches warning time
                    if currentTime.hour == warningTime.hour and 
                       currentTime.min == warningTime.min and 
                       currentTime.sec >= 0 and currentTime.sec <= 5 then
                        
                        local message = string.format('Server-Restart in %d Minuten!', warningMinutes)
                        local nextRestart = string.format('%02d:%02d', restartTime.hour, restartTime.minute)
                        
                        if warningMinutes == 1 then
                            message = 'Server-Restart in 1 Minute! Bitte verlasse Fahrzeuge und sichere deine Items!'
                        elseif warningMinutes <= 5 then
                            message = message .. ' Bereite dich vor!'
                        end
                        
                        -- Send to all clients
                        TriggerClientEvent('hud:txAdminNotification', -1, {
                            title = '🔄 Server-Neustart',
                            message = message .. '\nNächster Restart: ' .. nextRestart,
                            type = 'warning',
                            duration = warningMinutes <= 5 and 15000 or 10000
                        })
                        
                        -- Also send to chat for critical warnings
                        if warningMinutes <= 5 then
                            TriggerClientEvent('chat:addMessage', -1, {
                                color = { 255, 165, 0 },
                                multiline = true,
                                args = { "⚠️ SYSTEM", message }
                            })
                        end
                        
                        -- Log to server console
                        print(string.format('^3[HUD] ^7Restart warning sent: %s^7', message))
                    end
                end
            end
            
            Citizen.Wait(1000) -- Check every second
        end
    end)
end

-- Manual restart command for admins
RegisterNetEvent('hud:manualRestartWarning', function(minutes, reason)
    local source = source
    
    -- Check if player has permission
    if IsPlayerAceAllowed(source, 'command.restart') then
        local message = string.format('Manueller Server-Restart in %d Minuten!', minutes)
        if reason and reason ~= '' then
            message = message .. '\nGrund: ' .. reason
        end
        
        TriggerClientEvent('hud:txAdminNotification', -1, {
            title = '🔄 Manueller Restart',
            message = message,
            type = 'warning',
            duration = 12000
        })
        
        -- Send to chat
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 165, 0 },
            multiline = true,
            args = { "⚠️ ADMIN", message }
        })
        
        print(string.format('^3[HUD] ^7Manual restart warning sent by %s: %s^7', GetPlayerName(source), message))
    end
end)

-- Command for manual restart warnings
RegisterCommand('restartwarning', function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, 'command.restart') then
        local minutes = tonumber(args[1]) or 10
        local reason = table.concat(args, ' ', 2) or ''
        
        TriggerEvent('hud:manualRestartWarning', minutes, reason)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            args = { "ERROR", "Du hast keine Berechtigung für diesen Befehl." }
        })
    end
end, false)

-- Server startup notification
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Wait a bit for other resources to load
        Citizen.SetTimeout(5000, function()
            TriggerClientEvent('hud:txAdminNotification', -1, {
                title = '✅ Modern HUD',
                message = 'HUD-System wurde geladen und ist einsatzbereit!',
                type = 'success',
                duration = 6000
            })
            
            print('^2[Modern HUD] ^7System loaded successfully!^7')
        end)
    end
end)

-- Player connect notifications for admins
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local playerCount = #GetPlayers()
    
    -- Notify admins of player connections
    for _, playerId in ipairs(GetPlayers()) do
        if IsPlayerAceAllowed(playerId, 'command.kick') then
            TriggerClientEvent('hud:txAdminNotification', playerId, {
                title = '👤 Spieler verbunden',
                message = string.format('%s ist dem Server beigetreten (%d/%d)', name, playerCount + 1, GetConvarInt('sv_maxclients', 32)),
                type = 'info',
                duration = 4000
            })
        end
    end
end)

-- Player disconnect notifications for admins
AddEventHandler('playerDropped', function(reason)
    local source = source
    local name = GetPlayerName(source)
    local playerCount = #GetPlayers() - 1
    
    -- Notify admins of player disconnections
    for _, playerId in ipairs(GetPlayers()) do
        if playerId ~= source and IsPlayerAceAllowed(playerId, 'command.kick') then
            TriggerClientEvent('hud:txAdminNotification', playerId, {
                title = '👤 Spieler getrennt',
                message = string.format('%s hat den Server verlassen (%d/%d)\nGrund: %s', name, playerCount, GetConvarInt('sv_maxclients', 32), reason),
                type = 'info',
                duration = 4000
            })
        end
    end
end)

-- Exports for other resources
exports('SendRestartWarning', function(minutes, reason)
    TriggerEvent('hud:manualRestartWarning', minutes, reason or '')
end)

exports('SendAdminNotification', function(title, message, type, duration)
    TriggerClientEvent('hud:txAdminNotification', -1, {
        title = title or 'Admin-Nachricht',
        message = message or '',
        type = type or 'info',
        duration = duration or 8000
    })
end)