# 🎮 Modern FiveM HUD - ESX Compatible

Ein modernes, responsives HUD-System für FiveM-Server mit ESX-Framework. Designt mit grüner und violetter Farbgebung für eine zeitgemäße Benutzeroberfläche.

## ✨ Features

### 🏥 Status-Anzeigen
- **Gesundheit** - Animierte Lebensanzeige mit Pulseffekt bei niedrigen Werten
- **Rüstung** - Dynamische Rüstungsanzeige mit Transparenz-Effekten
- **Ausdauer** - Ausdauerbalken mit Echtzeit-Updates

### 💰 Geld-System
- **Bargeld** - Live-Anzeige des Bargelds mit Formatierung
- **Bank** - Bankguthaben-Anzeige
- **Animationen** - Sanfte Übergänge bei Geldänderungen

### 👤 Spieler-Info
- **Name & ID** - Spielername und Server-ID
- **Job-Anzeige** - Aktueller Job und Rang
- **ESX-Integration** - Vollständige ESX-Kompatibilität

### 🚗 Fahrzeug-HUD
- **Tachometer** - Kreisförmiger Tachometer mit Geschwindigkeitsanzeige
- **Gang-Anzeige** - Aktuelle Gangstellung (P/R/1-6)
- **Kraftstoff** - Tankfüllung mit Warnung bei niedrigem Stand
- **RPM-Anzeige** - Drehzahlmesser (optional)

### 🔔 Benachrichtigungen
- **Typen** - Info, Erfolg, Warnung, Fehler
- **Animationen** - Sanfte Ein-/Ausblendungen
- **Stapelbar** - Mehrere Benachrichtigungen gleichzeitig
- **Auto-Ausblendung** - Konfigurierbare Anzeigedauer

### 🗺️ Minimap-Styling
- **Moderne Optik** - Angepasste Minimap-Darstellung
- **Optimierte Position** - Perfekte Platzierung im HUD
- **Transparenz-Effekte** - Glasmorphismus-Design

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
```

### 3. ESX-Abhängigkeiten
Stelle sicher, dass ESX bereits installiert und konfiguriert ist:
- `es_extended` muss vor diesem HUD gestartet werden

## ⚙️ Konfiguration

### Config.lua anpassen

```lua
Config.HUD = {
    -- Anzeige-Optionen
    showHealth = true,      -- Gesundheitsanzeige
    showArmor = true,       -- Rüstungsanzeige  
    showMoney = true,       -- Geldanzeige
    showPlayerInfo = true,  -- Spielerinfo
    showJob = true,         -- Job-Anzeige
    showSpeedometer = true, -- Tachometer
    showFuel = true,        -- Kraftstoffanzeige
    
    -- Update-Intervalle (Millisekunden)
    statusUpdateInterval = 500,  -- Status-Updates
    vehicleUpdateInterval = 100, -- Fahrzeug-Updates
    
    -- Farben anpassen (Grün & Violett Theme)
    colors = {
        primary = '#10B981',      -- Hauptfarbe (Grün)
        secondary = '#8B5CF6',    -- Sekundärfarbe (Violett)
        accent = '#059669',       -- Akzentfarbe (Dunkelgrün)
        background = 'rgba(0, 0, 0, 0.8)',
        text = '#FFFFFF',
        textSecondary = '#D1D5DB'
    }
}
```

### 🎮 Verwendung

#### Ingame-Befehle
```
/hud - HUD ein/ausblenden
```

#### Für Entwickler - Benachrichtigungen

**Server-seitig (Lua)**
```lua
-- Einfache Benachrichtigung
TriggerClientEvent('esx:showNotification', source, 'Nachricht', 'success', 5000)

-- Erweiterte Benachrichtigung
TriggerClientEvent('hud:showAdvancedNotification', source, {
    title = 'System',
    message = 'Erweiterte Nachricht',
    type = 'info',
    duration = 3000
})
```

**Client-seitig (Lua)**
```lua
-- Export verwenden
exports['modern-hud']:ShowNotification('Titel', 'Nachricht', 'success', 5000)
```

## 🎨 Anpassungen

### Farben ändern
Bearbeite `html/style.css` um die Farbgebung anzupassen:

```css
:root {
    --primary-green: #10B981;
    --secondary-purple: #8B5CF6;
    --accent-green: #059669;
}
```

## 🔧 Technische Details

### Performance
- **Optimiert**: Minimale Server-Last durch effiziente Updates
- **60 FPS**: Smooth Animationen ohne Frame-Drops
- **Speicher**: Geringer RAM-Verbrauch

### Kompatibilität
- ✅ ESX Legacy & Old ESX
- ✅ Alle gängigen Fuel-Scripts
- ✅ Custom Job-Scripts
- ✅ Multi-Character-Support

---

**Entwickelt für die FiveM-Community mit ❤️**
