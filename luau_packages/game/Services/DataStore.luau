local InitModule = {}

local loveDatastore = {}
loveDatastore.__index = loveDatastore
local Json = require("@game/Vendors/Json")
local lfs = love.filesystem

local DATASTORE_FOLDER = "datastores"

local function ensureFolder(path)
    if not lfs.getInfo(path, "directory") then
        lfs.createDirectory(path)
    end
end

local function buildPath(datastoreName, key)
    ensureFolder(DATASTORE_FOLDER)
    ensureFolder(DATASTORE_FOLDER.."/"..datastoreName)
    return DATASTORE_FOLDER.."/"..datastoreName.."/"..key..".json"
end

local function _GetAsync(datastoreName, key)
    local path = buildPath(datastoreName, key)
    if lfs.getInfo(path) then
        local contents, _ = lfs.read(path)
        return Json.decode(contents)
    else
        return nil
    end
end

local function _SetAsync(datastoreName, key, value)
    local path = buildPath(datastoreName, key)
    local success, err = lfs.write(path, Json.encode(value, true))
    return success, err
end

local function _UpdateAsync(datastoreName, key, updateFunc)
    local current = _GetAsync(datastoreName, key)
    local newValue = updateFunc(current)
    return _SetAsync(datastoreName, key, newValue)
end

local function _RemoveAsync(datastoreName, key)
    local path = buildPath(datastoreName, key)
    if lfs.getInfo(path) then
        return lfs.remove(path)
    else
        return false, "Key does not exist"
    end
end

local function _ListAsync(datastoreName)
    local folderPath = DATASTORE_FOLDER.."/"..datastoreName
    ensureFolder(folderPath)
    local files = lfs.getDirectoryItems(folderPath)
    local result = {}
    for _, file in ipairs(files) do
        local key = file:gsub("%.json$", "")
        result[key] = _GetAsync(datastoreName, key)
    end
    return result
end

function loveDatastore:GetDataStore(name)
    assert(type(name) == "string", "Datastore name must be a string")
    local ds = {}
    ds.name = name
    ds.GetAsync = function(_, key) return _GetAsync(name, key) end
    ds.SetAsync = function(_, key, value) return _SetAsync(name, key, value) end
    ds.UpdateAsync = function(_, key, func) return _UpdateAsync(name, key, func) end
    ds.RemoveAsync = function(_, key) return _RemoveAsync(name, key) end
    ds.ListAsync = function(_) return _ListAsync(name) end
    return setmetatable(ds, {__index = ds})
end

return {module = loveDatastore, Init = InitModule}
