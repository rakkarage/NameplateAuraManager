local defaultConfigurations = {
	[1] = { -- Warrior
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {
			[388539] = true, -- Rend
			[275335] = true, -- Punish
			[397364] = true, -- Thunderous Roar
			[105771] = true, -- Charge
			[5246] = true, -- Intimidating Shout
			[1160] = true, -- Demoralizing Shout
			[132168] = true, -- Shockwave
			[132169] = true, -- Storm Bolt
			[355] = true, -- Taunt
			[1715] = true, -- Hamstring
			[376080] = true, -- Spear of Bastion
			[435203] = true, -- Thunder Clap
			[384954] = true, -- Shield Charge
			[385042] = true -- Gushing Wound
		},
		blockedDebuffs = {}
	},
	[2] = { -- Paladin
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[3] = { -- Hunter
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {
			[217200] = true, -- Barbed Shot
			[257284] = true, -- Hunter's Mark
			[375893] = true, -- Death Chakram
			[2649] = true, -- Growl
			[24394] = true, -- Intimidation
			[117405] = true, -- Binding Shot
			[135299] = true, -- Tar Trap
			[3355] = true, -- Freezing Trap
			[195645] = true -- Wing Clip
		},
		blockedDebuffs = {}
	},
	[4] = { -- Rogue
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[5] = { -- Priest
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[6] = { -- Death Knight
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[7] = { -- Shaman
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[8] = { -- Mage
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[9] = { -- Warlock
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[10] = { -- Monk
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[11] = { -- Druid
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[12] = { -- Demon Hunter
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	},
	[13] = { -- Evoker
		allowedBuffs = {},
		blockedBuffs = {},
		allowedDebuffs = {},
		blockedDebuffs = {}
	}
}

local function defaults(classId, resetBuffs, resetDebuffs)
	if not NAMDB then NAMDB = deepCopy(defaultConfigurations) end

	if classId and defaultConfigurations[classId] then
		if resetBuffs then
			NAMDB[classId].allowedBuffs = deepCopy(defaultConfigurations[classId].allowedBuffs)
			NAMDB[classId].blockedBuffs = deepCopy(defaultConfigurations[classId].blockedBuffs)
		end
		if resetDebuffs then
			NAMDB[classId].allowedDebuffs = deepCopy(defaultConfigurations[classId].allowedDebuffs)
			NAMDB[classId].blockedDebuffs = deepCopy(defaultConfigurations[classId].blockedDebuffs)
		end
	end
end
if not NAMDB then defaults() end

local function isAuraDisplayable(aura, forceAll, allowedAuras, blockedAuras)
	local playerAura = aura.sourceUnit == "player" or aura.sourceUnit == "pet" or aura.sourceUnit == "vehicle"
	if blockedAuras[aura.spellId] then
		return false
	end
	if next(allowedAuras) ~= nil then
		return allowedAuras[aura.spellId] and playerAura
	else
		return aura.nameplateShowAll or forceAll or (aura.nameplateShowPersonal and playerAura)
	end
end

local function determineAuraVisibility(_, aura, forceAll)
	if not aura or not aura.name then return false end
	local _, _, classId = UnitClass("player")
	local classDB = NAMDB[classId]
	if aura.isHarmful then
		return isAuraDisplayable(aura, forceAll, classDB.allowedDebuffs, classDB.blockedDebuffs)
	else
		return isAuraDisplayable(aura, forceAll, classDB.allowedBuffs, classDB.blockedBuffs)
	end
end

local function Mixin(baseFrame)
	baseFrame.UnitFrame.BuffFrame.ShouldShowBuff = determineAuraVisibility
end

local function handleSpellCommand(spellIdString, targetList, command, className, auraType)
	if not spellIdString or spellIdString == "" then
		print("NAM: No spell ID provided.")
		return
	end
	local spellId = tonumber(spellIdString)
	if not spellId then
		print("NAM: Invalid spell ID.")
		return
	end
	local spellInfo = C_Spell.GetSpellInfo(spellId)
	if not spellInfo or not spellInfo.name then
		print("NAM: Spell ID does not exist.")
		return
	end
	if targetList[spellId] ~= nil then
		targetList[spellId] = nil
	else
		targetList[spellId] = true
	end
	print(string.format("NAM: %s (%d) %s %s %s %s list.", spellInfo.name, spellId,
		targetList[spellId] and "added to" or "removed from", className, auraType, command))
end

local function listAuras(className, classDB, auraType, nameplateType)
	local allowedAuras = classDB["allowed" .. auraType]
	local blockedAuras = classDB["blocked" .. auraType]

	print(string.format("NAM: Allowed %s for %s %s nameplates:", auraType, className, nameplateType))
	for i, _ in pairs(allowedAuras) do
		local spellInfo = C_Spell.GetSpellInfo(i)
		print(string.format("  %s (%d)", spellInfo and spellInfo.name or "Unknown", i))
	end

	print(string.format("NAM: Blocked %s for %s %s nameplates:", auraType, className, nameplateType))
	for i, _ in pairs(blockedAuras) do
		local spellInfo = C_Spell.GetSpellInfo(i)
		print(string.format("  %s (%d)", spellInfo and spellInfo.name or "Unknown", i))
	end

	if next(allowedAuras) == nil and next(blockedAuras) == nil then
		print(string.format("  Empty lists means game defaults are used for %s %s nameplates.", className, nameplateType))
	end
end

SLASH_NAM1 = "/nam"
SlashCmdList["NAM"] = function(msg)
	local command, spellIdString = strsplit(" ", msg, 2)
	command = string.lower(command)
	local className, _, classId = UnitClass("player")
	local classDB = NAMDB[classId]
	if command == "allowbuff" then
		handleSpellCommand(spellIdString, classDB.allowedBuffs, "allow", className, "buff")
	elseif command == "blockbuff" then
		handleSpellCommand(spellIdString, classDB.blockedBuffs, "block", className, "buff")
	elseif command == "allowdebuff" then
		handleSpellCommand(spellIdString, classDB.allowedDebuffs, "allow", className, "debuff")
	elseif command == "blockdebuff" then
		handleSpellCommand(spellIdString, classDB.blockedDebuffs, "block", className, "debuff")
	elseif command == "list" then
		listAuras(className, classDB, "Buffs", "player")
		listAuras(className, classDB, "Debuffs", "enemy")
	elseif command == "listbuff" then
		listAuras(className, classDB, "Buffs", "player")
	elseif command == "listdebuff" then
		listAuras(className, classDB, "Debuffs", "enemy")
	elseif command == "clear" then
		classDB.allowedBuffs = {}
		classDB.blockedBuffs = {}
		classDB.allowedDebuffs = {}
		classDB.blockedDebuffs = {}
		print("NAM: Allow and block lists cleared for " .. className .. ".")
	elseif command == "clearbuff" then
		classDB.allowedBuffs = {}
		classDB.blockedBuffs = {}
		print("NAM: Buff allow and block lists for buffs cleared for " .. className .. ".")
	elseif command == "cleardebuff" then
		classDB.allowedDebuffs = {}
		classDB.blockedDebuffs = {}
		print("NAM: Buff allow and block lists for debuffs cleared for " .. className .. ".")
	elseif command == "reset" then
		defaults(classId, true, true)
		print("NAM: Allow and block lists reset for " .. className .. ".")
	elseif command == "resetbuff" then
		defaults(classId, true, false)
		print("NAM: Buff allow and block lists for buffs reset for " .. className .. ".")
	elseif command == "resetdebuff" then
		defaults(classId, false, true)
		print("NAM: Buff allow and block lists for debuffs reset for " .. className .. ".")
	elseif command == "help" or command == "?" or command == "" then
		print("NAM: Commands:")
		print("  `/nam list` display class allow and block lists.")
		print("  `/nam clear` clear class allow and block lists.")
		print("  `/nam reset` reset class allow and block lists to default.")
		print("Player Nameplate:")
		print("  `/nam allowbuff [spellId]` to toggle an allowed aura on player nameplate.")
		print("  `/nam blockbuff [spellid]` to toggle a blocked aura on player nameplate.")
		print("  `/nam listbuff` display class allow and block lists for buffs.")
		print("  `/nam clearbuff` clear class allow and block lists for buffs.")
		print("  `/nam resetbuff` reset class allow and block lists for buffs to default.")
		print("Enemy Nameplates:")
		print("  `/nam allowdebuff [spellId]` to toggle an allowed debuff on enemy nameplates.")
		print("  `/nam blockdebuff [spellId]` to toggle a blocked debuff on enemy nameplates.")
		print("  `/nam listdebuff` display class allow and block lists for debuffs.")
		print("  `/nam cleardebuff` clear class allow and block lists for debuffs.")
		print("  `/nam resetdebuff` reset class allow and block lists for debuffs to default.")
	else
		print("NAM: Invalid command. Use `/nam help`.")
	end
end

NAM = CreateFrame("Frame")
NAM:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NAM:RegisterEvent("ADDON_LOADED")
NAM:SetScript("OnEvent", function(_, event, arg1)
	if event == "NAME_PLATE_UNIT_ADDED" then
		Mixin(C_NamePlate.GetNamePlateForUnit(arg1))
	elseif event == "ADDON_LOADED" and arg1 == "NameplateAuraManager" then
		print("NAM: Loaded.")
	end
end)

for _, baseFrame in pairs(C_NamePlate.GetNamePlates()) do Mixin(baseFrame) end
