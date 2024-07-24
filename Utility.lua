function deepCopy(orig)
	local origType = type(orig)
	local copy
	if origType == 'table' then
		copy = {}
		for origKey, origValue in next, orig, nil do
			copy[deepCopy(origKey)] = deepCopy(origValue)
		end
		setmetatable(copy, deepCopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

function printTable(tbl, indent)
	if not indent then indent = 0 end
	local keys = {}
	for k in pairs(tbl) do table.insert(keys, k) end
	table.sort(keys)
	for _, k in ipairs(keys) do
		local v = tbl[k]
		local formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			printTable(v, indent + 1)
		else
			print(formatting .. tostring(v))
		end
	end
end
