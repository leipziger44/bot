local ESX = nil
local PlayerData = {}
local isHudVisible = true
local currentVehicle = nil
local fuelLevel = 100
local hunger = 100
local thirst = 100
local restartWarningActive = false

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

-- Player data update events
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- esx_basicneeds integration
RegisterNetEvent('esx_status:onTick')
AddEventHandler('esx_status:onTick', function(data)
    if Config.BasicNeeds.enabled then
        for i=1, #data do
            if data[i].name == Config.BasicNeeds.statusNames.hunger then
                hunger = math.floor(data[i].percent)
                
                -- Low hunger warning
                if hunger <= Config.BasicNeeds.lowHungerWarning and hunger > 0 then
                    if math.random(1, 100) <= 5 then -- 5% chance per tick
                        ShowNotification('Hunger', 'Du solltest etwas essen!', 'warning', 3000)
                    end
                end
            elseif data[i].name == Config.BasicNeeds.statusNames.thirst then
                thirst = math.floor(data[i].percent)
                
                -- Low thirst warning
                if thirst <= Config.BasicNeeds.lowThirstWarning and thirst > 0 then
                    if math.random(1, 100) <= 5 then -- 5% chance per tick
                        ShowNotification('Durst', 'Du solltest etwas trinken!', 'warning', 3000)
                    end
                end
            end
        end
    end
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
                hunger = hunger,
                thirst = thirst,
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

-- Server Restart Warning System
Citizen.CreateThread(function()
    if not Config.RestartWarnings.enabled then return end
    
    while true do
        local currentTime = os.date("*t")
        
        for _, restartTime in pairs(Config.RestartWarnings.restartTimes) do
            for _, warningMinutes in pairs(Config.RestartWarnings.times) do
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
                if currentTime.hour == warningTime.hour and currentTime.min == warningTime.min and currentTime.sec == 0 then
                    local message = string.format('Server-Restart in %d Minuten!', warningMinutes)
                    if warningMinutes == 1 then
                        message = 'Server-Restart in 1 Minute!'
                    end
                    
                    ShowNotification('🔄 Server-Restart', message, 'warning', 8000)
                    
                    -- Special handling for final warnings
                    if warningMinutes <= 5 then
                        TriggerEvent('chat:addMessage', {
                            color = { 255, 165, 0 },
                            multiline = true,
                            args = { "System", message }
                        })
                    end
                end
            end
        end
        
        Citizen.Wait(1000) -- Check every second
    end
end)

-- txAdmin Event Handlers
if Config.TxAdmin.enabled then
    -- txAdmin Announcements
    RegisterNetEvent('txcl:setAnnounce')
    AddEventHandler('txcl:setAnnounce', function(message, author)
        if Config.TxAdmin.showAnnouncements then
            ShowNotification('📢 Ankündigung', message, 'info', 10000)
        end
    end)
    
    -- txAdmin Direct Messages
    RegisterNetEvent('txcl:setDirectMessage')
    AddEventHandler('txcl:setDirectMessage', function(message, author)
        ShowNotification('💌 Direkte Nachricht', message, 'info', 8000)
    end)
    
    -- txAdmin Warnings
    RegisterNetEvent('txcl:receiveWarning')
    AddEventHandler('txcl:receiveWarning', function(message, author)
        if Config.TxAdmin.showWarnings then
            ShowNotification('⚠️ Warnung', message, 'warning', 12000)
        end
    end)
    
    -- Server Status Updates
    RegisterNetEvent('txcl:serverStatus')
    AddEventHandler('txcl:serverStatus', function(status, message)
        local title = '🖥️ Server'
        local type = 'info'
        
        if status == 'restarting' then
            title = '🔄 Server-Neustart'
            type = 'warning'
        elseif status == 'maintenance' then
            title = '🔧 Wartung'
            type = 'warning'
        elseif status == 'online' then
            title = '✅ Server Online'
            type = 'success'
        end
        
        ShowNotification(title, message, type, 8000)
    end)
end

-- Toggle HUD visibility
RegisterCommand('hud', function()
    isHudVisible = not isHudVisible
    SendNUIMessage({
        type = 'toggleHUD',
        show = isHudVisible
    })
end, false)

-- Admin command for testing restart warnings
RegisterCommand('testrestart', function()
    if IsPlayerAceAllowed(PlayerId(), 'command.testrestart') then
        ShowNotification('🔄 Server-Restart', 'Test Restart-Warnung in 5 Minuten!', 'warning', 5000)
    end
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

-- txAdmin notification handler
RegisterNetEvent('hud:txAdminNotification')
AddEventHandler('hud:txAdminNotification', function(data)
    ShowNotification(data.title, data.message, data.type, data.duration)
end)