--[[


--]]
local _, ns = ...
local oUF = ns.oUF or oUF

local T, C, G, P, U, _ = select(2, ...):UnPack()
local UF = T:GetModule("UnitFrames")

-- Localise a bunch of functions
local _G = _G
local format, unpack = string.format, unpack
local CreateFrame, UnitLevel, UnitPower, UnitPowerMax, InCombatLockdown = CreateFrame, UnitLevel, UnitPower, UnitPowerMax, InCombatLockdown
local UnitExists, GetComboPoints = UnitExists, GetComboPoints

--[[
		Totem bars
		These are used by various specs in various ways
--]]
do
	local UpdateTotemPosition = function(self)
		local totem = self.Totems
		if (not totem) then return end

		local width, height = totem.width, totem.height

		local maxTotems
		if (T.playerClass == "SHAMAN") then
			maxTotems = 4
		elseif (T.playerClass == "DRUID") then
			local form  = GetShapeshiftFormID()
			if (form == MOONKIN_FORM or not form) then
				if (GetSpecialization() == 1) then
					maxTotems = 3
				else
					maxTotems = 1
				end
			else
				maxTotems = 1
			end
		elseif (T.playerClass == "WARLOCK" or T.playerClass == "MAGE") then
			maxTotems = 2
		else
			maxTotems = 1
		end

		local maxWidth = (maxTotems * width) + ((maxTotems - 1) * 8) -- Total width of frame, totems + spacing
		totem:Size(maxWidth, height)
	end

	local TotemOnEnter = function(self)
		if (not self:IsVisible()) then return end

		-- Add aura owner to tooltip if available - colour by class/reaction because it looks nice!
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetUnitAura(self.parent:GetParent().unit, self:GetID(), self.filter)

		GameTooltip:Show()
	end

	local TotemOnLeave = function(self)
		self.parent:GetParent().HighlightAura:Hide()
		GameTooltip:Hide()
	end

	-- Totem bars for shaman
	UF.CreateTotemBar = function(self, point, anchor, relpoint, xOffset, yOffset)
		if (T.playerClass == "WARRIOR" or T.playerClass == "ROGUE" or T.playerClass == "PRIEST" or T.playerClass == "HUNTER") then return end

		local totem = CreateFrame("Frame", nil, self)
		totem:Point(point, anchor, relpoint, xOffset, yOffset)
		totem:SetFrameLevel(12)

		local width, height	= T.db["frames"].auras.auraLrg or 24, T.db["frames"].auras.auraLrg or 24

		totem.width = width
		totem.height = height

		for i = 1, MAX_TOTEMS do
			local t = CreateFrame("Button", nil, totem)
			t:Width(width)
			t:Height(height)

			if (i == 1) then
				t:Point("RIGHT", totem, "RIGHT", 0, 0)
			else
				t:Point("RIGHT", totem[i - 1], "LEFT", -8, 0)
			end

			local border = CreateFrame("Frame", nil, t)
			border:SetPoint("TOPLEFT", t, -2, 2)
			border:SetPoint("BOTTOMRIGHT", t, 2, -2)
			border:SetFrameStrata("BACKGROUND")
			border:SetBackdrop {
				edgeFile = "Interface\\Buttons\\White8x8",
				tile = false,
				edgeSize = 2
			}
			border:SetBackdropBorderColor(0, 0, 0)
			t.border = border

			local icon = t:CreateTexture(nil, "BACKGROUND")
			icon:SetAllPoints(t)
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			t.Icon = icon

			local cd = CreateFrame("Cooldown", nil, t)
			cd:SetAllPoints(t)
			cd:SetReverse(true)
			t.Cooldown = cd

			local text = t:CreateFontString(nil, "OVERLAY")
			text:SetFont(T["media"].font, T.db["general"].fontsize3, "OUTLINE")
			text:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 7, -6)
			t.Text = text

			t:SetScript("OnEnter", TotemOnEnter)
			t:SetScript("OnLeave", TotemOnLeave)

			totem[i] = t
		end

		self.Totems = totem

		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTotemPosition, true)
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateTotemPosition, true)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateTotemPosition, true)
	end
end
