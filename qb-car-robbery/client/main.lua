local QBCore = exports['qb-core']:GetCoreObject()
local RobbedCar = 0
local DeliveryLocation = {}
local BlipsLoaded = false
local SpawnBlip
local DeliveryBlip
VehicleTaken = false
Delivered = false
local timer = Config.timer
local carSellerPos = Config.carSeller.carSellerPos
local carSellerModel = Config.carSeller.carSellerModel
local carSellerHash = Config.carSeller.carSellerHash
local isPlayerInsideZone = false
local DeliveryZone = nil
local paid = false

local function createSpawnBlip(blipData)
    SpawnBlip = AddBlipForCoord(tonumber(blipData.position.x), tonumber(blipData.position.y),
        tonumber(blipData.position.z))
    SetBlipSprite(SpawnBlip, blipData.blipType)
    SetBlipDisplay(SpawnBlip, 4)
    SetBlipColour(SpawnBlip, blipData.blipColor)
    SetBlipScale(SpawnBlip, 1.0)
    SetBlipAsShortRange(SpawnBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(tostring(blipData.label))
    EndTextCommandSetBlipName(SpawnBlip)
end

local function removeBlip(blip)
    RemoveBlip(blip)
end

local function showTimer()
    CreateThread(function()
        while VehicleTaken and not Delivered do
            Wait(1)
            local curVeh = GetVehiclePedIsIn(ped)
            if curVeh ~= RobbedCar then
                local text = 'You have ~r~' .. timer .. '~s~ seconds to get back in car'
                local pos = { 0.42, 0.11 }
                SetTextFont(4)
                SetTextProportional(1)
                SetTextScale(0.55, 0.55)
                SetTextColour(255, 255, 255, 255)
                SetTextDropShadow(0, 0, 0, 0, 255)
                SetTextEdge(1, 0, 0, 0, 255)
                SetTextDropShadow()
                SetTextOutline()
                BeginTextCommandDisplayText('STRING')
                AddTextComponentSubstringPlayerName(text)
                EndTextCommandDisplayText(table.unpack(pos))
            end
        end
    end)
end

local function stopRobbery()
    SetEntityAsNoLongerNeeded(RobbedCar)
    DeleteEntity(RobbedCar)
    RemoveBlip(DeliveryBlip)
    VehicleTaken = false
    Delivered = true
    DeliveryZone:destroy()
    timer = Config.timer
    RobbedCar = 0
    TriggerServerEvent('server:update-activity', false)
end

--player left car
local function listenExit()
    showTimer()
    CreateThread(function()
        ped = PlayerPedId()
        timer = Config.timer
        while VehicleTaken and not Delivered do
            Wait(1)
            local curVeh = GetVehiclePedIsIn(ped)
            if curVeh ~= RobbedCar then
                Wait(1000)
                if timer > 0 then
                    timer = timer - 1
                end
                curVeh = GetVehiclePedIsIn(ped)
                if (timer <= 0) then
                    QBCore.Functions.Notify('Robbery Failed', 'error')
                    stopRobbery()
                    break
                end
            else
                timer = Config.timer
            end
        end
    end)
end

local function ControlPressed()
    CreateThread(function()
        while VehicleTaken and not Delivered and isPlayerInsideZone do
            Wait(0)
            if isPlayerInsideZone then
                if IsControlJustReleased(0, 38) then
                    exports['qb-core']:HideText()
                    if not paid then
                        QBCore.Functions.Notify('Selling Car', 'success', 3000)
                        stopRobbery()
                        TriggerServerEvent('server:payment', DeliveryLocation.Payment)
                        paid = true
                    end
                end
            end
        end
    end)
end

local function alertPolice()
    CreateThread(function()
        ped = PlayerPedId()
        while VehicleTaken and not Delivered do
            Wait(1000)
            local pos = GetEntityCoords(ped)
            local curVeh = GetVehiclePedIsIn(ped)
            if (curVeh == RobbedCar) then
                TriggerServerEvent('server:policeAlert', pos)
                Wait(Config.copTimerIntervel * 1000)
                curVeh = GetVehiclePedIsIn(ped)
                pos = GetEntityCoords(ped)
            end
        end
    end)
end

local function createDeliveryZone(location)
    DeliveryZone = BoxZone:Create(location.position, 20.0, 20.0, {
        name = "delivery-location",
        heading = location.heading,
        debugPoly = false,
        minZ = location.position.z - 2,
        maxZ = location.position.z + 2,
    })
    DeliveryZone:onPlayerInOut(function(isPlayerInside)
        if isPlayerInside then
            local ped = PlayerPedId()
            local curVeh = GetVehiclePedIsIn(ped)
            isPlayerInsideZone = true
            if VehicleTaken and not Delivered and (curVeh == RobbedCar) then
                exports['qb-core']:DrawText('Press E to Sell Car')
                ControlPressed()
            end
        else
            exports['qb-core']:HideText()
            isPlayerInsideZone = false
        end
    end)
end

local function spawnCar()
    QBCore.Functions.TriggerCallback('server:robbery-status', function(status, cooldown)
        if not status then
            if cooldown <= 0 then
                QBCore.Functions.TriggerCallback('server:GetCops', function(copsActive)
                    if (copsActive) then
                        DeliveryLocation = Config.Delivery[math.random(1, #Config.Delivery)]
                        SetEntityAsNoLongerNeeded(RobbedCar)
                        DeleteVehicle(RobbedCar)
                        RemoveBlip(DeliveryBlip)
                        local car = DeliveryLocation.Cars[math.random(1, #DeliveryLocation.Cars)]
                        local vehiclehash = GetHashKey(car)
                        RequestModel(vehiclehash)
                        while not HasModelLoaded(vehiclehash) do
                            RequestModel(vehiclehash)
                            Wait(1)
                        end
                        --creating car
                        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
                            RobbedCar = NetToVeh(netId)
                            exports['LegacyFuel']:SetFuel(RobbedCar, 100.0)
                            TaskWarpPedIntoVehicle(PlayerPedId(), RobbedCar, -1)
                            SetVehicleNumberPlateText(RobbedCar, "ROBBED")
                            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(RobbedCar))
                        end, vehiclehash, Config.vehicleSpawnPoint, true)
                        VehicleTaken = true
                        Delivered = false
                        paid = false
                        alertPolice()
                        listenExit()
                        timer = Config.timer
                        TriggerServerEvent('server:update-activity', true)
                        --delivery blip
                        createDeliveryZone(DeliveryLocation)
                        DeliveryBlip = AddBlipForCoord(tonumber(DeliveryLocation.position.x),
                            tonumber(DeliveryLocation.position.y),
                            tonumber(DeliveryLocation.position.z))
                        SetBlipSprite(DeliveryBlip, DeliveryLocation.blipType)
                        SetBlipDisplay(DeliveryBlip, 4)
                        SetBlipColour(DeliveryBlip, DeliveryLocation.blipColor)
                        SetBlipScale(DeliveryBlip, 1.0)
                        SetBlipAsShortRange(DeliveryBlip, true)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString(tostring(DeliveryLocation.label))
                        EndTextCommandSetBlipName(DeliveryBlip)
                        --route
                        SetBlipRoute(DeliveryBlip, true)
                        TriggerServerEvent('server:policeNotification')
                        TriggerEvent('client:start-Police-Alert')

                    else
                        QBCore.Functions.Notify('Not Enough Cops', 'error')
                    end
                end)
            else
                QBCore.Functions.Notify('Someone recently did This wait ' .. math.ceil(cooldown) .. ' Seconds', 'error')
            end
        else
            QBCore.Functions.Notify('A Robbery is in Progress', 'error')
        end
    end)
end

RegisterNetEvent('client:policeAlert', function(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    local blipText = ('Car Robber')
    SetBlipSprite(blip, 161)
    SetBlipColour(blip, 1)
    SetBlipFlashes(blip, true)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(blipText)
    EndTextCommandSetBlipName(blip)
    Wait(Config.copTimerIntervel * 1000)
    removeBlip(blip)
end)

RegisterNetEvent('client:policeNotification', function()
    QBCore.Functions.Notify('Car Robbery in Progress', 'police', 10000)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    createSpawnBlip(Config.spawnLocation)
    BlipsLoaded = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    removeBlip(SpawnBlip)
end)

RegisterNetEvent('client:start-robbery', function()
    spawnCar()
end)

if not BlipsLoaded then
    createSpawnBlip(Config.spawnLocation)
    BlipsLoaded = true
end

CreateThread(function()

    RequestModel(GetHashKey(carSellerModel))
    while (not HasModelLoaded(GetHashKey(carSellerModel))) do
        Wait(1)
    end
    local carseller = CreatePed(1, carSellerHash, carSellerPos, false, true)
    SetEntityInvincible(carseller, true)
    SetBlockingOfNonTemporaryEvents(carseller, true)
    FreezeEntityPosition(carseller, true)

    exports['qb-target']:AddBoxZone("carSeller", Config.carSeller.targetZone, 1, 1, {
        name = "carSeller",
        heading = Config.carSeller.targetHeading,
        debugPoly = false,
        minZ = Config.carSeller.minZ,
        maxZ = Config.carSeller.maxZ,
    }, {
        options = {
            {
                type = "client",
                event = "client:start-robbery",
                icon = "Fa fa-car",
                label = "Talk To Seller",
            },
        },
        distance = 1.0
    })
end)
