--[[
    Text Colors:
    ^0 = Thin White
    ^1 = Light Red
    ^2 = Neon Green
    ^3 = Bone White
    ^4 = Ocean Blue
    ^5 = Sky Blue
    ^6 = Magenta
    ^7 = Default White
    ^8 = Red
    ^9 = Indigo"
]]

-- ====================================== GLOBAL EXPORTS =================================

function table.Contains(set, item)
    for key, value in pairs(set) do
        if value == item then return true end
    end
    return false
end

function tobool(item)
    local itemtype = type(item)
    if itemtype == type(13) and item > 0 then
        if item > 1 then 
            Warn("DFS_Base > Utils.lua > tobool", "'item' is a number greater than 1, still returning true!", true)
        end
        return true
    elseif itemtype == type(13) and item == 0 then return false
    elseif itemtype == type("stringythingy") and item ~= "false" and item ~= "0" then
        if item ~= "true" then
            Warn("DFS_Base > Utils.lua > tobool", "'item' is a string but is not 'true' or 'false', still returning true!", true)
        end
        return true
    elseif itemtype == type("stringythingy") and (item == "0" or item == "false") then return false
    elseif itemtype == type(true) then return item
    elseif item == nil then return nil
    else error("dfs: could not convert "..tostring(item).." to bool!\n")
    end
end

function DevelopmentBuild()
    return Config.dfs.IsDebugBuild
end

function Log(resourceName, message, verbose) --^0
    if verbose and not Config.dfs.VerboseLogging then
        return
    end
    if IsDuplicityVersion() then
        InternalLog(resourceName, message, 0)
    else
        if DevelopmentBuild() then
            print("^0"..resourceName.."> "..message.."^7")
        else
            TriggerServerEvent("dfs:LogDebug", resourceName, message)
        end
    end
end

function Warn(resourceName, message, verbose) --^3
    if verbose and not Config.dfs.VerboseLogging then
        return
    end
    if IsDuplicityVersion() then
        InternalLog(resourceName, message, 3)
    else
        if DevelopmentBuild() then
            print("^3"..resourceName.."> "..message.."^7")
        else
            TriggerServerEvent("dfs:LogWarning", resourceName, message)
        end
    end
end

function Error(resourceName, message, verbose) --^1
    if verbose and not Config.dfs.VerboseLogging then
        return
    end
    if IsDuplicityVersion() then
        InternalLog(resourceName, message, 1)
    else
        if DevelopmentBuild() then
            print("^1"..resourceName.."> "..message.."^7")
        else
            TriggerServerEvent("dfs:LogError", resourceName, message)
        end
    end
end

function Success(resourceName, message, verbose) --^2
    if verbose and not Config.dfs.VerboseLogging then
        return
    end
    if IsDuplicityVersion() then
        InternalLog(resourceName, message, 2)
    else
        if DevelopmentBuild() then
            print("^2"..resourceName.."> "..message.."^7")
        else
            TriggerServerEvent("dfs:LogSuccess", resourceName, message)
        end
    end
end

function Info(resourceName, message, verbose) --^4
    if verbose and not Config.dfs.VerboseLogging then
        return
    end
    if IsDuplicityVersion() then
        InternalLog(resourceName, message, 4)
    else
        if DevelopmentBuild() then
            print("^4"..resourceName.."> "..message.."^7")
        else
            TriggerServerEvent("dfs:LogInfo", resourceName, message)
        end
    end
end

