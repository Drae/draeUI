local T, C, G, P, U, _ = unpack(select(2, ...))
local UF = T:GetModule("UnitFrames")

-- Auchindoun

UF["raiddebuffs"]["instances"]["Temple of Sethraliss"] = function()
	-- Galvazzt
	UF:AddRaidDebuff(true, 265973, 8) -- Galvanize
end