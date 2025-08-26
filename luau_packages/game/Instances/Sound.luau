--!nocheck
local module = {}
local Inherited = require("@game/Instances/Inherited")
local Signal = require("@game/signal")
local task = require("@game/BuiltIn/Task").module

local function CheckType(ID: string, Value, Properties)
    if Properties[ID] == "frozen" then
        return false
    end
    if typeof(Properties[ID]) == "string" then
        return typeof(Value) == Properties[ID]
    else
        for I, item in ipairs(Properties[ID]) do
            if typeof(Value) == item then
                return true
            end
        end

        return false
    end
end

local RealProperties = {
    Name = "string";
    ClassName = "frozen",
    Changed = "frozen",
    ID = "frozen",
    attributes = "table",
    Destroyed = "frozen",
    Sound = "string",
    Source = "frozen",
    SoundData = "frozen",
    TrackerThread = "frozen",
    Looped = "boolean",
    IsPlaying = "boolean",
    Volume = "number",
    TimePosition = "frozen",
    Length = "frozen",
    Thread = "frozen"
}

function module.new(InstanceUpdate:Signal, GetID:() -> string, SuperConstruct:(() -> ({Property}, {Method}, {Method}))?)
    local Changed = Signal.CreateSignal()
    local Stopped = Signal.CreateSignal()
    local self = {}
    local PropertyTypes = RealProperties
    local UID = GetID()

    local RawProperties = {
        Name = "Sound",
        ClassName = "Sound",
        Changed = Signal.CreateReadOnlySignal(Changed),
        Stopped = Signal.CreateReadOnlySignal(Stopped),
        ID = UID,
        attributes = {},
        Destroyed = false,

        ---- PRIVATE
        Source = "null",
        SoundData = "null",
        TimePosition = 0,
        Length = 0,

        ---- PUBLIC
        Sound = "",
        Looped = false,
        IsPlaying = false,
        Volume = 0.5,

        Thread = nil
    }

    local PropertyTransform = {
        Sound  = function(self, Value)
            if RawProperties.Source == "null" then
                RawProperties.SoundData = love.sound.newSoundData("assets/" .. Value)

                RawProperties.Source = love.audio.newSource(RawProperties.SoundData)
                RawProperties.Source:setVolume(0.5)

                RawProperties.Length = RawProperties.SoundData:getDuration()
            else
                RawProperties.Source:stop()
                RawProperties.SoundData:release()
                RawProperties.Source:release()

                RawProperties.SoundData = love.sound.newSoundData("assets/" .. Value)

                RawProperties.Source = love.audio.newSource(RawProperties.SoundData)

                RawProperties.Length = RawProperties.SoundData:getDuration()
            end

            return Value
        end,

        Looped = function(self, Value)
            if RawProperties.Source ~= "null" then
                RawProperties.Source:setLooping(Value)
            else
                return false
            end

            return Value
        end,

        Volume = function(self, Value)
            if RawProperties.Source ~= "null" then
                RawProperties.Source:setVolume(Value)
            else
                return 0.5
            end

            return Value
        end
    }

    local ReadTransform = {

    }

    local ExtendMethod = {

    }
    

    local RawMethods = {}
    for k, v in pairs(Inherited) do
        RawMethods[k] = v
    end

    RawMethods.Draw = function(self)
        if ExtendMethod["Draw"] then
            ExtendMethod["Draw"](self)
        end
    end

    RawMethods.Clone = function(self)
        if ExtendMethod["Clone"] then
            ExtendMethod["Clone"](self)
        end

        local clone = module.new(InstanceUpdate, GetID)

        for k, v in pairs(RawProperties) do
            if PropertyTypes[k] ~= "frozen" then
                clone[k] = v
            end
        end

        return clone
    end

    RawMethods.Play = function(self)
        if RawProperties.Sound ~= "" then

            if RawProperties.Source:isPlaying() == true then
                RawMethods.Stop(self)
            end

            RawProperties.Thread = task.spawn(function()
                RawProperties.Source:play()
                RawProperties.IsPlaying = true

                while true do
                    task.wait(1)
                    RawProperties.TimePosition = RawProperties.Source:tell()

                    if RawProperties.Source:isPlaying() == false then
                        break
                    end
                end
                
                RawProperties.TimePosition = 0
                RawProperties.IsPlaying = false
                Stopped:Fire()
            end)
        end
    end

    RawMethods.Stop = function(self)
        if RawProperties.Sound ~= "" and RawProperties.Thread ~= nil then
            task.cancel(RawProperties.Thread)
            RawProperties.IsPlaying = false
            RawProperties.TimePosition = 0
            RawProperties.Source:stop()
            Stopped:Fire()
        end
    end


    RawMethods.Destroy = function(self)
        if ExtendMethod["Destroy"] then
            ExtendMethod["Destroy"](self)
        end

        InstanceUpdate:Fire(UID, "Destroy", self)
        Changed:Destroy()
        Stopped:Destroy()
        table.clear(RawProperties)
        table.clear(RawMethods)
        table.clear(PropertyTypes)
        table.clear(ReadTransform)
        table.clear(PropertyTransform)
        table.clear(ExtendMethod)

        Changed = nil
        Stopped = nil
        UID = nil
        RawProperties.Destroyed = true
        PropertyTypes.Destroyed = "boolean"
    end

    if SuperConstruct then
        local Properties, Methods, Extended = SuperConstruct()

        for I, item in ipairs(Properties) do
            RawProperties[item.Property] = item.Value
            PropertyTypes[item.Property] = item.Type

            if item.ReadTransform then
                ReadTransform[item.Property] = item.ReadTransform
            end

            if item.WriteTransform then
                PropertyTransform[item.Property] = item.WriteTransform
            end
        end

        for I, item in ipairs(Methods) do
            RawMethods[item.Method] = function()
                if ExtendMethod[item.Method] then
                    ExtendMethod[item.Method](self)
                end

                item.Code(self)
            end
        end

        for I, item in ipairs(Extended) do
            ExtendMethod[item.Method] = item.Code
        end
    end

    local mt = {}

    mt.__index = function(_, index)
            if RawProperties[index] ~= nil then
                if ReadTransform[index] then
                    return ReadTransform[index](self, RawProperties[index])
                else
                    return RawProperties[index]
                end
            elseif RawMethods[index] then
                return RawMethods[index]
            end

            return nil
    end

    mt.__newindex = function(_, index, value)
        if RawProperties[index] ~= nil then
            if CheckType(index, value, PropertyTypes) then
                if PropertyTransform[index] then
                    RawProperties[index] = PropertyTransform[index](self, value)
                else
                    RawProperties[index] = value
                end
                Changed:Fire()
            else
                if PropertyTypes[index] == "frozen" then
                    error(index .. " cannot be changed")
                else
                    error(string.format(
                        "%s must be a %s",
                        index,
                        type(PropertyTypes[index]) == "table" and table.concat(PropertyTypes[index], " ") or type(RawProperties[index])
                    ))
                end
            end
        else
            error(index .. " is not a property of " .. RawProperties.ClassName)
        end
    end

    mt.__eq = function(a, b)
        if typeof(b) == "table" and b.ClassName ~= nil then
            return a.ID == b.ID
        else
            return false
        end
    end

    setmetatable(self, mt)
    InstanceUpdate:Fire(UID, "Create", self)

    return self
end

return module