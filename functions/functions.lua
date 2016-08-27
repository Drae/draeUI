--[[


--]]
local T, C, G, P, U, _ = select(2, ...):UnPack()

-- Localise a bunch of functions
local _G = _G
local pairs, ipairs, format, match, gupper, gsub, floor, abs, type, unpack, mmax, mmin, floor = pairs, ipairs, string.format, string.match, string.upper, string.gsub, math.floor, math.abs, type, unpack, math.max, math.min, math.floor
local UIParent, CreateFrame, ToggleDropDownMenu = UIParent, CreateFrame, ToggleDropDownMenu

--[[
		General functions
--]]
T.Print = function(...)
	print("|cff33ff99draeUI:|r ", ...)
end

-- Output an rgb hex string
T.Hex = function (r, g, b, a)
	if (type(r) == "table") then
		if (r.r) then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	return ("|c%02x%02x%02x%02x"):format((a or 1) * 255, r * 255, g * 255, b * 255)
end

-- MB or KB
T.MemFormat = function(num)
	if (num > 1024) then
		return format("%.2f MB", (num / 1024))
	else
		return format("%.1f KB", floor(num))
	end
end

-- UTF-8 encoding
T.UTF8 = function(str, i, dots)
	local bytes = str and str:len() or 0

	if (bytes <= i) then
		return str
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = str:byte(pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (len == i) then break end
		end

		if (len == i and pos <= bytes) then
			return str:sub(1, pos - 1)..(dots and "..." or "")
		else
			return str
		end
	end
end

-- Configuration/Alignment grid (stolen from Align!)
do
	local grid

	T.AlignGridShow = function(self, gridSize)
		if (not grid or (gridSize and grid.gridSize ~= gridSize)) then
			self:AlignGridCreate(gridSize)
		end

		grid:Show()
	end

	T.AlignGridHide = function(self, gridSize)
		if (not grid) then return end

		grid:Hide()

		if (gridSize and grid.gridSize ~= gridSize) then
			self:AlignGridCreate(gridSize)
		end
	end

	T.AlignGridToggle = function(self, gridSize)
		if (grid and grid:IsVisible()) then
			self:AlignGridHide(gridSize)
		else
			self:AlignGridShow(gridSize)
		end
	end

	T.AlignGridCreate = function(self, gridSize)
		if (not grid or (gridSize and grid.gridSize ~= gridSize)) then
			grid = nil

			grid = CreateFrame("Frame", nil, T.UIParent)
			grid:SetAllPoints(T.UIParent)
		end

		gridSize = gridSize or 128
		grid.gridSize = gridSize

		local size = 2
		local width = T.screenWidth
		local ratio = width / T.screenHeight
		local height = T.screenHeight * ratio

		local wStep = width / gridSize
		local hStep = height / gridSize

		for i = 0, gridSize do
			local tx = grid:CreateTexture(nil, "BACKGROUND")

			if (i == gridSize / 2 ) then
				tx:SetTexture(1, 0, 0, 0.5)
			else
				tx:SetTexture(0, 0, 0, 0.5)
			end

			tx:Point("TOPLEFT", grid, "TOPLEFT", i * wStep - (size / 2), 0)
			tx:Point("BOTTOMRIGHT", grid, "BOTTOMLEFT", i * wStep + (size / 2), 0)
		end

		height = T.screenHeight

		do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetTexture(1, 0, 0, 0.5)
			tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2) + (size / 2))
			tx:Point("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + size / 2))
		end

		for i = 1, floor((height / 2) / hStep) do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetTexture(0, 0, 0, 0.5)

			tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 + i * hStep) + (size / 2))
			tx:Point("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + i * hStep + size / 2))

			tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetTexture(0, 0, 0, 0.5)

			tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 - i * hStep) + (size / 2))
			tx:Point("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 - i * hStep + size / 2))
		end
	end
end

-- Smooth colour gradient between two r, g, b value
T.ColorGradient = function(perc, ...)
	if (perc > 1) then
		local r, g, b = select(select("#", ...) - 2, ...)
		return r, g, b
	elseif (perc < 0) then
		local r, g, b = ... return r, g, b
	end

	local num = select("#", ...) / 3

	local segment, relperc = math.modf(perc * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

-- Create and set font
T.CreateFontObject = function(parent, size, font, anchorAt, oX, oY, type, anchor, anchorTo)
	local fo = parent:IsObjectType("EditBox") and parent or parent:IsObjectType("FontString") and parent or parent:CreateFontString(nil, "OVERLAY")

	fo:SetFont(font, size, type or "THINOUTLINE")

	if (anchor) then
		fo:Point(anchorAt, anchor, anchorTo, oX, oY)
	else
		fo:SetJustifyH(anchorAt or "LEFT")

		if (oX or oY) then
			fo:Point(anchorAt or "LEFT", oX or 0, oY or 0)
		end
	end

	return fo
end

-- Print out money in a nicely formatted way
T.IntToGold = function(coins, showIcons)
	local g = floor(coins / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	local s = floor((coins - (g * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	local c = coins % COPPER_PER_SILVER

	local gText = showIcons and format("\124TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:1:0\124t", 12, 12) or "|cffffd700g|r"
	local sText = showIcons and format("\124TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:1:0\124t", 12, 12) or "|cffc7c7cfs|r"
	local cText = showIcons and format("\124TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:1:0\124t", 12, 12) or "|cffeda55fc|r"

	if (g) then
		return ("%d%s %d%s %d%s"):format(g or 0, gText, s or 0, sText, c or 0, cText)
	elseif (s) then
		return ("%d%s %d%s"):format(s or 0, sText, c or 0, cText)
	else
		return ("%d%s"):format(c or 0, cText)
	end
end

do
	local CreateHiddenFrame = function(...)
		local frame = CreateFrame(...)

		frame:Hide()

		return frame
	end

	T.CreateClass = function(self, frameType, prototype)
		local class = CreateHiddenFrame(frameType)
		local class_mt = { __index = class }

		class.Bind = function(self, obj)
			return setmetatable(obj, class_mt)
		end

		if prototype then
			class.proto = prototype

			return setmetatable(class, {__index = prototype})
		end

		return class
	end
end

function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end
