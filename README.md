# 🎮 Modern FiveM HUD - ESX Compatible v1.1

Ein modernes, responsives HUD-System für FiveM-Server mit ESX-Framework. Designt mit grüner und violetter Farbgebung für eine zeitgemäße Benutzeroberfläche.

## ✨ Features

### 🏥 Status-Anzeigen (Neue Position: Unten Links)
- **Gesundheit** - Animierte Lebensanzeige mit Pulseffekt bei niedrigen Werten
- **Rüstung** - Dynamische Rüstungsanzeige mit Transparenz-Effekten
- **Hunger** - esx_basicneeds Integration mit Warnungen
- **Durst** - Durstsystem mit visuellen Warnhinweisen

### 💰 Geld-System (Unten Links)
- **Bargeld** - Live-Anzeige des Bargelds mit Formatierung
- **Bank** - Bankguthaben-Anzeige
- **Animationen** - Sanfte Übergänge bei Geldänderungen

### 👤 Spieler-Info (Neue Position: Oben Rechts)
- **Name & ID** - Spielername und Server-ID
- **Job-Anzeige** - Aktueller Job und Rang
- **ESX-Integration** - Vollständige ESX-Kompatibilität

### 🚗 Fahrzeug-HUD
- **Tachometer** - Kreisförmiger Tachometer mit Geschwindigkeitsanzeige
- **Gang-Anzeige** - Aktuelle Gangstellung (P/R/1-6)
- **Kraftstoff** - Tankfüllung mit Warnung bei niedrigem Stand
- **RPM-Anzeige** - Drehzahlmesser (optional)

### 🔔 Erweiterte Benachrichtigungen (Oben Rechts)
- **Typen** - Info, Erfolg, Warnung, Fehler
- **txAdmin-Integration** - Server-Verwaltungsbenachrichtigungen
- **Restart-Warnungen** - Automatische Server-Neustart-Benachrichtigungen
- **Admin-Notifications** - Spieler-Verbindungen und -Trennungen
- **Animationen** - Sanfte Ein-/Ausblendungen
- **Stapelbar** - Mehrere Benachrichtigungen gleichzeitig
- **Auto-Ausblendung** - Konfigurierbare Anzeigedauer

### 🗺️ Minimap-Styling
- **Moderne Optik** - Angepasste Minimap-Darstellung
- **Optimierte Position** - Perfekte Platzierung im HUD
- **Transparenz-Effekte** - Glasmorphismus-Design

## 🆕 Neue Features v1.1

### 📢 txAdmin-Integration
- **Ankündigungen** - Server-Ankündigungen werden als HUD-Benachrichtigungen angezeigt
- **Direkte Nachrichten** - Admin-Nachrichten an spezifische Spieler
- **Warnungen** - Admin-Warnungen mit spezieller Hervorhebung
- **Server-Status** - Wartungsmodus und Server-Status-Updates

### ⏰ Automatische Restart-Warnungen
- **Konfigurerbare Zeiten** - Standard: 06:00, 12:00, 18:00, 00:00
- **Mehrfache Warnungen** - 30, 15, 10, 5, 3, 2, 1 Minuten vor Restart
- **Visuelle Hervorhebung** - Spezielle Animationen für wichtige Warnungen
- **Chat-Integration** - Kritische Warnungen auch im Chat

### 🍽️ esx_basicneeds Integration
- **Hunger-System** - Integrierte Hunger-Anzeige
- **Durst-System** - Durst-Überwachung mit Warnungen
- **Automatische Warnungen** - Benachrichtigungen bei niedrigen Werten

## 🛠️ Installation

### 1. Dateien kopieren
```bash
# Kopiere alle Dateien in deinen FiveM-Server resources Ordner
cp -r modern-hud [dein-server]/resources/modern-hud/
```

### 2. Server.cfg anpassen
```cfg
# Füge diese Zeile in deine server.cfg ein:
start modern-hud

# Stelle sicher, dass ESX vor diesem HUD gestartet wird:
start es_extended
start esx_basicneeds  # Falls verwendet
start modern-hud
```

### 3. Abhängigkeiten
**Erforderlich:**
- `es_extended` (ESX Framework)

**Optional:**
- `esx_basicneeds` (für Hunger/Durst)
- `txAdmin` (für Admin-Features)

## ⚙️ Konfiguration

### Config.lua Grundeinstellungen

```lua
Config.HUD = {
    -- Neue Positionierungen
    positions = {
        statusBars = { x = 20, y = -200 },    -- Unten links
        money = { x = 20, y = -80 },          -- Unten links
        playerInfo = { x = -350, y = 20 },    -- Oben rechts
        notifications = { x = -400, y = 80 }  -- Oben rechts
    },
    
    -- Anzeige-Optionen
    showHealth = true,
    showArmor = true,
    showHunger = true,      -- NEU
    showThirst = true,      -- NEU
    showMoney = true,
    showPlayerInfo = true,
    showJob = true
}
```

### txAdmin-Integration konfigurieren

```lua
Config.TxAdmin = {
    enabled = true,                -- txAdmin-Features aktivieren
    showAnnouncements = true,      -- Server-Ankündigungen
    showWarnings = true,           -- Admin-Warnungen
    showKicks = true,             -- Kick-Benachrichtigungen
    showBans = true               -- Ban-Benachrichtigungen
}
```

