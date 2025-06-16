let config = {};
let hudVisible = true;
let notifications = [];
let notificationId = 0;

// Initialize HUD
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'initHUD':
            config = data.config;
            initializeHUD();
            break;
            
        case 'updateStatus':
            updateStatusBars(data);
            updateMoney(data);
            updatePlayerInfo(data);
            break;
            
        case 'updateVehicle':
            updateVehicleHUD(data);
            break;
            
        case 'toggleVehicleHUD':
            toggleVehicleHUD(data.show);
            break;
            
        case 'toggleHUD':
            toggleHUD(data.show);
            break;
            
        case 'showNotification':
            showNotification(data);
            break;
            
        case 'showAdvancedNotification':
            showAdvancedNotification(data.data);
            break;
    }
});

function initializeHUD() {
    console.log('Modern HUD Initialized');
    
    // Apply configuration
    if (config.HUD) {
        // Set visibility based on config
        document.getElementById('status-section').style.display = 
            config.HUD.showHealth ? 'flex' : 'none';
            
        // Apply custom positioning if needed
        if (config.HUD.positions) {
            const positions = config.HUD.positions;
            
            if (positions.statusBars) {
                const statusSection = document.getElementById('status-section');
                statusSection.style.left = positions.statusBars.x + 'px';
                statusSection.style.top = positions.statusBars.y + 'px';
            }
            
            if (positions.money) {
                const moneySection = document.getElementById('money-section');
                moneySection.style.left = positions.money.x + 'px';
                moneySection.style.top = positions.money.y + 'px';
            }
            
            if (positions.playerInfo) {
                const playerSection = document.getElementById('player-info-section');
                playerSection.style.left = positions.playerInfo.x + 'px';
                playerSection.style.top = positions.playerInfo.y + 'px';
            }
            
            if (positions.speedometer) {
                const vehicleSection = document.getElementById('vehicle-section');
                vehicleSection.style.right = Math.abs(positions.speedometer.x) + 'px';
                vehicleSection.style.bottom = Math.abs(positions.speedometer.y) + 'px';
            }
        }
    }
    
    // Add smooth entrance animation
    setTimeout(() => {
        document.getElementById('hud-container').style.opacity = '1';
    }, 100);
}

function updateStatusBars(data) {
    // Update Health
    const healthFill = document.querySelector('.health-fill');
    const healthText = document.getElementById('health-text');
    const healthPercent = Math.max(0, Math.min(100, data.health));
    
    healthFill.style.width = healthPercent + '%';
    healthText.textContent = Math.round(healthPercent);
    
    // Add pulsing effect for low health
    if (healthPercent < 25) {
        healthFill.style.animation = 'pulse 1s infinite';
    } else {
        healthFill.style.animation = 'none';
    }
    
    // Update Armor
    const armorFill = document.querySelector('.armor-fill');
    const armorText = document.getElementById('armor-text');
    const armorPercent = Math.max(0, Math.min(100, data.armor));
    
    armorFill.style.width = armorPercent + '%';
    armorText.textContent = Math.round(armorPercent);
    
    // Update Stamina
    const staminaFill = document.querySelector('.stamina-fill');
    const staminaText = document.getElementById('stamina-text');
    const staminaPercent = Math.max(0, Math.min(100, data.stamina));
    
    staminaFill.style.width = staminaPercent + '%';
    staminaText.textContent = Math.round(staminaPercent);
    
    // Show/hide armor bar based on armor value
    const armorBar = document.querySelector('.armor-bar');
    if (armorPercent > 0) {
        armorBar.style.display = 'flex';
        armorBar.style.opacity = '1';
    } else {
        armorBar.style.opacity = '0.5';
    }
}

function updateMoney(data) {
    const cashAmount = document.getElementById('cash-amount');
    const bankAmount = document.getElementById('bank-amount');
    
    // Format money with commas and currency symbol
    cashAmount.textContent = '$' + formatNumber(data.money || 0);
    bankAmount.textContent = '$' + formatNumber(data.bank || 0);
    
    // Add money change animation
    animateMoneyChange(cashAmount);
    animateMoneyChange(bankAmount);
}

function updatePlayerInfo(data) {
    const playerName = document.getElementById('player-name');
    const playerId = document.getElementById('player-id');
    const jobInfo = document.getElementById('job-info');
    
    playerName.textContent = data.playerName || 'Unknown';
    playerId.textContent = '#' + (data.serverId || '000');
    
    let jobText = data.job || 'Civilian';
    if (data.jobGrade && data.jobGrade !== '') {
        jobText += ' - ' + data.jobGrade;
    }
    jobInfo.textContent = jobText;
}

