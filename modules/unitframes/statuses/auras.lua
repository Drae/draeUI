--[[
		Inspired by Grid, Aptcheka and others
--]]
local _, ns = ...
local oUF = ns.oUF or draeUF

--
local T, C, G, P, U, _ = unpack(select(2, ...))
local UF = T:GetModule("UnitFrames")

local Status = UF:NewModule("StatusAuras")

-- Localise a bunch of functions
local UnitAura, UnitIsDeadOrGhost = UnitAura, UnitIsDeadOrGhost
local pairs = pairs

--
local aura_buffs = {}
local aura_debuffs = {}

--[[

--]]
local UpdateIndicatorList = function()
	local auras = T.dbClass["auras"]
	if (not auras) then return end

	wipe(aura_buffs)
	wipe(aura_debuffs)

	for status, aura in pairs(auras) do
		if (not aura.disable) then
			if (aura.buff) then
				aura_buffs[aura.buff] = aura
				aura_buffs[aura.buff]["status"] = status
			elseif (aura.debuff) then
				aura_debuffs[aura.debuff] = aura
				aura_debuffs[aura.debuff]["status"] = status
			end
		end
	end
end

--[[

--]]
local Update
do
	local index, name, texture, stack, duration, expires, caster

	local player_buffs_seen = {}
	local buffs_seen = {}
	local debuffs_seen = {}

	Update = function(self, event, unit)
		if (unit and self.unit ~= unit) then return end
		unit = unit or self.unit

		if (not UnitIsDeadOrGhost(unit)) then
			-- Buffs
			index = 1
			while (true) do
				name, texture, stack, _, duration, expires, caster = UnitAura(unit, index)

				if (not name) then break end

				if (aura_buffs[name]) then
					local aura = aura_buffs[name]

					local start = expires and (expires - duration)

					if (aura.mine and caster and caster == "player") then
						player_buffs_seen[name] = true

						-- status, color, texture, text, value, maxValue, start, duration, stack, notMine, pulse, flash
						self:GainedStatus(aura.status, aura.color, texture, aura.text, nil, nil, start, duration, stack, nil, aura.pulse, aura.flash)
					else
						buffs_seen[name] = true

						local notMine = caster and caster ~= "player" and true or false

						-- status, color, texture, text, value, maxValue, start, duration, stack, notMine, pulse, flash
						self:GainedStatus(aura.status, aura.color, texture, aura.text, nil, nil, start, duration, stack, notMine, aura.pulse, aura.flash)
					end
				end

				index = index + 1
			end

			-- Debuffs
			index = 1
			while (true) do
				name, texture, stack, _, duration, expires, caster = UnitAura(unit, index, "HARMFUL")

				if (not name) then break end

				local start = expires and (expires - duration)

				if (aura_debuffs[name]) then
					local aura = aura_debuffs[name]

					debuffs_seen[name] = true

					-- status, color, texture, text, value, maxValue, start, duration, stack, notMine, pulse, flash
					self:GainedStatus(aura.status, aura.color, texture, aura.text, nil, nil, start, duration, stack, nil, aura.pulse, aura.flash)
				end

				index = index + 1
			end
		end

		-- LostStatus will return if the status doesn't exist so this isn't
		-- horribly inefficient

		-- handle lost buffs
		for name in pairs(aura_buffs) do
			if (not player_buffs_seen[name] and not buffs_seen[name]) then

				local status = aura_buffs[name]["status"]
				self:LostStatus(status)
			end
		end

		-- handle lost debuffs
		for name in pairs(aura_debuffs) do
			if (not debuffs_seen[name]) then

				local status = aura_debuffs[name]["status"]
				self:LostStatus(status)
			end
		end

		wipe(player_buffs_seen)
		wipe(buffs_seen)
		wipe(debuffs_seen)
	end
end

local Enable = function(self)
	if (self.__is_grid) then
		self:RegisterEvent("UNIT_AURA", Update)
		return true
	end
end

local Disable = function(self)
	if (self.__is_grid) then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("StatusAuras", Update, Enable, Disable)

--[[

--]]
Status.OnEnable = function(self)
	UpdateIndicatorList()
end
