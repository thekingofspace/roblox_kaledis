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

function loveDatastore:GetDataStore(name)
    assert(type(name) == "string", "Datastore name must be a string")

    local ds = {}
    ds.name = name

    local function buildPath(key)
        ensureFolder(DATASTORE_FOLDER)
        ensureFolder(DATASTORE_FOLDER.."/"..name)
        return DATASTORE_FOLDER.."/"..name.."/"..key..".json"
    end

    function ds:GetAsync(key)
        local path = buildPath(key)
        if lfs.getInfo(path) then
            local contents, _ = lfs.read(path)
            return Json.decode(contents)
        else
            return nil
        end
    end

    function ds:SetAsync(key, value)
        local path = buildPath(key)
        local success, err = lfs.write(path, Json.encode(value, true))
        return success, err
    end

    function ds:UpdateAsync(key, updateFunc)
        local current = self:GetAsync(key)
        local newValue = updateFunc(current)
        return self:SetAsync(key, newValue)
    end

    function ds:RemoveAsync(key)
        local path = buildPath(key)
        if lfs.getInfo(path) then
            return lfs.remove(path)
        else
            return false, "Key does not exist"
        end
    end

    function ds:ListAsync()
        local folderPath = DATASTORE_FOLDER.."/"..name
        ensureFolder(folderPath)
        local files = lfs.getDirectoryItems(folderPath)
        local result = {}
        for _, file in ipairs(files) do
            local key = file:gsub("%.json$", "")
            result[key] = self:GetAsync(key)
        end
        return result
    end

    return setmetatable(ds, {__index = ds})
end

return {module = loveDatastore, Init = InitModule}
