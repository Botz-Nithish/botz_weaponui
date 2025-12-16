fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Botz'
description 'Standalone DUI Weapon UI'
version '1.0.0'
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

dependencies { 'ox_lib' }
ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/font.woff2' -- Assuming we might use a font, but for now standard fonts or google fonts CDN in html
}

client_script 'client.lua'
