fx_version "cerulean"
game "gta5"

author 'Delbes @Lambra'
description 'https://discord.gg/dVSe8Kwfuy'

files { 
    "meta/carcols_gen9.meta", 
    "meta/carmodcols_gen9.meta" 
}
data_file "CARCOLS_GEN9_FILE" "meta/carcols_gen9.meta"
data_file "CARMODCOLS_GEN9_FILE" "meta/carmodcols_gen9.meta"

shared_scripts {
    'colors.lua'
}

server_script '@oxmysql/lib/MySQL.lua'
server_script "server.lua"

client_script "client.lua"