### Restart-Warnungen konfigurieren

```lua
Config.RestartWarnings = {
    enabled = true,
    times = { 30, 15, 10, 5, 3, 2, 1 }, -- Warnzeiten in Minuten
    restartTimes = {                      -- Restart-Zeiten (24h Format)
        { hour = 6, minute = 0 },         -- 06:00
        { hour = 12, minute = 0 },        -- 12:00
        { hour = 18, minute = 0 },        -- 18:00
        { hour = 0, minute = 0 }          -- 00:00
    }
}
```

## 🎮 Verwendung

### Ingame-Befehle
```
/hud - HUD ein/ausblenden
```

### Admin-Befehle
```
/restartwarning [Minuten] [Grund] - Manuelle Restart-Warnung senden
/testrestart - Test-Restart-Warnung (nur für Admins)
```

### Für Entwickler - Benachrichtigungen

#### Server-seitig (Lua)
```lua
-- Standard ESX-Benachrichtigung
TriggerClientEvent('esx:showNotification', source, 'Nachricht', 'success', 5000)

-- Erweiterte HUD-Benachrichtigung
TriggerClientEvent('hud:txAdminNotification', source, {
    title = 'Custom Title',
    message = 'Custom Message',
    type = 'info',
    duration = 6000
})

-- Export für andere Ressourcen
exports['modern-hud']:SendRestartWarning(10, 'Wartungsarbeiten')
exports['modern-hud']:SendAdminNotification('Admin-Info', 'Nachricht', 'warning', 8000)
```

#### Client-seitig (Lua)
```lua
-- Export verwenden
exports['modern-hud']:ShowNotification('Titel', 'Nachricht', 'success', 5000)
```

## 🎨 Anpassungen

### Neue Positionierung verstehen
- **Status-Balken**: Unten links neben der Minimap für bessere Sichtbarkeit
- **Spieler-Info**: Oben rechts für weniger Ablenkung
- **Benachrichtigungen**: Oben rechts unter Spieler-Info
- **Geld**: Unten links über den Status-Balken

### Farben ändern
```css
:root {
    --primary-green: #10B981;
    --secondary-purple: #8B5CF6;
    --accent-green: #059669;
    --hunger-orange: #F59E0B;
    --thirst-blue: #3B82F6;
}
```

## 🔧 Technische Details

### Performance
- **Optimiert**: Minimale Server-Last durch effiziente Updates
- **60 FPS**: Smooth Animationen ohne Frame-Drops
- **Speicher**: Geringer RAM-Verbrauch
- **Separate Updates**: Unterschiedliche Update-Intervalle für verschiedene Systeme

### Kompatibilität
- ✅ ESX Legacy & Old ESX
- ✅ esx_basicneeds Integration
- ✅ txAdmin Integration
- ✅ Alle gängigen Fuel-Scripts
- ✅ Custom Job-Scripts
- ✅ Multi-Character-Support

### Neue Event-Handler
```lua
-- Client Events
'esx_status:onTick'              -- Für Hunger/Durst
'hud:txAdminNotification'        -- txAdmin-Benachrichtigungen
'hud:showAdvancedNotification'   -- Erweiterte Benachrichtigungen

-- Server Events
'txAdmin:receiveAnnouncement'    -- Server-Ankündigungen
'txAdmin:receiveWarning'         -- Admin-Warnungen
'hud:manualRestartWarning'       -- Manuelle Restart-Warnungen
```

## 🐛 Fehlerbehebung

### Häufige Probleme

**Status-Balken sind nicht sichtbar:**
- Überprüfe ob esx_basicneeds gestartet ist
- Kontrolliere die neuen Positionierungen in config.lua

**txAdmin-Benachrichtigungen funktionieren nicht:**
- Stelle sicher, dass txAdmin installiert ist
- Überprüfe Config.TxAdmin.enabled = true

**Restart-Warnungen erscheinen nicht:**
- Kontrolliere die restartTimes in der Konfiguration
- Überprüfe Server-Zeit und Zeitzone

### Debug-Informationen
```lua
-- In client.lua DEBUG aktivieren
local DEBUG = true  -- Für detaillierte Logs
```

## 📝 Changelog

### Version 1.1.0
- ✨ Neue Positionierung: Status unten links, Spieler-Info oben rechts
- 🍽️ esx_basicneeds Integration (Hunger & Durst)
- 📢 txAdmin-Benachrichtigungen
- ⏰ Automatische Server-Restart-Warnungen
- 👥 Admin-Benachrichtigungen für Spieler-Events
- 🎨 Verbesserte Benachrichtigungs-Animationen
- 🔧 Server-seitige Logik hinzugefügt
- 📱 Responsive Design-Verbesserungen

### Version 1.0.0
- ✨ Initiale Version
- 🎨 Modernes Design mit Grün/Violett Theme  
- 🏥 Vollständige Status-Anzeigen
- 🚗 Fahrzeug-HUD mit Tachometer
- 💰 ESX-Geld-Integration
- 🔔 Basis-Benachrichtigungssystem
- 🗺️ Minimap-Styling

---

**Entwickelt für die FiveM-Community mit ❤️**

*Moderne Benutzeroberfläche für moderne Server*
