local Toml = require("@game/Vendors/toml")

local InitModule = {}
local module = {}

local lfs = love.filesystem

local function SaveData(self)
    if self.Settings then
        lfs.write("settings.toml", Toml.encode(self.Settings))
    end
end

function module.new()
    local self = setmetatable({}, { __index = module })

    if not lfs.getInfo("settings.toml") then
        lfs.write("settings.toml", "")
    end

    local contents = lfs.read("settings.toml")
    self.Settings = Toml.decode(contents or "") or {}

    return self
end

function module:Save()
    SaveData(self)
end

function module:Load()
    local contents = lfs.read("settings.toml")
    self.Settings = Toml.decode(contents or "") or {}
end

function module:Set(section, key, value)
    if not self.Settings[section] then
        self.Settings[section] = {}
    end
    self.Settings[section][key] = value
    self:Save()
end

function module:Get(section, key)
    local sec = self.Settings[section]
    if sec and sec[key] ~= nil then
        return sec[key]
    end
    return
end


return { module = module, Init = InitModule }
