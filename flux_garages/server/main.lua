ESX              = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('esx:playerLoaded', function(source)

  local xPlayer = ESX.GetPlayerFromId(source)
    
end)

ESX.RegisterServerCallback('flux_garages:getOwnedVehicles', function (source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll(
		'SELECT * FROM owned_vehicles WHERE owner = @owner',
		{
		['@owner'] = identifier
		},
		function (result2)
			local vehicles = {}

			for i=1, #result2, 1 do
				local vehicleData = json.decode(result[i].vehicle)
				table.insert(vehicles, vehicleData)
			end

			cb(vehicles)
		end
	)
end)

ESX.RegisterServerCallback('flux_garages:checkIfVehicleIsOwned', function (source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	local found = nil
	local vehicleData = nil
	MySQL.Async.fetchAll(
	'SELECT * FROM owned_vehicles WHERE owner = @owner',
	{ 
		['@owner'] = identifier
	},
	function (result2)
		local vehicles = {}
		for i=1, #result2, 1 do
			vehicleData = json.decode(result2[i].vehicle)
			if vehicleData.plate == plate then
				found = true
				cb(vehicleData)
				break
			end
		end
		if not found then
			cb(nil)
		end
	end
	)
end)

ESX.RegisterServerCallback('flux_garages:checkVehProps', function (source, cb, plate)
	MySQL.Async.fetchAll(
	'SELECT * FROM owned_vehicles WHERE plate = @plate',
	{ 
		['@plate'] = plate
	},
	function (result2)
		if result2[1] then
			cb(json.decode(result2[1].vehicle))
		end
	end
	)
end)

ESX.RegisterServerCallback('flux_garages:checkIfPlayerIsOwner', function (source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll(
	'SELECT * FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND owner_type = 1',
	{ 
		['@owner'] = identifier,
		['@plate'] = plate
	},
	function (result2)
		if result2[1] ~= nil then
			cb(true)
		else
			cb(false)
		end
	end
	)
end)

RegisterServerEvent('flux_garages:updateOwnedVehicle')
AddEventHandler('flux_garages:updateOwnedVehicle', function(vehicleProps)
 	local _source = source
 	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll(
		'SELECT * FROM owned_vehicles WHERE owner = @owner',
		{
			['@owner'] = identifier
		},
		function(result2) 
			local foundVehicleId = nil 
			for i=1, #result2, 1 do 				
				local vehicle = json.decode(result2[i].vehicle)
				if vehicle.plate == vehicleProps.plate then
					foundVehiclePlate = result2[i].plate
					break
				end
			end
			if foundVehiclePlate ~= nil then
				MySQL.Async.execute(
					'UPDATE owned_vehicles SET vehicle = @vehicle, vehicleid = NULL, state = 1 WHERE plate = @plate',
					{
						['@vehicle'] 	= json.encode(vehicleProps),
						['@plate']      = vehicleProps.plate
					}
				) 
			end
		end
	)
 end)

RegisterServerEvent('flux_garages:removeCarFromParking')
AddEventHandler('flux_garages:removeCarFromParking', function(plate, networkid)
	local xPlayer = ESX.GetPlayerFromId(source)
	if plate ~= nil then
		MySQL.Async.execute(
			'UPDATE `owned_vehicles` SET state = 0, vehicleid = @networkid WHERE plate = @plate',
			{
			  ['@plate'] = plate,
			  ['@networkid'] = networkid
			}
		)
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('veh_released'))
	end
end)

RegisterServerEvent('flux_garages:removeCarFromPoliceParking')
AddEventHandler('flux_garages:removeCarFromPoliceParking', function(plate, networkid)
	local xPlayer = ESX.GetPlayerFromId(source)
	if plate ~= nil then
		MySQL.Async.execute(
			'UPDATE `owned_vehicles` SET state = 0, vehicleid = @networkid WHERE plate = @plate',
			{
			  ['@plate'] = plate,
			  ['@networkid'] = networkid
			}
		)
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('veh_released'))
	end
end)

ESX.RegisterServerCallback('flux_garages:getVehiclesInGarage', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll(
	'SELECT * FROM `owned_vehicles` WHERE owner = @identifier AND state = 1',
	{
		['@identifier'] = identifier
	},
	function(result2)
		local vehicles = {}
		for i=1, #result2, 1 do
			local vehicleData = json.decode(result2[i].vehicle)
			table.insert(vehicles, vehicleData)
		end
		cb(vehicles)
	end
	)
end)

ESX.RegisterServerCallback('flux_garages:towVehicle', function(source, cb, plate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll("SELECT vehicleid FROM owned_vehicles WHERE owner=@identifier AND plate = @plate",
	{
		['@identifier'] = identifier,
		['@plate'] = plate
	}, 
	function(data)
		if data[1] ~= nil then
			cb(data[1].vehicleid)
		end
	end)
end)

ESX.RegisterServerCallback('flux_garages:getVehiclesToTow',function(source, cb)	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier
	local vehicles = {}
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier AND state=0",
	{
		['@identifier'] = identifier
	}, 
	function(data) 
		for _,v in pairs(data) do
			if v.vehicleid == nil then
				v.vehicleid = -1
			end
			v.vehicle = v.vehicle:sub(1,-2)
			v.vehicle = v.vehicle .. ',"networkid":' .. v.vehicleid .. '}'
			local vehicle = json.decode(v.vehicle)
			table.insert(vehicles, vehicle)
		end
		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('flux_garages:getTakedVehicles', function(source, cb)
	local vehicles = {}
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE state=2",
	{}, 
	function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(vehicles, vehicle)
		end
		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('flux_garages:checkMoney', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.get('money') >= Config.ImpoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('flux_garages:pay')
AddEventHandler('flux_garages:pay', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.ImpoundPrice)
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mecano', function(account)
		account.addMoney(Config.ImpoundPrice/2)
	end)
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_police', function(account)
		account.addMoney(Config.ImpoundPrice/2)
	end)
end)

RegisterServerEvent('flux_garages:updateState')
AddEventHandler('flux_garages:updateState', function(plate)
	MySQL.Sync.execute(
		'UPDATE `owned_vehicles` SET state = 1, vehicleid = NULL WHERE plate = @plate',
		{
		['@plate'] = plate
		}
	)
end)

--SUBOWNER
ESX.RegisterServerCallback('flux_garages:getSubowners', function(source, cb, plate)
	local subowners = {}
	local found = false
	MySQL.Async.fetchAll(
		'SELECT owner FROM owned_vehicles WHERE plate = @plate and owner_type = 0',
		{ ['@plate'] = plate },
		function(data)
			if #data == nil or #data < 1 then
				found = true
			else
				for i=1, #data, 1 do
					MySQL.Async.fetchAll(
						'SELECT firstname, lastname FROM characters WHERE identifier = @identifier',
						{
							['@identifier'] = data[i].owner
						},
						function(data2)
							local subowner = {}
							table.insert(subowners, {label = data2[1].firstname .. " " .. data2[1].lastname, value= data[i].owner})
						end
					)
					if i==#data then
						found = true
					end
				end
			end
		end
	)
	Citizen.CreateThread(function()
		while found == false do
			Citizen.Wait(250)
			if found == true then
				cb(subowners)
			end
		end
	end)
end)

RegisterServerEvent('flux_garages:setSubowner')
AddEventHandler('flux_garages:setSubowner', function(plate, tID)
	local xPlayer = ESX.GetPlayerFromId(source)
	local tPlayer = ESX.GetPlayerFromId(tID)
	local identifier = xPlayer.identifier
	local tIdentifier = tPlayer.identifier
	
	MySQL.Async.fetchAll(
		'SELECT * FROM owned_vehicles WHERE plate = @plate AND owner_type = 1',
		{
			['@plate'] = plate
		},
		function(result2)
			if result2 ~= nil then
				if result2[1].owner_type == 1 then
					MySQL.Async.fetchAll(
						'SELECT owner FROM owned_vehicles WHERE plate = @plate AND owner_type = 0',
						{
							['@plate'] = plate
						},
						function(count)
							if #count >= Config.MaxSubs then
								TriggerClientEvent('esx:showNotification', xPlayer.source, _U('max_subs'))
							else
								MySQL.Sync.execute(
									'INSERT INTO owned_vehicles (owner, owner_type, state, plate, vehicle, vehicleid) VALUES (@owner, @owner_type, @state, @plate, @vehicle, @vehicleid)',
									{
										['@owner']   = tIdentifier,
										['@owner_type'] = 0,
										['@state'] = result2[1].state,
										['@plate'] = plate,
										['@vehicle'] =	result2[1].vehicle,
										['@vehicleid'] = result2[1].vehicleid
									}
								)
								TriggerClientEvent('esx:showNotification', xPlayer.source, _U('sub_added'))
								TriggerClientEvent('esx:showNotification', tPlayer.source, _U('you_are_sub', plate))	
							end
						end
					)
				else
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_owner'))
				end
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_veh'))
			end
		end
	)
end)

RegisterServerEvent('flux_garages:deleteSubowner')
AddEventHandler('flux_garages:deleteSubowner', function(plate, identifier)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Sync.execute(
		'DELETE FROM owned_vehicles WHERE owner = @owner AND plate = @plate',
		{
			['@owner']   = identifier,
			['@plate'] 	 = plate
		}
	)
	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('sub_deleted'))
end)

function parkAllOwnedVehicles()
	MySQL.ready(function ()
		MySQL.Sync.execute(
			'UPDATE `owned_vehicles` SET vehicleid = NULL WHERE vehicleid IS NOT NULL',
			{
			}, function(rowsChanged)
			end
		)
	end)
end

parkAllOwnedVehicles()
