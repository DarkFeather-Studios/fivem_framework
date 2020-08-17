local jobList = {}
local itemTable = {}
local PlayersConnected = {}


--This is because we haven't removed ESX dependencies fully yet
local ESX
Citizen.CreateThread(function()
    while not ESX do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(100)
    end
end)
--/ESX

RegisterNetEvent('esx_skin:save')
AddEventHandler('esx_skin:save', function(skin)
    local src = source
    local playerData = PlayersConnected[src]
    if not playerData then print('^1ERROR: Could not save skin for player '..src..' as there is no record of them!^7') return end
    playerData.Skin = json.encode(skin)
end)

RegisterNetEvent("dfs:CreatePlayer")
AddEventHandler("dfs:CreatePlayer", function()
    CreatePlayer(source)
end)

function CreatePlayer(playerId)
    --return --If for whatever reaosn, this breaks things all to hell, jsut uncomment the return here
    local playerData = {}
    playerData.Identifiers      = GetTheirIdentifiers(playerId)
    local dbPlayerData          = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `user_id` = @uid", {["@uid"] = playerData.Identifiers.UserID})[1]
    --for keyName, Value in pairs(dbPlayerData) do print("keyName "..keyName.." Data "..type(Value)) end
    local dbPlayerPos           = json.decode(dbPlayerData.position)
    playerData.Identity         = GetTheirIdentity(playerId)
    playerData.Money            = dbPlayerData.money
    playerData.Bank             = dbPlayerData.bank
    playerData.Skin             = dbPlayerData.skin
    playerData.Inventory        = json.decode(dbPlayerData.inventory)
    playerData.Position         = vector4(dbPlayerPos.x, dbPlayerPos.y, dbPlayerPos.z, dbPlayerPos.heading)
    playerData.JobId            = dbPlayerData.dfs_job_id
    PlayersConnected[playerId]  = playerData
    print("^2Now tracking player "..playerId.."^7")
end

function SavePlayer(playerId)
    local playerData = PlayersConnected[playerId]
    if not playerData then print('^1ERROR: Could not save player '..playerId..' as there is no record of them!^7') return end
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(playerId)))
    local heading = GetEntityHeading(GetPlayerPed(playerId))
    local inventory = json.encode(playerData.Inventory)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local _Inventory = {}
    local index = 0
    for k, v in pairs(ESX.GetPlayerFromId(playerId).getInventory()) do
        _Inventory[v.name] = v.count
        index = index + 1
    end
    MySQL.Async.execute("UPDATE `users` SET `money` = @cash, `skin` = @skin, `job` = @job, `job_grade` = @jobgrade, `inventory` = @inventory, `position` = @position,\
     `bank` = @bank, `phone_number` = @phonenumber"--[[, `dfs_job_id`]].." WHERE `user_id` = @uid",
        {
            ["@cash"]           = xPlayer.getMoney(), --playerData.Money,
            ["@skin"]           = playerData.Skin, --May cause an issue. Not sure how skins are handled.
            ["@job"]            = xPlayer.getJob().name,-- playerData.Identity.JobName,
            ["@jobgrade"]       = xPlayer.getJob().grade, --playerData.Identity.JobGrade,
            ["@inventory"]      = json.encode(_Inventory),--json.encode(xPlayer.getInventory()),
            ["@position"]       = json.encode({["x"] = tonumber(string.format("%.1f", x)), ["y"] = tonumber(string.format("%.1f", y)), ["z"] = tonumber(string.format("%.1f", z)), ["heading"] = tonumber(string.format("%.1f", heading))}),
            ["@bank"]           = xPlayer.getAccount("bank").money, --playerData.Bank,
            ["@phonenumber"]    = playerData.Identity.PhoneNumber,
            ["@uid"]            = playerData.Identifiers.UserID
            --["@dfsjobid"]       = playerData.JobId
        })
    print('^2Saved '..playerData.Identity.FirstName.." "..playerData.Identity.LastName.."^7")
end

function AddPlayerMoney(playerId, amount)
    local playerData = PlayersConnected[playerId]
    if not playerData then print('^1ERROR: Could not AddPlayerMoney '..playerId..' as there is no record of them!^7') return end
    playerData.Money = playerData.Money + amount
    SavePlayer(playerId)
end

function RemovePlayerMoney(playerId, amount)
    AddPlayerMoney(playerId, amount)
end

function AddPlayerBank(playerId, amount)
    local playerData = PlayersConnected[playerId]
    if not playerData then print('^1ERROR: Could not AddPlayerBank '..playerId..' as there is no record of them!^7') return end
    playerData.Bank = playerData.Bank + amount
    SavePlayer(playerId)
end

function RemovePlayerBank(playerId, amount)
    AddPlayerBank(playerId, amount)
