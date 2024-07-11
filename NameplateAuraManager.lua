local function defaults(classId)
	local defaultConfigurations = {
		[1] = {      -- Warrior
			allowed = {
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
			blocked = {}
		},
		[2] = { -- Paladin
			allowed = {},
			blocked = {}
		},
		[3] = {      -- Hunter
			allowed = {
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
			blocked = {}
		},
		[4] = { -- Rogue
			allowed = {},
			blocked = {}
		},
		[5] = { -- Priest
			allowed = {},
			blocked = {}
		},
		[6] = { -- Death Knight
			allowed = {},
			blocked = {}
		},
		[7] = { -- Shaman
			allowed = {},
			blocked = {}
		},
		[8] = { -- Mage
			allowed = {},
			blocked = {}
		},
		[9] = { -- Warlock
			allowed = {},
			blocked = {}
		},
		[10] = { -- Monk
			allowed = {},
			blocked = {}
		},
		[11] = { -- Druid
			allowed = {},
			blocked = {}
		},
		[12] = { -- Demon Hunter
			allowed = {},
			blocked = {}
		},
		[13] = { -- Evoker
			allowed = {},
			blocked = {}
		}
	}

	if not NAMDB then NAMDB = defaultConfigurations end

	if classId and defaultConfigurations[classId] then
		NAMDB[classId] = defaultConfigurations[classId]
	end
end
if not NAMDB then defaults() end

local function newShouldShowBuff(_, aura, forceAll)
	if (not aura or not aura.name) then return false end
	local _, _, classId = UnitClass("player")
	local hasCustomizations = next(NAMDB[classId].allowed) ~= nil or next(NAMDB[classId].blocked) ~= nil
	return aura.nameplateShowAll or forceAll or
		((not hasCustomizations and aura.nameplateShowPersonal) or
			(NAMDB[classId].allowed[aura.spellId] and not NAMDB[classId].blocked[aura.spellId]) and
			(aura.sourceUnit == "player" or aura.sourceUnit == "pet" or aura.sourceUnit == "vehicle"))
end

local function Mixin(baseFrame)
	baseFrame.UnitFrame.BuffFrame.ShouldShowBuff = newShouldShowBuff
end

local function handleSpellCommand(spellIdString, targetList, command, className)
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
	local text = status .. " " .. className .. " " .. command .. " list."
	print("NAM: " .. spellName .. " (" .. tostring(spellId) .. ") " .. text)
end

SLASH_NAM1 = "/nam"
SlashCmdList["NAM"] = function(msg)
	local command, spellIdString = strsplit(" ", msg, 2)
	command = string.lower(command)
	local className, _, classId = UnitClass("player")
	if command == "allow" then
		handleSpellCommand(spellIdString, NAMDB[classId].allowed, "allow", className)
	elseif command == "block" then
		handleSpellCommand(spellIdString, NAMDB[classId].blocked, "block", className)
	elseif command == "list" then
		print("NAM: Allowed spells for " .. className .. "(" .. tostring(classId) .. "):")
		for i, _ in pairs(NAMDB[classId].allowed) do
			print("  " .. GetSpellInfo(i) .. " (" .. i .. ")")
		end
		print("NAM: Blocked spells for " .. className .. "(" .. tostring(classId) .. "):")
		for i, _ in pairs(NAMDB[classId].blocked) do
			print("  " .. GetSpellInfo(i) .. " (" .. i .. ")")
		end
	elseif command == "clear" then
		NAMDB[classId].allowed = {}
		NAMDB[classId].blocked = {}
		print("NAM: Allow and block lists cleared for " .. className .. ".")
	elseif command == "reset" then
		defaults(classId)
		print("NAM: Allow and block lists reset for " .. className .. ".")
	elseif command == "help" or command == "?" or command == "" then
		print("NAM: Commands:")
		print("  `/nam allow [spellId]` to toggle an allowed aura.")
		print("  `/nam block [spellid]` to toggle a blocked aura.")
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