function updateVehicleHUD(data) {
    // Update Speedometer
    const speedValue = document.getElementById('speed-value');
    const speedUnit = document.getElementById('speed-unit');
    const speedCircle = document.getElementById('speed-progress-circle');
    
    speedValue.textContent = data.speed || 0;
    speedUnit.textContent = data.unit || 'KM/H';
    
    // Calculate speed percentage for circle animation
    const maxSpeed = data.maxSpeed || 300;
    const speedPercent = Math.min(100, (data.speed / maxSpeed) * 100);
    const circumference = 2 * Math.PI * 45; // radius = 45
    const offset = circumference - (speedPercent / 100) * circumference;
    
    speedCircle.style.strokeDashoffset = offset;
    
    // Change color based on speed
    if (speedPercent > 80) {
        speedCircle.style.stroke = '#EF4444'; // Red for high speed
    } else if (speedPercent > 60) {
        speedCircle.style.stroke = '#F59E0B'; // Orange for medium speed
    } else {
        speedCircle.style.stroke = '#10B981'; // Green for normal speed
    }
    
    // Update Gear
    const gearValue = document.getElementById('gear-value');
    let gearText = 'P';
    
    if (data.gear === 0) {
        gearText = 'R';
    } else if (data.gear > 0) {
        gearText = data.gear.toString();
    }
    
    gearValue.textContent = gearText;
    
    // Update Fuel
    const fuelFill = document.getElementById('fuel-fill');
    const fuelPercentage = document.getElementById('fuel-percentage');
    const fuelPercent = Math.max(0, Math.min(100, data.fuel || 0));
    
    fuelFill.style.width = fuelPercent + '%';
    fuelPercentage.textContent = Math.round(fuelPercent) + '%';
    
    // Change fuel color based on level
    if (fuelPercent < 20) {
        fuelFill.style.background = 'linear-gradient(90deg, #DC2626, #EF4444)';
        // Add pulsing animation for low fuel
        fuelFill.style.animation = 'pulse 2s infinite';
    } else if (fuelPercent < 50) {
        fuelFill.style.background = 'linear-gradient(90deg, #D97706, #F59E0B)';
        fuelFill.style.animation = 'none';
    } else {
        fuelFill.style.background = 'linear-gradient(90deg, #059669, #10B981)';
        fuelFill.style.animation = 'none';
    }
}

function toggleVehicleHUD(show) {
    const vehicleSection = document.getElementById('vehicle-section');
    
    if (show) {
        vehicleSection.style.display = 'block';
        setTimeout(() => {
            vehicleSection.style.opacity = '1';
            vehicleSection.style.transform = 'translateY(0)';
        }, 10);
    } else {
        vehicleSection.style.opacity = '0';
        vehicleSection.style.transform = 'translateY(20px)';
        setTimeout(() => {
            vehicleSection.style.display = 'none';
        }, 300);
    }
}

function toggleHUD(show) {
    hudVisible = show;
    const hudContainer = document.getElementById('hud-container');
    
    if (show) {
        hudContainer.classList.remove('hud-hidden');
    } else {
        hudContainer.classList.add('hud-hidden');
    }
}

function showNotification(data) {
    const container = document.getElementById('notifications-container');
    const notification = document.createElement('div');
    const id = ++notificationId;
    
    notification.className = `notification ${data.notificationType || 'info'}`;
    notification.id = `notification-${id}`;
    
    // Create notification icon based on type
    let icon = 'fa-info-circle';
    switch (data.notificationType) {
        case 'success':
            icon = 'fa-check-circle';
            break;
        case 'warning':
            icon = 'fa-exclamation-triangle';
            break;
        case 'error':
            icon = 'fa-times-circle';
            break;
    }
    
    notification.innerHTML = `
        <div class="notification-header">
            <i class="fas ${icon}"></i>
            <span class="notification-title">${data.title || 'Notification'}</span>
        </div>
        <div class="notification-message">${data.message || ''}</div>
    `;
    
    container.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // Auto remove
    const duration = data.duration || 5000;
    setTimeout(() => {
        removeNotification(id);
    }, duration);
    
    // Keep track of notifications
    notifications.push({
        id: id,
        element: notification,
        timestamp: Date.now()
    });
    
    // Limit visible notifications
    if (notifications.length > 5) {
        removeNotification(notifications[0].id);
    }
}

function showAdvancedNotification(data) {
    // Enhanced notification with custom styling
    const notification = {
        title: data.title || 'System',
        message: data.message || '',
        notificationType: data.type || 'info',
        duration: data.duration || 5000
    };
    
    showNotification(notification);
}

function removeNotification(id) {
    const notification = document.getElementById(`notification-${id}`);
    if (notification) {
        notification.classList.remove('show');
        notification.classList.add('hide');
        
        setTimeout(() => {
            notification.remove();
        }, 500);
    }
    
    // Remove from array
    notifications = notifications.filter(n => n.id !== id);
}

// Utility Functions
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function animateMoneyChange(element) {
    element.style.transform = 'scale(1.05)';
    element.style.transition = 'transform 0.2s ease';
    
    setTimeout(() => {
        element.style.transform = 'scale(1)';
    }, 200);
}

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.6; }
    }
    
    @keyframes glow {
        0%, 100% { box-shadow: 0 0 5px rgba(16, 185, 129, 0.5); }
        50% { box-shadow: 0 0 20px rgba(16, 185, 129, 0.8); }
    }
    
    .low-health {
        animation: pulse 1s infinite;
    }
    
    .speed-warning {
        animation: glow 1s infinite;
    }
`;
document.head.appendChild(style);

// Initialize when document is ready
document.addEventListener('DOMContentLoaded', function() {
    console.log('Modern HUD UI Ready');
});

// Handle window resize
window.addEventListener('resize', function() {
    // Adjust HUD positioning if needed
    if (config.HUD && config.HUD.positions) {
        initializeHUD();
    }
});

// Export functions for external use
window.ModernHUD = {
    showNotification: showNotification,
    toggleHUD: toggleHUD,
    updateStatus: updateStatusBars,
    formatNumber: formatNumber
};