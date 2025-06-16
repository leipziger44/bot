// ESX Modern HUD - JavaScript
let config = {};
let isVisible = false;

// Initialize when NUI is ready
window.addEventListener('DOMContentLoaded', function() {
    // Send ready signal to Lua
    fetch(`https://${GetParentResourceName()}/ready`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
});

// Listen for messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'setConfig':
            config = data.config;
            break;
            
        case 'show':
            showHUD();
            break;
            
        case 'hide':
            hideHUD();
            break;
            
        case 'updatePlayerInfo':
            updatePlayerInfo(data.data);
            break;
            
        case 'updateSpeedometer':
            updateSpeedometer(data.data);
            break;
            
        case 'updateStatus':
            updateStatus(data.data);
            break;
            
        case 'showNotification':
            showNotification(data.data);
            break;
    }
});

// Show/Hide HUD
function showHUD() {
    isVisible = true;
    document.getElementById('playerInfo').style.display = 'block';
    document.getElementById('statusBars').style.display = 'block';
}

function hideHUD() {
    isVisible = false;
    document.getElementById('playerInfo').style.display = 'none';
    document.getElementById('speedometer').style.display = 'none';
    document.getElementById('statusBars').style.display = 'none';
}

// Update player information
function updatePlayerInfo(data) {
    if (!isVisible) return;
    
    // Update player name and ID
    document.getElementById('playerName').textContent = data.name || 'Unknown';
    document.getElementById('playerId').textContent = '#' + (data.id || '0');
    
    // Update health
    const healthValue = Math.max(0, Math.min(100, data.health || 0));
    document.getElementById('healthBar').style.width = healthValue + '%';
    document.getElementById('healthValue').textContent = healthValue;
    
    // Update armor
    const armorValue = Math.max(0, Math.min(100, data.armor || 0));
    document.getElementById('armorBar').style.width = armorValue + '%';
    document.getElementById('armorValue').textContent = armorValue;
    
    // Update money
    document.getElementById('moneyValue').textContent = '$' + formatNumber(data.money || 0);
    document.getElementById('bankValue').textContent = '$' + formatNumber(data.bank || 0);
    
    // Update job
    document.getElementById('jobTitle').textContent = data.job || 'Arbeitslos';
    document.getElementById('jobGrade').textContent = data.jobGrade || '';
}

// Update speedometer
function updateSpeedometer(data) {
    const speedometer = document.getElementById('speedometer');
    
    if (data.show) {
        speedometer.style.display = 'block';
        speedometer.classList.add('show');
        
        // Update speed
        document.getElementById('speedValue').textContent = data.speed || 0;
        document.getElementById('speedUnit').textContent = data.unit?.toUpperCase() || 'KMH';
        
        // Update fuel
        const fuelPercent = Math.max(0, Math.min(100, data.fuel || 0));
        const fuelBar = document.querySelector('.fuel .bar-fill::after');
        if (fuelBar) {
            fuelBar.style.width = fuelPercent + '%';
        }
        document.getElementById('fuelValue').textContent = fuelPercent + '%';
        
        // Update engine
        const enginePercent = Math.max(0, Math.min(100, data.engineHealth || 0));
        const engineBar = document.querySelector('.engine .bar-fill::after');
        if (engineBar) {
            engineBar.style.width = enginePercent + '%';
        }
        document.getElementById('engineValue').textContent = enginePercent + '%';
        
        // Update gear
        let gearText = 'P';
        if (data.gear === 0) gearText = 'R';
        else if (data.gear === 1) gearText = 'N';
        else if (data.gear > 1) gearText = (data.gear - 1).toString();
        document.getElementById('gearValue').textContent = gearText;
        
        // Update seatbelt indicator
        const seatbeltIndicator = document.getElementById('seatbeltIndicator');
        if (data.seatbelt) {
            seatbeltIndicator.classList.add('on');
            seatbeltIndicator.classList.remove('off');
        } else {
            seatbeltIndicator.classList.add('off');
            seatbeltIndicator.classList.remove('on');
        }
        
        // Apply custom CSS for fuel/engine bars
        updateBarFill('fuel', fuelPercent);
        updateBarFill('engine', enginePercent);
        
    } else {
        speedometer.style.display = 'none';
        speedometer.classList.remove('show');
    }
}

// Helper function to update bar fills
function updateBarFill(type, percent) {
    const bar = document.querySelector(`.${type} .bar-fill`);
    if (bar) {
        bar.style.background = `linear-gradient(90deg, 
            ${percent > 50 ? '#10B981' : percent > 25 ? '#F59E0B' : '#EF4444'} ${percent}%, 
            rgba(255, 255, 255, 0.1) ${percent}%)`;
    }
}

// Update status bars (hunger/thirst)
function updateStatus(data) {
    if (!isVisible) return;
    
    // Update hunger
    const hungerPercent = Math.max(0, Math.min(100, data.hunger || 0));
    document.getElementById('hungerBar').style.width = hungerPercent + '%';
    document.getElementById('hungerValue').textContent = hungerPercent + '%';
    
    // Update thirst
    const thirstPercent = Math.max(0, Math.min(100, data.thirst || 0));
    document.getElementById('thirstBar').style.width = thirstPercent + '%';
    document.getElementById('thirstValue').textContent = thirstPercent + '%';
}

// Notification system
function showNotification(data) {
    const container = document.getElementById('notifications');
    const notification = document.createElement('div');
    
    notification.className = `notification ${data.type || 'info'}`;
    notification.innerHTML = `
        <div class="notification-content">${data.message}</div>
        <div class="notification-time">${new Date().toLocaleTimeString()}</div>
    `;
    
    // Add to container
    container.insertBefore(notification, container.firstChild);
    
    // Remove after duration
    const duration = data.duration || 5000;
    setTimeout(() => {
        if (notification.parentNode) {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }
    }, duration);
    
    // Limit max notifications
    const maxNotifications = config.Notifications?.maxNotifications || 5;
    while (container.children.length > maxNotifications) {
        container.removeChild(container.lastChild);
    }
}

// Utility functions
function formatNumber(num) {
    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    } else if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return num.toString();
}

// Get parent resource name (for fetch requests)
function GetParentResourceName() {
    return window.location.hostname;
}