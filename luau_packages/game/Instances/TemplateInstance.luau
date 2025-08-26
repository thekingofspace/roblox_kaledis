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

local RealProperties = {
        Name = "string";
        ClassName = "frozen",
        Changed = "frozen",
        ID = "frozen",
        attributes = "table",
        Destroyed = "frozen"
}

export type Property = {
    Property: string,
    Type: string | {string},
    Value: any,
    WriteTransform: ((self: any, OldValue: any) -> ...any)?,
    ReadTransform: ((self: any, OldValue: any) -> any)?,
}

export type Method = {
    Method: string,
    Code: (self: any, ...any) -> ...any,
}

function module.new(InstanceUpdate:Signal, GetID:() -> string, UserInput, SuperConstruct:(() -> ({Property}, {Method}, {Method}))?)
    local Changed = Signal.CreateSignal()
    local self = {}
    local PropertyTypes = RealProperties
    local UID = GetID()

    local PropertyTransform = {

    }

    local ReadTransform = {

    }

    local ExtendMethod = {

    }

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
        if ExtendMethod["Draw"] then
            ExtendMethod["Draw"](self)
        end
    end

    RawMethods.Clone = function(self)
        if ExtendMethod["Clone"] then
            ExtendMethod["Clone"](self)
        end

        local clone = module.new(InstanceUpdate, GetID, UserInput)

        for k, v in pairs(RawProperties) do
            if PropertyTypes[k] ~= "frozen" then
                clone[k] = v
            end
        end

        return clone
    end

    RawMethods.Destroy = function(self)
        if ExtendMethod["Destroy"] then
            ExtendMethod["Destroy"](self)
        end

        InstanceUpdate:Fire(UID, "Destroy", self)
        Changed:Destroy()
        table.clear(RawProperties)
        table.clear(RawMethods)
        table.clear(PropertyTypes)
        table.clear(ReadTransform)
        table.clear(PropertyTransform)
        table.clear(ExtendMethod)

        Changed = nil
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