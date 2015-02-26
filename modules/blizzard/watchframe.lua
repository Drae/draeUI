--[[


--]]
local T, C, G, P, U, _ = select(2, ...):UnPack()

local B = T:GetModule("Blizzard")

--[[

--]]
local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", UIParent)
ObjectiveFrameHolder:Width(ObjectiveTrackerFrame:GetWidth())
ObjectiveFrameHolder:Height(ObjectiveTrackerFrame:GetTop() - CONTAINER_OFFSET_Y)
ObjectiveFrameHolder:Point("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -10, -30)

B.MoveWatchFrame = function(self)
	ObjectiveFrameHolder:SetScale(0.95)
	
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
	ObjectiveTrackerFrame:Height(ObjectiveTrackerFrame:GetTop() - CONTAINER_OFFSET_Y)

	hooksecurefunc(ObjectiveTrackerFrame,"SetPoint", function(_, _, parent)
		if (parent ~= ObjectiveFrameHolder) then
			ObjectiveTrackerFrame:ClearAllPoints()
            ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
		end
	end)
end
