Config = {}

-- HUD Configuration
Config.HUD = {
    -- Display toggles
    showHealth = true,
    showArmor = true,
    showHunger = true,
    showThirst = true,
    showMoney = true,
    showPlayerInfo = true,
    showJob = true,
    showSpeedometer = true,
    showFuel = true,
    showMinimap = true,
    
    -- Update intervals (ms)
    statusUpdateInterval = 500,
    vehicleUpdateInterval = 100,
    basicNeedsUpdateInterval = 1000,
    
    -- Colors (Green & Purple theme)
    colors = {
        primary = '#10B981',      -- Green
        secondary = '#8B5CF6',    -- Purple
        accent = '#059669',       -- Dark Green
        background = 'rgba(0, 0, 0, 0.8)',
        text = '#FFFFFF',
        textSecondary = '#D1D5DB',
        hunger = '#F59E0B',       -- Orange for hunger
        thirst = '#3B82F6'        -- Blue for thirst
    },
    
    -- New Positions (updated)
    positions = {
        statusBars = { x = 20, y = -200 },    -- Bottom left near minimap
        money = { x = 20, y = -80 },          -- Bottom left above status
        playerInfo = { x = -350, y = 20 },    -- Top right
        speedometer = { x = -250, y = -120 }, -- Bottom right
        notifications = { x = -400, y = 80 }  -- Top right below player info
    }
}

-- Speedometer settings
Config.Speedometer = {
    useKmh = true,  -- false for MPH
    maxSpeed = 300,
    showGears = true,
    showRPM = true
}

-- Fuel system
Config.Fuel = {
    enabled = true,
    showBar = true,
    lowFuelWarning = 20  -- Percentage
}

-- Notifications
Config.Notifications = {
    duration = 5000,  -- 5 seconds
    maxVisible = 5,
    fadeTime = 500
}

-- Basic Needs (esx_basicneeds)
Config.BasicNeeds = {
    enabled = true,
    showHunger = true,
    showThirst = true,
    lowHungerWarning = 20,   -- Show warning below 20%
    lowThirstWarning = 20,   -- Show warning below 20%
    statusNames = {
        hunger = 'hunger',
        thirst = 'thirst'
    }
}

-- txAdmin Integration
Config.TxAdmin = {
    enabled = true,
    showAnnouncements = true,
    showWarnings = true,
    showKicks = true,
    showBans = true
}

-- Server Restart Warnings
Config.RestartWarnings = {
    enabled = true,
    times = { 30, 15, 10, 5, 3, 2, 1 }, -- Minutes before restart
    restartTimes = {                      -- Restart schedule (24h format)
        { hour = 6, minute = 0 },         -- 06:00
        { hour = 12, minute = 0 },        -- 12:00
        { hour = 18, minute = 0 },        -- 18:00
        { hour = 0, minute = 0 }          -- 00:00
    }
}