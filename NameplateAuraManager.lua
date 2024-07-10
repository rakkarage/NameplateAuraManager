local function defaults(classId)
	local defaultConfigurations = {
		[1] = {      -- warrior
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
			blocked = {
				[355] = true, -- Taunt
			}
		},
		[3] = {      -- hunter
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
		}
	}

	if not NAMDB then NAMDB = defaultConfigurations end

	if classId and defaultConfigurations[classId] then
		NAMDB[classId] = defaultConfigurations[classId]
	end
end
if not NAMDB then defaults() end

local function ensureClassTableInitialized(classId)
	NAMDB[classId] = NAMDB[classId] or {}
end

local function newShouldShowBuff(_, aura, forceAll)
	if (not aura or not aura.name) then return false end
	local _, _, classId = UnitClass("player")
	return aura.nameplateShowAll or forceAll or
		((NAMDB[classId].allowed[aura.spellId] and not NAMDB[classId].blocked[aura.spellId]) and
			(aura.sourceUnit == "player" or aura.sourceUnit == "pet" or
				aura.sourceUnit == "vehicle"))
end

local function Mixin(baseFrame)
	baseFrame.UnitFrame.BuffFrame.ShouldShowBuff = newShouldShowBuff
end

SLASH_NAM1 = "/nam"
SlashCmdList["NAM"] = function(msg)
	local command, spellIdString = strsplit(" ", msg, 2)
	local spellId = tonumber(spellIdString)
	local spellName = GetSpellInfo(spellId)
	local className, _, classId = UnitClass("player")
	ensureClassTableInitialized(classId)
	if command == "allow" and spellName then
		NAMDB[classId].allowed[spellId] = not NAMDB[classId].allowed[spellId]
		local status = NAMDB[classId].allowed[spellId] and "added to" or "removed from"
		print("NAM: " .. spellName .. " (" .. tostring(spellId) .. ") " .. status .. " " .. className .. " allow list.")
	elseif command == "block" and spellName then
		NAMDB[classId].blocked[spellId] = not NAMDB[classId].blocked[spellId]
		local status = NAMDB[classId].blocked[spellId] and "added to" or "removed from"
		print("NAM: " .. spellName .. " (" .. tostring(spellId) .. ") " .. status .. " " .. className .. " block list.")
	elseif command == "list" then
		print("NAM: Allowed spells for " .. className .. "(" .. tostring(classId) .. "):")
		for i, _ in pairs(NAMDB[classId].allowed) do
			print("  " .. GetSpellInfo(i) .. " (" .. i .. ")")
		end
		print("NAM: Blocked spells for " .. className .. "(" .. tostring(classId) .. "):")
		for i, _ in pairs(NAMDB[classId].blocked) do
			print("  " .. GetSpellInfo(i) .. " (" .. i .. ")")
		end
	elseif command == "reset" then
		defaults(classId)
		print("NAM: Allow and block lists reset for " .. className .. ".")
	elseif command == "help" then
		print("NAM: Commands")
		print("'/nam allow [spellName]' to toggle an allowed aura.")
		print("'/nam block [spellName]' to toggle a blocked aura.")
		print("'/nam list' display class allow and block lists.")
		print("'/nam reset' reset class allow and block lists to default.")
	else
		print("NAM: Invalid command. Use /nam help")
	end
end

NAM = CreateFrame("Frame")
NAM:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NAM:RegisterEvent("ADDON_LOADED")
NAM:SetScript("OnEvent", function(_, event, arg1)
	if event == "NAME_PLATE_UNIT_ADDED" then
		Mixin(C_NamePlate.GetNamePlateForUnit(arg1))
	elseif event == "ADDON_LOADED" and arg1 == "NameplateAuraManager" then
		print("NameplateAuraManager: Loaded")
	end
end)

for _, baseFrame in pairs(C_NamePlate.GetNamePlates()) do Mixin(baseFrame) end