end

function SetPlayerJob(playerId, JobName, JobGrade) --created table dfs_jobs, added dfs_job_id to users
    local JobToSet
    local playerData = PlayersConnected[playerId]
    if not playerData then print('^1ERROR: Could not SetPlayerJob '..playerId..' as there is no record of them!^7') return end
    for k, v in pairs(jobList) do
        if v.JobName == JobName and v.JobGrade == JobGrade then
            JobToSet = k
            break
        end
    end
    if not JobToSet then print('^1ERROR: Could not SetPlayerJob '..playerId..' as there is no record of that job!^7') return end
    playerData.Identity.JobName = JobName
    playerData.Identity.JobGrade = JobGrade
    playerData.JobId = JobToSet
    SavePlayer(playerId)
end

function AddPlayerInventoryItem(playerId, itemName, itemCount)
    local playerData = PlayersConnected[playerId]
    if not playerData then print('^1ERROR: Could not AddPlayerInventoryItem '..playerId..' as there is no record of them!^7') return end

    local itemToAdd
    for k, v in pairs(itemTable) do
        if v.name == itemName then
            itemToAdd = v
            break
        end
    end

    if not itemToAdd then print('^1ERROR: Could not AddPlayerInventoryItem '..playerId..' as there is no record of item '..itemName..'!^7') return end
    playerData.Inventory[itemName] = playerData.Inventory[itemName] + itemCount
    SavePlayer(playerId)
end

function RemovePlayerInventoryItem(playerId, itemName, itemCount)
    AddPlayerInventoryItem(playerId, itemName, itemCount)
end

function GetPlayerInventoryItem(playerId, itemName)
    local playerData = PlayersConnected[playerId]
    if not playerData then print('^1ERROR: Could not GetPlayerInventoryItem '..playerId..' as there is no record of them!^7') return end

    local itemToAdd
    for k, v in pairs(itemTable) do
        if v.name == itemName then
            itemToAdd = v
            break
        end
    end

    if not itemToAdd then print('^1ERROR: Could not GetPlayerInventoryItem '..playerId..' as there is no record of item '..itemName..'!^7') return end
    return {Name = itemName, Label = itemToAdd.label, Count = playerData.Inventory[itemName], Weight = itemToAdd.weight * playerData.Inventory[itemName],
    WeightEach = itemToAdd.weight, Value = itemToAdd.price * playerData.Inventory[itemName], ValueEach = itemToAdd.price}
end


function GetPlayerInventory(playerId)
    local playerData = PlayersConnected[playerId]
    if not playerData then print('^1ERROR: Could not GetPlayerInventory '..playerId..' as there is no record of them!^7') return end

    --Start ESX BloatCode
    
    local _Inventory = {}
    local index = 0
    for k, v in pairs(ESX.GetPlayerFromId(playerId).getInventory()) do
        _Inventory[v.name] = v.count
        index = index + 1
    end
    
    playerData.Inventory = _Inventory
    --End ESX BloatCode

    local Inventory = {}
    for k, v in pairs(playerData.Inventory) do
        if v > 0 then
            table.insert(Inventory, GetPlayerInventoryItem(playerId, k))
        end
    end

    table.insert(Inventory, {Name = "cash", Label = "Cash", Count = ESX.GetPlayerFromId(playerId).getMoney(), Weight = 0,
    WeightEach = 0, Value = ESX.GetPlayerFromId(playerId).getMoney(), ValueEach = 1})

    
    --{ESX.GetPlayerFromId(playerId).getMoney())

    return Inventory
end


AddEventHandler("onServerResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        RegisterServerCallback("dfs:GetItemsTable", function(playerId)
            return itemTable
        end)

        local jobListData = MySQL.Sync.fetchAll("SELECT `id`, `name`, `salary` FROM `job_grades`")
        for k, v in pairs(jobListData) do
            jobList[v.id] = {JobName = v.name, Salary = v.salary}
        end

        local dbItems = MySQL.Sync.fetchAll("SELECT `item_id`, `name`, `label`, `weight`, `price` FROM `items`") --DFS is 15000, ESX is 33000
        for k, v in pairs(dbItems) do
            itemTable[v.item_id] = {name = v.name, label = v.label, weight = v.weight, price = v.price}
        end
    end
end)

RegisterNetEvent("playerDropped")
AddEventHandler("playerDropped", function(reason)
    local src = source
    SavePlayer(src)
    PlayersConnected[src] = nil
end)

Citizen.CreateThread(function()
    while true do
        for k, v in pairs(PlayersConnected) do
            if v then
                SavePlayer(k)
                Wait(0)
            end
        end
        Wait(60 * 1000 / #PlayersConnected)
    end
end)