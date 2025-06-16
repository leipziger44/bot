Config = {}

-- HUD Configuration
Config.HUD = {
    -- Display toggles
    showHealth = true,
    showArmor = true,
    showMoney = true,
    showPlayerInfo = true,
    showJob = true,
    showSpeedometer = true,
    showFuel = true,
    showMinimap = true,
    
    -- Update intervals (ms)
    statusUpdateInterval = 500,
    vehicleUpdateInterval = 100,
    
    -- Colors (Green & Purple theme)
    colors = {
        primary = '#10B981',      -- Green
        secondary = '#8B5CF6',    -- Purple
        accent = '#059669',       -- Dark Green
        background = 'rgba(0, 0, 0, 0.8)',
        text = '#FFFFFF',
        textSecondary = '#D1D5DB'
    },
    
    -- Positions
    positions = {
        statusBars = { x = 20, y = 20 },
        money = { x = 20, y = 120 },
        playerInfo = { x = 20, y = 180 },
        speedometer = { x = -250, y = -120 },
        notifications = { x = 350, y = 50 }
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