----------===================== ONLY works on the server-side =============================
if IsDuplicityVersion() then
    --========================= SERVER VARIBALES ==========================================
    local Headshots = {}
    --========================= SERVER EVENTS =============================================

    RegisterNetEvent("dfs:LogInfo")
    AddEventHandler("dfs:LogInfo", function(resourceName, message)
        InternalLog(resourceName, message, 4)
    end)

    RegisterNetEvent("dfs:LogSuccess")
    AddEventHandler("dfs:LogSuccess", function(resourceName, message)
        InternalLog(resourceName, message, 2)
    end)

    RegisterNetEvent("dfs:LogError")
    AddEventHandler("dfs:LogError", function(resourceName, message)
        InternalLog(resourceName, message, 1)
    end)

    RegisterNetEvent("dfs:LogWarning")
    AddEventHandler("dfs:LogWarning", function(resourceName, message)
        InternalLog(resourceName, message, 3)
    end)

    RegisterNetEvent("dfs:LogDebug")
    AddEventHandler("dfs:LogDebug", function(resourceName, message)
        InternalLog(resourceName, message, 0)
    end)

    AddEventHandler("onServerResourceStart", function (resourceName)
        if resourceName == GetCurrentResourceName() then
            RegisterServerCallback("dfs:GetMyIdentity", function(playerId)
                return GetTheirIdentity(playerId)
            end)


            RegisterServerCallback("dfs:GetMyIdentifiers", function(playerId)
                return GetTheirIdentifiers(playerId)
            end)

            if Config.dfs.IsDebugBuild then
                Warn("DFS_Base", "IsDebugBuild is set to true in DFS_Base > Config.lua")
            end

            if Config.dfs.VerboseLogging then
                Warn("DFS_Base", "VerboseLogging is set to true in DFS_Base > Config.lua")
            end
        end
    end)
    -- ======================== SERVER FUNCTIONS ==========================================
    function InternalLog(resourceName, message, colorCodeInt)
        local src = source
        local identifier = src and #src > 0 and "(source; "..src..")" or ""
        print(string.format("^%d%s %s> %s^7", colorCodeInt, resourceName, identifier, message))
    end
    -- ======================== SERVER EXPORTS ============================================

    function GetTheirIdentifiers(source) --This is named GetTheirIdentifiers because GetPlayerIdentifiers is a CFX native
        local PlayerIdentifiers =     {
            ServerID = nil,
            DiscordID = nil,
            LicenseID = nil,
            SteamID = nil,
            XboxLiveID = nil,
            IPAddress = nil,
            LiveID = nil, --No idea what this is
            UserID = nil --User row ID in the db
        }
    
        if not source then
            Error("DFS_Base > Utils.lua > GetTheirIdentifiers", "NilArgument 'source'. Aborting...")
            return PlayerIdentifiers
        end
        PlayerIdentifiers.ServerID = source
        
        for k,v in pairs(GetPlayerIdentifiers(PlayerIdentifiers.ServerID)) do
            if      string.match(v, 'discord:') then
                PlayerIdentifiers.DiscordID = v		
            elseif  string.match(v, 'steam:') then
                PlayerIdentifiers.SteamID = v		
            elseif  string.match(v, 'license:') then
                PlayerIdentifiers.LicenseID = v		
            elseif  string.match(v, 'xbl:') then
                PlayerIdentifiers.XboxLiveID = v		
            elseif  string.match(v, 'live:') then
                PlayerIdentifiers.LiveID = v		
            elseif  string.match(v, 'ip:') then
                PlayerIdentifiers.IPAddress = v
            end
        end

        if not PlayerIdentifiers.DiscordID and PlayerIdentifiers.SteamID then
            -- We need to double check to see if we have this tucked away so that it doesn't crap itself
            PlayerIdentifiers.DiscordID = MySQL.Sync.fetchScalar('SELECT `discord_id` FROM `dfs_useraccounts` WHERE `steam_id` = \''..PlayerIdentifiers.SteamID.."'")
        end

        if PlayerIdentifiers.SteamID then
            PlayerIdentifiers.UserID = MySQL.Sync.fetchScalar('SELECT `user_id` FROM `users` WHERE `identifier` = \''..PlayerIdentifiers.SteamID.."'")
        end
        return PlayerIdentifiers
    end

    function GetTheirIdentity(playerId)
        local PulledData = MySQL.Sync.fetchAll("SELECT `job`, `job_grade`, `permission_level`, `badge_number`, `firstname`, `lastname`, `dateofbirth`, `sex`, `height`, `phone_number` FROM `users` WHERE `identifier` = '"..GetPlayerIdentifiers(playerId)[1].."'")[1]
        if not PulledData then return -1
        else
            return {
                JobName         = PulledData.job,
                JobGrade        = PulledData.job_grade,
                PermissionLevel = PulledData.permission_level,
                BadgeNumber     = PulledData.badge_number,
                FirstName       = PulledData.firstname,
                LastName        = PulledData.lastname,
                DateOfBirth     = PulledData.dateofbirth,
                IsMale          = PulledData.sex == 'm',
                Height          = PulledData.height,
                PhoneNumber     = PulledData.phone_number
            }
        end
    end

