fx_version 'cerulean'
game 'gta5'

author 'Modern HUD System'
description 'Modern ESX HUD with Green/Purple Theme, txAdmin Integration & Restart Warnings'
version '1.1.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png'
}

dependencies {
    'es_extended'
}

-- Optional dependencies for enhanced functionality
optional_dependencies {
    'esx_basicneeds',
    'txAdmin'
}