local Json = {}

local function escapeString(str: string): string
	return '"' .. str
		:gsub('\\', '\\\\')
		:gsub('"', '\\"')
		:gsub('\n', '\\n')
		:gsub('\r', '\\r')
		:gsub('\t', '\\t')
		:gsub('\b', '\\b')
		:gsub('\f', '\\f')
	.. '"'
end

local function isArray(tbl: {any}): boolean
	local i = 0
	for k in pairs(tbl) do
		if type(k) ~= "number" then
			return false
		end
		if k > i then
			i = k
		end
	end
	for n = 1, i do
		if tbl[n] == nil then
			return false
		end
	end
	return true
end

local encodeValue

encodeValue = function(value: any, pretty: boolean, depth: number): string
	local t = type(value)
	if t == "string" then
		return escapeString(value)
	elseif t == "number" or t == "boolean" then
		return tostring(value)
	elseif t == "nil" then
		return "null"
	elseif t == "table" then
		local indent = pretty and string.rep("  ", depth) or ""
		local nextIndent = pretty and string.rep("  ", depth + 1) or ""
		if isArray(value) then
			local out = {}
			for i = 1, #value do
				table.insert(out, encodeValue(value[i], pretty, depth + 1))
			end
			if pretty then
				return "[\n" .. nextIndent .. table.concat(out, ",\n" .. nextIndent) .. "\n" .. indent .. "]"
			else
				return "[" .. table.concat(out, ",") .. "]"
			end
		else
			local out = {}
			for k, v in pairs(value) do
				if type(k) ~= "string" then
					error("JSON object keys must be strings")
				end
				local entry = escapeString(k) .. ":" .. (pretty and " " or "") .. encodeValue(v, pretty, depth + 1)
				table.insert(out, entry)
			end
			if pretty then
				return "{\n" .. nextIndent .. table.concat(out, ",\n" .. nextIndent) .. "\n" .. indent .. "}"
			else
				return "{" .. table.concat(out, ",") .. "}"
			end
		end
	else
		error("Unsupported JSON type: " .. t)
	end
end

local decodeValue

local function skipWhitespace(str, i)
	while true do
		local c = str:sub(i, i)
		if c == " " or c == "\n" or c == "\r" or c == "\t" then
			i += 1
		else
			break
		end
	end
	return i
end

local function parseString(str, i)
	i += 1
	local result = {}
	while i <= #str do
		local c = str:sub(i, i)
		if c == '"' then
			return table.concat(result), i + 1
		elseif c == "\\" then
			local nextChar = str:sub(i + 1, i + 1)
			if nextChar == '"' then table.insert(result, '"')
			elseif nextChar == "\\" then table.insert(result, "\\")
			elseif nextChar == "/" then table.insert(result, "/")
			elseif nextChar == "b" then table.insert(result, "\b")
			elseif nextChar == "f" then table.insert(result, "\f")
			elseif nextChar == "n" then table.insert(result, "\n")
			elseif nextChar == "r" then table.insert(result, "\r")
			elseif nextChar == "t" then table.insert(result, "\t")
			else
				error("Invalid escape sequence at " .. i)
			end
			i += 2
		else
			table.insert(result, c)
			i += 1
		end
	end
	error("Unterminated string at " .. i)
end

local function parseNumber(str, i)
	local numStr = str:match("^-?%d+%.?%d*[eE]?[+-]?%d*", i)
	if not numStr then
		error("Invalid number at " .. i)
	end
	return tonumber(numStr), i + #numStr
end

local function parseLiteral(str, i, literal, value)
	if str:sub(i, i + #literal - 1) == literal then
		return value, i + #literal
	end
	error("Invalid literal at " .. i)
end

local function parseArray(str, i)
	i += 1
	local result = {}
	i = skipWhitespace(str, i)
	if str:sub(i, i) == "]" then
		return result, i + 1
	end
	while true do
		local val
		val, i = decodeValue(str, i)
		table.insert(result, val)
		i = skipWhitespace(str, i)
		local c = str:sub(i, i)
		if c == "]" then
			return result, i + 1
		elseif c == "," then
			i += 1
		else
			error("Expected ',' or ']' at " .. i)
		end
		i = skipWhitespace(str, i)
	end
end

local function parseObject(str, i)
	i += 1
	local result = {}
	i = skipWhitespace(str, i)
	if str:sub(i, i) == "}" then
		return result, i + 1
	end
	while true do
		local key
		key, i = parseString(str, i)
		i = skipWhitespace(str, i)
		if str:sub(i, i) ~= ":" then
			error("Expected ':' at " .. i)
		end
		i = skipWhitespace(str, i + 1)
		local val
		val, i = decodeValue(str, i)
		result[key] = val
		i = skipWhitespace(str, i)
		local c = str:sub(i, i)
		if c == "}" then
			return result, i + 1
		elseif c == "," then
			i += 1
		else
			error("Expected ',' or '}' at " .. i)
		end
		i = skipWhitespace(str, i)
	end
end

decodeValue = function(str, i)
	i = skipWhitespace(str, i)
	local c = str:sub(i, i)
	if c == '"' then
		return parseString(str, i)
	elseif c == "{" then
		return parseObject(str, i)
	elseif c == "[" then
		return parseArray(str, i)
	elseif c == "t" then
		return parseLiteral(str, i, "true", true)
	elseif c == "f" then
		return parseLiteral(str, i, "false", false)
	elseif c == "n" then
		return parseLiteral(str, i, "null", nil)
	else
		return parseNumber(str, i)
	end
end

function Json.encode(value: any, pretty: boolean?): string
	return encodeValue(value, pretty or false, 0)
end

function Json.decode(str: string): any
	local result, i = decodeValue(str, 1)
	i = skipWhitespace(str, i)
	if i <= #str then
		error("Unexpected trailing characters at " .. i)
	end
	return result
end

return Json
