--Ty to MEW Feral Sim
-- jpganis
function druid_cat(self)
	local energy = UnitMana("player")
	local cp = GetComboPoints("player")
	local tfCD = jps.cooldown("tiger's fury")
	local ripDuration = jps.debuffDuration("rip")
	local rakeDuration = jps.debuffDuration("rake")
	local srDuration = jps.buffDuration("savage roar")
	local srRipSyncTimer = abs(ripDuration - srDuration)
	local mangleDuration = jps.notmyDebuffDuration("mangle")
	local executePhase = jps.hp("target") <= 0.25
	local t11 = "strength of the panther"
	local gcdLocked = jps.cooldown("shred") > 0
	local energyPerSec = 10
	local clearcasting = jps.buff("clearcasting")
	local berserking = jps.buff("berserk")
	local tf_up = jps.buff("tiger's fury")

	local spellTable =
	{
		{ nil,					not jps.buff("cat form") },
		--
		{"tiger's fury", 		IsSpellInRange("shred","target") and energy <= 35 and not clearcasting and not gcdLocked },
		--
		{"berserk", 			jps.UseCDs and jps.buff("tiger's fury") },
		{jps.DPSRacial,			jps.LastCast == "berserk" },
		--
		{"skull bash(cat form)",jps.shouldKick() and jps.Interrupts },
		{"swipe",				jps.MultiTarget },
		--
		{nil,					gcdLocked },
		--
		{"mangle(cat form)",	jps.buff(t11) and jps.buffDuration(t11) < 4 },
		--
		{"faerie fire (feral)", not jps.debuff("faerie fire") and not jps.debuffStacks("sunder armor")==3 and not jps.debuff("expose armor") },
		--
		{"mangle(cat form)", 	mangleDuration < 2 and not jps.debuff("trauma") and not jps.debuff("hemorrhage") },
		--
		{"ravage!", 				jps.buff("stampede") and jps.buffDuration("stampede") < 2 },
		--
		{"ferocious bite", 		executePhase and cp == 5 and ripDuration > 0 },
		{"ferocious bite", 		executePhase and cp > 0 and ripDuration <= 2.1 },
		--
		-- MANGLE/SHRED FOR GLYPH OF BLOODLETTING :(
		--
		{"rip", 				cp == 5 and ripDuration < 2 and (berserking or ripDuration+2 <= tfCD) },
		--
		{"ferocious bite",		berserking and cp == 5 and ripDuration > 5 and srDuration > 3 },
		--
		{"rake", 				jps.buff("tiger's fury") and rakeDuration < 9 },
		{"rake", 				rakeDuration < 3 and (berserking or rakeDuration-0.8 <= tfCD or energy >= 71) },
		--
		{"shred",				jps.buff("clearcasting") },
		--
		{"savage roar",			cp > 0 and srDuration < 1 and ripDuration > 6 },
		--
		{"ferocious bite",		(not berserking or energy < 25) and cp == 5 and ripDuration >= 14 and srDuration >= 10 },
		--
		{"ravage!", 				jps.buff("stampede") and not clearcasting and energy <= 100-energyPerSec },
		--
		{"mangle(cat form)",	jps.buff(t11) and jps.buffStacks(t11) < 3 },
		--
		{"shred", 				berserking or tfUp },
		{"shred",				(cp < 5 and ripDuration <= 3) or (cp == 0 and srDuration <= 2) },
		{"shred",				tfCD <= 3 },
		{"shred",				energy >= 100 - energyPerSec },
	}

	return parseSpellTable(spellTable)
end
