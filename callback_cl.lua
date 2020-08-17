local RegisteredClientCallbacks = {}
local ServerCallbackResults = {}

function RegisterClientCallback(CallbackName, Callback)
    Success("DFS_Base > callback_cl.lua > RegisterClientCallback", "Registering client callback '"..CallbackName.."'", true)
    for k, CallbackData in pairs(RegisteredClientCallbacks) do
        if CallbackData.Name == CallbackName then
            table.remove(RegisteredClientCallbacks, k)
            if CallbackData.Callback ~= Callback then
                Info("DFS_Base > callback_cl.lua > RegisterClientCallback", "Overwriting client callback "..CallbackName, true)
            end
            break
        end
    end

    table.insert(RegisteredClientCallbacks, 
        {
            Name = CallbackName,
            Callback = Callback
        }
    )
end

function TriggerServerCallback(CallbackName, Callback, ...)
    local CallbackID = math.random(1000000,9999999) --Used to allow multiple callbacks to be used at once
    local Timeout = 30000
    local StartedOn = GetGameTimer()
    TriggerServerEvent("dfsbs:TriggerServerCallback", CallbackID, CallbackName, ...)
    while StartedOn + Timeout > GetGameTimer () do
        for k, ReturnData in pairs(ServerCallbackResults) do
            if CallbackID == ReturnData.ID then
                table.remove(ServerCallbackResults, k)
                return Callback(table.unpack(ReturnData.Args)) 
            end
        end
        Wait(0)
    end
    Error("DFS_Base > callback_cl.lua > TriggerServerCallback", "Response timeout for callback "..CallbackName.."! Aborting...")
end

RegisterNetEvent("dfsbs:ServerCallbackResult")
AddEventHandler("dfsbs:ServerCallbackResult", function(CallbackID, ResultTable)
    table.insert(ServerCallbackResults,
        {
            ID = CallbackID,
            Args = ResultTable
        }
    )
end)

RegisterNetEvent("dfsbs:TriggerClientCallback")
AddEventHandler("dfsbs:TriggerClientCallback", function(CallbackID, CallbackName, ...)
    for k, Callback in pairs(RegisteredClientCallbacks) do
        if CallbackName == Callback.Name then
            TriggerServerEvent("dfsbs:ClientCallbackResult", CallbackID, {Callback.Callback(...)})
            return
        end
    end
    if type(CallbackName) == "string" then
        Error("DFS_Base > Utils.lua > callback_cl.lua", "No such callback "..CallbackName)
    else
        Warn("DFS_Base > Utils.lua > callback_cl.lua", "A callback was not coded properly; Data: "..json.encode(CallbackName), true)
    end
end)

function table.Contains(set, item)
    for key, value in pairs(set) do
        if value == item then return true end
    end
    return false
end