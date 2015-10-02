--
-- write info to a sqlite database at the following path:
-- Documents\My Games\Sid Meier's Civilization 5\ModUserData\exported streaming info-1.db
-- it contains lists of the building IDs in each of your cities, your policy IDs, and your belief IDs
print("loaded Export Info Mod")
local data = Modding.OpenUserData("exported streaming info", 1)
local numBuildings = 161
local numPolicies = 110
local numBeliefs = 68

function exportLocalizedNames()
	local buildingNames = {}
	local wonderNames = {}
	for buildingId=0,numBuildings do
		local building = GameInfo.Buildings[buildingId];
		if (building) then
			local name = Locale.ConvertTextKey(building.Description)
			table.insert(buildingNames, buildingId .. ":" .. name)
			-- this is a hack. i can't find out the right way to see whether it's a wonder, but WonderSplashImage seems to work
			if (building.WonderSplashImage) then
				table.insert(wonderNames, buildingId .. ":" .. name)
			end
		end
	end		
	data.SetValue("buildingNames", table.concat(buildingNames, "\n"))
	data.SetValue("wonderNames", table.concat(wonderNames, "\n"))
	
	local policyNames = {}
	for policyId=0,numPolicies do
		local policy = GameInfo.Policies[policyId]
		if (policy) then
			local name = Locale.ConvertTextKey(policy.Description)
			table.insert(policyNames, policyId .. ":" .. name)
		end
	end		
	data.SetValue("policyNames", table.concat(policyNames, "\n"))

	local beliefNames = {}
	for beliefId=0,numBeliefs do
		local belief = GameInfo.Beliefs[beliefId]
		if (belief) then
			local name = Locale.ConvertTextKey(belief.ShortDescription)
			table.insert(beliefNames, beliefId .. ":" .. name)
		end
	end		
	data.SetValue("beliefNames", table.concat(beliefNames, "\n"))

	
end

function updateInfo()
	
	local player = Players[Game.GetActivePlayer()]
	local buildings = {}
	for pCity in player:Cities() do				
		for buildingId=0,numBuildings do
			if (pCity:IsHasBuilding(buildingId)) then 
				--there's some kind of indexing confusion with buildings, we have to subtract 1 here or the ids don't match
				table.insert(buildings, buildingId - 1)
			end
		end		
	end
	data.SetValue("buildings", table.concat(buildings, " "))

	local policies = {}

	for policyId=0,numPolicies do
		if (player:HasPolicy(policyId)) then
			table.insert(policies, policyId)
		end
	end
	data.SetValue("policies", table.concat(policies, " "))

	local beliefs = {}
	local pantheonBelief = player:GetBeliefInPantheon()
	if(pantheonBelief) then
		table.insert(beliefs, pantheonBelief)
	end
	local religion = player:GetReligionCreatedByPlayer()
	if(religion and religion > 0) then
		for i,val in ipairs(Game.GetBeliefsInReligion(religion)) do
			table.insert(beliefs, val)
		end
	end		
	data.SetValue("religion", table.concat(beliefs, " "))

	data.SetValue("turn", Game.GetElapsedGameTurns())

end

--get localization once at startup
exportLocalizedNames()

--update what the player has at the end of every turn
Events.ActivePlayerTurnEnd.Add(updateInfo)
