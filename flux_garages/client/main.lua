local GUI                     = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentGarage           = nil
local PlayerData              = {}
local CurrentAction           = nil
local IsInShopMenu            = false
local pCoords 				  = nil
ESX                           = nil
GUI.Time                      = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

-- Create Blips
Citizen.CreateThread(function()
	for i=1, #Config.Garages do
		if Config.Garages[i].Blip == true then
			local blip = AddBlipForCoord(Config.Garages[i].Marker)
			SetBlipSprite (blip, 50)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.6)
			SetBlipColour (blip, 38)
			SetBlipAsShortRange(blip, true)		
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('garage_blip'))
			EndTextCommandSetBlipName(blip)
		end
	end
	for i=1, #Config.Impound, 1 do
		local blip2 = AddBlipForCoord(Config.Impound[i])
		SetBlipSprite (blip2, 430)
		SetBlipDisplay(blip2, 4)
		SetBlipScale  (blip2, 0.8)
		SetBlipColour (blip2, 1)
		SetBlipAsShortRange(blip2, true)		
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('impound_blip'))
		EndTextCommandSetBlipName(blip2)
	end

end)

Citizen.CreateThread(function()
	while true do
		local playerPed = PlayerPedId()
		pCoords = GetEntityCoords(playerPed)
		Citizen.Wait(400)
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while PlayerData.job == nil do
		Citizen.Wait(100)
	end
	while true do
		Citizen.Wait(1)
		for i=1, #Config.Garages, 1 do
			if(GetDistanceBetweenCoords(pCoords, Config.Garages[i].Marker, true) < Config.DrawDistance) then
				if Config.Garages[i].Visible[1] == nil then
					DrawMarker(Config.MarkerType, Config.Garages[i].Marker, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
				else
					for j=1, #Config.Garages[i].Visible, 1 do
						if PlayerData.job.name == Config.Garages[i].Visible[j] then
							DrawMarker(Config.MarkerType, Config.Garages[i].Marker, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						end
					end
				end
			end
		end
		for i=1, #Config.Impound, 1 do
			if(GetDistanceBetweenCoords(pCoords, Config.Impound[i], true) < Config.DrawDistance) then
				DrawMarker(Config.MarkerType, Config.Impound[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2,true, false, false, false)
			end	
		end
		for i=1, #Config.PoliceImpound, 1 do
			if PlayerData.job.name == 'police' then
				if(GetDistanceBetweenCoords(pCoords, Config.PoliceImpound[i], true) < Config.DrawDistance) then
					DrawMarker(Config.MarkerType, Config.PoliceImpound[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2,true, false, false, false)
				end
			end
		end
		for i=1, #Config.SetSubowner, 1 do
			if(GetDistanceBetweenCoords(pCoords, Config.SetSubowner[i], true) < Config.DrawDistance) then
				DrawMarker(Config.MarkerType, Config.SetSubowner[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2,true, false, false, false)
			end	
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function ()
  while PlayerData.job == nil do
	Citizen.Wait(100)
  end
  while true do
    Wait(1)
    local isInMarker  = false
    local currentZone = nil
	local playerPed = GetPlayerPed(-1)
    for i=1, #Config.Garages, 1 do
		if(GetDistanceBetweenCoords(pCoords, Config.Garages[i].Marker, true) < Config.MarkerSize.x) then
			if Config.Garages[i].Visible[1] == nil then
				if IsPedInAnyVehicle(playerPed) then
					isInMarker  = true
					currentZone = 'park_car'
					CurrentGarage = Config.Garages[i].Marker
				elseif not IsPedInAnyVehicle(playerPed) then
					isInMarker = true
					currentZone = 'pullout_car'
					CurrentGarage = Config.Garages[i].Marker
				end
			else
				for j=1, #Config.Garages[i].Visible, 1 do
					if PlayerData.job.name == Config.Garages[i].Visible[j] then
						if IsPedInAnyVehicle(playerPed) then
							isInMarker  = true
							currentZone = 'park_car'
							CurrentGarage = Config.Garages[i].Marker
						elseif not IsPedInAnyVehicle(playerPed) then
							isInMarker = true
							currentZone = 'pullout_car'
							CurrentGarage = Config.Garages[i].Marker
						end
					end
				end
			end
		end
    end
	for i=1, #Config.Impound, 1 do
		if(GetDistanceBetweenCoords(pCoords, Config.Impound[i], true) < Config.MarkerSize.x) then
			isInMarker  = true
			currentZone = 'impound_veh'
			CurrentGarage = Config.Impound[i]
		end
    end
	for i=1, #Config.PoliceImpound, 1 do
		if(GetDistanceBetweenCoords(pCoords, Config.PoliceImpound[i], true) < Config.MarkerSize.x) then
			if PlayerData.job.name == 'police' then
				isInMarker  = true
				currentZone = 'police_impound_veh'
				CurrentGarage = Config.PoliceImpound[i]
			end
		end
    end
	for i=1, #Config.SetSubowner, 1 do
		if(GetDistanceBetweenCoords(pCoords, Config.SetSubowner[i], true) < Config.MarkerSize.x) then
			isInMarker  = true
			currentZone = 'subowner_veh'
			CurrentGarage = Config.SetSubowner[i]
		end
	end
    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
		HasAlreadyEnteredMarker = true
		LastZone = currentZone
		TriggerEvent('flux_garages:hasEnteredMarker', currentZone)
    end
    if not isInMarker and HasAlreadyEnteredMarker then
		HasAlreadyEnteredMarker = false
		TriggerEvent('flux_garages:hasExitedMarker', LastZone)
    end
  end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

function SpawnImpoundedVehicle(plate)
	TriggerServerEvent('flux_garages:updateState', plate)
end

function SubownerVehicle()
	ESX.UI.Menu.Open(
		'dialog', GetCurrentResourceName(), 'subowner_player',
		{
			title = _U('veh_reg'),
			align = 'center'
		},
		function(data, menu)
			local plate = string.upper(tostring(data.value))
			if string.len(plate) < 8 or string.len(plate) > 8 then
				ESX.ShowNotification(_U('no_veh'))
			else
				ESX.TriggerServerCallback('flux_garages:checkIfPlayerIsOwner', function(isOwner)
					if isOwner then
						menu.close()
						ESX.UI.Menu.Open(
							'default', GetCurrentResourceName(), 'subowner_menu',
							{
								title = _U('owner_menu', plate),
								align = 'center',
								elements	= {
									{label = _U('set_sub'), value = 'give_sub'},
									{label = _U('manage_sub'), value = 'manage_sub'},
								}
							},
							function(data2, menu2)
								if data2.current.value == 'give_sub' then
									local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
									if closestPlayer ~= -1 and closestDistance <= 3.0 then
										TriggerServerEvent('flux_garages:setSubowner', plate, GetPlayerServerId(closestPlayer))
									else
										ESX.ShowNotification(_U('no_players'))
									end
								elseif data2.current.value == 'manage_sub' then
									ESX.TriggerServerCallback('flux_garages:getSubowners', function(subowners)
										if #subowners > 0 then
											ESX.UI.Menu.Open(
												'default', GetCurrentResourceName(), 'subowners',
												{
													title = _U('deleting_sub', plate),
													align = 'center',
													elements = subowners
												},
												function(data3, menu3)
													local subowner = data3.current.value
													ESX.UI.Menu.Open(
														'default', GetCurrentResourceName(), 'yesorno',
														{
															title = _U('sure_delete'),
															align = 'center',
															elements = {
																{label = _U('no'), value = 'no'},
																{label = _U('yes'), value = 'yes'}
															}
														},
														function(data4, menu4)
															if data4.current.value == 'yes' then
																TriggerServerEvent('flux_garages:deleteSubowner', plate, subowner)
																menu4.close()
																menu3.close()
																menu2.close()
															elseif data4.current.value == 'no' then
																menu4.close()
															end
														end,
														function(data4, menu4)
															menu4.close()
														end
													)													
												end,
												function(data3, menu3)
													menu3.close()
												end
											)
										else
											ESX.ShowNotification(_U('no_subs'))
										end
									end, plate)
								end
							end,
							function(data2,menu2)
								menu2.close()
							end
						)
					else
						ESX.ShowNotification(_U('not_owner'))
					end
				end, plate)
			end
		end,
		function(data,menu)
			menu.close()
		end
	)
end
-- Key controls
Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(1)
		if CurrentAction ~= nil then
			if CurrentAction == 'park_car' then
				DisplayHelpText(_U('store_veh'))
			elseif CurrentAction == 'pullout_car' then
				DisplayHelpText(_U('release_veh'))
			elseif CurrentAction == 'tow_menu' then
				DisplayHelpText(_U('tow_veh'))
			elseif CurrentAction == 'police_impound_menu' then
				DisplayHelpText(_U('p_impound_veh'))
			elseif CurrentAction == 'subowner_veh' then
				DisplayHelpText(_U('subowner_veh'))
			end

			if IsControlPressed(0, 38) and (GetGameTimer() - GUI.Time) > 300 then
				if CurrentAction == 'park_car' then
					local playerPed = GetPlayerPed(-1)
					local vehicle       = GetVehiclePedIsIn(playerPed)
					local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
					local name          = GetDisplayNameFromVehicleModel(vehicleProps.model)
					local plate         = vehicleProps.plate
					local health		= GetVehicleEngineHealth(vehicle)
					if health > Config.MinimumHealth then
						ESX.TriggerServerCallback('flux_garages:checkIfVehicleIsOwned', function (owned)
							if owned ~= nil then                    
								TriggerServerEvent("flux_garages:updateOwnedVehicle", vehicleProps)
								TaskLeaveVehicle(playerPed, vehicle, 16)
								ESX.Game.DeleteVehicle(vehicle)
							else
								ESX.ShowNotification(_U('not_owner'))
							end
						end, vehicleProps.plate)
					else
						ESX.ShowNotification(_U('repair'))
					end
				elseif CurrentAction == 'pullout_car' then
					SendNUIMessage({
						clearme = true
					})
					ESX.TriggerServerCallback('flux_garages:getVehiclesInGarage', function(vehicles)
						for i=1, #vehicles, 1 do
							SendNUIMessage({
								addcar = true,
								number = i,
								model = vehicles[i].plate,
								name = "<font color=#AAAAAA>" .. vehicles[i].plate .. "</font>&emsp;" ..  GetDisplayNameFromVehicleModel(vehicles[i].model)
							})
						end
					end)
					openGui()
				elseif CurrentAction == 'tow_menu' then
					SendNUIMessage({
						clearimp = true
					})
					ESX.TriggerServerCallback('flux_garages:getVehiclesToTow', function(vehicles)
						for i=1, #vehicles, 1 do
							SendNUIMessage({
								impcar = true,
								number = i,
								model = vehicles[i].plate,
								name = "<font color=#AAAAAA>" .. vehicles[i].plate .. "</font>&emsp;" ..  GetDisplayNameFromVehicleModel(vehicles[i].model)
							})
						end
					end)
					openGui()
				elseif CurrentAction == 'police_impound_menu' then
					SendNUIMessage({
						clearpolice = true
					})
					ESX.TriggerServerCallback('flux_garages:getTakedVehicles', function(vehicles)
						for i=1, #vehicles, 1 do
							SendNUIMessage({
								policecar = true,
								number = i,
								model = vehicles[i].plate,
								name = "<font color=#AAAAAA>" .. vehicles[i].plate .. "</font>&emsp;" ..  GetDisplayNameFromVehicleModel(vehicles[i].model)
							})
						end
					end)
					openGui()
				elseif CurrentAction == 'subowner_veh' then
					if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
						SubownerVehicle()
					end
				end
				CurrentAction = nil
				GUI.Time      = GetGameTimer()
			end
		end
	end
end)

Citizen.CreateThread(function()
	SetNuiFocus(false, false)
end)

-- Open Gui and Focus NUI
function openGui()
	SetNuiFocus(true, true)
	SendNUIMessage({openGarage = true})
end

-- Close Gui and disable NUI
function closeGui()
	SetNuiFocus(false)
	SendNUIMessage({openGarage = false})
end

-- NUI Callback Methods
RegisterNUICallback('close', function(data, cb)
	closeGui()
	cb('ok')
end)

-- NUI Callback Methods
RegisterNUICallback('pullCar', function(data, cb)
	local playerPed  = GetPlayerPed(-1)
	ESX.TriggerServerCallback('flux_garages:checkIfVehicleIsOwned', function (owned)
		local spawnCoords  = {
			x = CurrentGarage.x,
			y = CurrentGarage.y,
			z = CurrentGarage.z,
		}
		ESX.Game.SpawnVehicle(owned.model, spawnCoords, GetEntityHeading(playerPed), function(vehicle)
			TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
			ESX.Game.SetVehicleProperties(vehicle, owned)
			local localVehPlate = string.lower(GetVehicleNumberPlateText(vehicle))
			local localVehLockStatus = GetVehicleDoorLockStatus(vehicle)
			TriggerEvent("ls:getOwnedVehicle", vehicle, localVehPlate, localVehLockStatus)
			local networkid = NetworkGetNetworkIdFromEntity(vehicle)
			TriggerServerEvent("flux_garages:removeCarFromParking", owned.plate, networkid)
		end)
	end, data.model)
	closeGui()
	cb('ok')
end)

RegisterNUICallback('towCar', function(data, cb)
	closeGui()
	cb('ok')
	ESX.TriggerServerCallback('flux_garages:towVehicle', function(id)
		if id ~= nil then
			local entity = NetworkGetEntityFromNetworkId(tonumber(id))
			ESX.ShowNotification(_U('checking_veh'))
			Citizen.Wait(math.random(500, 4000))
			if entity == 0 then
				ESX.TriggerServerCallback('flux_garages:checkMoney', function(hasMoney)
					if hasMoney then
						ESX.ShowNotification(_U('checking_veh'))
						Citizen.Wait(math.random(500, 4000))
						TriggerServerEvent('flux_garages:pay')
						SpawnImpoundedVehicle(data.model)
						ESX.ShowNotification(_U('veh_impounded', data.model))
					else
						ESX.ShowNotification(_U('no_money'))
					end
				end)
			elseif entity ~= 0 and (GetVehicleNumberOfPassengers(entity) > 0 or not IsVehicleSeatFree(entity, -1)) then
				ESX.ShowNotification(_U('cant_impound'))
			else
				ESX.TriggerServerCallback('flux_garages:checkMoney', function(hasMoney)
					if hasMoney then
						TriggerServerEvent('flux_garages:pay')
						SpawnImpoundedVehicle(data.model)
						if entity ~= 0 then
							ESX.Game.DeleteVehicle(entity)
						end
						ESX.ShowNotification(_U('veh_impounded', data.model))
					else
						ESX.ShowNotification(_U('no_money'))
					end
				end)
			end
		else
			ESX.TriggerServerCallback('flux_garages:checkMoney', function(hasMoney)
				if hasMoney then
					ESX.ShowNotification(_U('checking_veh'))
					Citizen.Wait(math.random(500, 4000))
					TriggerServerEvent('flux_garages:pay')
					SpawnImpoundedVehicle(data.model)
					ESX.ShowNotification(_U('veh_impounded', data.model))
				else
					ESX.ShowNotification(_U('no_money'))
				end
			end)
		end
	end, data.model)
end)

RegisterNUICallback('impoundCar', function(data, cb)
	closeGui()
	cb('ok')
	local playerPed  = GetPlayerPed(-1)
	ESX.TriggerServerCallback('flux_garages:checkVehProps', function(veh)
		ESX.ShowNotification(_U('checking_veh'))
		Citizen.Wait(math.random(500, 4000))
		local spawnCoords  = {
			x = CurrentGarage.x,
			y = CurrentGarage.y,
			z = CurrentGarage.z,
		}
		ESX.Game.SpawnVehicle(veh.model, spawnCoords, GetEntityHeading(playerPed), function(vehicle)
			TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
			ESX.Game.SetVehicleProperties(vehicle, veh)
			local networkid = NetworkGetNetworkIdFromEntity(vehicle)
			TriggerServerEvent("flux_garages:removeCarFromPoliceParking", data.model, networkid)
		end)
	end, data.model)
	
end)

function DisplayHelpText(str)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentScaleform(str)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
end

AddEventHandler('flux_garages:hasEnteredMarker', function (zone)
	if zone == 'pullout_car' then
		CurrentAction = 'pullout_car'
	elseif zone == 'park_car' then
		CurrentAction = 'park_car'
	elseif zone == 'impound_veh' then
		CurrentAction = 'tow_menu'
	elseif zone == 'police_impound_veh' then
		CurrentAction = 'police_impound_menu'
	elseif zone == 'subowner_veh' then
		CurrentAction = 'subowner_veh'
	end
end)

AddEventHandler('flux_garages:hasExitedMarker', function (zone)
  if IsInShopMenu then
    IsInShopMenu = false
    CurrentGarage = nil
  end
  if not IsInShopMenu then
	ESX.UI.Menu.CloseAll()
  end
  CurrentAction = nil
end)


