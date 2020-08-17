local RegisteredServerCallbacks = {}
local ClientCallbackResults = {}

function RegisterServerCallback(CallbackName, Callback)
    Success("DFS_Base > Utils.lua > callback_sv.lua", "Registering Server Callback '"..CallbackName.."'", true)
    for k, CallbackData in pairs(RegisteredServerCallbacks) do
        if CallbackData.Name == CallbackName then
            table.remove(RegisteredServerCallbacks, k)
            if CallbackData.Callback ~= Callback then
                Info("DFS_Base > Utils.lua > callback_sv.lua", "Overwriting server callback "..CallbackName, true)
            end
            break
        end
    end
    table.insert(RegisteredServerCallbacks,
        {
            Name = CallbackName,
            Callback = Callback
        }
    )
end

function TriggerClientCallback(CallbackName, PlayerID, Callback, ...)
    local CallbackID = math.random(1000000,9999999) --Used to allow multiple callbacks to be used at once
    local Timeout = 30000
    local StartedOn = GetGameTimer()
    if GetPlayerEndpoint(PlayerID) == nil then return nil end
    TriggerClientEvent("dfsbs:TriggerClientCallback", PlayerID, CallbackID, CallbackName, ...)
    while StartedOn + Timeout > GetGameTimer() do
        for k, ReturnData in pairs(ClientCallbackResults) do
            if CallbackID == ReturnData.ID then
                table.remove(ClientCallbackResults, k)
                return Callback(table.unpack(ReturnData.Args))
            end
        end
        Wait(0)
    end
    Error("DFS_Base > Utils.lua > callback_sv.lua", "Callback "..CallbackName.." timeout! Aborting...")
end

RegisterNetEvent("dfsbs:ClientCallbackResult")
AddEventHandler("dfsbs:ClientCallbackResult", function(CallbackID, ResultTable)
    table.insert(ClientCallbackResults, 
        {
            ID = CallbackID,
            Args = ResultTable
        }
    )
end)

RegisterNetEvent("dfsbs:TriggerServerCallback")
AddEventHandler("dfsbs:TriggerServerCallback", function(CallbackID, CallbackName, ...)
    local src = source
    for k, Callback in pairs(RegisteredServerCallbacks) do
        if CallbackName == Callback.Name then
            TriggerClientEvent("dfsbs:ServerCallbackResult", src, CallbackID, {Callback.Callback(src, ...)})
            return
        end
    end
    if type(CallbackName) == "string" then
        Error("DFS_Base > Utils.lua > callback_sv.lua", "No such callback "..CallbackName)
    else
        Warn("DFS_Base > Utils.lua > callback_sv.lua", "A callback was not coded properly; Data: "..json.encode(CallbackName))
    end
end)

function table.Contains(set, item)
    for key, value in pairs(set) do
        if value == item then return true end
    end
    return false
end