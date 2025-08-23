export type Case = {
	[any]: (
		stop: () -> (),
		Roll: () -> (),
		Push: (Key: any) -> (),
		Pop: () -> (),
		Stack: (indexOrValue: any, value: any?) -> (),
		...any
	) -> ...any
}

return function(Aray: Case, PassedVariables: { any }, Key: any)
	assert(Aray, "Must include switch aray")

	Key = Aray[Key] and Key or (Aray["default"] and "default" or nil)
	if not Key then
		return nil
	end

	local keys = {}
	for k, _ in pairs(Aray) do
		table.insert(keys, k)
	end
	table.sort(keys, function(a, b)
		if a == "default" then return false end
		if b == "default" then return true end
		return tostring(a) < tostring(b)
	end)

	local keyToIndex = {}
	for i, k in ipairs(keys) do
		keyToIndex[k] = i
	end

	local currentIndex = keyToIndex[Key]
	local results = {}
	local stopped = false
	local skipNext = false
	local pushedIndex = nil

	local function Stop()
		stopped = true
	end

	local function Roll()
		skipNext = true
	end

	local function Push(key)
		if keyToIndex[key] then
			pushedIndex = keyToIndex[key]
		else
			error("Push called with invalid key: " .. tostring(key))
		end
	end

	local function Pop()
		results = {}
	end

	local function Stack(indexOrValue, value)
		if value == nil then
			table.insert(PassedVariables, indexOrValue)
		elseif type(indexOrValue) == "number" then
			PassedVariables[indexOrValue] = value
		else
			error("Invalid Stack usage. Pass either Stack(value) or Stack(index, value)")
		end
	end

	while currentIndex <= #keys do
		if skipNext then
			skipNext = false
			currentIndex = currentIndex + 1
			if currentIndex > #keys then break end
		end

		local caseKey = keys[currentIndex]
		local caseFn = Aray[caseKey]

		local ret = { caseFn(Stop, Roll, Push, Pop, Stack, unpack(PassedVariables)) }

		for _, v in ipairs(ret) do
			table.insert(results, v)
		end

		if stopped then
			break
		end

		if pushedIndex then
			currentIndex = pushedIndex
			pushedIndex = nil
		else
			currentIndex = currentIndex + 1
		end
	end

	return unpack(results)
end