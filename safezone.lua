---------- Safezone -- -----
local safezone = {
	{ ['x'] = -75.34, ['y'] = -818.64, ['z'] = 326.18}
}

local inncz = false
local outncz = false
local closestZone = 1

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	for i = 1, #safezone, 1 do
		local radius = 60.0
		local mjBlip = AddBlipForRadius(safezone[i].x, safezone[i].y, safezone[i].z, radius)
		SetBlipColour(mjBlip, 42)
		SetBlipAlpha (mjBlip, 128)
		SetBlipAsShortRange(mjBlip, true)
	end
end)

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #safezone, 1 do
			dist = Vdist(safezone[i].x, safezone[i].y, safezone[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(safezone[closestZone].x, safezone[closestZone].y, safezone[closestZone].z, x, y, z)
		local vehicle = GetVehiclePedIsIn(player, false)
	
		if dist <= 60.0 then 
			if not inncz then
				NetworkSetFriendlyFireOption(false)
				--SetEntityAlpha(player, 200, false)
				DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
				DisablePlayerFiring(player,true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
				DisableControlAction(0, 106, true) -- Disable in-game mouse controls
				DisableControlAction(0, 24, true) -- Disable in-game mouse controls
				EnableControlAction(0, 163, true)
				if GetVehiclePedIsIn(player, true) then
					local limitsp = 9999.076344490051
					SetEntityMaxSpeed(vehicle, limitsp)
					--SetEntityAlpha(vehicle, 200, false)
				end
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
				inncz = true
				outncz = false
			end
		else
			if not outncz then
				NetworkSetFriendlyFireOption(true)
				--ResetEntityAlpha(player)
				if GetVehiclePedIsIn(player, true) then
					maxSpeed = GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
					SetEntityMaxSpeed(vehicle, maxSpeed)
					--ResetEntityAlpha(vehicle)
				end
				outncz = true
				inncz = false
			end
		end
		if inncz then
			DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
			DisableControlAction(0, 24, true) -- Disable in-game mouse controls
			DisableControlAction(0, 140, true) -- Disable R
			if IsDisabledControlJustPressed(2, 37) then
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
			end
			--SetEntityAlpha(player, 200, false)
			if GetVehiclePedIsIn(player, true) then
				SetEntityMaxSpeed(vehicle, limitsp)
				--SetEntityAlpha(vehicle, 200, false)
			end
			if IsDisabledControlJustPressed(0, 106) then
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
			end
		end
	end
end)
