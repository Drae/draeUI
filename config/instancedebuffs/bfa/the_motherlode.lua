local DraeUI = select(2, ...)
local UF = DraeUI:GetModule("UnitFrames")

-- Auchindoun

UF["raiddebuffs"]["instances"]["The Motherlode"] = function()
	-- Galvazzt
	UF:AddRaidDebuff(true, 265973, 8) -- Galvanize
end
