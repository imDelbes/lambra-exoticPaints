if GetGameBuildNumber() < 2699 then print("YOU NEED AT LEAST 2699 GAME BUILD") return end

local QBCore = exports["qb-core"]:GetCoreObject()

local sprayProp
local paintMode = false
local canStatus = 0
local needToShake = false
local spraying = false
local smokeParticle


local function LoadModel(model)
    while not HasModelLoaded(model) do RequestModel(model) Wait(500) end
end
local function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do RequestAnimDict(dict) Wait(500) end
end
local function DrawText3D(x, y, z, text)
	SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    DrawRect(0.0, 0.0+0.01, 0.015, 0.022, 0, 0, 0, 100)
    ClearDrawOrigin()
end

while not HasNamedPtfxAssetLoaded("scr_playerlamgraff") do RequestNamedPtfxAsset("scr_playerlamgraff") Wait(500) end

RegisterNetEvent("lambra-exoticPaints:client:usedSpray", function(i)
    if paintMode then return end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 2175)

    if veh ~= 0 and not IsPedInAnyVehicle(ped, true) then
        paintMode = true
        LoadModel("prop_cs_spray_can")
        LoadAnimDict("switch@franklin@lamar_tagging_wall")

        sprayProp = CreateObject("prop_cs_spray_can", GetEntityCoords(ped), true, true, false)
		AttachEntityToEntity(sprayProp, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.04, -70.0, 0.0, -10.0, true, true, false, false, 1, true)
        FreezeEntityPosition(veh, true)
        TaskPlayAnim(ped, "switch@franklin@lamar_tagging_wall", "lamar_tagging_wall_loop_lamar", 8.0, 1.0, -1, 48, 0, 0, 0, 0)
        Wait(1000)
        while IsEntityPlayingAnim(ped, "switch@franklin@lamar_tagging_wall", "lamar_tagging_wall_loop_lamar", 3) do Wait(500) end
        canStatus = 100
        paintModeThread(veh, i)
    end
end)

function paintModeThread(veh, i)
    CreateThread(function()
        while paintMode do
            DisableControlAction(0, 24, true) -- Attack (Primary)
            EnableControlAction(0, 25, true) -- Aim (Secondary)
            Wait(0)
        end
    end)

    CreateThread(function()
        local ped = PlayerPedId()
        local vehPos = GetEntityCoords(veh)

        while paintMode do
            local dist = #(GetEntityCoords(ped) - vehPos)
            local propPos = GetEntityCoords(sprayProp)
            DrawMarker(1 , vehPos.x, vehPos.y, vehPos.z - 1.0 ,0,0,0,0.0,0.0,0.0,10.0,10.0,1.0,255,0,0,50,0,0,0,0) --range marker
            DrawText3D(propPos.x, propPos.y, propPos.z, "~y~"..canStatus.."~w~%")

            
            if not needToShake then
                if IsDisabledControlPressed(0, 24) then
                    if not spraying then
                        spraying = true
                        TaskPlayAnim(ped, "switch@franklin@lamar_tagging_wall", "lamar_tagging_exit_loop_lamar", 8.0, 1.0, -1, 0, 0, 0, 0, 0)
                        UseParticleFxAssetNextCall("scr_playerlamgraff")
                        smokeParticle = StartNetworkedParticleFxLoopedOnEntity("scr_lamgraff_paint_spray", sprayProp, 0.0, 0.0, 0.0, 0.0, 0.0, 90.0, 1.0, false, false, false)
                        SetParticleFxLoopedColour(smokeParticle, 255.0, 0.0, 0.0, 0)

                        CreateThread(function()
                            while spraying do
                                local newVal = canStatus - 3
                                if newVal < 0 then newVal = 0 end
                                canStatus = newVal
                                Wait(1000)
                            end
                        end)
                        Wait(1)
                    end
                    if not IsEntityPlayingAnim(ped, "switch@franklin@lamar_tagging_wall", "lamar_tagging_exit_loop_lamar", 3) then
                        needToShake = true
                        if canStatus == 0 then applyPaint(veh, i) end
                        StopParticleFxLooped(smokeParticle, false)
                        spraying = false
                    end
                elseif IsDisabledControlJustReleased(0, 24) then
                    needToShake = true
                    if canStatus == 0 then applyPaint(veh, i) end
                    StopParticleFxLooped(smokeParticle, false)
                    spraying = false
                    ClearPedTasks(ped)
                end
            else
                if IsDisabledControlPressed(0, 25) then
                    if not spraying then
                        spraying = true
                        TaskPlayAnim(ped, "switch@franklin@lamar_tagging_wall", "lamar_tagging_wall_loop_lamar", 8.0, 1.0, -1, 48, 0, 0, 0, 0)
                        Wait(1)
                        CreateThread(function()
                            while IsEntityPlayingAnim(ped, "switch@franklin@lamar_tagging_wall", "lamar_tagging_wall_loop_lamar", 3) do Wait(500) end
                            spraying = false
                            needToShake = false
                            ClearPedTasks(ped)
                        end)
                    end
                end
            end

            if dist > 5.0 then
                ClearPedTasks(ped)
                DeleteEntity(sprayProp)
                FreezeEntityPosition(veh, false)
                needToShake = false
                paintMode = false
            end

            Wait(1)
        end
    end)
end

function applyPaint(veh, i)
    paintMode = false
    needToShake = false
    SetVehicleColours(veh, Paints[i], Paints[i])
    DeleteEntity(sprayProp)
    FreezeEntityPosition(veh, false)
    TriggerServerEvent('lambra-exoticPaints:client:finishedSpray', QBCore.Functions.GetVehicleProperties(veh), i)
end