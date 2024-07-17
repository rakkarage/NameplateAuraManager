local function defaults(classId)
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
				[6343] = true, -- Thunder Clap
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

	if not NAMDB then NAMDB = defaultConfigurations end

	if classId and defaultConfigurations[classId] then
		NAMDB[classId] = defaultConfigurations[classId]
	end
end
if not NAMDB then defaults() end

local function shouldShowAura(aura, forceAll, allowedAuras, blockedAuras)
	local playerAura = aura.sourceUnit == "player" or aura.sourceUnit == "pet" or aura.sourceUnit == "vehicle"
	if next(allowedAuras) ~= nil or next(blockedAuras) ~= nil then
		local returnValue = aura.nameplateShowAll or forceAll or
			((allowedAuras[aura.spellId] and not blockedAuras[aura.spellId]) and playerAura)
		return returnValue or false
	else
		return aura.nameplateShowAll or forceAll or (aura.nameplateShowPersonal and playerAura)
	end
end

local function newShouldShowBuff(_, aura, forceAll)
	if not aura or not aura.name then return false end
	local _, _, classId = UnitClass("player")
	local classDB = NAMDB[classId]
	if aura.isHarmful then
		return shouldShowAura(aura, forceAll, classDB.allowedDebuffs, classDB.blockedDebuffs)
	else
		return shouldShowAura(aura, forceAll, classDB.allowedBuffs, classDB.blockedBuffs)
	end
end

local function Mixin(baseFrame)
	baseFrame.UnitFrame.BuffFrame.ShouldShowBuff = newShouldShowBuff
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
	local spellName = GetSpellInfo(spellId)
	if not spellName then
		print("NAM: Spell ID does not exist.")
		return
	end
	targetList[spellId] = not targetList[spellId]
	local status = targetList[spellId] and "added to" or "removed from"
	local text = status .. " " .. className .. " " .. auraType .. " " .. command .. " list."
	print("NAM: " .. spellName .. " (" .. tostring(spellId) .. ") " .. text)
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
		print("NAM: Allowed buff auras for " .. className .. ":")
		for i, _ in pairs(classDB.allowedBuffs) do
			print("  " .. GetSpellInfo(i) .. " (" .. i .. ")")
		end
		print("NAM: Blocked buff auras for " .. className .. ":")
		for i, _ in pairs(classDB.blockedBuffs) do
			print("  " .. GetSpellInfo(i) .. " (" .. i .. ")")
		end
		print("NAM: Allowed debuff auras for " .. className .. ":")
		for i, _ in pairs(classDB.allowedDebuffs) do
			print("  " .. GetSpellInfo(i) .. " (" .. i .. ")")
		end
		print("NAM: Blocked deuff auras for " .. className .. ":")
		for i, _ in pairs(classDB.blockedDebuffs) do
			print("  " .. GetSpellInfo(i) .. " (" .. i .. ")")
		end
	elseif command == "clear" then
		classDB.allowedBuffs = {}
		classDB.blockedBuffs = {}
		classDB.allowedDebuffs = {}
		classDB.blockedDebuffs = {}
		print("NAM: Allow and block lists cleared for " .. className .. ".")
	elseif command == "reset" then
		defaults(classId)
		print("NAM: Allow and block lists reset for " .. className .. ".")
	elseif command == "help" or command == "?" or command == "" then
		print("NAM: Commands:")
		print("  `/nam allowbuff [spellId]` to toggle an allowed aura on player nameplate.")
		print("  `/nam blockbuff [spellid]` to toggle a blocked aura on player nameplate.")
		print("  `/nam allowdebuff [spellId]` to toggle an allowed debuff on enemy nameplate.")
		print("  `/nam blockdebuff [spellId]` to toggle a blocked debuff on enemy nameplate.")
		print("  `/nam list` display class allow and block lists.")
		print("  `/nam clear` clear class allow and block lists.")
		print("  `/nam reset` reset class allow and block lists to default.")
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
