Config = {}

-- HUD Settings
Config.HUD = {
    enabled = true,
    refreshRate = 100, -- milliseconds
    hideInVehicle = false
}

-- Player Info Settings
Config.PlayerInfo = {
    enabled = true,
    position = {x = 'right', y = 20}, -- top right position
    showMoney = true,
    showBank = true,
    showJob = true,
    showHealth = true,
    showArmor = true,
    colors = {
        primary = '#8B5CF6', -- purple
        secondary = '#10B981', -- green
        background = 'transparent' -- no background color
    }
}

-- Speedometer Settings  
Config.Speedometer = {
    enabled = true,
    position = {x = 50, y = 85}, -- bottom center (percentage)
    unit = 'kmh', -- kmh or mph
    showFuel = true,
    showEngine = true,
    colors = {
        primary = '#8B5CF6',
        secondary = '#10B981',
        background = 'transparent' -- no background color
    }
}

-- Notification Settings
Config.Notifications = {
    enabled = true,
    position = {x = 85, y = 15}, -- top right
    duration = 5000, -- milliseconds
    maxNotifications = 5,
    colors = {
        info = '#3B82F6',
        success = '#10B981',
        warning = '#F59E0B',
        error = '#EF4444',
        announcement = '#8B5CF6'
    }
}

-- Seatbelt Settings
Config.Seatbelt = {
    enabled = true,
    key = 'K', -- toggle key
    showIcon = true,
    position = {x = 50, y = 50}, -- center
    ejectSpeed = 45, -- speed threshold for ejection
    colors = {
        on = '#10B981',
        off = '#EF4444'
    }
}

-- Status Settings (Hunger/Thirst)
Config.Status = {
    enabled = true,
    position = {x = 'right', y = 'bottom'}, -- bottom right
    showHunger = true,
    showThirst = true,
    colors = {
        hunger = '#F59E0B',
        thirst = '#3B82F6',
        background = 'transparent' -- no background color
    }
}

-- Server Restart Notifications
Config.ServerRestart = {
    enabled = true,
    warningTimes = {30, 15, 10, 5, 3, 2, 1}, -- minutes before restart
    message = 'Server Neustart in %s Minuten!'
}