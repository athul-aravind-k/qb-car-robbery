local QBCore = exports['qb-core']:GetCoreObject()
local Active = false
local cooldown = 0
local lastRobbed = 0

RegisterServerEvent('server:update-activity', function(status)
    Active = status
    lastRobbed = os.time()
end)

RegisterServerEvent('server:payment', function(payment)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    xPlayer.Functions.AddItem('markedbills', payment)
    lastRobbed = os.time()
    TriggerClientEvent('QBCore:Notify', source, "Roberry Success", 'success')
end)

RegisterNetEvent('server:policeAlert', function(coords, text)
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            TriggerClientEvent('client:policeAlert', v.PlayerData.source, coords)
        end
    end
end)

RegisterNetEvent('server:policeNotification', function(coords, text)
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            TriggerClientEvent('client:policeNotification', v.PlayerData.source)
        end
    end
end)

QBCore.Functions.CreateCallback('server:robbery-status', function(source, cb)
    if (lastRobbed ~= 0) then
        cooldown = (Config.coolDown * 60) - (os.time() - lastRobbed)
    end
    cb(Active, cooldown)
end)

QBCore.Functions.CreateCallback('server:GetCops', function(source, cb)
    local cops = 0
    for k, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if (v.PlayerData.job.name == "police") and v.PlayerData.job.onduty then
            cops = cops + 1
        end
    end
    if (cops >= Config.copsRequired) then
        cb(true)
    else
        cb(false)
    end
end)
