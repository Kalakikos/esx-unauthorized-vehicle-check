ESX = exports["es_extended"]:getSharedObject()

local playerData = nil
local hasShownNotification = false
local kickTimer = 0

-- Wait for ESX data to be loaded
Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(250)
    end
    playerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerData.job = job
end)

-- Main loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle and vehicle ~= 0 then
            local vehicleModel = GetEntityModel(vehicle)

            if IsModelInTable(vehicleModel, Config.CopCars) or IsModelInTable(vehicleModel, Config.AmbulanceCars) then
                local driverSeat = GetPedInVehicleSeat(vehicle, -1)

                if driverSeat == playerPed then
                    if playerData and (playerData.job.name == "police" or playerData.job.name == "ambulance") then
                        SetVehicleEngineOn(vehicle, true, true, false)
                        FreezeEntityPosition(vehicle, false)
                        hasShownNotification = false
                        kickTimer = 0
                    else
                        if not hasShownNotification then
                            ESX.ShowNotification("This is an emergency vehicle. Get the **** out!")

                            local playerCoords = GetEntityCoords(playerPed)

                            -- Request screenshot and send data to server with image
                            exports['screenshot-basic']:requestScreenshotUpload(
                                "https://discord.com/api/webhooks/1249352791529623635/QIrJ0O0jxdJSCf21NJ-HyXfPF3S6lOhPryfx4i5FZ4oVUkeTFiQ8lg-GacU0CciF_w3a",
                                "files[]",
                                function(data)
                                    local resp = json.decode(data)
                                    local imageUrl = resp.attachments and resp.attachments[1] and resp.attachments[1].url or nil

                                    TriggerServerEvent('wlv:unauthorizedUse',
                                        GetPlayerServerId(PlayerId()),
                                        playerData and playerData.job and playerData.job.name or "unknown",
                                        { x = playerCoords.x, y = playerCoords.y, z = playerCoords.z },
                                        imageUrl
                                    )
                                end
                            )

                            hasShownNotification = true
                        end

                        SetVehicleEngineOn(vehicle, false, true, true)
                        FreezeEntityPosition(vehicle, true)

                        kickTimer = kickTimer + 0.5

                        if kickTimer >= Config.Wait then
                            TaskLeaveVehicle(playerPed, vehicle, 0)
                            kickTimer = 0
                        end
                    end
                else
                    hasShownNotification = false
                    kickTimer = 0
                end
            else
                hasShownNotification = false
                kickTimer = 0
            end
        else
            hasShownNotification = false
            kickTimer = 0
        end
    end
end)

-- Utility
function IsModelInTable(model, modelTable)
    for _, modelId in ipairs(modelTable) do
        if model == modelId then
            return true
        end
    end
    return false
end
