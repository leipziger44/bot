local ESX = exports['es_extended']:getSharedObject()

-- Variables
local PlayerData = {}
local isLoggedIn = false
local seatbeltOn = false
local speedBuffer = {}
local velBuffer = {}
local isInVehicle = false
local currentVehicle = nil

-- Initialize
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    isLoggedIn = true
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setConfig',
        config = Config
    })
    SendNUIMessage({action = 'show'})
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    isLoggedIn = false
    SendNUIMessage({action = 'hide'})
end)

-- Update player data
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Main HUD Thread
CreateThread(function()
    while true do
        if isLoggedIn and Config.HUD.enabled then
            local playerPed = PlayerPedId()
            local playerId = PlayerId()
            
            -- Get player info
            local health = GetEntityHealth(playerPed) - 100
            local armor = GetPedArmour(playerPed)
            local money = 0
            local bank = 0
            
            if PlayerData.money then
                money = PlayerData.money
            end
            if PlayerData.accounts then
                for i=1, #PlayerData.accounts, 1 do
                    if PlayerData.accounts[i].name == 'bank' then
                        bank = PlayerData.accounts[i].money
                    end
                end
            end
            
            -- Check if in vehicle
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local wasInVehicle = isInVehicle
            isInVehicle = vehicle ~= 0
            
            if isInVehicle then
                currentVehicle = vehicle
                local speed = GetEntitySpeed(vehicle)
                local speedKmh = math.floor(speed * 3.6)
                local speedMph = math.floor(speed * 2.237)
                local fuel = GetVehicleFuelLevel(vehicle)
                local engineHealth = GetVehicleEngineHealth(vehicle)
                local rpm = GetVehicleCurrentRpm(vehicle)
                
                -- Speed buffer for seatbelt system
                speedBuffer[#speedBuffer + 1] = speedKmh
                if #speedBuffer > 5 then
                    table.remove(speedBuffer, 1)
                end
                
                SendNUIMessage({
                    action = 'updateSpeedometer',
                    data = {
                        speed = Config.Speedometer.unit == 'kmh' and speedKmh or speedMph,
                        unit = Config.Speedometer.unit,
                        fuel = math.floor(fuel),
                        engineHealth = math.floor(engineHealth / 10),
                        rpm = rpm,
                        gear = GetVehicleCurrentGear(vehicle),
                        seatbelt = seatbeltOn,
                        show = true
                    }
                })
            else
                if wasInVehicle then
                    SendNUIMessage({
                        action = 'updateSpeedometer',
                        data = {show = false}
                    })
                end
                currentVehicle = nil
                speedBuffer = {}
            end
            
            -- Update player info
            SendNUIMessage({
                action = 'updatePlayerInfo',
                data = {
                    health = health,
                    armor = armor,
                    money = money,
                    bank = bank,
                    job = PlayerData.job and PlayerData.job.label or 'Arbeitslos',
                    jobGrade = PlayerData.job and PlayerData.job.grade_label or '',
                    name = GetPlayerName(playerId),
                    id = GetPlayerServerId(playerId)
                }
            })
            
            -- Check hunger and thirst (ESX Status)
            TriggerEvent('esx_status:getStatus', 'hunger', function(hunger)
                TriggerEvent('esx_status:getStatus', 'thirst', function(thirst)
                    SendNUIMessage({
                        action = 'updateStatus',
                        data = {
                            hunger = hunger and hunger.getPercent() or 100,
                            thirst = thirst and thirst.getPercent() or 100
                        }
                    })
                end)
            end)
        end
        
        Wait(Config.HUD.refreshRate)
    end
end)

-- Seatbelt System
CreateThread(function()
    while true do
        if isLoggedIn and Config.Seatbelt.enabled and isInVehicle then
            local playerPed = PlayerPedId()
            
            -- Seatbelt physics
            if not seatbeltOn then
                local coords = GetEntityCoords(playerPed)
                local prevSpeed = speedBuffer[#speedBuffer - 1] or 0
                local currentSpeed = speedBuffer[#speedBuffer] or 0
                
                if prevSpeed > Config.Seatbelt.ejectSpeed and currentSpeed < (prevSpeed * 0.75) then
                    -- Eject player
                    SetEntityCoords(playerPed, coords.x, coords.y, coords.z + 1.0, true, true, true)
                    SetEntityVelocity(playerPed, 0.0, 0.0, 0.0)
                    SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
                    
                    -- Damage
                    local damage = math.random(10, 25)
                    SetEntityHealth(playerPed, GetEntityHealth(playerPed) - damage)
                    
                    ShowNotification('Du wurdest aus dem Fahrzeug geschleudert! Schnall dich an!', 'error')
                end
            end
        end
        Wait(100)
    end
end)

-- Seatbelt key binding
RegisterKeyMapping('seatbelt', 'Seatbelt Toggle', 'keyboard', Config.Seatbelt.key)
RegisterCommand('seatbelt', function()
    if isInVehicle and Config.Seatbelt.enabled then
        seatbeltOn = not seatbeltOn
        local message = seatbeltOn and 'Sicherheitsgurt angelegt' or 'Sicherheitsgurt abgelegt'
        ShowNotification(message, seatbeltOn and 'success' or 'warning')
        
        -- Play sound
        if seatbeltOn then
            PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', 1)
        else
            PlaySoundFrontend(-1, 'CANCEL', 'HUD_MINI_GAME_SOUNDSET', 1)
        end
    end
end, false)

-- Notification system
function ShowNotification(message, type, duration)
    SendNUIMessage({
        action = 'showNotification',
        data = {
            message = message,
            type = type or 'info',
            duration = duration or Config.Notifications.duration
        }
    })
end

-- Server events
RegisterNetEvent('esx_modern_hud:showNotification')
AddEventHandler('esx_modern_hud:showNotification', function(message, type, duration)
    ShowNotification(message, type, duration)
end)

RegisterNetEvent('esx_modern_hud:serverRestart')
AddEventHandler('esx_modern_hud:serverRestart', function(minutes)
    local message = string.format(Config.ServerRestart.message, minutes)
    ShowNotification(message, 'announcement', 10000)
end)

-- NUI Callbacks
RegisterNUICallback('ready', function(data, cb)
    SendNUIMessage({
        action = 'setConfig',
        config = Config
    })
    cb('ok')
end)

-- Hide default HUD elements
CreateThread(function()
    while true do
        if isLoggedIn then
            -- Hide default HUD components
            HideHudComponentThisFrame(1)  -- Wanted Stars
            HideHudComponentThisFrame(2)  -- Weapon Icon
            HideHudComponentThisFrame(3)  -- Cash
            HideHudComponentThisFrame(4)  -- MP Cash
            HideHudComponentThisFrame(6)  -- Vehicle Name
            HideHudComponentThisFrame(7)  -- Area Name
            HideHudComponentThisFrame(8)  -- Vehicle Class
            HideHudComponentThisFrame(9)  -- Street Name
            HideHudComponentThisFrame(13) -- Cash Change
            HideHudComponentThisFrame(17) -- Save Game
            HideHudComponentThisFrame(20) -- Stamina Bar
        end
        Wait(0)
    end
end)