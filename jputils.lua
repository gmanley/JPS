--[[
	 JPS - WoW Protected Lua DPS AddOn
    Copyright (C) 2011 Jp Ganis

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
]]--
-- VARIABLES_LOADED
function jps_VARIABLES_LOADED()
	if ( not jpsDB ) then
		jpsDB = {}
	end
	if ( not jpsDB[jpsRealm] ) then
		jpsDB[jpsRealm] = {}
	end
	if ( not jpsDB[jpsRealm][jpsName] ) then
		jpsDB[jpsRealm][jpsName] = {}
		--defaults
		jpsDB[jpsRealm][jpsName][Enabled] = true
		jpsDB[jpsRealm][jpsName][MoveToTarget] = false
		jpsDB[jpsRealm][jpsName][FaceTarget] = false
		jpsDB[jpsRealm][jpsName][Interrupts] = true
		jpsDB[jpsRealm][jpsName][UseCDs] = false
		jpsDB[jpsRealm][jpsName][PvP] = false
		jpsDB[jpsRealm][jpsName][MultiTarget] = false
		jpsDB[jpsRealm][jpsName][ExtraButtons] = false
	end

	jps_LOAD_PROFILE()
	jps_variablesLoaded = true
end

-- LOAD_PROFILE
function jps_LOAD_PROFILE()
	for saveVar,value in pairs( jpsDB[jpsRealm][jpsName] ) do
		jps[saveVar] = value
	end

	jps.gui_toggleEnabled( jps.Enabled )
	jps.gui_toggleCDs( jps.UseCDs )
	jps.gui_toggleMulti( jps.MultiTarget )
	jps.gui_toggleToggles( jps.ExtraButtons )
	jps.togglePvP( jps.PvP )
	jps.resize( jps.IconSize )
end

-- SAVE_PROFILE
function jps_SAVE_PROFILE()
	for varName, _ in pairs( jpsDB[jpsRealm][jpsName] ) do
		jpsDB[jpsRealm][jpsName][varName] = jps[varName]
	end
end

-- Get Combat Function
function jps_getCombatFunction( class, spec )
	local Rotations =
	{ 
		["Druid"]        = { ["Feral Combat"]  = druid_feral,
							 ["Balance"]       = druid_balance,
							 ["Restoration"]   = druid_resto },
		["Death Knight"] = { ["Unholy"]        = new_dk_unholy,
							 ["Blood"]         = new_dk_blood,
							 ["Frost"]         = dk_frost  },  
		["Shaman"]       = { ["Enhancement"]   = shaman_enhancement,
							 ["Elemental"]     = shaman_elemental,
							 ["Restoration"]   = shaman_resto_pvp },
		["Paladin"]      = { ["Protection"]    = paladin_protadin,
							 ["Retribution"]   = paladin_ret,
							 ["Holy"]          = paladin_holy },
		["Warlock"]      = { ["Affliction"]    = warlock_affliction,
							 ["Destruction"]   = warlock_destro,
							 ["Demonology"]    = warlock_demo },
		["Hunter"]       = { ["Beast Mastery"] = hunter_bm,
							 ["Marksmanship"]  = hunter_mm,
							 ["Survival"]      = hunter_sv },
		["Mage"]         = { ["Fire"]          = mage_fire,
							 ["Arcane"]        = mage_arcane,
							 ["Frost"]         = mage_frost },
		["Rogue"]        = { ["Assassination"] = rogue_assass,
							 ["Subtlety"] 	   = rogue_sub,
							 ["Combat"] 	   = rogue_combat },
		["Warrior"]      = { ["Fury"]          = warrior_fury,
							 ["Protection"]    = warrior_prot,
							 ["Arms"]          = warrior_arms },
		["Priest"]       = { ["Shadow"]        = priest_shadow,
							 ["Holy"]          = priest_holy,
							 ["Discipline"]    = priest_disc },
	} 
	
	return Rotations[class][spec]
end

-- Get Class Cooldowns
function jps.setClassCooldowns()
	local options = {}

	-- Trolls n' Orcs
	if jps.Race == "Troll" then
		jps.DPSRacial = "berserking"
	elseif jps.Race == "Orc" then
		jps.DPSRacial = "blood fury"
	end
	if jps.DPSRacial then table.insert(options,"DPS Racial") end

	-- Lifeblood
	if GetSpellBookItemInfo("lifeblood") then
		table.insert(options, "Lifeblood")
	end

	-- Shaman
	if jps.Class == "Shaman" then
		if jps.Spec == "Elemental" then
			table.insert(options,"Elementary Mastery")
		elseif jps.Spec == "Enhancement" then
			table.insert(options,"shamanistic rage")
			table.insert(options,"feral spirit")
		end
	-- DK
	elseif jps.Class == "Death Knight" then
		table.insert(options,"Icebound Fortitude")
		table.insert(options,"Strangulate")
		table.insert(options,"Blood Tap")
		table.insert(options,"Empower Rune Weapon")
		table.insert(options,"Raise Dead (DPS)")
		table.insert(options,"Raise Dead (Sacrifice)")
		table.insert(options,"Death Grip")
		if jps.Spec == "Frost" then
			table.insert(options,"Pillar of Frost")
		elseif jps.Spec == "Blood" then
			table.insert(options,"Dancing Rune Weapon")
			table.insert(options,"Vampiric Blood")
			table.insert(options,"Rune Tap")
		elseif jps.Spec == "Unholy" then
			table.insert(options,"unholy frenzy")
			table.insert(options,"summon gargoyle")
		end
	-- Druid
	elseif jps.Class == "Druid" then
		if jps.Spec == "Feral Combat" then
			table.insert(options,"growl")
			table.insert(options,"challenging roar")
		elseif jps.Spec == "Balance" then
			table.insert(options,"solar beam")
		end
	-- Warrior
	elseif jps.Class == "Warrior" then
		if jps.Spec == "Arms" then
			table.insert(options,"charge")
			table.insert(options,"bladestorm")
			table.insert(options,"recklessness")
		end
	end

	-- Add spells
	for i,spell in pairs(options) do
		if jpsDB[jpsRealm][jpsName][spell] == nil then
			table.insert(jps_saveVars, { spell,true })
			jpsDB[jpsRealm][jpsName][spell] = true
			jps[spell] = true
		end
	end
end


-- Toggle PvP
function jps.togglePvP( value )
	if value == nil then jps.PvP = not jps.PvP
	else jps.PvP = value end

	if jps.PvP then jpsIcon.texture:SetTexture(jps.GUIpvp)
	else jpsIcon.texture:SetTexture(jps.GUInormal) end
end
