local Toml = require("@game/Vendors/toml")

local InitModule = {}
local module = {}

local lfs = love.filesystem

local function SaveData(self)
    if self.Settings and self.Name then
        local allSettings = {}
        if lfs.getInfo("settings.toml") then
            local contents = lfs.read("settings.toml")
            allSettings = Toml.decode(contents or "") or {}
        end

        allSettings[self.Name] = self.Settings

        lfs.write("settings.toml", Toml.encode(allSettings))
    end
end

function module.new(name)
    assert(type(name) == "string", "A name must be provided for this settings instance")
    local self = setmetatable({}, { __index = module })
    self.Name = name

    if not lfs.getInfo("settings.toml") then
        lfs.write("settings.toml", "")
    end

    local contents = lfs.read("settings.toml")
    local allSettings = Toml.decode(contents or "") or {}

    self.Settings = allSettings[name] or {}

    return self
end

function module:Save()
    SaveData(self)
end

function module:Load()
    if not self.Name then return end
    local contents = lfs.read("settings.toml")
    local allSettings = Toml.decode(contents or "") or {}
    self.Settings = allSettings[self.Name] or {}
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
