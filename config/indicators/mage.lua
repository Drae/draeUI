--[[


--]]
local DraeUI = select(2, ...)

DraeUI.defaults.class["MAGE"] = {
	auras = {
		["buff_arcaneintellect"]  	= { buff = "Arcane Intellect",  mine = false, color = { 0.8, 0.8, 0.8 } },  -- Spell Power + Crit
		["buff_arcanenbrilliance"] 	= { buff = "Arcane Brilliance", mine = false, color = { 0.8, 0.8, 0.8 } },  -- Spell Power + Crit
	},

	statusmap = {
		["TEXT2"] = {
			["alert_afk"] 		= 95,
			["alert_dc"] 		= 95,
			["alert_ghost"]		= 92,
			["alert_feign"] 	= 90,
			["alert_dead"] 		= 90,
			["alert_charmed"] 	= 85,
			["unit_vehicle"] 	= 81,
			["unit_health"] 	= 80,
		},

        ["BORDER"] = {
            ["status_raiddebuff_one"] 	= 90,
            ["status_dispell"] 			= 80,
        },

        ["CENTERICON"] = {
            ["status_raiddebuff_one"] 	= 90,
            ["status_dispell"] 			= 80,
        },

        ["BOTTOMICON"] = {
            ["status_raiddebuff_two"] = 90,
        },

        ["TOPLEFT"] = {
        },

        ["TOPRIGHT"] = {
            ["status_incheal"] = 90,
        },

		["TOPRIGHTL"] = {
		},

        ["TOPRIGHTB"] = {
        },

        ["BOTTOM"] = {
            ["status_summon"] 	= 70,
            ["status_res"] 		= 80,
        },

        ["TOP"] = {
            ["status_aggro"] = 90,
        },

        ["TOPL"] = {
        },

        ["TOPR"] = {
        },

        ["BOTTOMRIGHT"] = {
        },

        ["BOTTOMRIGHTL"] = {
        },

        ["BOTTOMRIGHTT"] = {
        },

        ["BOTTOMLEFT"] = {
        },

        ["LEFT"] = {
        },

        ["LEFTB"] = {
        },

        ["RIGHT"] = {
        },

		["RIGHTT"] = {
			["buff_arcaneintellect"] = 70,
			["buff_arcanenbrilliance"] = 70,
		}
    }
}
