# ESX Modern HUD

Ein modernes, funktionsreiches HUD-System für FiveM ESX-Roleplay-Server.

## 🎯 Features

### 🎮 Spieler-Informationen (Oben Links)
- **Transparenter Hintergrund** mit lila/grünen Akzenten
- **Spielername und Server-ID**
- **Gesundheit und Rüstung** mit animierten Balken
- **Bargeld und Bankguthaben** 
- **Job und Rang** Anzeige

### 🚗 Fahrzeug-Tacho (Unten Mitte)
- **Geschwindigkeitsanzeige** (KMH/MPH)
- **Treibstoffanzeige** mit Farbverlauf
- **Motor-Gesundheit** Anzeige
- **Gang-Anzeige** (P, R, N, 1-6)
- **Anschnallgurt-Indikator**

### 🔔 Benachrichtigungssystem
- **TX-Benachrichtigungen** für Ankündigungen
- **Server-Neustart** Warnungen
- **Spieler-Verbindungen** (Beitritt/Verlassen)
- **Verschiedene Typen**: Info, Erfolg, Warnung, Fehler, Ankündigung

### 🔒 Anschnallsystem
- **Taste 'K'** zum An-/Abschnallen
- **Automatische Auswurf-Mechanik** bei Unfällen
- **Schaden-System** bei Nichtanschnallen
- **Visuelle und Audio-Indikatoren**

### 🍔 Status-Anzeigen
- **Hunger-Balken** neben der Minikarte
- **Durst-Balken** mit Farbverlauf
- **ESX Status Integration**

## 📦 Installation

### 1. Download & Platzierung
```bash
# Lade die Ressource in deinen resources Ordner
[FiveM]/resources/esx_modern_hud/
```

### 2. Server.cfg Konfiguration
```cfg
# Füge diese Zeile zu deiner server.cfg hinzu
ensure esx_modern_hud
```

### 3. Abhängigkeiten
Stelle sicher, dass folgende Ressourcen installiert sind:
- `es_extended` (ESX Framework)
- `esx_status` (für Hunger/Durst)

## ⚙️ Konfiguration

Bearbeite die `config.lua` um das HUD an deine Bedürfnisse anzupassen:

### Grundeinstellungen
```lua
Config.HUD = {
    enabled = true,
    refreshRate = 100, -- Aktualisierungsrate in ms
    hideInVehicle = false
}
```

### Farben anpassen
```lua
Config.PlayerInfo.colors = {
    primary = '#8B5CF6', -- Lila
    secondary = '#10B981', -- Grün
    background = 'rgba(0, 0, 0, 0.6)' -- Transparent Schwarz
}
```

### Positionen anpassen
```lua
Config.PlayerInfo.position = {x = 20, y = 20} -- Pixel von links/oben
Config.Speedometer.position = {x = 50, y = 85} -- Prozent von links/oben
```

## 🎮 Bedienung

### Tasten
- **K** - Anschnallgurt an-/abschnallen

### Befehle (Admins)
- `/restart [Minuten]` - Server-Neustart planen
- `/cancelrestart` - Neustart abbrechen  
- `/announce [Nachricht]` - Globale Ankündigung

## 🔧 Entwickler-Integration

### Benachrichtigung senden
```lua
-- Von anderen Ressourcen
exports['esx_modern_hud']:ShowNotification(playerId, 'Nachricht', 'success', 5000)
exports['esx_modern_hud']:ShowGlobalNotification('Globale Nachricht', 'announcement', 10000)

-- Via Events
TriggerClientEvent('esx_modern_hud:showNotification', playerId, 'Nachricht', 'info', 5000)
```

### Notification-Typen
- `info` - Blaue Information
- `success` - Grüner Erfolg
- `warning` - Orange Warnung  
- `error` - Rote Fehlermeldung
- `announcement` - Lila Ankündigung

## 🎨 Anpassungen

### CSS-Dateien bearbeiten
Die UI kann vollständig über die CSS-Datei angepasst werden:
```
html/style.css - Hauptstyles
```

### Farben ändern
```css
/* Primärfarbe (Lila) */
--primary: #8B5CF6;

/* Sekundärfarbe (Grün) */  
--secondary: #10B981;

/* Hintergrund */
--background: rgba(0, 0, 0, 0.6);
```

## 🐛 Fehlerbehebung

### HUD wird nicht angezeigt
1. Prüfe die F8-Konsole auf Fehler
2. Stelle sicher, dass ESX läuft
3. Überprüfe die Abhängigkeiten

### Speedometer funktioniert nicht
1. Prüfe ob du in einem Fahrzeug bist
2. Kontrolliere die Konfiguration
3. Restart die Ressource

### Benachrichtigungen kommen nicht an
1. Überprüfe Berechtigungen (Admin-Befehle)
2. Kontrolliere Server-Events
3. Prüfe die Konfiguration

## 📝 Changelog

### Version 1.0.0
- ✅ Grundlegendes HUD-System
- ✅ Spieler-Informationen
- ✅ Fahrzeug-Tacho
- ✅ Anschnallsystem
- ✅ Benachrichtigungssystem
- ✅ Status-Balken (Hunger/Durst)
- ✅ Server-Neustart-System

## 🆘 Support

Bei Problemen oder Fragen:
1. Überprüfe die Konfiguration
2. Kontrolliere die Abhängigkeiten  
3. Prüfe Server-Logs auf Fehler

## 📜 Lizenz

Diese Ressource ist Open Source und kann frei verwendet werden.

---

**Hinweis**: Diese Ressource wurde für ESX-Framework entwickelt und getestet. Andere Frameworks können Anpassungen erfordern.