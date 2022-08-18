fx_version 'cerulean'

game 'gta5'

-- description 'QB car robbery'

shared_script 'config.lua'

server_script 'server/main.lua'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/main.lua',
}

lua54 'yes'

dependencies {
    'qb-core',
    'PolyZone',
}
