local ESX = nil
local PlayerData = {}
local isHudVisible = true
local currentVehicle = nil
local fuelLevel = 100

-- Initialize ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    
    PlayerData = ESX.GetPlayerData()
    SendNUIMessage({
        type = 'initHUD',
        config = Config
    })
end)

-- Player data update event
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Main HUD update loop
Citizen.CreateThread(function()
    while true do
        if isHudVisible then
            local playerPed = PlayerPedId()
            local health = GetEntityHealth(playerPed) - 100
            local armor = GetPedArmour(playerPed)
            local stamina = GetPlayerSprintStaminaRemaining(PlayerId())
            
            -- Get money (ESX)
            local money = 0
            local bank = 0
            if PlayerData.money then
                money = PlayerData.money or 0
            end
            if PlayerData.accounts then
                for i=1, #PlayerData.accounts, 1 do
                    if PlayerData.accounts[i].name == 'bank' then
                        bank = PlayerData.accounts[i].money
                    end
                end
            end
            
            -- Send status update to NUI
            SendNUIMessage({
                type = 'updateStatus',
                health = math.max(0, health),
                armor = armor,
                stamina = stamina,
                money = money,
                bank = bank,
                playerName = GetPlayerName(PlayerId()),
                serverId = GetPlayerServerId(PlayerId()),
                job = PlayerData.job and PlayerData.job.label or 'Civilian',
                jobGrade = PlayerData.job and PlayerData.job.grade_label or ''
            })
        end
        
        Citizen.Wait(Config.HUD.statusUpdateInterval)
    end
end)

-- Vehicle HUD update loop
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if vehicle ~= currentVehicle then
                currentVehicle = vehicle
                SendNUIMessage({
                    type = 'toggleVehicleHUD',
                    show = true
                })
            end
            
            if currentVehicle and currentVehicle ~= 0 then
                local speed = GetEntitySpeed(currentVehicle)
                local speedDisplay = Config.Speedometer.useKmh and math.ceil(speed * 3.6) or math.ceil(speed * 2.237)
                local rpm = GetVehicleCurrentRpm(currentVehicle)
                local gear = GetVehicleCurrentGear(currentVehicle)
                local fuel = GetVehicleFuelLevel(currentVehicle)
                
                SendNUIMessage({
                    type = 'updateVehicle',
                    speed = speedDisplay,
                    maxSpeed = Config.Speedometer.maxSpeed,
                    rpm = rpm,
                    gear = gear,
                    fuel = fuel,
                    unit = Config.Speedometer.useKmh and 'KM/H' or 'MPH'
                })
            end
        else
            if currentVehicle then
                currentVehicle = nil
                SendNUIMessage({
                    type = 'toggleVehicleHUD',
                    show = false
                })
            end
        end
        
        Citizen.Wait(Config.HUD.vehicleUpdateInterval)
    end
end)

-- Minimap customization
Citizen.CreateThread(function()
    RequestStreamedTextureDict('squaremap', false)
    while not HasStreamedTextureDictLoaded('squaremap') do
        Wait(150)
    end
    
    SetMinimapClipType(0)
    AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
    AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
    
    -- Minimap positioning and styling
    SetMinimapComponentPosition('minimap', 'L', 'B', -0.0045, -0.025, 0.150, 0.188888)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', -0.020, 0.032, 0.111, 0.159)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.012, 0.025, 0.227, 0.213)
    
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetRadarZoom(1150)
end)

-- Toggle HUD visibility
RegisterCommand('hud', function()
    isHudVisible = not isHudVisible
    SendNUIMessage({
        type = 'toggleHUD',
        show = isHudVisible
    })
end, false)

-- Notification system
function ShowNotification(title, message, type, duration)
    SendNUIMessage({
        type = 'showNotification',
        title = title,
        message = message,
        notificationType = type or 'info',
        duration = duration or Config.Notifications.duration
    })
end

-- Export the notification function
exports('ShowNotification', ShowNotification)

-- ESX Notification override
RegisterNetEvent('esx:showNotification')
AddEventHandler('esx:showNotification', function(message, type, duration)
    ShowNotification('System', message, type, duration)
end)

-- Advanced notification with custom styling
RegisterNetEvent('hud:showAdvancedNotification')
AddEventHandler('hud:showAdvancedNotification', function(data)
    SendNUIMessage({
        type = 'showAdvancedNotification',
        data = data
    })
end)