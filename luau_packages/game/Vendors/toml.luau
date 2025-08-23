local Toml = {}

local function escapeString(str: string): string
    if str:find("\n") then
        return '"""' .. str .. '"""'
    else
        return '"' .. str:gsub('"', '\\"') .. '"'
    end
end

local function isArray(tbl: {any}): boolean
    local i = 0
    for k in pairs(tbl) do
        if type(k) ~= "number" then return false end
        if k > i then i = k end
    end
    for n = 1, i do
        if tbl[n] == nil then return false end
    end
    return true
end

local function encodeValue(value: any)
    local t = type(value)
    if t == "string" then
        return escapeString(value)
    elseif t == "number" or t == "boolean" then
        return tostring(value)
    elseif t == "table" then
        if isArray(value) then
            local out = {}
            for _, v in ipairs(value) do
                table.insert(out, encodeValue(v))
            end
            return "[" .. table.concat(out, ", ") .. "]"
        else
            error("Nested tables should be handled separately in TOML sections")
        end
    else
        error("Unsupported TOML value type: " .. t)
    end
end

local function encodeTable(tbl: {any}, prefix: string?)
    local out = {}
    local subtables = {}
    local arrayTables = {}

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            if isArray(v) then
                if type(v[1]) == "table" then
                    arrayTables[k] = v
                else
                    out[#out + 1] = k .. " = " .. encodeValue(v)
                end
            else
                subtables[k] = v
            end
        else
            out[#out + 1] = k .. " = " .. encodeValue(v)
        end
    end

    local result = {}
    if prefix then
        if #out > 0 then
            table.insert(result, "[" .. prefix .. "]")
            table.insert(result, table.concat(out, "\n"))
        end
    else
        if #out > 0 then
            table.insert(result, table.concat(out, "\n"))
        end
    end

    for k, v in pairs(subtables) do
        local subPrefix = prefix and (prefix .. "." .. k) or k
        table.insert(result, encodeTable(v, subPrefix))
    end

    for k, arr in pairs(arrayTables) do
        for _, item in ipairs(arr) do
            local fullPrefix = prefix and (prefix .. "." .. k) or k
            table.insert(result, "[[" .. fullPrefix .. "]]")
            table.insert(result, encodeTable(item))
        end
    end

    return table.concat(result, "\n\n")
end

function Toml.encode(tbl: any):string
    return encodeTable(tbl)
end

local function parseValue(val)
    val = val:match("^%s*(.-)%s*$")
    if val:match('^"""') then
        return val:sub(4, -4)
    elseif val:match('^".*"$') then
        return val:sub(2, -2)
    elseif val == "true" then
        return true
    elseif val == "false" then
        return false
    elseif tonumber(val) then
        return tonumber(val)
    elseif val:match("^%[.*%]$") then
        local arr = {}
        for item in val:sub(2, -2):gmatch("([^,]+)") do
            table.insert(arr, parseValue(item))
        end
        return arr
    else
        return val
    end
end

function Toml.decode(str: string)
    local result = {}
    local current = result
    local arrayTableStack = {}
    for line in str:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and not line:match("^#") then
            local arrayTableName = line:match("^%[%[(.-)%]%]$")
            local tableName = line:match("^%[(.-)%]$")

            if arrayTableName then
                local parts = {}
                for part in arrayTableName:gmatch("[^%.]+") do
                    table.insert(parts, part)
                end
                local parent = result
                for i = 1, #parts - 1 do
                    parent[parts[i]] = parent[parts[i]] or {}
                    parent = parent[parts[i]]
                end
                parent[parts[#parts]] = parent[parts[#parts]] or {}
                table.insert(arrayTableStack, parent[parts[#parts]])
                current = {}
                table.insert(parent[parts[#parts]], current)
            elseif tableName then
                local parts = {}
                for part in tableName:gmatch("[^%.]+") do
                    table.insert(parts, part)
                end
                current = result
                for _, p in ipairs(parts) do
                    current[p] = current[p] or {}
                    current = current[p]
                end
            else
                local key, val = line:match("^(.-)%s*=%s*(.+)$")
                if key and val then
                    current[key] = parseValue(val)
                end
            end
        end
    end
    return result
end

return Toml