else --======================= ONLY works on the client-side ==============================
    -- ======================= CLIENT VARIABLES ===========================================

    local KeyCodes ={
        { KeyChar = "ESC"        , ControlIndex = 322},                                            
        { KeyChar = "F1"         , ControlIndex = 288},                                            
        { KeyChar = "F2"         , ControlIndex = 289},                                            
        { KeyChar = "F3"         , ControlIndex = 170},                                            
        { KeyChar = "F5"         , ControlIndex = 166},                                            
        { KeyChar = "F6"         , ControlIndex = 167},                                            
        { KeyChar = "F7"         , ControlIndex = 168},                                            
        { KeyChar = "F8"         , ControlIndex = 169},                                            
        { KeyChar = "F9"         , ControlIndex = 56},                                            
        { KeyChar = "F10"        , ControlIndex = 57},                                            
        { KeyChar = "~"          , ControlIndex = 243},                                            
        { KeyChar = "1"          , ControlIndex = 157},                                            
        { KeyChar = "2"          , ControlIndex = 158},                                            
        { KeyChar = "3"          , ControlIndex = 160},                                            
        { KeyChar = "4"          , ControlIndex = 164},                                            
        { KeyChar = "5"          , ControlIndex = 165},                                            
        { KeyChar = "6"          , ControlIndex = 159},                                            
        { KeyChar = "7"          , ControlIndex = 161},                                            
        { KeyChar = "8"          , ControlIndex = 162},                                            
        { KeyChar = "9"          , ControlIndex = 163},                                            
        { KeyChar = "-"          , ControlIndex = 84},                                            
        { KeyChar = "="          , ControlIndex = 83},                                            
        { KeyChar = "BACKSPACE"  , ControlIndex = 177},                                            
        { KeyChar = "TAB"        , ControlIndex = 37},                                            
        { KeyChar = "Q"          , ControlIndex = 44},                                            
        { KeyChar = "W"          , ControlIndex = 32},                                            
        { KeyChar = "E"          , ControlIndex = 38},                                            
        { KeyChar = "R"          , ControlIndex = 45},                                            
        { KeyChar = "T"          , ControlIndex = 245},                                            
        { KeyChar = "Y"          , ControlIndex = 246},                                            
        { KeyChar = "U"          , ControlIndex = 303},                                            
        { KeyChar = "P"          , ControlIndex = 199},                                            
        { KeyChar = ""          , ControlIndex = 39},                                            
        { KeyChar = ""          , ControlIndex = 40},                                            
        { KeyChar = "ENTER"      , ControlIndex = 18},                                           
        { KeyChar = "CAPS"       , ControlIndex = 137},                                            
        { KeyChar = "A"          , ControlIndex = 34},                                            
        { KeyChar = "S"          , ControlIndex = 8},                                            
        { KeyChar = "D"          , ControlIndex = 9},                                            
        { KeyChar = "F"          , ControlIndex = 23},                                            
        { KeyChar = "G"          , ControlIndex = 47}, 
        { KeyChar = "H"          , ControlIndex = 74}, 
        { KeyChar = "K"          , ControlIndex = 311}, 
        { KeyChar = "L"          , ControlIndex = 182},
        { KeyChar = "LEFTSHIFT"  , ControlIndex = 21}, 
        { KeyChar = "Z"          , ControlIndex = 20}, 
        { KeyChar = "X"          , ControlIndex = 73}, 
        { KeyChar = "C"          , ControlIndex = 26}, 
        { KeyChar = "V"          , ControlIndex = 0}, 
        { KeyChar = "B"          , ControlIndex = 29}, 
        { KeyChar = "N"          , ControlIndex = 249}, 
        { KeyChar = "M"          , ControlIndex = 244}, 
        { KeyChar = "},"         , ControlIndex = 82}, 
        { KeyChar = "."          , ControlIndex = 81},
        { KeyChar = "LEFTCTRL"   , ControlIndex = 36}, 
        { KeyChar = "LEFTALT"    , ControlIndex = 19}, 
        { KeyChar = "SPACE"      , ControlIndex = 22}, 
        { KeyChar = "RIGHTCTRL"  , ControlIndex = 70}, 
        { KeyChar = "HOME"       , ControlIndex = 213}, 
        { KeyChar = "PAGEUP"     , ControlIndex = 10}, 
        { KeyChar = "PAGEDOWN"   , ControlIndex = 11}, 
        { KeyChar = "DELETE"     , ControlIndex = 178},
        { KeyChar = "LEFT"       , ControlIndex = 174}, 
        { KeyChar = "RIGHT"      , ControlIndex = 175}, 
        { KeyChar = "TOP"        , ControlIndex = 27}, 
        { KeyChar = "DOWN"       , ControlIndex = 173},
        { KeyChar = "NENTER"     , ControlIndex = 201}, 
        { KeyChar = "N4"         , ControlIndex = 108}, 
        { KeyChar = "N5"         , ControlIndex = 60}, 
        { KeyChar = "N6"         , ControlIndex = 107}, 
        { KeyChar = "N+"         , ControlIndex = 96}, 
        { KeyChar = "N-"         , ControlIndex = 97}, 
        { KeyChar = "N7"         , ControlIndex = 117}, 
        { KeyChar = "N8"         , ControlIndex = 61}, 
        { KeyChar = "N9"         , ControlIndex = 118}                      
    }

    local VehiclesInWorld = {}
    local PlayersInWorld = {}
    local PedsInWorld = {}
    local ObjectsInWorld = {}
    local ActivePed = GetPlayerPed(-1)
    local Bones = {
        ["RHAND"] = 57005,
    }

    -- ====================== CLIENT EVENTS ===============================================
    RegisterNetEvent("dfs:NetworkFadeOut")
    AddEventHandler("dfs:NetworkFadeOut", function(NetID)
        local Entity = NetworkGetEntityFromNetworkId(NetID)
        SetVehicleIsConsideredByPlayer(Entity, false)
        SetEntityAlpha(Entity, 255)
        while DoesEntityExist(Entity) and GetEntityAlpha(Entity) > 0 do
            Wait(0)
            SetEntityAlpha(Entity, math.ceil(GetEntityAlpha(Entity) - 15), false)
        end
    end)

    RegisterNetEvent("dfs:NetworkFadeIn")
    AddEventHandler("dfs:NetworkFadeIn", function(NetID)
        local Entity = NetworkGetEntityFromNetworkId(NetID)
        SetEntityAlpha(Entity, 0)
        while DoesEntityExist(Entity) and GetEntityAlpha(Entity) < 255 do
            Wait(0)
            SetEntityAlpha(Entity, math.ceil(GetEntityAlpha(Entity) + 15), false)
        end
    end)

    -- ====================== CLIENT EXPORTS ==============================================
    function SpawnVehicle(modelHash, vector3Position, heading, setPedInDriversSeat, GetKeysFor, BasicPersistent, ServerRestartPersistnet, VehicleProps, PlateNumberText, EngineOn, EnableExtrasList, Livery, FuelLevel)
        modelHash = modelHash or 0x94204D89

        if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
            Error("DFS_Base > Utils.lua > SpawnVehicle", "Invalid spawn modelHash '"..modelHash.."'; Aborting.")
            return nil
        end
        --TODO: Pull in and upgrade ESX.VehicleProps methods
        while not HasModelLoaded(modelHash) do 
            RequestModel(modelHash)
            Wait(0) 
        end
        
        if not vector3Position then
            Error("DFS_Base > Utils.lua > SpawnVehicle", "Invalid vector3 spawn position '"..vector3Position.."'; Aborting.")
            return nil
        end
    
        --SPAWN CAR CODE
        local newCar 
        while not DoesEntityExist(newCar) do
            newCar = CreateVehicle(modelHash, vector3Position, heading, true, true) --Last arg NetMissionEntity may need disabled.
            Wait(0)
        end

        NetworkRegisterEntityAsNetworked(newCar)
        SetEntityHeading(newCar, heading)
        SetVehicleWindowTint(newCar, 0)

        local NetID = NetworkGetNetworkIdFromEntity(newCar)
        SetNetworkIdExistsOnAllMachines(NetID, true)

        SetEntityAlpha(newCar, 0)
        NetworkFadeInEntity(newCar, 1)

		SetVehRadioStation(vehicle, 'OFF')
        --/SPAWN CAR CODE

        if setPedInDriversSeat then
            SetPedIntoVehicle(PlayerPedId(), newCar, -1)
        end
    
        if BasicPersistent then
            SetEntityAsMissionEntity(newCar, true, true)
        end
    
        if ServerRestartPersistnet then
            TriggerEvent('persistent-vehicles/register-vehicle', newCar)
        end
    
        if VehicleProps then
            SetVehicleProps(newCar, VehicleProps)
        end
    
        if PlateNumberText then
            SetVehicleNumberPlateText(newCar, PlateNumberText)
        end
    
        if EngineOn then
            SetVehicleEngineOn(newCar, true, true, true)
        end
    
        for ExtraNumber,_ in pairs(EnableExtrasList or {}) do
            SetVehicleExtra(newCar, ExtraNumber, false)
        end

        if Livery then
            SetVehicleLivery(newCar, Livery)
        end
    
        if GetKeysFor then
            if type(VehicleProps) == "string" then
                VehicleProps = json.decode(VehicleProps)
            end
            TriggerEvent("dfscl:GetKeysForCar", PlateNumberText or (VehicleProps and VehicleProps.plate) or GetVehicleNumberPlateText(newCar))
        end

        if FuelLevel then
            SetVehicleFuelLevel(newCar, FuelLevel)
        end

        return newCar
    end

    function GetMyIdentity()
        return TriggerServerCallback("dfs:GetMyIdentity", function(IdentityData)
            return IdentityData
        end)
    end

    function GetActivePed()
        if not DoesEntityExist(ActivePed) then ActivePed = GetPlayerPed(-1) end
        return ActivePed
    end

    function SetActivePed(Ped)
       ActivePed = Ped
       return ActivePed 
    end

    function GetVehicleInFrontOfMe()
        local pX, pY, pZ = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        local BestVehicle
        local BestDistance = 3
        for k, vehicle in pairs(GetAllVehicles()) do
            local vX, vY, vZ = table.unpack(GetEntityCoords(vehicle))
            local Dist = GetDistanceBetweenCoords(vX, vY, vZ, pX, pY, pZ, true)
            
            if Dist <= BestDistance then
                BestDistance = Dist
                BestVehicle = vehicle
            end
        end
        return BestVehicle
    end
    
    function ConvertKey(KeyIntStr)
        for k, KeyCodePair in pairs(KeyCodes) do
            if KeyCodePair.KeyChar == KeyIntStr then return KeyCodePair.ControlIndex end
            if KeyCodePair.ControlIndex == KeyIntStr then return KeyCodePair.KeyChar end
        end
        return nil
    end

    function GetMyIdentifiers()
        return TriggerServerCallback("dfs:GetMyIdentifiers", function(Identifiers)
            Identifiers.NetworkID = PlayerId()
            return Identifiers
        end)
    end

    function GetAllPeds()
        return PedsInWorld
    end

    function DeleteVehicle(Vehicle)
        local TimeToAttemptUntilMs = GetGameTimer() + 10000
        SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Vehicle), true)
        while GetGameTimer() < TimeToAttemptUntilMs do
            NetworkRequestControlOfEntity(Vehicle)
            if NetworkGetEntityOwner(Vehicle) == PlayerId() and not IsPedAPlayer(GetPedInVehicleSeat(Vehicle, -1)) then
                SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(Vehicle), false)
                NetworkFadeOutEntity(Vehicle, false, true)
                while GetEntityAlpha(Vehicle) > 15 and DoesEntityExist(Vehicle) do
                    SetEntityAlpha(Vehicle, GetEntityAlpha(Vehicle) - 15, false)
                    SetVehicleDoorsShut(Vehicle, true)
                    SetVehicleDoorsLockedForAllPlayers(Vehicle, true)
                    SetVehicleUndriveable(Vehicle, true)
                    Wait(0) 
                end
                DeleteEntity(Vehicle)
                return true
            end
            Wait(0)
        end
        return false
    end

    function DeleteVehicleAsync(Vehicle, cb)
        --Can we maybe reduce this to `return Citizen.CreateThread
        Citizen.CreateThread(function ()
            local result = DeleteVehicle(Vehicle)
            if cb then 
                cb(result)
            end
        end)
    end

    function GetAllObjects()
        return ObjectsInWorld
    end

    function GetAllVehicles()
        return VehiclesInWorld
    end

    function GetAllPlayers()
        return PlayersInWorld
    end

    function DrawText3DMe (x,y,z, text)
        local onScreen,_x,_y=World3dToScreen2d(x,y,z)
        local px,py,pz=table.unpack(GetGameplayCamCoords())
        
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 370
        DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
    end

    function GetCurrentStreetName()
        local coords = GetEntityCoords(PlayerPedId())
        local streethash, crosshash = GetStreetNameAtCoord(coords[1], coords[2], coords[3])
        local _returnable = ""
    
        if crosshash ~= nil and GetStreetNameFromHashKey(crosshash) ~= "" then _returnable = " "..GetStreetNameFromHashKey(streethash).." and \
            "..GetStreetNameFromHashKey(crosshash)
        else _returnable = " "..GetStreetNameFromHashKey(streethash) end
        return _returnable
    end

    function AttachPropToPlayer(BoneName, PropName, xoffs, yoffs, zoffs, xrot, yrot, zrot)
        local Cooldown = 100
        while not HasModelLoaded(GetHashKey(PropName)) do
            RequestModel(GetHashKey(PropName))
            Wait(0)
            Cooldown = Cooldown - 1
            if Cooldown < 0 then 
                --Citizen.Trace("^1ERROR: dfs>Utils.lua:349; Could not load prop "..PropName.."^7\n") 
                return 
            end
        end
        Cooldown = 100

        local Prop
        while not DoesEntityExist(Prop) do
            Prop = CreateObject(GetHashKey(PropName), 0.0, 0.0, 0.0, true, true, true)
            Wait(0)
            Cooldown = Cooldown - 1
            if Cooldown < 0 then
                --Citizen.Trace("^1ERROR: dfs>Utils.lua:349; Could not create prop "..PropName.."^7\n") 
                return 
            end
        end

        AttachEntityToEntity(Prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), Bones[BoneName]), xoffs, yoffs, zoffs, xrot, yrot, zrot, true, false, false, false, 0, true)
        return Prop
    end

    function RemovePropFromPlayer(Prop)
        DetachEntity(Prop, true, false)
        DeleteObject(Prop)
    end

    function GetAllKeyCodes()
        return KeyCodes
    end

    function GetVehicleByPlate(PlateNumberText)
        local AllVehicles = GetAllVehicles()
        local Plate = string.toupper(PlateNumberText)
        for k, Vehicle in pairs(AllVehicles) do
            if GetVehicleNumberPlateText(Vehicle) == Plate then return Vehicle end
        end
        return nil
    end

    
    function GetVehicleProps(vehicle)
        if DoesEntityExist(vehicle) then
            local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            local extras = {}
    
            for id=0, 12 do
                if DoesExtraExist(vehicle, id) then
                    local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
                    extras[tostring(id)] = state
                end
            end
    
            return {
                model             = GetEntityModel(vehicle),
    
                plate             = GetVehicleNumberPlateText(vehicle),
                plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),
    
                bodyHealth        = GetVehicleBodyHealth(vehicle),
                engineHealth      = GetVehicleEngineHealth(vehicle),
    
                fuelLevel         = GetVehicleFuelLevel(vehicle),
                dirtLevel         = GetVehicleDirtLevel(vehicle),
                color1            = colorPrimary,
                color2            = colorSecondary,
    
                pearlescentColor  = pearlescentColor,
                wheelColor        = wheelColor,
    
                wheels            = GetVehicleWheelType(vehicle),
                windowTint        = GetVehicleWindowTint(vehicle),
    
                neonEnabled       = {
                    IsVehicleNeonLightEnabled(vehicle, 0),
                    IsVehicleNeonLightEnabled(vehicle, 1),
                    IsVehicleNeonLightEnabled(vehicle, 2),
                    IsVehicleNeonLightEnabled(vehicle, 3)
                },
    
                neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
                extras            = extras,
                tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),
    
                modSpoilers       = GetVehicleMod(vehicle, 0),
                modFrontBumper    = GetVehicleMod(vehicle, 1),
                modRearBumper     = GetVehicleMod(vehicle, 2),
                modSideSkirt      = GetVehicleMod(vehicle, 3),
                modExhaust        = GetVehicleMod(vehicle, 4),
                modFrame          = GetVehicleMod(vehicle, 5),
                modGrille         = GetVehicleMod(vehicle, 6),
                modHood           = GetVehicleMod(vehicle, 7),
                modFender         = GetVehicleMod(vehicle, 8),
                modRightFender    = GetVehicleMod(vehicle, 9),
                modRoof           = GetVehicleMod(vehicle, 10),
    
                modEngine         = GetVehicleMod(vehicle, 11),
                modBrakes         = GetVehicleMod(vehicle, 12),
                modTransmission   = GetVehicleMod(vehicle, 13),
                modHorns          = GetVehicleMod(vehicle, 14),
                modSuspension     = GetVehicleMod(vehicle, 15),
                modArmor          = GetVehicleMod(vehicle, 16),
    
                modTurbo          = IsToggleModOn(vehicle, 18),
                modSmokeEnabled   = IsToggleModOn(vehicle, 20),
                modXenon          = IsToggleModOn(vehicle, 22),
    
                modFrontWheels    = GetVehicleMod(vehicle, 23),
                modBackWheels     = GetVehicleMod(vehicle, 24),
    
                modPlateHolder    = GetVehicleMod(vehicle, 25),
                modVanityPlate    = GetVehicleMod(vehicle, 26),
                modTrimA          = GetVehicleMod(vehicle, 27),
                modOrnaments      = GetVehicleMod(vehicle, 28),
                modDashboard      = GetVehicleMod(vehicle, 29),
                modDial           = GetVehicleMod(vehicle, 30),
                modDoorSpeaker    = GetVehicleMod(vehicle, 31),
                modSeats          = GetVehicleMod(vehicle, 32),
                modSteeringWheel  = GetVehicleMod(vehicle, 33),
                modShifterLeavers = GetVehicleMod(vehicle, 34),
                modAPlate         = GetVehicleMod(vehicle, 35),
                modSpeakers       = GetVehicleMod(vehicle, 36),
                modTrunk          = GetVehicleMod(vehicle, 37),
                modHydrolic       = GetVehicleMod(vehicle, 38),
                modEngineBlock    = GetVehicleMod(vehicle, 39),
                modAirFilter      = GetVehicleMod(vehicle, 40),
                modStruts         = GetVehicleMod(vehicle, 41),
                modArchCover      = GetVehicleMod(vehicle, 42),
                modAerials        = GetVehicleMod(vehicle, 43),
                modTrimB          = GetVehicleMod(vehicle, 44),
                modTank           = GetVehicleMod(vehicle, 45),
                modWindows        = GetVehicleMod(vehicle, 46),
                modLivery         = GetVehicleMod(vehicle, 48)
            }
        else
            return
        end
    end
    
    function SetVehicleProps(vehicle, props)
        if type(props) == "string" then
            props = json.decode(props)
        end

        if DoesEntityExist(vehicle) then
            local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleModKit(vehicle, 0)
    
            if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
            if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
            if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
            if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
            if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
            if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
            SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2 or colorSecondary)
            SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor or wheelColor)
            if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
            if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end
    
            if props.neonEnabled then
                SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
                SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
                SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
                SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
            end
    
            if props.extras then
                for id,enabled in pairs(props.extras) do
                    if enabled then
                        SetVehicleExtra(vehicle, tonumber(id), 0)
                    else
                        SetVehicleExtra(vehicle, tonumber(id), 1)
                    end
                end
            end
    
            if props.neonColor then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
            if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, true) end
            if props.tyreSmokeColor then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
            if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
            if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
            if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
            if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
            if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
            if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
            if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
            if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
            if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
            if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
            if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
            if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
            if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
            if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
            if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
            if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
            if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
            if props.modTurbo then ToggleVehicleMod(vehicle,  18, props.modTurbo) end
            if props.modXenon then ToggleVehicleMod(vehicle,  22, props.modXenon) end
            if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
            if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
            if props.modPlateHolder then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
            if props.modVanityPlate then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
            if props.modTrimA then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
            if props.modOrnaments then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
            if props.modDashboard then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
            if props.modDial then SetVehicleMod(vehicle, 30, props.modDial, false) end
            if props.modDoorSpeaker then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
            if props.modSeats then SetVehicleMod(vehicle, 32, props.modSeats, false) end
            if props.modSteeringWheel then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
            if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
            if props.modAPlate then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
            if props.modSpeakers then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
            if props.modTrunk then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
            if props.modHydrolic then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
            if props.modEngineBlock then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
            if props.modAirFilter then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
            if props.modStruts then SetVehicleMod(vehicle, 41, props.modStruts, false) end
            if props.modArchCover then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
            if props.modAerials then SetVehicleMod(vehicle, 43, props.modAerials, false) end
            if props.modTrimB then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
            if props.modTank then SetVehicleMod(vehicle, 45, props.modTank, false) end
            if props.modWindows then SetVehicleMod(vehicle, 46, props.modWindows, false) end
    
            if props.modLivery then
                SetVehicleMod(vehicle, 48, props.modLivery, false)
                SetVehicleLivery(vehicle, props.modLivery)
            end
        end
    end

-- ================================= CLIENT Moving Data (threads) ==============================

    Citizen.CreateThread(function ()
        local success
        local _veh, _ped, _obj
        local _handle
        local TempVehiclesInWorld = {}
        local TempPedsInWorld      = {}
        local TempPlayersInWorld   = {}
        while true do
            Wait(0)
            --Vehicles
            TempVehiclesInWorld = {}
            _handle, _veh = FindFirstVehicle()

            table.insert(TempVehiclesInWorld, _veh)
            repeat
                success, _veh = FindNextVehicle(_handle)
                table.insert(TempVehiclesInWorld, _veh)
            until not success
            EndFindVehicle(_handle)

            VehiclesInWorld = TempVehiclesInWorld
            Wait(333)
            --Peds
            TempPedsInWorld    = {}
            TempPlayersInWorld = {}
            _handle, _ped      = FindFirstPed()

            repeat
                if IsPedAPlayer(_ped) then
                    TempPlayersInWorld[GetPlayerServerId(NetworkGetPlayerIndexFromPed(_ped))] = NetworkGetPlayerIndexFromPed(_ped)
                end
                success, _ped = FindNextPed(_handle)
                table.insert(TempPedsInWorld, _ped)
            until not success
            EndFindPed(_handle)

            PedsInWorld    = TempPedsInWorld
            PlayersInWorld = TempPlayersInWorld
            Wait(333)

            --Objects
            TempObjectsInWorld = {}
            _handle, _obj      = FindFirstObject()

            repeat
                success, _obj = FindNextObject(_handle)
                table.insert(TempObjectsInWorld, _obj)
            until not success
            EndFindObject(_handle)

            ObjectsInWorld    = TempObjectsInWorld
            Wait(333)
        end
    end)

end