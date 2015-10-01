--
-- write info to a sqlite database at the following path:
-- Documents\My Games\Sid Meier's Civilization 5\ModUserData\exported streaming info-1.db
-- it contains lists of the building IDs in each of your cities, your policy IDs, and your belief IDs
print("loaded Export Info Mod")
local data = Modding.OpenUserData("exported streaming info", 1)

function updateInfo()
	
	local player = Players[Game.GetActivePlayer()]
	local buildings = {}
	for pCity in player:Cities() do				
		--buildings appear to go from 0 to 91
		for buildingId=0,91 do
			if (pCity:IsHasBuilding(buildingId)) then 
				--there's some kind of indexing confusion with buildings, we have to subtract 1 here or the ids don't match
				table.insert(buildings, buildingId - 1)
			end
		end		
	end
	data.SetValue("buildings", table.concat(buildings, " "))

	local policies = {}
	--policies appear to go from 0 to 110
	for policyId=0,110 do
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

end

--update at the end of every turn
Events.ActivePlayerTurnEnd.Add(updateInfo)
