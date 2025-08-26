local module = {}
local Inherited = require("@game/Instances/Inherited")
local Signal = require("@game/signal")

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

local PropertyTypes = {
        Name = "string";
        ClassName = "frozen",
        Changed = "frozen",
        ID = "frozen",
        attributes = "table",
        Destroyed = "frozen"
}

local PropertyTransform = {

}

local ReadTransform = {

}

function module.new(InstanceUpdate:Signal, GetID:() -> string, UserInput)
    local Changed = Signal.CreateSignal()

    local UID = GetID()

    local RawProperties = {
        Name = "Class",
        ClassName = "Class",
        Changed = Signal.CreateReadOnlySignal(Changed),
        ID = UID,
        attributes = {},
        Destroyed = false
    }

    local RawMethods = {}
    for k, v in pairs(Inherited) do
        RawMethods[k] = v
    end

    RawMethods.Draw = function(self)
        
    end

    RawMethods.Clone = function(self)
        local clone = module.new(InstanceUpdate, GetID, UserInput)

        for k, v in pairs(RawProperties) do
            if PropertyTypes[k] ~= "frozen" then
                clone[k] = v
            end
        end

        return clone
    end

    RawMethods.Destroy = function(self)
        InstanceUpdate:Fire(UID, "Destroy", self)
        Changed:Destroy()
        table.clear(RawProperties)
        table.clear(RawMethods)
        Changed = nil
        UID = nil
        RawProperties.Destroyed = true
    end

    local self = {}
    local mt = {}

    mt.__index = function(_, index)
        if RawProperties[index] then
            if ReadTransform[index] then
                return ReadTransform[index](self, RawProperties[index])
            else
                return RawProperties[index]
            end
        elseif RawMethods[index] then
            return RawMethods[index]
        end

        return
    end

    mt.__newindex = function(_, index, value)
        if RawProperties[index] then
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