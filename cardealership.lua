local carsForSale = {} -- Et tomt array til at holde styr på biler til salg

-- Event handler for når en spiller skriver "/sellcar <pris>"
RegisterCommand("sellcar", function(source, args, rawCommand)
    local price = tonumber(args[1])
    if price == nil then
        TriggerClientEvent("chatMessage", source, "^1Fejl: ^7Angiv en pris.")
        return
    end
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    if DoesEntityExist(vehicle) then
        local owner = GetPlayerServerId(NetworkGetEntityOwner(vehicle))
        if owner == source then
            local plate = GetVehicleNumberPlateText(vehicle)
            carsForSale[plate] = price -- Tilføj bilen til listen over biler til salg
            TriggerClientEvent("chatMessage", source, "^2Succes: ^7Bilen med nummerplade " .. plate .. " sættes til salg for " .. price .. " kr.")
        else
            TriggerClientEvent("chatMessage", source, "^1Fejl: ^7Du kan kun sælge din egen bil.")
        end
    else
        TriggerClientEvent("chatMessage", source, "^1Fejl: ^7Du er ikke i en bil.")
    end
end)

-- Event handler for når en spiller skriver "/buycar <nummerplade>"
RegisterCommand("buycar", function(source, args, rawCommand)
    local plate = args[1]
    if plate == nil then
        TriggerClientEvent("chatMessage", source, "^1Fejl: ^7Angiv en nummerplade.")
        return
    end
    local price = carsForSale[plate]
    if price == nil then
        TriggerClientEvent("chatMessage", source, "^1Fejl: ^7Bilen er ikke til salg.")
        return
    end
    local money = tonumber(GetPlayerMoney(source))
    if money < price then
        TriggerClientEvent("chatMessage", source, "^1Fejl: ^7Du har ikke råd til at købe bilen.")
        return
    end
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    if DoesEntityExist(vehicle) then
        TriggerClientEvent("chatMessage", source, "^1Fejl: ^7Du kan kun eje én bil ad gangen.")
        return
    end
    -- Spilleren har råd og har ikke allerede en bil, så lad dem købe bilen
    local seller = GetPlayerFromServerId(NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(GetVehicleNetworkId(plate))))
    TriggerClientEvent("chatMessage", seller, "^2Salg: ^7Bilen med nummerplade " .. plate .. " er blevet solgt til " .. GetPlayerName(source) .. " for " .. price .. " kr.")
    TriggerClientEvent("chatMessage", source, "^2Succes: ^7Du har købt bilen med nummerplade " .. plate .. " for " .. price .. " kr.")
    carsForSale[plate] = nil -- Fjern bilen fra listen over biler til salg
    TriggerEvent("esx_addonaccount:getSharedAccount", "society_mechanic", function(account)
        account:addMoney(price) 
    end
