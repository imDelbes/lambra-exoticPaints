local QBCore = exports['qb-core']:GetCoreObject()

for i, d in pairs(Paints) do 
    QBCore.Functions.CreateUseableItem(i, function(source, item)
        TriggerClientEvent("lambra-exoticPaints:client:usedSpray", source, i)
    end)
end

RegisterNetEvent("lambra-exoticPaints:client:finishedSpray", function(vehicleProps, i)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveItem(i, 1) then
        if IsVehicleOwned(vehicleProps.plate) then
            MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
        end
    end
end)

function IsVehicleOwned(plate)
    local result = MySQL.scalar.await('SELECT 1 from player_vehicles WHERE plate = ?', {plate})
    if result then
        return true
    else
        return false
    end
end