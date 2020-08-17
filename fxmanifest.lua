fx_version 'bodacious'

game 'gta5'

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    'Utils.lua',
    'Config.lua',
    'callback_cl.lua',
    --'PlayerTracker_cl.lua' ONLY re-enable if you make sure it works for you. This module is incomplete due to indecsisiveness. It was a shortfell attempt at replacing ESX.
}

server_scripts {
    'Config.lua',
    'Utils.lua',
    'callback_sv.lua',
    --'PlayerTracker_sv.lua' ONLY re-enable if you make sure it works for you. This module is incomplete due to indecsisiveness. It was a shortfell attempt at replacing ESX.
    '@mysql-async/lib/MySQL.lua'
}

exports {
    'tobool',
    'GetMyIdentifiers',
    'DevelopmentBuild',
    'DeleteVehicle',
    'DeleteVehicleAsync',
    'GetAllVehicles',
    'GetAllPlayers',
    'GetVehicleInFrontOfMe',
    'GetActivePed',
    'SetActivePed',
    'DrawText3DMe',
    'GetMyIdentity',
    "ConvertKey",
    "GetAllPeds",
    "GetCurrentStreetName",
    "TriggerServerCallback",
    "RegisterClientCallback",
    "AttachPropToPlayer",
    "RemovePropFromPlayer",
    "GetAllKeyCodes",
    "GetVehicleByPlate",
    "GetAllObjectsInWorld",
    "GetAllObjects",
    "SpawnVehicle",
    "GetVehicleProps",
    "SetVehicleProps",
    "Log",
    "Warn",
    "Error",
    "Success",
    "Info"
}

server_exports {
    'tobool',
    'GetPlayerDiscordID',
    'MySQLAsyncExecute',
    'GetTheirIdentifiers',
    'DevelopmentBuild',
    "TriggerClientCallback",
    "RegisterServerCallback",
    "GetTheirIdentity",
    "CreatePlayer",
    "GetPlayerInventoryItem",
    "AddPlayerInventoryItem",
    "RemovePlayerInventoryItem",
    "SetPlayerJob",
    "AddPlayerBank",
    "RemovePlayerBank",
    "AddPlayerMoney",
    "RemovePlayerMoney",
    "GetPlayerInventory",
    "Log",
    "Warn",
    "Error",
    "Success",
    "Info"
}
