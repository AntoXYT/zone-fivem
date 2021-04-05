local dentro = false
local fuori = false

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	for k,v in pairs(Config.redzone) do
		for i = 1, #v.Pos, 1 do
		local radius = v.radius
		local redzoneblip = AddBlipForRadius(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, radius)
		SetBlipColour(redzoneblip, 1)
		SetBlipAlpha (redzoneblip, 128)
		SetBlipAsShortRange(redzoneblip, true)
	end
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
		for k,v in pairs(Config.redzone) do
			for i = 1, #v.Pos, 1 do
			dist = Vdist(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
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
	for k,v in pairs(Config.redzone) do
			for i = 1, #v.Pos, 1 do
				weapon = v.arma
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(v.Pos[closestZone].x, v.Pos[closestZone].y,  v.Pos[closestZone].z, x, y, z)
		local vehicle = GetVehiclePedIsIn(player, false)
	
		if dist <= 60.0 then 
			  if not dentro then
				NetworkSetFriendlyFireOption(false)
				GiveWeaponToPed(player, GetHashKey(weapon), 99990, true, true)
				--SetEntityAlpha(player, 200, false)
				DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
				DisableControlAction(0, 289, true)
				DisableControlAction(0, 106, true) -- Disable in-game mouse controls
				EnableControlAction(0, 163, true)


				GiveWeaponToPed(ped, GetHashKey(weapon), 99990, true, true)
				dentro = true
				fuori = false
			end
		else
			if not fuori then
				NetworkSetFriendlyFireOption(true)
				fuori = true
				dentro = false
			end
		end
		if dentro then
			DisableControlAction(0, 289, true)
			DisableControlAction(0, 288, true)
			DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
			if IsDisabledControlJustPressed(2, 37) then
				GiveWeaponToPed(player, GetHashKey(weapon), 99990, true, true)
			end
			--SetEntityAlpha(player, 200, false)
			if IsDisabledControlJustPressed(0, 106) then
				GiveWeaponToPed(player, GetHashKey(weapon), 99990, true, true)
			end
		end 
		end
	end
end
end)